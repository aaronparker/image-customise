#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set Microsoft Defender settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

If (Get-Module -Name ConfigDefender -ListAvailable -ErrorAction SilentlyContinue) {
    Set-MpPreference -PUAProtection Enabled
}
