<#
    Functions used by Install-Defaults.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()

function New-ScriptEventLog {
    # Create the custom event log used to record events
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($EventLog, $Property)
    $params = @{
        LogName     = $EventLog
        Source      = $Property
        ErrorAction = "SilentlyContinue"
    }
    if ($PSCmdlet.ShouldProcess($EventLog, "New-EventLog")) {
        New-EventLog @params
    }
}

function Write-ToEventLog {
    # Write an entry to the custom event log
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter()]$Property,
        [Parameter()]
        [ValidateNotNullOrEmpty()] $Object
    )
    foreach ($Item in $Object) {

        Write-Verbose -Message "$($Item.Name), $($Item.Value), $($Item.Result)"
        switch ($Item.Result) {
            0 { $EntryType = "Information" }
            1 { $EntryType = "Warning" }
            default { $EntryType = "Information" }
        }
        $params = @{
            LogName     = "Customised Defaults"
            Source      = $Property
            EventID     = (100 + [System.Int16]$Item.Result)
            EntryType   = $EntryType
            Message     = "$($Item.Name), $($Item.Value), $($Item.Result)"
            ErrorAction = "Continue"
        }
        if ($PSCmdlet.ShouldProcess("Customised Defaults", "Write-EventLog")) {
            Write-EventLog @params
        }
    }
}

function Get-Platform {
    # Return platform we are running on - client or server
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
    # Return the OS name string
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
    # Return details of the hardware model we are running on
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
    # Return a JSON object from the text/JSON file passed
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
    # Change the owner on the specified registry path
    # Links: https://stackoverflow.com/questions/12044432/how-do-i-take-ownership-of-a-registry-key-via-powershell
    # "S-1-5-32-544" - Administrators
    [CmdletBinding(SupportsShouldProcess = $true)]
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
            [CmdletBinding(SupportsShouldProcess = $true)]
            param($RootKey, $Key, $Sid, $Recurse, $RecurseLevel = 0)

            ### Step 2 - get ownerships of key - it works only for current key
            $RegKey = [Microsoft.Win32.Registry]::$RootKey.OpenSubKey($Key, "ReadWriteSubTree", "TakeOwnership")
            $Acl = New-Object -TypeName "System.Security.AccessControl.RegistrySecurity"
            if ($PSCmdlet.ShouldProcess($Sid, "SetOwner")) {
                $Acl.SetOwner($Sid)
            }
            if ($PSCmdlet.ShouldProcess($RegKey, "SetAccessControl")) {
                $RegKey.SetAccessControl($Acl)
            }

            ### Step 3 - enable inheritance of permissions (not ownership) for current key from parent
            if ($PSCmdlet.ShouldProcess("ACL", "SetAccessRuleProtection")) {
                $Acl.SetAccessRuleProtection($false, $false)
            }
            if ($PSCmdlet.ShouldProcess($RegKey, "SetAccessControl")) {
                $RegKey.SetAccessControl($Acl)
            }

            ### Step 4 - only for top-level key, change permissions for current key and propagate it for subkeys
            # to enable propagations for subkeys, it needs to execute Steps 2-3 for each subkey (Step 5)
            if ($RecurseLevel -eq 0) {
                $RegKey = $RegKey.OpenSubKey("", "ReadWriteSubTree", "ChangePermissions")
                $Rule = New-Object -TypeName System.Security.AccessControl.RegistryAccessRule($Sid, "FullControl", "ContainerInherit", "None", "Allow")
                if ($PSCmdlet.ShouldProcess("ACL", "ResetAccessRule")) {
                    $Acl.ResetAccessRule($Rule)
                }
                if ($PSCmdlet.ShouldProcess($RegKey, "SetAccessControl")) {
                    $RegKey.SetAccessControl($Acl)
                }
            }

            ### Step 5 - recursively repeat steps 2-5 for subkeys
            if ($Recurse) {
                foreach ($SubKey in $RegKey.OpenSubKey("").GetSubKeyNames()) {
                    Set-RegistryKeyOwner -RootKey $RootKey -Key ($Key + "\" + $SubKey) -Sid $Sid -Recurse $Recurse -RecurseLevel ($RecurseLevel + 1)
                }
            }
        }

        Set-RegistryKeyOwner -RootKey $RootKey -Key $Key -Sid $Sid -Recurse $Recurse
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Set-RegistryOwner: $RootKey, $Key"; Value = $Sid; Result = 0 })
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Set-RegistryOwner: $RootKey, $Key, $Sid"; Value = $Msg; Result = 1 })
    }
}

