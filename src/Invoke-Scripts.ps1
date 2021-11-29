#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
    .SYNOPSIS
    Configuration changes to a default install of Windows during provisioning.
  
    .NOTES
    NAME: Invoke-Scripts.ps1
    AUTHOR: Aaron Parker
    TWITTER: @stealthpuppy
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $PSScriptRoot,

    [Parameter(Mandatory = $False)]
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944",

    [Parameter(Mandatory = $False)]
    [System.String] $Publisher = "stealthpuppy",
    
    [Parameter(Mandatory = $False)]
    [System.String] $RunOn = $(Get-Date -Format "yyyy-MM-dd"),

    [Parameter(Mandatory = $False)]
    [System.String] $Project = "Customised Defaults",

    [Parameter(Mandatory = $False)]
    [System.String] $Helplink = "https://stealthpuppy.com/image-customise/",

    [Parameter(Mandatory = $False)]
    [System.String[]] $Properties = @("Registry", "Paths", "StartMenu", "Features", "Capabilities", "Packages", "Apps")
)

#region Functions
Function New-ScriptEventLog ($EventLog, $Property) {
    $params = @{
        LogName     = $EventLog
        Source      = $Property
        ErrorAction = "SilentlyContinue"
    }
    New-EventLog @params
}

Function Write-Log ($EventLog, $Property, $Object) {
    ForEach ($Item in $Object) {
        Write-Verbose -Message "Write-Log: $($Property): $($Item.Name)."
        Switch ($Item.Status) {
            0 { $EntryType = "Information" }
            1 { $EntryType = "Warning" }
            Default { $EntryType = "Information" }
        }
        $params = @{
            LogName     = $EventLog
            Source      = $Property
            EventID     = (100 + [System.Int16]$Item.Status)
            EntryType   = $EntryType
            Message     = "$($Item.Name), $($Item.Value), $($Item.Status)"
            #Category    = 1
            #RawData   = 10, 20
            ErrorAction = "SilentlyContinue"
        }
        Write-EventLog @params
    }
}

Function Get-Platform {
    Switch -Regex ((Get-WmiObject -Class "Win32_OperatingSystem").Caption) {
        "Microsoft Windows Server*" {
            $Platform = "Server"
        }
        "Microsoft Windows 10 Enterprise for Virtual Desktops" {
            #$Platform = "Multi"
            $Platform = "Client"
        }
        "Microsoft Windows 11 Enterprise for Virtual Desktops" {
            #$Platform = "Multi"
            $Platform = "Client"
        }
        "Microsoft Windows 10*" {
            $Platform = "Client"
        }
        "Microsoft Windows 11*" {
            $Platform = "Client"
        }
        Default {
            $Platform = "Client"
        }
    }
    Write-Output -InputObject $Platform
}

Function Get-OSName {
    Switch -Regex ((Get-WmiObject -Class "Win32_OperatingSystem").Caption) {
        "Microsoft Windows Server 2022*" {
            $Caption = "Windows2022"; Break
        }
        "Microsoft Windows Server 2019*" {
            $Caption = "Windows2019"; Break
        }
        "Microsoft Windows Server 2016*" {
            $Caption = "Windows2016"; Break
        }
        "Microsoft Windows 10 Enterprise for Virtual Desktops" {
            $Caption = "Windows10"; Break
        }
        "Microsoft Windows 11 Enterprise for Virtual Desktops" {
            $Caption = "Windows10"; Break
        }
        "Microsoft Windows 10*" {
            $Caption = "Windows10"; Break
        }
        "Microsoft Windows 11*" {
            $Caption = "Windows11"; Break
        }
        Default {
            $Caption = "Unknown"
        }
    }
    Write-Output -InputObject $Caption
}

Function Get-Model {
    $Hypervisor = "Parallels*|VMware*|Virtual*"
    If ((Get-WmiObject -Computer . -Class "Win32_ComputerSystem").Model -match $Hypervisor) {
        $Model = "Virtual"
    }
    Else {
        $Model = "Physical"
    }
    Write-Output -InputObject $Model
}

