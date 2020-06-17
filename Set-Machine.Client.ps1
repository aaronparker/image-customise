#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Registry Commands; Process Registry Commands
$RegCommands =
'add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f',
'add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f'
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose $Command
        Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed to run: [$Command]."
    }
}

# Configure Windows features
$features = "Printing-XPSServices-Features", "SMB1Protocol", "WorkFolders-Client", "FaxServicesClientPackage", "WindowsMediaPlayer"
$features | ForEach-Object { Get-WindowsOptionalFeature -Online -FeatureName $_ } | `
    ForEach-Object { 
    try {
        Disable-WindowsOptionalFeature -FeatureName $_.FeatureName -Online -NoRestart -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed removing feature: [$($_.FeatureName)]."
    }
}

# Remove Windows capabilities
$Capabilities = $("App.Support.QuickAssist~~~~0.0.1.0", "MathRecognizer~~~~0.0.1.0", "Media.WindowsMediaPlayer~~~~0.0.12.0", "XPS.Viewer~~~~0.0.1.0")
ForEach ($Capability in $Capabilities) {
    try {    
        Remove-WindowsCapability -Online -Name $Capability -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed removing capability: [$Capability]."
    }
}


# Remove packages
Get-WindowsPackage -Online -PackageName "Microsoft-Windows-MediaPlayer-Package*" | `
    ForEach-Object {
    try {
        Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed removing package: [$($_.PackageName)]."
    }
}