function Set-Registry {
    # Set a registry value. Create the target key if it doesn't already exist
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Setting)

    foreach ($Item in $Setting) {
        if (-not(Test-Path -Path $Item.path)) {
            try {
                if ($PSCmdlet.ShouldProcess($RegPath, "New-Item")) {
                    $params = @{
                        Path        = $Item.path
                        Type        = "RegistryKey"
                        Force       = $true
                        ErrorAction = "SilentlyContinue"
                    }
                    $ItemResult = New-Item @params
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "New-Item"; Value = $Item.path; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "New-Item: $($Item.path)"; Value = $Msg; Result = 1 })
            }
            finally {
                if ("Handle" -in ($ItemResult | Get-Member | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
            }
        }

        try {
            if ($PSCmdlet.ShouldProcess("$($Item.path), $($Item.name), $($Item.value)", "Set-ItemProperty")) {
                $params = @{
                    Path        = $Item.path
                    Name        = $Item.name
                    Value       = $Item.value
                    Type        = $Item.type
                    Force       = $true
                    ErrorAction = "Continue"
                }
                Set-ItemProperty @params > $null
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$($Item.path); $($Item.name)"; Value = $Item.value; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$($Item.path); $($Item.name); $($Item.value)"; Value = $Msg; Result = 1 })
        }
    }
}

function Set-DefaultUserProfile {
    # Add settings into the default profile
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Setting)
    try {
        # Variables
        $RegDefaultUser = "$env:SystemDrive\Users\Default\NTUSER.DAT"
        $DefaultUserPath = "HKLM:\MountDefaultUser"

        try {
            if ($PSCmdlet.ShouldProcess("reg load $RegPath $RegDefaultUser", "Start-Process")) {
                # Load registry hive
                $RegPath = $DefaultUserPath -replace ":", ""
                $params = @{
                    FilePath     = "reg"
                    ArgumentList = "load $RegPath $RegDefaultUser"
                    Wait         = $true
                    PassThru     = $true
                    WindowStyle  = "Hidden"
                    ErrorAction  = "Continue"
                }
                $Result = Start-Process @params | Out-Null
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Load: $RegDefaultUser"; Value = $RegPath; Result = $Result })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Load: $RegDefaultUser, $RegPath"; Value = $MSg; Result = 1 })
            throw $_
        }

        # Process Registry Commands
        foreach ($Item in $Setting) {
            $RegPath = $Item.path -replace "HKCU:", $DefaultUserPath
            if (-not(Test-Path -Path $RegPath)) {
                try {
                    if ($PSCmdlet.ShouldProcess($RegPath, "New-Item")) {
                        $params = @{
                            Path        = $RegPath
                            Type        = "RegistryKey"
                            Force       = $true
                            ErrorAction = "Continue"
                        }
                        $ItemResult = New-Item @params
                        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "New-Item"; Value = $RegPath; Result = 0 })
                    }
                }
                catch {
                    $Msg = $_.Exception.Message
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "New-Item: $RegPath"; Value = $Msg; Result = 1 })
                }
                finally {
                    if ($null -ne $ItemResult) {
                        if ("Handle" -in ($ItemResult | Get-Member -ErrorAction "SilentlyContinue" | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
                    }
                }
            }

            try {
                if ($PSCmdlet.ShouldProcess("$RegPath, $($Item.name), $($Item.value)", "Set-ItemProperty")) {
                    $params = @{
                        Path        = $RegPath
                        Name        = $Item.name
                        Value       = $Item.value
                        Type        = $Item.type
                        Force       = $true
                        ErrorAction = "Continue"
                    }
                    Set-ItemProperty @params > $null
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$RegPath; $($Item.name)"; Value = $Item.value; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$RegPath; $($Item.name); $($Item.value)"; Value = $Msg; Result = 1 })
            }
        }
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "General"; Value = $Msg; Result = 1 })
    }
    finally {
        try {
            if ($PSCmdlet.ShouldProcess("reg unload $($DefaultUserPath -replace ':', '')", "Start-Process")) {
                # Unload Registry Hive
                [gc]::Collect()
                $params = @{
                    FilePath     = "reg"
                    ArgumentList = "unload $($DefaultUserPath -replace ':', '')"
                    Wait         = $true
                    WindowStyle  = "Hidden"
                    ErrorAction  = "Continue"
                }
                Start-Process @params > $null
                Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Unload"; Value = $RegDefaultUser; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Unload: $RegDefaultUser"; Value = $Msg; Result = 1 })
        }
    }
}

