#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    https://stealthpuppy.com
#>
[CmdletBinding()]
param (
    [Parameter()]
    [System.Path] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

# Run Remove-AppxApps.ps1 in block list mode
Write-Verbose -Message "Execution path: $Path."

# Registry Commands
$RegCommands =
'add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose $Command
        $params = @{
            FilePath     = "$Env:SystemRoot\System32\reg.exe"
            ArgumentList = $Command
            Wait         = $True
            NoNewWindow  = $True           
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params
    }
    catch {
        Throw "Failed to run: [$Command]."
    }
}

# Configure services
If ((Get-WindowsFeature -Name "RDS-RD-Server").InstallState -eq "Installed") {
    ForEach ($service in "Audiosrv", "WSearch") {
        try {
            $params = @{
                Name        = $service
                StartupType = "Automatic"
                ErrorAction = "SilentlyContinue"
            }
            Set-Service @params
        }
        catch {
            Throw "Failed to set service properties [$service]."
        }
    }
}
