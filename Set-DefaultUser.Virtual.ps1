#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings by mounting the default profile registry hive and adding settings.
    Adds settings for optimising a profile for virtual desktops.

    .NOTES
    AUTHOR: Aaron Parker

    .LINK
    http://stealthpuppy.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

# Load Registry Hives
$RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
If (Test-Path -Path $RegDefaultUser) {
    Write-Verbose -Message "Loading $RegDefaultUser"
    $params = @{
        FilePath     = "$Env:SystemRoot\System32\reg.exe"
        ArgumentList = "load HKLM\MountDefaultUser $RegDefaultUser"
        Wait         = $True
        WindowStyle  = "Hidden"
        ErrorAction  = "SilentlyContinue"
    }
    Start-Process @params
}

# Registry Commands
$RegCommands =
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableBlurBehind" /d 0 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v ShellState /t REG_BINARY /d 240000003C2800000000000000000000 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v IconsOnly /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCompColor /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowInfoTip /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 3 /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\DWM" /v AlwaysHiberNateThumbnails /t REG_DWORD /d 0 /f',
'add "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d 0 /f',
'add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9032078010000000 /f',
'add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f',
'add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" /v Disabled /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe" /v DisabledByUser /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" /v Disabled /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SkypeApp_kzf8qxf38zg5c" /v DisabledByUser /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" /v Disabled /t REG_DWORD /d 1 /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe" /v DisabledByUser /t REG_DWORD /d 1 /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    If ($Command -like "*HKCU*") {
        $Command = $Command -replace "HKCU", "HKLM\MountDefaultUser"
        try {
            Write-Verbose -Message "reg $Command"
            $params = @{
                FilePath     = "$Env:SystemRoot\System32\reg.exe"
                ArgumentList = $Command
                Wait         = $True
                WindowStyle  = "Hidden"
                ErrorAction  = "SilentlyContinue"
            }
            Start-Process @params
        }
        catch {
            Write-Error -Message "Failed to run $Command"
        }
    }
    Else {
        try {
            Write-Verbose -Message "reg $Command"
            $params = @{
                FilePath     = "$Env:SystemRoot\System32\reg.exe"
                ArgumentList = $Command
                Wait         = $True
                WindowStyle  = "Hidden"
                ErrorAction  = "SilentlyContinue"
            }
            Start-Process @params
        }
        catch {
            Write-Error -Message "Failed to run $Command"
        }
    }
}

# Unload Registry Hives
try {
    Write-Verbose -Message "reg unload"
    $params = @{
        FilePath     = "$Env:SystemRoot\System32\reg.exe"
        ArgumentList = "unload HKLM\MountDefaultUser"
        Wait         = $True
        WindowStyle  = "Hidden"
        ErrorAction  = "SilentlyContinue"
    }
    Start-Process @params
}
catch {
    Throw "Failed to run: [reg unload]."
}
