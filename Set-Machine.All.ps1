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
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg" /d "Tahoma" /t REG_SZ /f',
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg 2" /d "Tahoma" /t REG_SZ /f',
'add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /d 2 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose "reg $Command"
        Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed to run: [$Command]."
    }   
}

# Remove specified paths
$Paths = 
"$env:PUBLIC\Music\Sample Music",
"$env:PUBLIC\Pictures\Sample Pictures",
"$env:PUBLIC\Videos\Sample Videos",
"$env:PUBLIC\Recorded TV\Sample Media",
"$env:SystemDrive\Logs"
ForEach ($Path in $Paths) {
    If (Test-Path -Path $Path) { Remove-Item $Path -Recurse -Force }
}
 