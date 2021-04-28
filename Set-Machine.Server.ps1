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
    [Parameter()]    
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

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
