<#
    Functions used by Install-Defaults.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()

function New-ScriptEventLog {
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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Property, $Object)
    foreach ($Item in $Object) {
        if ($Item.Value.Length -gt 0) {
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
        $Msg = "Success"; $Result = 0
    }
    catch {
        $Msg = $_.Exception.Message; $Result = 1
    }
    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Set-RegistryOwner: $RootKey, $Key, $Sid"; Value = $Msg; Result = $Result })
}

function Set-Registry {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Setting)

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
                if ($PSCmdlet.ShouldProcess($RegPath, "New-Item")) {
                    $ItemResult = New-Item @params
                }
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
            if ($PSCmdlet.ShouldProcess("$($Item.path), $($Item.name), $($Item.value)", "Set-ItemProperty")) {
                Set-ItemProperty @params > $Null
            }
            $Msg = "SetValue"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-Verbose -Message "Set value: $($Item.path); $($Item.name); $($Item.value); Result: $Result"
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "$($Item.path); $($Item.name); $($Item.value)"; Value = $Msg; Result = $Result })
    }
}

function Set-DefaultUserProfile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Setting)
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
            if ($PSCmdlet.ShouldProcess("reg load $RegPath $RegDefaultUser", "Start-Process")) {
                $result = Start-Process @params > $Null
            }
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
                    if ($PSCmdlet.ShouldProcess($RegPath, "New-Item")) {
                        $ItemResult = New-Item @params
                    }
                    $Msg = "CreatePath"; $Result = 0
                }
                catch {
                    $Msg = $_.Exception.Message; $Result = 1
                }
                finally {
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = $Item.path; Value = $Msg; Result = $Result })
                    if ($Null -ne $ItemResult) {
                        if ("Handle" -in ($ItemResult | Get-Member -ErrorAction "SilentlyContinue" | Select-Object -ExpandProperty "Name")) { $ItemResult.Handle.Close() }
                    }
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
                if ($PSCmdlet.ShouldProcess("$RegPath, $($Item.name), $($Item.value)", "Set-ItemProperty")) {
                    Set-ItemProperty @params > $Null
                }
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
            if ($PSCmdlet.ShouldProcess("reg unload $($DefaultUserPath -replace ':', '')", "Start-Process")) {
                Start-Process @params > $Null
            }
            $Msg = "Success"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-Verbose -Message "Unload: $RegDefaultUser. Result: $Result"
        Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Unload: $RegDefaultUser"; Value = $Msg; Result = $Result })
    }
}

function Copy-File {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path, $Parent)
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
                if ($PSCmdlet.ShouldProcess("$Source to $($Item.Destination)", "Copy-Item")) {
                    Copy-Item @params
                }
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

function New-Directory {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)
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
            if ($PSCmdlet.ShouldProcess($Path, "New-Item")) {
                New-Item @params > $Null
            }
            $Msg = "CreatePath"; $Result = 0
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = $Msg; Result = $Result })
    }
}

function Remove-Path {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)
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
                if ($PSCmdlet.ShouldProcess($Item, "Remove-Item")) {
                    Remove-Item @params
                }
                $Msg = "RemovePath"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = $Path; Value = $Msg; Result = $Result })
        }
    }
}

function Remove-Feature {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Feature)

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
                if ($PSCmdlet.ShouldProcess($_.FeatureName, "Disable-WindowsOptionalFeature")) {
                    Disable-WindowsOptionalFeature @params | Out-Null
                }
                $Msg = "RemoveFeature"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Features" -Object ([PSCustomObject]@{Name = "Disable-WindowsOptionalFeature; $($_.FeatureName)"; Value = $Msg; Result = $Result })
        }
    }
}

function Remove-Capability {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Capability)

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
                if ($PSCmdlet.ShouldProcess($Item, "Remove-WindowsCapability")) {
                    Remove-WindowsCapability @params | Out-Null
                }
                $Msg = "RemoveCapability"; $Result = 0
            }
            catch {
                $Msg = $_.Exception.Message; $Result = 1
            }
            Write-ToEventLog -Property "Capabilities" -Object ([PSCustomObject]@{Name = "Remove-WindowsCapability; $Item"; Value = $Msg; Result = $Result })
        }
    }
}

function Remove-Package {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Package)

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
                    if ($PSCmdlet.ShouldProcess($_.PackageName, "Remove-WindowsPackage")) {
                        Remove-WindowsPackage @params | Out-Null
                    }
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

function Get-CurrentUserSid {
    $MyID = New-Object -TypeName System.Security.Principal.NTAccount([Environment]::UserName)
    return $MyID.Translate([System.Security.Principal.SecurityIdentifier]).toString()
}

function Restart-ServiceName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            $Msg = "Success"; $Result = 0
            if ($PSCmdlet.ShouldProcess($Item, "Start-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Restart-Service -Force
            }
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Restart service: $Item;"; Value = $Msg; Result = $Result })
    }
}

function Start-ServiceName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            $Msg = "Success"; $Result = 0
            if ($PSCmdlet.ShouldProcess($Item, "Start-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Start-Service -Force
            }
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Start service: $Item;"; Value = $Msg; Result = $Result })
    }
}

function Stop-ServiceName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Service)

    foreach ($Item in $Service) {
        try {
            $Msg = "Success"; $Result = 0
            if ($PSCmdlet.ShouldProcess($Item, "Start-Service")) {
                Get-Service -Name $Item -ErrorAction "Ignore" | Stop-Service -Force
            }
        }
        catch {
            $Msg = $_.Exception.Message; $Result = 1
        }
        Write-ToEventLog -Property "Services" -Object ([PSCustomObject]@{Name = "Stop service: $Item;"; Value = $Msg; Result = $Result })
    }
}
