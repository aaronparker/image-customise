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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "ShouldProcess will add too much code at this time.")]
[CmdletBinding(SupportsShouldProcess = $false)]
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
    [System.String[]] $Properties = @("General", "Registry", "Paths", "StartMenu", "Features", "Capabilities", "Packages", "AppX", "Language"),

    [Parameter(Mandatory = $False)]
    [System.String] $AppxMode = "Block",

    [Parameter(Mandatory = $False)]
    [System.String] $Language = "en-AU"
)

#region Restart if running in a 32-bit session
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell."
        Write-Verbose -Message "File path: $ProcessPath."
        Write-Verbose -Message "Arguments: $Arguments."
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
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

function Write-ToEventLog ($Property, $Object) {
    foreach ($Item in $Object) {
        if ($Item.Value.Length -gt 0) {
            switch ($Item.Status) {
                0 { $EntryType = "Information" }
                1 { $EntryType = "Warning" }
                default { $EntryType = "Information" }
            }
            $params = @{
                LogName     = "Customised Defaults"
                Source      = $Property
                EventID     = (100 + [System.Int16]$Item.Status)
                EntryType   = $EntryType
                Message     = "$($Item.Name), $($Item.Value), $($Item.Status)"
                ErrorAction = "Continue"
            }
            Write-EventLog @params
        }
    }
}

