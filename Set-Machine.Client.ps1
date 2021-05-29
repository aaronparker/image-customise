#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

# Registry Commands
$RegCommands =
'add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f',
'add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose $Command
        $params = @{
            FilePath     = "$Env:SystemRoot\System32\reg.exe"
            ArgumentList = $Command
            Wait         = $True
            NoNewWindow  = $True
            WindowStyle  = "Hidden"
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params
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
        $params = @{
            FeatureName = $_.FeatureName
            Online      = $True
            NoRestart   = $True
            ErrorAction = "SilentlyContinue"
        }
        Disable-WindowsOptionalFeature @params
    }
    catch {
        Throw "Failed removing feature: [$($_.FeatureName)]."
    }
}

# Remove Windows capabilities
$Capabilities = $("App.Support.QuickAssist~~~~0.0.1.0", "MathRecognizer~~~~0.0.1.0", "Media.WindowsMediaPlayer~~~~0.0.12.0", "XPS.Viewer~~~~0.0.1.0")
ForEach ($Capability in $Capabilities) {
    try {    
        $params = @{
            Name        = $Capability
            Online      = $True
            ErrorAction = "SilentlyContinue"
        }
        Remove-WindowsCapability @params
    }
    catch {
        Throw "Failed removing capability: [$Capability]."
    }
}


# Remove packages
Get-WindowsPackage -Online -PackageName "Microsoft-Windows-MediaPlayer-Package*" | `
    ForEach-Object {
    try {
        $params = @{
            PackageName = $_.PackageName
            Online      = $True
            ErrorAction = "SilentlyContinue"
        }
        Remove-WindowsPackage @params
    }
    catch {
        Throw "Failed removing package: [$($_.PackageName)]."
    }
}
