#   Windows 10 Set-Customisations.ps1

# Registry Commands
$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg" /d "Tahoma" /t REG_SZ /f',
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg 2" /d "Tahoma" /t REG_SZ /f'
'add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /d 2 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    Write-Host "reg $Command"
    Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
}

# Remove sample files if they exist
$Paths = "$env:PUBLIC\Music\Sample Music", "$env:PUBLIC\Pictures\Sample Pictures", `
    "$env:PUBLIC\Videos\Sample Videos", "$env:PUBLIC\Recorded TV\Sample Media"
ForEach ($Path in $Paths) {
    If (Test-Path $Path) { Remove-Item $Path -Recurse -Force }
}

# Remove the C:\Logs folder
$Path = "$env:SystemDrive\Logs"
If (Test-Path $Path) { Remove-Item $Path -Recurse -Force }
 