function Get-Platform {
    switch -Regex ((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption) {
        "Microsoft Windows Server*" {
            $Platform = "Server"; break
        }
        "Microsoft Windows 10 Enterprise for Virtual Desktops" {
            $Platform = "Client"; break
        }
        "Microsoft Windows 11 Enterprise for Virtual Desktops" {
            $Platform = "Client"; break
        }
        "Microsoft Windows 10*" {
            $Platform = "Client"; break
        }
        "Microsoft Windows 11*" {
            $Platform = "Client"; break
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
    try {
        $params = @{
            Path        = $Path
            ErrorAction = "Continue"
        }
        Write-Verbose -Message "Importing: $Path."
        $Settings = Get-Content @params | ConvertFrom-Json -ErrorAction "Continue"
    }
    catch {
        # If we have an error we won't get usable data
        throw $_
    }
    Write-Output -InputObject $Settings
}

function Set-RegistryOwner {
    # Links: https://stackoverflow.com/questions/12044432/how-do-i-take-ownership-of-a-registry-key-via-powershell
    # "S-1-5-32-544" - Administrators
    param($RootKey, $Key, [System.Security.Principal.SecurityIdentifier]$Sid = "S-1-5-32-544", $Recurse = $true)

    switch -regex ($rootKey) {
        "HKCU|HKEY_CURRENT_USER" { $RootKey = "CurrentUser" }
        "HKLM|HKEY_LOCAL_MACHINE" { $RootKey = "LocalMachine" }
        "HKCR|HKEY_CLASSES_ROOT" { $RootKey = "ClassesRoot" }
        "HKCC|HKEY_CURRENT_CONFIG" { $RootKey = "CurrentConfig" }
        "HKU|HKEY_USERS" { $RootKey = "Users" }
    }

    try {
        ### Step 1 - escalate current process's privilege
        # get SeTakeOwnership, SeBackup and SeRestore privileges before executes next lines, script needs Admin privilege
        $Import = '[DllImport("ntdll.dll")] public static extern int RtlAdjustPrivilege(ulong a, bool b, bool c, ref bool d);'
        $Ntdll = Add-Type -Member $import -Name "NtDll" -PassThru
        $Privileges = @{ SeTakeOwnership = 9; SeBackup = 17; SeRestore = 18 }
        foreach ($i in $Privileges.Values) {
            $null = $Ntdll::RtlAdjustPrivilege($i, 1, 0, [ref]0)
        }

        function Set-RegistryKeyOwner {
            param($RootKey, $Key, $Sid, $Recurse, $RecurseLevel = 0)

            ### Step 2 - get ownerships of key - it works only for current key
            $RegKey = [Microsoft.Win32.Registry]::$RootKey.OpenSubKey($Key, "ReadWriteSubTree", "TakeOwnership")
            $Acl = New-Object -TypeName "System.Security.AccessControl.RegistrySecurity"
            $Acl.SetOwner($Sid)
            $RegKey.SetAccessControl($Acl)

            ### Step 3 - enable inheritance of permissions (not ownership) for current key from parent
            $Acl.SetAccessRuleProtection($false, $false)
            $RegKey.SetAccessControl($Acl)

            ### Step 4 - only for top-level key, change permissions for current key and propagate it for subkeys
            # to enable propagations for subkeys, it needs to execute Steps 2-3 for each subkey (Step 5)
            if ($RecurseLevel -eq 0) {
                $RegKey = $RegKey.OpenSubKey("", "ReadWriteSubTree", "ChangePermissions")
                $Rule = New-Object -TypeName System.Security.AccessControl.RegistryAccessRule($Sid, "FullControl", "ContainerInherit", "None", "Allow")
                $Acl.ResetAccessRule($Rule)
                $RegKey.SetAccessControl($Acl)
            }

            ### Step 5 - recursively repeat steps 2-5 for subkeys
            if ($Recurse) {
                foreach ($SubKey in $RegKey.OpenSubKey("").GetSubKeyNames()) {
                    Set-RegistryKeyOwner $RootKey ($Key + "\" + $SubKey) $Sid $Recurse ($RecurseLevel + 1)
                }
            }
        }

        Set-RegistryKeyOwner $RootKey $Key $Sid $Recurse
        $Msg = "Success"; $Result = 0
    }
    catch {
        $Msg = $_.Exception.Message; $Result = 1
    }
    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Set-RegistryOwner: $RootKey, $Key, $Sid"; Value = $Msg; Result = $Result })
}

function Set-Registry ($Setting) {
    foreach ($Item in $Setting) {
        if (-not(Test-Path -Path $Item.path)) {
            try {
                $params = @{
                    Path        = $Item.path
                    Type        = "RegistryKey"
                    Force       = $True
                    ErrorAction = "SilentlyContinue"
                }
                Write-Verbose "Create path: $RegPath"
                $ItemResult = New-Item @params
                $Msg = "CreatePath"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            finally {
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = $Item.path; Value = $Msg; Result = $Result })
                if ("Handle" -in ($ItemResult | Get-Member | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
            }
        }

        try {
            $params = @{
                Path        = $Item.path
                Name        = $Item.name
                Value       = $Item.value
                Type        = $Item.type
                Force       = $True
                ErrorAction = "Continue"
            }
            Set-ItemProperty @params > $Null
            $Msg = "SetValue"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-Verbose -Message "Set value: $($Item.path); $($Item.name); $($Item.value); Result: $Result"
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$($Item.path); $($Item.name); $($Item.value)"; Value = $Msg; Result = $Result })
    }
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
                ErrorAction  = "Continue"
            }
            $result = Start-Process @params > $Null
        }
        catch {
            Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Load: $RegDefaultUser"; Value = $RegPath; Result = 1 })
            throw $_
        }
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Load: $RegDefaultUser"; Value = $RegPath; Result = 0 })

        # Process Registry Commands
        foreach ($Item in $Setting) {
            $RegPath = $Item.path -replace "HKCU:", $DefaultUserPath
            if (-not(Test-Path -Path $RegPath)) {
                try {
                    $params = @{
                        Path        = $RegPath
                        Type        = "RegistryKey"
                        Force       = $True
                        ErrorAction = "Continue"
                    }
                    Write-Verbose "Create path: $RegPath"
                    $ItemResult = New-Item @params
                    $Msg = "CreatePath"; $Result = 0
                }
                catch {
                    $Msg = $_.Exception.Message; $Result = 1
                }
                finally {
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = $Item.path; Value = $Msg; Result = $Result })
                    if ("Handle" -in ($ItemResult | Get-Member | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
                }
            }

            try {
                $params = @{
                    Path        = $RegPath
                    Name        = $Item.name
                    Value       = $Item.value
                    Type        = $Item.type
                    Force       = $True
                    ErrorAction = "Continue"
                }
                Set-ItemProperty @params > $Null
                $Msg = "SetValue"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-Verbose -Message "Set value: $RegPath, $($Item.name), $($Item.value). Result: $Result"
            Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$RegPath; $($Item.name); $($Item.value)"; Value = $Msg; Result = $Result })
        }
    }
    catch {
        Write-Verbose -Message "Set: $RegPath, $($Item.name), $($Item.value). Skip"
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "General"; Value = $_.Exception.Message; Result = $Result })
    }
    finally {
        try {
            # Unload Registry Hive
            [gc]::Collect()
            $params = @{
                FilePath     = "reg"
                ArgumentList = "unload $($DefaultUserPath -replace ':', '')"
                Wait         = $True
                WindowStyle  = "Hidden"
                ErrorAction  = "Continue"
            }
            Start-Process @params > $Null
            $Msg = "Success"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-Verbose -Message "Unload: $RegDefaultUser. Result: $Result"
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Unload: $RegDefaultUser"; Value = $Msg; Result = $Result })
    }
}

function Copy-File ($Path, $Parent) {
    foreach ($Item in $Path) {
        $Source = $(Join-Path -Path $Parent -ChildPath $Item.Source)
        Write-Verbose -Message "Source: $Source."
        Write-Verbose -Message "Destination: $($Item.Destination)."
        if (Test-Path -Path $Source -ErrorAction "Continue") {
            New-Directory -Path $(Split-Path -Path $Item.Destination -Parent)
            try {
                $params = @{
                    Path        = $Source
                    Destination = $Item.Destination
                    Confirm     = $False
                    Force       = $True
                    ErrorAction = "Continue"
                }
                Copy-Item @params
                $Msg = "Copy path"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Item.Destination; Value = $Msg; Result = $Result })
        }
        else {
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Source; Value = "Does not exist"; Result = 1 })
        }
    }
}

