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
    Set-Service Audiosrv -StartupType Automatic
    Set-Service WSearch -StartupType Automatic
}