function Copy-File {
    # Copy a file from source to destination. Create the destination directory if it doesn't exist
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path, $Parent)
    foreach ($Item in $Path) {
        $Source = $(Join-Path -Path $Parent -ChildPath $Item.Source)
        Write-Verbose -Message "Source: $Source."
        Write-Verbose -Message "Destination: $($Item.Destination)."
        if (Test-Path -Path $Source -ErrorAction "Continue") {
            New-Directory -Path $(Split-Path -Path $Item.Destination -Parent)
            try {
                if ($PSCmdlet.ShouldProcess("$Source to $($Item.Destination)", "Copy-Item")) {
                    $params = @{
                        Path        = $Source
                        Destination = $Item.Destination
                        Confirm     = $false
                        Force       = $true
                        ErrorAction = "Continue"
                    }
                    Copy-Item @params
                    Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "Copy: $Source"; Value = $Item.Destination; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Item.Destination; Value = $Msg; Result = 1 })
            }
        }
        else {
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Source; Value = "Does not exist"; Result = 1 })
        }
    }
}

function New-Directory {
    # Create a new directory
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)
    if (Test-Path -Path $Path -ErrorAction "Continue") {
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = "Exists"; Result = 0 })
    }
    else {
        try {
            if ($PSCmdlet.ShouldProcess($Path, "New-Item")) {
                $params = @{
                    Path        = $Path
                    ItemType    = "Directory"
                    ErrorAction = "Continue"
                }
                New-Item @params > $null
                Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "New-Item"; Value = $Path; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "New-Item: $Path"; Value = $Msg; Result = 1 })
        }
    }
}

function Remove-Path {
    # Recursively remove a specific path
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)
    foreach ($Item in $Path) {
        if (Test-Path -Path $Item -ErrorAction "Continue") {
            try {
                if ($PSCmdlet.ShouldProcess($Item, "Remove-Item")) {
                    $params = @{
                        Path        = $Item
                        Recurse     = $true
                        Confirm     = $false
                        Force       = $true
                        ErrorAction = "Continue"
                    }
                    Remove-Item @params
                    Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "Remove-Item"; Value = $Path; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "Remove-Item: $Path"; Value = $Msg; Result = 1 })
            }
        }
    }
}

function Remove-Feature {
    # Remove a Windows feature
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Feature)

    if ($Feature.Count -ge 1) {
        Write-Verbose -Message "Remove features."
        $Feature | ForEach-Object { Get-WindowsOptionalFeature -Online -FeatureName $_ -ErrorAction "Continue" } | `
            ForEach-Object {
            try {
                if ($PSCmdlet.ShouldProcess($_.FeatureName, "Disable-WindowsOptionalFeature")) {
                    $params = @{
                        FeatureName = $_.FeatureName
                        Online      = $true
                        NoRestart   = $true
                        ErrorAction = "Continue"
                    }
                    Disable-WindowsOptionalFeature @params | Out-Null
                    Write-ToEventLog -Property "Features" -Object ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature"; Value = $_.FeatureName; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Features" -Object ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature; $($_.FeatureName)"; Value = $Msg; Result = 1 })
            }
        }
    }
}

function Remove-Capability {
    # Remove a Windows capability
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Capability)

    if ($Capability.Count -ge 1) {
        Write-Verbose -Message "Remove capabilities."
        foreach ($Item in $Capability) {
            try {
                if ($PSCmdlet.ShouldProcess($Item, "Remove-WindowsCapability")) {
                    $params = @{
                        Name        = $Item
                        Online      = $true
                        ErrorAction = "Continue"
                    }
                    Remove-WindowsCapability @params | Out-Null
                    Write-ToEventLog -Property "Capabilities" -Object ([PSCustomObject]@{Name = "Remove-WindowsCapability"; Value = $Item; Result = 0 })
                }
            }
            catch {
                $Msg = $_.Exception.Message
                Write-ToEventLog -Property "Capabilities" -Object ([PSCustomObject]@{Name = "Remove-WindowsCapability; $Item"; Value = $Msg; Result = 1 })
            }
        }
    }
}

function Remove-Package {
    # Remove AppX packages
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Package)

    if ($Package.Count -ge 1) {
        Write-Verbose -Message "Remove packages."
        foreach ($Item in $Package) {
            Get-WindowsPackage -Online -ErrorAction "Continue" | Where-Object { $_.PackageName -match $Item } | `
                ForEach-Object {
                try {
                    if ($PSCmdlet.ShouldProcess($_.PackageName, "Remove-WindowsPackage")) {
                        $params = @{
                            PackageName = $_.PackageName
                            Online      = $true
                            ErrorAction = "Continue"
                        }
                        Remove-WindowsPackage @params | Out-Null
                        Write-ToEventLog -Property "Packages" -Object ([PSCustomObject]@{Name = "Remove-WindowsPackage"; Value = $Item; Result = 0 })
                    }
                }
                catch {
                    $Msg = $_.Exception.Message
                    Write-ToEventLog -Property "Packages" -Object ([PSCustomObject]@{Name = "Remove-WindowsPackage: $Item;"; Value = $Msg; Result = 1 })
                }
            }
        }
    }
}

