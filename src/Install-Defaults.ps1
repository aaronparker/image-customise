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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
    [System.String[]] $Properties = @("General", "Registry", "Paths", "StartMenu", "Features", "Capabilities", "Packages", "AppX"),

    [Parameter(Mandatory = $False)]
    [System.String] $AppxMode = "Allow"
)

#region Restart if running in a 32-bit session
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell."
        Write-Verbose -Message "FilePath: $ProcessPath."
        Write-Verbose -Message "Arguments: $Arguments."
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        Exit 0
    }
}
#endregion

#region Functions
function New-ScriptEventLog ($EventLog, $Property) {
    $params = @{
        LogName     = $EventLog
        Source      = $Property
        ErrorAction = "SilentlyContinue"
    }
    New-EventLog @params
}

function Write-ToEventLog ($EventLog, $Property, $Object) {
    foreach ($Item in $Object) {
        if ($Item.Value.Length -gt 0) {
            Write-Verbose -Message "Write-ToEventLog: $($Property); $($Item.Name)."
            Write-Verbose -Message "Write-ToEventLog: $($Item.Value); $($Item.Status)"
            switch ($Item.Status) {
                0 { $EntryType = "Information" }
                1 { $EntryType = "Warning" }
                default { $EntryType = "Information" }
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
}

function Get-Platform {
    switch -Regex ((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption) {
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
        default {
            $Platform = "Client"
        }
    }
    Write-Output -InputObject $Platform
}

function Get-OSName {
    switch -Regex ((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption) {
        "^Microsoft Windows Server 2022.*$" {
            $Caption = "Windows2022"; break
        }
        "^Microsoft Windows Server 2019.*$" {
            $Caption = "Windows2019"; break
        }
        "^Microsoft Windows Server 2016.*$" {
            $Caption = "Windows2016"; break
        }
        "^Microsoft Windows 11 Enterprise for Virtual Desktops$" {
            $Caption = "Windows10"; break
        }
        "^Microsoft Windows 10 Enterprise for Virtual Desktops$" {
            $Caption = "Windows10"; break
        }
        "^Microsoft Windows 11.*$" {
            $Caption = "Windows11"; break
        }
        "^Microsoft Windows 10.*$" {
            $Caption = "Windows10"; break
        }
        default {
            $Caption = "Unknown"
        }
    }
    Write-Output -InputObject $Caption
}

function Get-Model {
    $Hypervisor = "Parallels*|VMware*|Virtual*"
    if ((Get-CimInstance -ClassName "Win32_ComputerSystem").Model -match $Hypervisor) {
        $Model = "Virtual"
    }
    else {
        $Model = "Physical"
    }
    Write-Output -InputObject $Model
}

function Get-SettingsContent ($Path) {
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
        return 1
    }
    try {
        $params = @{
            ErrorAction = "SilentlyContinue"
        }
        $Settings = $Content | ConvertFrom-Json @params
    }
    catch {
        $_.Exception.Message
        return 1
    }
    Write-Output -InputObject $Settings
}

function Set-DefaultUserProfile ($Setting) {
    try {
        # Variables
        $RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
        $DefaultUserPath = "HKLM:\MountDefaultUser"

        try {
            # Load registry hive
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
            Write-Output -InputObject ([PSCustomObject]@{Name = "Load"; Value = "Start"; Status = 0 })
        }
        catch {
            Write-Output -InputObject ([PSCustomObject]@{Name = "Load"; Value = $_.Exception.Message; Status = 1 })
            return 1
        }

        # Process Registry Commands
        foreach ($Item in $Setting) {
            try {
                $RegPath = $Item.path -replace "HKCU:", $DefaultUserPath
                if (!(Test-Path -Path $Item.path -ErrorAction "SilentlyContinue")) {
                    $params = @{
                        Path        = $Item.path
                        Type        = "RegistryKey"
                        Force       = $True
                        ErrorAction = "SilentlyContinue"
                    }
                    $ItemResult = New-Item @params
                    if ("Handle" -in ($ItemResult | Get-Member | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
                }
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
                $Msg = "Success"
                $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "$RegPath; $($Item.name); $($Item.value)"; Value = $Msg; Status = $Result })
        }
    }
    catch {
        Write-Output -InputObject ([PSCustomObject]@{Name = "General"; Value = $_.Exception.Message; Status = $Result })
    }
    finally {
        try {
            # Unload Registry Hive
            Write-Verbose -Message "Unload: $RegDefaultUser."
            [gc]::Collect()
            $params = @{
                FilePath     = "reg"
                ArgumentList = "unload $($DefaultUserPath -replace ':', '')"
                Wait         = $True
                WindowStyle  = "Hidden"
                ErrorAction  = "SilentlyContinue"
            }
            Start-Process @params > $Null
            Write-Output -InputObject ([PSCustomObject]@{Name = "Unload"; Value = "End"; Status = 0 })
        }
        catch {
            Write-Output -InputObject ([PSCustomObject]@{Name = "Unload"; Value = $_.Exception.Message; Status = 1 })
        }
    }
}

function Set-Registry ($Setting) {
    foreach ($Item in $Setting) {
        try {
            if (!(Test-Path -Path $Item.path -ErrorAction "SilentlyContinue")) {
                $params = @{
                    Path        = $Item.path
                    Type        = "RegistryKey"
                    Force       = $True
                    ErrorAction = "SilentlyContinue"
                }
                $ItemResult = New-Item @params
                if ("Handle" -in ($ItemResult | Get-Member | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
            }
            $params = @{
                Path        = $Item.path
                Name        = $Item.name
                Value       = $Item.value
                Type        = $Item.type
                Force       = $True
                ErrorAction = "SilentlyContinue"
            }
            Set-ItemProperty @params > $Null
            $Msg = "Success"
            $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message
            $Result = 1
        }
        Write-Output -InputObject ([PSCustomObject]@{Name = "$($Item.path); $($Item.name); $($Item.value)"; Value = $Msg; Status = $Result })
    }
}

function Copy-File ($Path, $Parent) {
    foreach ($Item in $Path) {
        $Source = $(Join-Path -Path $Parent -ChildPath $Item.Source)
        Write-Verbose -Message "Source: $Source."
        Write-Verbose -Message "Destination: $($Item.Destination)."
        if (Test-Path -Path $Source -ErrorAction "SilentlyContinue") {
            New-Directory -Path $(Split-Path -Path $Item.Destination -Parent)
            try {
                $params = @{
                    Path        = $Source
                    Destination = $Item.Destination
                    Confirm     = $False
                    Force       = $True
                    ErrorAction = "SilentlyContinue"
                }
                Copy-Item @params
                $Msg = "Success"
                $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "$Source; $($Item.Destination)"; Value = $Msg; Status = $Result })
        }
        else {
            Write-Output -InputObject ([PSCustomObject]@{Name = $Source; Value = "Does not exist"; Status = 1 })
        }
    }
}

function New-Directory ($Path) {
    if (!(Test-Path -Path $Path -ErrorAction "SilentlyContinue")) {
        try {
            $params = @{
                Path        = $Path
                ItemType    = "Directory"
                ErrorAction = "SilentlyContinue"
            }
            New-Item @params > $Null
            $Msg = "Success"
            $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message
            $Result = 1
        }
        Write-Output -InputObject ([PSCustomObject]@{Name = $Path; Value = $Msg; Status = $Result })
    }
}

function Remove-Path ($Path) {
    foreach ($Item in $Path) {
        if (Test-Path -Path $Item -ErrorAction "SilentlyContinue") {
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
                $Msg = "Success"
                $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "Remove: $Item"; Value = $Msg; Status = $Result })
        }
    }
}

function Remove-Feature ($Feature) {
    if ($Feature.Count -ge 1) {
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
                $Msg = "Success"
                $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature; $($_.FeatureName)"; Value = $Msg; Status = $Result })
        }
    }
}

function Remove-Capability ($Capability) {
    if ($Capability.Count -ge 1) {
        Write-Verbose -Message "Remove capabilities."
        foreach ($Item in $Capability) {
            try {
                Write-Verbose -Message "Remove-WindowsCapability: $Item."
                $params = @{
                    Name        = $Item
                    Online      = $True
                    ErrorAction = "SilentlyContinue"
                }
                Remove-WindowsCapability @params
                $Msg = "Success"
                $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message
                $Result = 1
            }
            Write-Output -InputObject ([PSCustomObject]@{Name = "Remove-WindowsCapability; $Item"; Value = $Msg; Status = $Result })
        }
    }
}

function Remove-Package ($Package) {
    if ($Package.Count -ge 1) {
        Write-Verbose -Message "Remove packages."
        foreach ($Item in $Package) {
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
                    $Msg = "Success"
                    $Result = 0
                }
                catch {
                    $Msg = $_.Exception.Message
                    $Result = 1
                }
                Write-Output -InputObject ([PSCustomObject]@{Name = "Remove-WindowsPackage; $Item;"; Value = $Msg; Status = $Result })
            }
        }
    }
}
#endregion

# Configure working path
if ($Path.Length -eq 0) { $WorkingPath = $PWD.Path } else { $WorkingPath = $Path }
Push-Location -Path $WorkingPath
Write-Verbose -Message "Execution path: $WorkingPath."

try {
    # Setup logging
    New-ScriptEventLog -EventLog $Project -Property $Properties

    # Start logging
    $PSProcesses = Get-CimInstance -ClassName "Win32_Process" -Filter "Name = 'powershell.exe'" | Select-Object -Property "CommandLine"
    foreach ($Process in $PSProcesses) {
        $Object = ([PSCustomObject]@{Name = "CommandLine"; Value = $Process.CommandLine; Status = 0 })
        Write-ToEventLog -EventLog $Project -Property "General" -Object $Object
    }

    # Get system properties
    $Platform = Get-Platform
    Write-Verbose -Message "Platform: $Platform."
    Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = "Platform"; Value = $Platform; Status = 0 })

    $Build = ([System.Environment]::OSVersion.Version).Build
    $Version = [System.Environment]::OSVersion.Version
    Write-Verbose -Message "   Build: $Build."
    Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = "Build/version"; Value = $Version; Status = 0 })

    $Model = Get-Model
    Write-Verbose -Message "   Model: $Model."
    Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = "Model"; Value = $Model; Status = 0 })

    $OSName = Get-OSName
    Write-Verbose -Message "      OS: $OSName."
    Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = "OSName"; Value = $OSName; Status = 0 })

    $Version = Get-ChildItem -Path $WorkingPath -Filter "VERSION.txt" -Recurse | Get-Content -Raw
    Write-Verbose -Message "Customisation scripts version: $Version."
    Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = "Version"; Value = $Version; Status = 0 })

    #region Gather configs and run
    $AllConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.All.json" -Recurse -ErrorAction "SilentlyContinue")
    $PlatformConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Platform.json" -Recurse -ErrorAction "SilentlyContinue")
    $BuildConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Build.json" -Recurse -ErrorAction "SilentlyContinue")
    $ModelConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Model.json" -Recurse -ErrorAction "SilentlyContinue")
    Write-Verbose -Message "   Found: $(($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs).Count) configs."
    foreach ($Config in ($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs)) {

        # Read the settings JSON
        $Settings = Get-SettingsContent -Path $Config.FullName

        # Implement the settings only if the local build is greater or equal that what's specified in the JSON
        if ([System.Version]$Version -ge [System.Version]$Settings.MinimumBuild) {
            if ([System.Version]$Version -le [System.Version]$Settings.MaximumBuild) {
                # Implement each setting in the JSON
                switch ($Settings.Registry.Type) {
                    "DefaultProfile" {
                        $Results = Set-DefaultUserProfile -Setting $Settings.Registry.Set; break
                    }
                    "Direct" {
                        $Results = Set-Registry -Setting $Settings.Registry.Set; break
                    }
                    default {
                        $Results = ([PSCustomObject]@{Name = "Registry"; Value = "Skipped"; Status = 0 })
                        Write-Verbose -Message "Skip registry."
                    }
                }
                Write-ToEventLog -EventLog $Project -Property "Registry" -Object $Results

                switch ($Settings.StartMenu.Type) {
                    "Server" {
                        if ((Get-WindowsFeature -Name $Settings.StartMenu.Feature).InstallState -eq "Installed") {
                            $Results = Copy-File -Path $Settings.StartMenu.Exists -Parent $WorkingPath
                            Write-ToEventLog -EventLog $Project -Property "StartMenu" -Object $Results
                        }
                        else {
                            $Results = Copy-File -Path $Settings.StartMenu.NotExists -Parent $WorkingPath
                            Write-ToEventLog -EventLog $Project -Property "StartMenu" -Object $Results
                        }
                    }
                    "Client" {
                        $Results = Copy-File -Path $Settings.StartMenu.$OSName -Parent $WorkingPath
                        Write-ToEventLog -EventLog $Project -Property "StartMenu" -Object $Results
                    }
                }

                $Results = Copy-File -Path $Settings.Files.Copy -Parent $WorkingPath
                Write-ToEventLog -EventLog $Project -Property "Paths" -Object $Results

                $Results = Remove-Path -Path $Settings.Paths.Remove
                Write-ToEventLog -EventLog $Project -Property "Paths" -Object $Results

                $Results = Remove-Feature -Feature $Settings.Features.Disable
                Write-ToEventLog -EventLog $Project -Property "Features" -Object $Results

                $Results = Remove-Capability -Capability $Settings.Capabilities.Remove
                Write-ToEventLog -EventLog $Project -Property "Capabilities" -Object $Results

                $Results = Remove-Package -Package $Settings.Packages.Remove
                Write-ToEventLog -EventLog $Project -Property "Packages" -Object $Results
            }
        }
        else {
            Write-ToEventLog -EventLog $Project -Property "General" -Object ([PSCustomObject]@{Name = $Config.FullName; Value = "Skipped"; Status = 0 })
            Write-Verbose -Message "Skip config: $($Config.FullName)."
        }
    }
    #endregion

    # If on a client OS, run the script to remove AppX; UWP apps
    if ($Platform -eq "Client") {

        # Get the script location
        $Script = Get-ChildItem -Path $WorkingPath -Filter "Remove-AppxApps.ps1" -Recurse -ErrorAction "SilentlyContinue"
        if ($Null -ne $Script) {
            Write-ToEventLog -EventLog $Project -Property "AppX" -Object ([PSCustomObject]@{Name = "Script"; Value = $Script.FullName; Status = 1 })

            switch ($AppxMode) {
                "Block" { $Apps = & $Script.FullName -Operation "BlockList" }
                "Allow" { $Apps = & $Script.FullName -Operation "AllowList" }
            }
            Write-ToEventLog -EventLog $Project -Property "AppX" -Object $Apps
        }
        else {
            Write-ToEventLog -EventLog $Project -Property "AppX" -Object ([PSCustomObject]@{Name = "Script"; Value = "Remove-AppxApps.ps1"; Status = 0 })
        }
    }
}
catch {
    # Write last entry to the event log and output failure
    $Object = ([PSCustomObject]@{Name = "Result"; Value = $_.Exception.Message; Status = 1 })
    Write-ToEventLog -EventLog $Project -Property "General" -Object $Object
    $_.Exception.Message
    return 1
}