function New-Directory ($Path) {
    if (Test-Path -Path $Path -ErrorAction "Continue") {
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = "Exists"; Result = 0 })
    }
    else {
        try {
            $params = @{
                Path        = $Path
                ItemType    = "Directory"
                ErrorAction = "Continue"
            }
            New-Item @params > $Null
            $Msg = "CreatePath"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = $Msg; Result = $Result })
    }
}

function Remove-Path ($Path) {
    foreach ($Item in $Path) {
        if (Test-Path -Path $Item -ErrorAction "Continue") {
            Write-Verbose -Message "Remove-Item: $Item."
            try {
                $params = @{
                    Path        = $Item
                    Recurse     = $True
                    Confirm     = $False
                    Force       = $True
                    ErrorAction = "Continue"
                }
                Remove-Item @params
                $Msg = "RemovePath"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = $Msg; Result = $Result })
        }
    }
}

function Remove-Feature ($Feature) {
    if ($Feature.Count -ge 1) {
        Write-Verbose -Message "Remove features."
        $Feature | ForEach-Object { Get-WindowsOptionalFeature -Online -FeatureName $_ -ErrorAction "Continue" } | `
            ForEach-Object {
            try {
                Write-Verbose -Message "Disable-WindowsOptionalFeature: $($_.FeatureName)."
                $params = @{
                    FeatureName = $_.FeatureName
                    Online      = $True
                    NoRestart   = $True
                    ErrorAction = "Continue"
                }
                Disable-WindowsOptionalFeature @params | Out-Null
                $Msg = "RemoveFeature"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Features" -Object ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature; $($_.FeatureName)"; Value = $Msg; Result = $Result })
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
                    ErrorAction = "Continue"
                }
                Remove-WindowsCapability @params | Out-Null
                $Msg = "RemoveCapability"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Capabilities" -Object ([PSCustomObject]@{Name = "Remove-WindowsCapability; $Item"; Value = $Msg; Result = $Result })
        }
    }
}

function Remove-Package ($Package) {
    if ($Package.Count -ge 1) {
        Write-Verbose -Message "Remove packages."
        foreach ($Item in $Package) {
            Get-WindowsPackage -Online -ErrorAction "Continue" | Where-Object { $_.PackageName -match $Item } | `
                ForEach-Object {
                try {
                    Write-Verbose -Message "Remove-WindowsPackage: $($_.PackageName)."
                    $params = @{
                        PackageName = $_.PackageName
                        Online      = $True
                        ErrorAction = "Continue"
                    }
                    Remove-WindowsPackage @params | Out-Null
                    $Msg = "RemovePackage"; $Result = 0
                }
                catch {
                    $Msg = $_.Exception.Message; $Result = 1
                }
                Write-ToEventLog -Property "Packages" -Object ([PSCustomObject]@{Name = "Remove-WindowsPackage; $Item;"; Value = $Msg; Result = $Result })
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
        $Object = ([PSCustomObject]@{Name = "CommandLine"; Value = $Process.CommandLine; Result = 0 })
        Write-ToEventLog -Property "General" -Object $Object
    }

    # Get system properties
    $Platform = Get-Platform
    Write-Verbose -Message "Platform: $Platform."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Platform"; Value = $Platform; Result = 0 })

    $Build = ([System.Environment]::OSVersion.Version).Build
    $OSVersion = [System.Environment]::OSVersion.Version
    Write-Verbose -Message "Build: $Build."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Build/version"; Value = $OSVersion; Result = 0 })

    $Model = Get-Model
    Write-Verbose -Message "Model: $Model."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Model"; Value = $Model; Result = 0 })

    $OSName = Get-OSName
    Write-Verbose -Message "OS: $OSName."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "OSName"; Value = $OSName; Result = 0 })

    $DisplayVersion = Get-ChildItem -Path $WorkingPath -Filter "VERSION.txt" -Recurse | Get-Content -Raw
    Write-Verbose -Message "Customisation scripts version: $DisplayVersion."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Version"; Value = $DisplayVersion; Result = 0 })

    #region Gather configs and run
    $AllConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.All.json" -Recurse -ErrorAction "Continue")
    $PlatformConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Platform.json" -Recurse -ErrorAction "Continue")
    $BuildConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Build.json" -Recurse -ErrorAction "Continue")
    $ModelConfigs = @(Get-ChildItem -Path $WorkingPath -Filter "*.$Model.json" -Recurse -ErrorAction "Continue")
    Write-Verbose -Message "Found: $(($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs).Count) configs."

    foreach ($Config in ($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs)) {

        # Read the settings JSON
        $Settings = Get-SettingsContent -Path $Config.FullName
        Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Config file"; Value = $Config.Name; Result = 0 })

        # Implement the settings only if the local build is greater or equal that what's specified in the JSON
        if ([System.Version]$OSVersion -ge [System.Version]$Settings.MinimumBuild) {
            if ([System.Version]$OSVersion -le [System.Version]$Settings.MaximumBuild) {

                # Implement each setting in the JSON
                if ($Settings.Registry.ChangeOwner.Length -gt 0) {
                    foreach ($Item in $Settings.Registry.ChangeOwner) {
                        Set-RegistryOwner -RootKey $Item.Root -Key $Item.Key -Sid $Item.Sid
                    }
                }
                switch ($Settings.Registry.Type) {
                    "DefaultProfile" {
                        Set-DefaultUserProfile -Setting $Settings.Registry.Set; break
                    }
                    "Direct" {
                        Set-Registry -Setting $Settings.Registry.Set; break
                    }
                    default {
                        Write-Verbose -Message "Skip registry."
                        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Registry"; Value = "Skipped"; Result = 0 })
                    }
                }

                switch ($Settings.StartMenu.Type) {
                    "Server" {
                        if ((Get-WindowsFeature -Name $Settings.StartMenu.Feature).InstallState -eq "Installed") {
                            Copy-File -Path $Settings.StartMenu.Exists -Parent $WorkingPath
                        }
                        else {
                            Copy-File -Path $Settings.StartMenu.NotExists -Parent $WorkingPath
                        }
                    }
                    "Client" {
                        Copy-File -Path $Settings.StartMenu.$OSName -Parent $WorkingPath
                    }
                }

                Copy-File -Path $Settings.Files.Copy -Parent $WorkingPath
                Remove-Path -Path $Settings.Paths.Remove
                Remove-Feature -Feature $Settings.Features.Disable
                Remove-Capability -Capability $Settings.Capabilities.Remove
                Remove-Package -Package $Settings.Packages.Remove
            }
            else {
                Write-Verbose -Message "Skip maximum version config: $($Config.FullName)."
                Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = $Config.FullName; Value = "Skipped maximum version"; Result = 0 })
            }
        }
        else {
            Write-Verbose -Message "Skip minimum version config: $($Config.FullName)."
            Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = $Config.FullName; Value = "Skipped minimum version"; Result = 0 })
        }
    }
    #endregion

    # If on a client OS, run the script to remove AppX; UWP apps
    if ($Platform -eq "Client") {

        # Get the script location
        $Script = Get-ChildItem -Path $WorkingPath -Filter "Remove-AppxApps.ps1" -Recurse -ErrorAction "Continue"
        if ($Null -eq $Script) {
            $Object = ([PSCustomObject]@{Name = "Remove-AppxApps.ps1"; Value = "Script not found"; Result = 1 })
            Write-ToEventLog -Property "AppX" -Object $Object
        }
        else {
            Write-ToEventLog -Property "AppX" -Object ([PSCustomObject]@{Name = "Run script"; Value = $Script.FullName; Result = 0 })
            switch ($AppxMode) {
                "Block" { $Apps = & $Script.FullName -Operation "BlockList"; break }
                "Allow" { $Apps = & $Script.FullName -Operation "AllowList"; break }
            }
            $RemovedApps = $Apps | Where-Object { $_.Value -eq "Removed" }
            $Object = ([PSCustomObject]@{Name = "Remove-AppxApps.ps1"; Value = $RemovedApps.Name; Result = 0 })
            Write-ToEventLog -Property "AppX" -Object $Object
        }

        # Set language support
        if ($Language -eq "Skip") {
            Write-Verbose -Message "Skip install language support."
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Install language"; Value = "Skipped"; Result = 0})
        }
        else {
            try {
                $params = @{
                    Language        = $Language
                    CopyToSettings  = $True
                    ExcludeFeatures = $False
                }
                Write-Verbose -Message "Install language: $Language."
                $Msg = "Success"; $Result = 0
                Install-Language @params | Out-Null
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Install language: $Language"; Value = $Msg; Result = $Result })
            try {
                $params = @{
                    Language = $Language
                    PassThru = $False
                }
                Write-Verbose -Message "Set system language: $Language."
                $Msg = "Success"; $Result = 0
                Set-SystemPreferredUILanguage @params
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set system language: $Language"; Value = $Msg; Result = $Result })
        }
    }
}
catch {
    # Write last entry to the event log and output failure
    $Object = ([PSCustomObject]@{Name = "Result"; Value = $_.Exception.Message; Result = 1 })
    Write-ToEventLog -Property "General" -Object $Object
    return 1
}

try {
    # Copy the source files for use with upgrades
    $FeaturePath = "$env:ProgramData\FeatureUpdates\image-customise"
    if ($FeaturePath -eq $WorkingPath) {
        $Object = ([PSCustomObject]@{Name = "Result"; Value = "Skipping file copy"; Result = 1 })
        Write-ToEventLog -Property "General" -Object $Object
    }
    else {
        New-Item -Path $FeaturePath -ItemType "Directory" -Force -ErrorAction "Continue" | Out-Null
        Copy-Item -Path "$WorkingPath\*.*" -Destination $FeaturePath -Recurse -ErrorAction "SilentlyContinue"
    }
}
catch {
    $Object = ([PSCustomObject]@{Name = "Result"; Value = $_.Exception.Message; Result = 1 })
    Write-ToEventLog -Property "General" -Object $Object
    return 1
}

# Set uninstall registry value for detecting as an installed application
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
New-Item -Path "$Key\{$Guid}" -Type "RegistryKey" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayName" -Value $Project -Type "String" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "Publisher" -Value $Publisher -Type "String" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayVersion" -Value $DisplayVersion -Type "String" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "RunOn" -Value $RunOn -Type "String" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "SystemComponent" -Value 1 -Type "DWord" -Force -ErrorAction "Continue" | Out-Null
Set-ItemProperty -Path "$Key\{$Guid}" -Name "HelpLink" -Value $HelpLink -Type "String" -Force -ErrorAction "Continue" | Out-Null

# Write last entry to the event log and output success
$Object = ([PSCustomObject]@{Name = "Install-Defaults.ps1"; Value = "Success"; Result = 0 })
Write-ToEventLog -Property "General" -Object $Object
return 0
