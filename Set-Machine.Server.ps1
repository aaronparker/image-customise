#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Configure services
If ((Get-WindowsFeature -Name "RDS-RD-Server").InstallState -eq "Installed") {
    ForEach ($service in "Audiosrv", "WSearch") {
        try {
            Set-Service $service -StartupType "Automatic"
        }
        catch {
            Throw "Failed to set service properties [$service]."
        }
    }
}