Function Get-Settings ($Path) {
    Write-Verbose -Message "Importing: $Path."
    try {
        $params = @{
            Path        = $Path
            ErrorAction = "SilentlyContinue"
        }
        $Content = Get-Content @params
    }
    catch {
        $_.Exception.Message
        Return 1
    }
    try {
        $params = @{
            ErrorAction = "SilentlyContinue"
        }
        $Settings = $Content | ConvertFrom-Json @params
    }
    catch {
        $_.Exception.Message
        Return 1
    }
    Write-Output -InputObject $Settings
}

Function Set-DefaultUserProfile ($Setting) {

    # Variables
    $RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
    $DefaultUserPath = "HKLM:\MountDefaultUser"

    # Load registry hive
    try {
        Write-Verbose -Message "Load: $RegDefaultUser."
        $RegPath = $DefaultUserPath -replace ":", ""
        $params = @{
            FilePath     = "reg"
            ArgumentList = "load $RegPath $RegDefaultUser"
            Wait         = $True
            WindowStyle  = "Hidden"
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params > $Null
    }
    catch {
        Write-Output -InputObject @{Name = "Load"; Value = $_.Exception.Message; Status = 1 }
        Return 1
    }

    # Process Registry Commands
    ForEach ($Item in $Setting) {
        try {
            $RegPath = $Item.path -replace "HKCU:", $DefaultUserPath
            $params = @{
                Path        = $RegPath
                Type        = "RegistryKey"
                Force       = $True
                ErrorAction = "SilentlyContinue"
            }
            New-Item @params > $Null
            $params = @{
                Path        = $RegPath
                Name        = $Item.name
                Value       = $Item.value
                Type        = $Item.type
                Force       = $True
                ErrorAction = "SilentlyContinue"
            }
            Write-Verbose -Message "Set: $RegPath, $($Item.name), $($Item.value)."
            Set-ItemProperty @params > $Null
            $Result = 0
        }
        catch {
            $Result = 1
        }
        Write-Output -InputObject @{Name = $Item.name; Value = $Item.value; Status = $Result }
    }

    # Unload Registry Hive
    try {
        Write-Verbose -Message "Unload: $RegDefaultUser."
        $params = @{
            FilePath     = "reg"
            ArgumentList = "unload $($DefaultUserPath -replace ':', '')"
            Wait         = $True
            WindowStyle  = "Hidden"
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params > $Null
    }
    catch {
        Write-Output -InputObject @{Name = "Unload"; Value = $_.Exception.Message; Status = 1 }
        Return 1
    }
}

# Import default Start layout
Function Import-StartMenu ($StartMenuLayout) {
    If ($Null -ne $StartMenuLayout) {
        $StartPath = "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell"
        If (!(Test-Path -Path $StartPath -ErrorAction "SilentlyContinue")) {
            $params = @{
                Value       = $StartPath
                ItemType    = "Directory"
                ErrorAction = "SilentlyContinue"
            }
            New-Item @params > $Null
        }
        try {
            $params = @{
                LayoutPath  = $StartMenuLayout
                MountPath   = "$($env:SystemDrive)\"
                ErrorAction = "SilentlyContinue"
            }
            Write-Verbose -Message "Import-StartLayout: $StartMenuLayout."
            Import-StartLayout @params > $Null
            $Result = 0
        }
        catch {
            $Result = 1
        }
        Write-Output -InputObject ([PSCustomObject]@{Name = "Import-StartLayout"; Value = $StartMenuLayout; Status = $Result })
    }
}

Function Remove-Feature ($Feature) {
    If ($Null -ne $Feature) {
        Write-Verbose -Message "Remove features."
        $Feature | ForEach-Object { Get-WindowsOptionalFeature -Online -FeatureName $_ -ErrorAction "SilentlyContinue" } | `
            ForEach-Object { 
            try {
                Write-Verbose -Message "Disable-WindowsOptionalFeature: $($_.FeatureName)."
                $params = @{
                    FeatureName = $_.FeatureName
                    Online      = $True
                    NoRestart   = $True
                    ErrorAction = "SilentlyContinue"
                }
                Disable-WindowsOptionalFeature @params
                $Result = 0
            }
            catch {
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature"; Value = $_.FeatureName; Status = $Result })
        }
    }
}

Function Remove-Capability ($Capability) {
    If ($Null -ne $Capability) {
        Write-Verbose -Message "Remove capabilities."
        ForEach ($Item in $Capability) {
            try {    
                Write-Verbose -Message "Remove-WindowsCapability: $Item."
                $params = @{
                    Name        = $Item
                    Online      = $True
                    ErrorAction = "SilentlyContinue"
                }
                Remove-WindowsCapability @params
                $Result = 0
            }
            catch {
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "Remove-WindowsCapability"; Value = $Item; Status = $Result })
        }
    }
}

Function Remove-Package ($Package) {
    If ($Null -ne $Package) {
        Write-Verbose -Message "Remove packages."
        ForEach ($Item in $Package) {
            Get-WindowsPackage -Online -ErrorAction "SilentlyContinue" | Where-Object { $_.PackageName -match $Item } | `
                ForEach-Object {
                try {
                    Write-Verbose -Message "Remove-WindowsPackage: $($_.PackageName)."
                    $params = @{
                        PackageName = $_.PackageName
                        Online      = $True
                        ErrorAction = "SilentlyContinue"
                    }
                    Remove-WindowsPackage @params
                    $Result = 0
                }
                catch {
                    $Result = 1
                }
                Write-Output -InputObject ([PSCustomObject]@{Name = "Remove-WindowsPackage"; Value = $Item; Status = $Result })
            }
        }
    }
}

Function Remove-Path ($Path) {
    ForEach ($Item in $Path) {
        If (Test-Path -Path $Item -ErrorAction "SilentlyContinue") {
            Write-Verbose -Message "Remove-Item: $Item."
            try {
                $params = @{
                    Path        = $Item 
                    Recurse     = $True
                    Confirm     = $False
                    Force       = $True
                    ErrorAction = "SilentlyContinue"
                }
                Remove-Item @params
                $Result = 0
            }
            catch {
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = $Item; Value = "Remove"; Status = $Result })
        }
    }
}

