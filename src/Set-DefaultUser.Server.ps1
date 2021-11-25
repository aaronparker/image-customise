#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings by mounting the default profile registry hive and adding settings.
    Imports a default Start menu layout.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    https://stealthpuppy.com
#>
[CmdletBinding()]
param (
    [Parameter()]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

# Run Remove-AppxApps.ps1 in block list mode
Write-Verbose -Message "Execution path: $Path."

# Load Registry Hives
$RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
If (Test-Path -Path $RegDefaultUser) {
    try {
        Write-Verbose -Message "Loading $RegDefaultUser"
        $params = @{
            FilePath     = "$Env:SystemRoot\System32\reg.exe"
            ArgumentList = "load HKLM\MountDefaultUser $RegDefaultUser"
            Wait         = $True
            NoNewWindow  = $True
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params
    }
    catch {
        Throw "Failed to run $Command"
    }
}

$RegCommands =
'add "HKCU\Software\Microsoft\ServerManager" /v "DoNotOpenServerManagerAtLogon" /d 1 /t REG_DWORD /f',
'add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableBlurBehind" /d 0 /t REG_DWORD /f'

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
                NoNewWindow  = $True
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
                NoNewWindow  = $True
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
    Throw "Failed to run: reg unload"
}

# Configure the default Start menu
$MinBuild = "14393"
$CurrentBuild = ([System.Environment]::OSVersion.Version).Build
If ($CurrentBuild -ge $MinBuild) {
    try {
        $params = @{
            Path        = "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell"
            ItemType    = "Directory"
            ErrorAction = "SilentlyContinue"
        }
        New-Item @params > $Null
        If ((Get-WindowsFeature -Name "RDS-RD-Server").InstallState -eq "Installed") {
            $Layout = Get-ChildItem -Path $Path -Filter "WindowsRDSStartMenuLayout.xml" -Recurse
        }
        Else {
            $Layout = Get-ChildItem -Path $Path -Filter "WindowsServerStartMenuLayout.xml" -Recurse
        }
        Write-Verbose -Message "Importing Start layout file: $Layout."
        Import-StartLayout -LayoutPath $Layout -MountPath "$($env:SystemDrive)\"
    }
    catch {
        Throw "Failed to import Start menu layout: [$Layout]."
    }
}


# Configure Microsoft Teams defaults
If ((Get-WindowsFeature -Name "RDS-RD-Server").InstallState -eq "Installed") {
    try {
        $params = @{
            Path        = "$env:SystemDrive\Users\Default\AppData\Roaming\Microsoft\Teams"
            ItemType    = "Directory"
            ErrorAction = "SilentlyContinue"
        }
        New-Item @params > $Null
        $Config = Get-ChildItem -Path $Path -Filter "desktop-config.json" -Recurse
        Write-Verbose -Message "Copy Teams config file file: $($Config.FullName)."
        $params = @{
            Path        = $Config.FullName
            Destination = "$env:SystemDrive\Users\Default\AppData\Roaming\Microsoft\Teams"
            ErrorAction = "SilentlyContinue"
        }
        Copy-Item @params
    }
    catch {
        Throw "Failed to copy Microsoft Teams default config: $($Config.FullName)."
    }
}
