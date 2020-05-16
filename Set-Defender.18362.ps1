#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set Microsoft Defender settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /d 5 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    Write-Verbose "reg $Command"
    Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
}