try {
    $Path = "$env:ProgramData\FeatureUpdates"
    if ($Path -eq $WorkingPath) {
        $Object = ([PSCustomObject]@{Name = "Result"; Value = "Skipping file copy"; Status = 1 })
        Write-ToEventLog -EventLog $Project -Property "General" -Object $Object
    }
    else {
        New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null
        Copy-Item -Path $WorkingPath -Destination $Path -Recurse
    }
}
catch {
    $Object = ([PSCustomObject]@{Name = "Result"; Value = $_.Exception.Message; Status = 1 })
    Write-ToEventLog -EventLog $Project -Property "General" -Object $Object
    $_.Exception.Message
}

# Set uninstall registry value for detecting as an installed application
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
New-Item -Path "$Key\{$Guid}" -Type "RegistryKey" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayName" -Value $Project -Type "String" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "Publisher" -Value $Publisher -Type "String" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayVersion" -Value $Version -Type "String" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "RunOn" -Value $RunOn -Type "String" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "SystemComponent" -Value 1 -Type "DWord" -Force -ErrorAction "SilentlyContinue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "HelpLink" -Value $HelpLink -Type "String" -Force -ErrorAction "SilentlyContinue" | Out-Null

# Write last entry to the event log and output success
$Object = ([PSCustomObject]@{Name = "Result"; Value = "Success"; Status = 0 })
Write-ToEventLog -EventLog $Project -Property "General" -Object $Object
return 0
