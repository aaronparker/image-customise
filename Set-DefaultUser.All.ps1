#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Load Registry Hives
$RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
If (Test-Path -Path $RegDefaultUser) {
    Write-Verbose "Loading $RegDefaultUser"
    Start-Process reg -ArgumentList "load HKLM\MountDefaultUser $RegDefaultUser" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# Registry Commands
$RegCommands =
'add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Network\Persistent Connections" /v "SaveConnections" /d "No" /t REG_SZ /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /d 1 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableBlurBehind" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorPrevalence" /d 1 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v "AccentColor" /d 4289815296 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorizationAfterglow" /d 3288359857 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorizationColor" /d 3288359857 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentColor" /d 4289992518 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v "AccentPalette" /d 86CAFF005FB2F2001E91EA000063B10000427500002D4F000020380000CC6A00 /t REG_SZ /f',
'add "HKCU\Software\Microsoft\TabletTip\1.7" /v "TipbandDesiredVisibility" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceButtonDesiredVisibility" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /d 1 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MMTaskbarGlomLevel" /d 1 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "01" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "2048" /d 0 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "04" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "08" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "256" /d 14 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "32" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "512" /d 14 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "StoragePoliciesNotified" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /d 1 /t REG_DWORD /f',
'add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /d 0 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    If ($Command -like "*HKCU*") {
        $Command = $Command -replace "HKCU","HKLM\MountDefaultUser"
        try {
            Write-Verbose "reg $Command"
            Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
        }
        catch {
            Throw "Failed to run $Command"
        }
    }
    Else {
        try {
            Write-Verbose "reg $Command"
            Start-Process reg -ArgumentList $Command -Wait -WindowStyle Hidden -ErrorAction "SilentlyContinue"
        }
        catch {
            Throw "Failed to run $Command"
        }
    }
}

# Unload Registry Hives
Start-Process reg -ArgumentList "unload HKLM\MountDefaultUser" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
