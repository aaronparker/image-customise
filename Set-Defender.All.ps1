#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set Microsoft Defender settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

Set-MpPreference -PUAProtection Enabled
