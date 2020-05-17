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

$RegCommands =
'add "HKCU\Software\Microsoft\ServerManager" /v "DoNotOpenServerManagerAtLogon" /d 1 /t REG_DWORD /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    If ($Command -like "*HKCU*") {
        $Command = $Command -replace "HKCU", "HKLM\MountDefaultUser"
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

# Configure the default Start menu
$MinBuild = "14393"
$CurrentBuild = ([System.Environment]::OSVersion.Version).Build
If (!(Test-Path("$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows"))) { New-Item -Value "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows" -ItemType Directory }
If ($CurrentBuild -ge $MinBuild) {
    Import-StartLayout -LayoutPath ".\WindowsServerStartMenuLayout.xml" -MountPath "$($env:SystemDrive)\"
}
