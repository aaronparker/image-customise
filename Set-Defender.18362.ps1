#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set Microsoft Defender settings specific to Windows 10 1903 and above
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Process Registry Commands
$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /d 5 /t REG_DWORD /f'
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose "reg $Command"
        Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to run: [$Command]."
    }
}
