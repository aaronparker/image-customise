#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Registry Commands
$RegCommands =
'add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    Write-Verbose "reg $Command"
    Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
}

# Configure Windows features
try {
    $features = "Printing-XPSServices-Features", "SMB1Protocol", "WorkFolders-Client", "FaxServicesClientPackage", "WindowsMediaPlayer"
    $features | ForEach-Object { Get-WindowsOptionalFeature -Online -FeatureName $_ } | `
        ForEach-Object { Disable-WindowsOptionalFeature -FeatureName $_.FeatureName -Online -NoRestart -ErrorAction "SilentlyContinue" }
}
catch { }

try {
    $Capabilities = $("App.Support.QuickAssist~~~~0.0.1.0", "MathRecognizer~~~~0.0.1.0", "Media.WindowsMediaPlayer~~~~0.0.12.0", "XPS.Viewer~~~~0.0.1.0")
    ForEach ($Capability in $Capabilities) { Remove-WindowsCapability -Online -Name $Capability -ErrorAction "SilentlyContinue" }
}
catch { }

try {
    Get-WindowsPackage -Online -PackageName "Microsoft-Windows-MediaPlayer-Package*" | `
        ForEach-Object { Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction "SilentlyContinue" }
}
catch { }
