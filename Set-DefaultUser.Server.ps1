#   Windows Server 2016/2019

# Load Registry Hives
$RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
If (Test-Path -Path $RegDefaultUser) {
    Write-Host "Loading $RegDefaultUser" -ForegroundColor DarkGray
    Start-Process reg -ArgumentList "load HKLM\MountDefaultUser $RegDefaultUser" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
}

$RegCommands =
'add "HKCU\Software\Microsoft\ServerManager" /v "DoNotOpenServerManagerAtLogon" /d 1 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    If ($Command -like "*HKCU*") {
        $Command = $Command -replace "HKCU","HKLM\MountDefaultUser"
        Write-Host "reg $Command"
        Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    }
    Else {
        Write-Host "reg $Command"
        Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    }
}

# Configure the default Start menu
If (!(Test-Path("$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows"))) { New-Item -Value "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows" -ItemType Directory }
Import-StartLayout -LayoutPath .\WindowsServerStartMenuLayout.xml -MountPath "$($env:SystemDrive)\"