function Get-CurrentUserSid {
    # Set the SID of the current user
    $MyID = New-Object -TypeName System.Security.Principal.NTAccount([Environment]::UserName)
    return $MyID.Translate([System.Security.Principal.SecurityIdentifier]).toString()
}

function Restart-NamedService {
    # Restart a specified service
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            if ($PSCmdlet.ShouldProcess($Item, "Restart-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Restart-Service -Force
                Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Restart-Service"; Value = $Item; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Restart service: $Item;"; Value = $Msg; Result = 0 })
        }
    }
}

function Start-NamedService {
    # Start a specified service
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            if ($PSCmdlet.ShouldProcess($Item, "Start-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Start-Service
                Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Start-Service"; Value = $Item; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Start service: $Item"; Value = $Msg; Result = 1 })
        }
    }
}

function Stop-NamedService {
    # Stop a named service
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            if ($PSCmdlet.ShouldProcess($Item, "Stop-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Stop-Service -Force
                Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Stop-Service"; Value = $Item; Result = 0 })
            }
        }
        catch {
            $Msg = $_.Exception.Message
            Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Stop service: $Item"; Value = $Msg; Result = 1 })
        }
    }
}

function Install-SystemLanguage {
    # Use LanguagePackManagement to install a specific language and set as default
    # Requires minimum number of Windows 10 or 11
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Language)

    try {
        if ($PSCmdlet.ShouldProcess("LanguagePackManagement", "Import-Module")) {
            Import-Module -Name "LanguagePackManagement"
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Import module LanguagePackManagement"; Value = "Success"; Result = 0 })
        }
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Import module LanguagePackManagement"; Value = $Msg; Result = 1 })
    }

    try {
        if ($PSCmdlet.ShouldProcess($Language, "Install-Language")) {
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Language pack install"; Value = "Start"; Result = 0 })
            $params = @{
                Language        = $Language
                CopyToSettings  = $true
                ExcludeFeatures = $false
            }
            Install-Language @params | Out-Null
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Install language pack: $Language"; Value = $Msg; Result = 0 })
        }
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Install language pack: $Language"; Value = $Msg; Result = 1 })
    }
}

function Set-SystemLocale {
    # Set system locale and regional settings
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([System.Globalization.CultureInfo] $Language)
    try {
        if ($PSCmdlet.ShouldProcess($Language, "Set locale")) {
            Import-Module -Name "International"
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Import module"; Value = "International"; Result = 0 })

            Set-Culture -CultureInfo $Language
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-Culture"; Value = $Language.Name; Result = 0 })

            Set-WinSystemLocale -SystemLocale $Language
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-WinSystemLocale"; Value = $Language.Name; Result = 0 })

            Set-WinUILanguageOverride -Language $Language
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-WinUILanguageOverride"; Value = $Language.Name; Result = 0 })

            Set-WinUserLanguageList -LanguageList $Language.Name -Force
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-WinUserLanguageList"; Value = $Language.Name; Result = 0 })

            $RegionInfo = New-Object -TypeName "System.Globalization.RegionInfo" -ArgumentList $Language
            Set-WinHomeLocation -GeoId $RegionInfo.GeoId
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-WinHomeLocation"; Value = $RegionInfo.GeoId; Result = 0 })

            if (Get-Command -Name "Set-SystemPreferredUILanguage" -ErrorAction "SilentlyContinue") {
                # Cmdlet not available on Windows Server
                Set-SystemPreferredUILanguage -Language $Language
                Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set-SystemPreferredUILanguage: $Language.Name"; Value = $Msg; Result = 0 })
            }
            Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set system locale: $($Language.Name)"; Value = "Success"; Result = 0 })
        }
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Set system locale: $($Language.Name)"; Value = $Msg; Result = 1 })
    }
}

function Set-TimeZoneUsingName {
    # Set the time zone using a valid time zone name
    # https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([System.String] $TimeZone = "AUS Eastern Standard Time")
    try {
        if ($PSCmdlet.ShouldProcess($TimeZone, "Set-TimeZone")) {
            Set-TimeZone -Name $TimeZone
            Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Set time zone"; Value = $TimeZone; Result = 0 })
        }
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Set time zone: $TimeZone"; Value = $Msg; Result = 1 })
    }
}
