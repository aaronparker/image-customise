# Registry Commands
$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /d 5 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    Write-Host "reg $Command"
    Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
}