Function Set-Registry ($Setting) {
    ForEach ($Item in $Setting) {
        try {
            New-Item -Path $Item.path -Type "RegistryKey" -Force -ErrorAction "SilentlyContinue" > $Null
            $params = @{
                Path        = $Item.path
                Name        = $Item.name
                Value       = $Item.value
                Type        = $Item.type
                Force       = $True
                ErrorAction = "SilentlyContinue"
            }
            Set-ItemProperty @params > $Null
            $Result = 0
        }
        catch {
            $Result = 1
        }
        Write-Output -InputObject ([PSCustomObject]@{Name = $Item.name; Value = $Item.value; Status = $Result })
    }
}

Function Copy-Path ($Path) {
    ForEach ($Item in $Path) {
        If (Test-Path -Path $Item -ErrorAction "SilentlyContinue") {
            try {
                $params = @{
                    Path        = $Item.Source
                    Destination = $Item.Destination
                    Confirm     = $False
                    Force       = $True
                    ErrorAction = "SilentlyContinue"
                }
                Copy-Item @params
                $Result = 0
            }
            catch {
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = $Item.Source; Value = $Item.Destination; Status = $Result })
        }
    }
}
#endregion


try {
    Push-Location -Path $Path
    $Version = Get-ChildItem -Path $Path -Filter "VERSION.txt" -Recurse | Get-Content -Raw
    Write-Verbose -Message "Execution path: $Path."
    Write-Verbose -Message "Customisation scripts version: $Version."

    # Setup logging
    New-ScriptEventLog -EventLog $Project -Property $Properties

    # Get system properties
    $Platform = Get-Platform
    #$Build = ([System.Environment]::OSVersion.Version).Build
    $Build = [System.Environment]::OSVersion.Version
    $Model = Get-Model
    $OSName = Get-OSName
    Write-Verbose -Message "      OS: $OSName."
    Write-Verbose -Message "Platform: $Platform."
    Write-Verbose -Message "   Build: $Build."
    Write-Verbose -Message "   Model: $Model."

    #region Gather configs and run
    $AllConfigs = @(Get-ChildItem -Path $Path -Filter "*.All.json" -Recurse -ErrorAction "SilentlyContinue")
    $PlatformConfigs = @(Get-ChildItem -Path $Path -Filter "*.$Platform.json" -Recurse -ErrorAction "SilentlyContinue")
    $BuildConfigs = @(Get-ChildItem -Path $Path -Filter "*.$Build.json" -Recurse -ErrorAction "SilentlyContinue")
    $ModelConfigs = @(Get-ChildItem -Path $Path -Filter "*.$Model.json" -Recurse -ErrorAction "SilentlyContinue")
    Write-Verbose -Message "   Found: $(($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs).Count) configs."
    ForEach ($Config in ($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs)) {

        # Read the settings JSON
        $Settings = Get-Settings -Path $Config.FullName

        # Implement the settings only if the local build is greater or equal that what's specified in the JSON
        If ([System.Version]$Build -ge [System.Version]$Settings.MininumBuild) {

            # Implement each setting in the JSON
            $Results = Remove-Feature -Feature $Settings.Features.Disable
            Write-Log -EventLog $Project -Property "Features" -Object $Results

            $Results = Remove-Capability -Capability $Settings.Capabilities.Remove
            Write-Log -EventLog $Project -Property "Capabilities" -Object $Results

            $Results = Remove-Package -Package $Settings.Packages.Remove
            Write-Log -EventLog $Project -Property "Packages" -Object $Results

            $Results = Remove-Path -Path $Settings.Paths.Remove
            Write-Log -EventLog $Project -Property "Paths" -Object $Results

            $Results = Copy-Path -Path $Settings.Paths.Copy
            Write-Log -EventLog $Project -Property "Paths" -Object $Result

            Switch ($Settings.Registry.Type) {
                "Direct" {
                    $Results = Set-Registry -Setting $Settings.Registry.Set
                }
                "DefaultProfile" {
                    $Results = Set-DefaultUserProfile -Setting $Settings.Registry.Set
                }
                Default {
                    Write-Verbose -Message "Skip registry."
                }
            }
            Write-Log -EventLog $Project -Property "Registry" -Object $Results

            Switch ($Settings.StartMenu.Type) {
                "Server" {
                    If ((Get-WindowsFeature -Name $Settings.StartMenu.Feature).InstallState -eq "Installed") {
                        $File = $(Join-Path -Path $Path -ChildPath $Settings.StartMenu.Exists)
                    }
                    Else {
                        $File = $(Join-Path -Path $Path -ChildPath $Settings.StartMenu.NotExists)
                    }
                    $Results = Import-StartMenu -StartMenuLayout $File
                }
                "Client" {
                    $Results = Import-StartMenu -StartMenuLayout $(Join-Path -Path $Path -ChildPath $Settings.StartMenu.$OSName)
                    
                }
                Default {
                    $Results = ([PSCustomObject]@{Name = "Start menu layout"; Value = "Skipped"; Status = 0 })
                }
            }
            Write-Log -EventLog $Project -Property "StartMenu" -Object $Results
        }
        Else {
            Write-Verbose -Message "Skip config: $($Config.FullName)."
        }
    }
    #endregion

    # If on a client OS, run the script to remove AppX / UWP apps
    If ($Platform -eq "Client") {
        Switch ($Model) {
            "Physical" { $Apps = & (Join-Path -Path $Path -ChildPath "Remove-AppxApps.ps1") -Operation "BlockList" }
            "Virtual" { $Apps = & (Join-Path -Path $Path -ChildPath "Remove-AppxApps.ps1") -Operation "AllowList" }
        }
        Write-Log -EventLog $Project -Property "AppX" -Object $Apps
    }
}
catch {
    $_.Exception.Message
    Return 1
}

# Set uninstall registry value for detecting as an installed application
$Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
reg add "$Key\{$Guid}" /v "DisplayName" /d $Project /t REG_SZ /f 4> $Null
reg add "$Key\{$Guid}" /v "Publisher" /d $Publisher /t REG_SZ /f 4> $Null
reg add "$Key\{$Guid}" /v "DisplayVersion" /d $Version /t REG_SZ /f 4> $Null
reg add "$Key\{$Guid}" /v "RunOn" /d $RunOn /t REG_SZ /f 4> $Null
reg add "$Key\{$Guid}" /v "SystemComponent" /d 1 /t REG_DWORD /f 4> $Null
reg add "$Key\{$Guid}" /v "HelpLink" /d $Helplink /t REG_SZ /f 4> $Null
Return 0
