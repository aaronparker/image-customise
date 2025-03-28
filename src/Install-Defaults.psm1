using namespace System.Management.Automation
<#
    Functions used by Install-Defaults.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()

function Write-Msg {
    [CmdletBinding()]
    param(
        [System.String] $Message
    )
    process {
        $Msg = [HostInformationMessage]@{
            Message         = "[$(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')]"
            ForegroundColor = "Black"
            BackgroundColor = "DarkCyan"
            NoNewline       = $true
        }
        $params = @{
            MessageData       = $Msg
            InformationAction = "Continue"
            Tags              = "Microsoft365"
        }
        Write-Information @params
        $params = @{
            MessageData       = " $Message"
            InformationAction = "Continue"
            Tags              = "Microsoft365"
        }
        Write-Information @params
    }
}

function Write-LogFile {
    <#
        .SYNOPSIS
            This function creates or appends a line to a log file

        .DESCRIPTION
            This function writes a log line to a log file in the form synonymous with
            ConfigMgr logs so that tools such as CMtrace and SMStrace can easily parse
            the log file.  It uses the ConfigMgr client log format's file section
            to add the line of the script in which it was called.

        .PARAMETER  Message
            The message parameter is the log message you'd like to record to the log file

        .PARAMETER  LogLevel
            The logging level is the severity rating for the message you're recording. Like ConfigMgr
            clients, you have 3 severity levels available; 1, 2 and 3 from informational messages
            for FYI to critical messages that stop the install. This defaults to 1.

        .EXAMPLE
            PS C:\> Write-LogFile -Message 'Value1' -LogLevel 'Value2'
            This example shows how to call the Write-LogFile function with named parameters.

        .NOTES
            Constantin Lotz;
            Adam Bertram, https://github.com/adbertram/PowerShellTipsToWriteBy/blob/f865c4212284dc25fe613ca70d9a4bafb6c7e0fe/chapter_7.ps1#L5
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true)]
        [System.String[]] $Message,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet(1, 2, 3)]
        [System.Int16] $LogLevel = 1
    )

    begin {
        if (Test-Path -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs") {
            # If we're running under Intune, put the log file in the IntuneManagementExtension folder
            $LogFile = "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\CustomisedDefaults.log"
        }
        else {
            # Otherwise, put the log file in the $Env:SystemRoot\Logs\image-customise folder
            $Path = "$Env:SystemRoot\Logs\image-customise"
            $LogFile = "$Path\CustomisedDefaults.log"
            if (-not(Test-Path -Path $Path)) {
                New-Item -Path $Path -ItemType "Directory" -Force | Out-Null
            }
        }
    }

    process {
        foreach ($Msg in $Message) {
            # Build the line which will be recorded to the log file
            $TimeGenerated = $(Get-Date -Format "HH:mm:ss.ffffff")
            $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
            $Thread = $([Threading.Thread]::CurrentThread.ManagedThreadId)
            $LineFormat = $Msg, $TimeGenerated, (Get-Date -Format "yyyy-MM-dd"), "$($MyInvocation.ScriptName | Split-Path -Leaf -ErrorAction "SilentlyContinue"):$($MyInvocation.ScriptLineNumber)", $Context, $LogLevel, $Thread
            $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="">' -f $LineFormat

            # Add content to the log file and output to the console
            Add-Content -Value $Line -Path $LogFile
            Write-Msg -Message $Msg

            # Write-Warning for log level 2 or 3
            if ($LogLevel -eq 3 -or $LogLevel -eq 2) {
                Write-Warning -Message "[$TimeGenerated] $Msg"
            }
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
    Write-LogFile -Message "Platform: $Platform"
    Write-Output -InputObject $Platform
}

function Get-OSName {
    # Return the OS name string
    switch -Regex ((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption) {
        "^Microsoft Windows Server 2025.*$" {
            $Caption = "Windows2025"; break
        }
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
    Write-LogFile -Message "OS Name: $Caption"
    Write-Output -InputObject $Caption
}

function Get-Model {
    # Return details of the hardware model we are running on
    $Hypervisor = "Parallels*|VMware*|Virtual*|HVM*"
    if ((Get-CimInstance -ClassName "Win32_ComputerSystem").Model -match $Hypervisor) {
        $Model = "Virtual"
    }
    else {
        $Model = "Physical"
    }
    Write-LogFile -Message "Model: $Model"
    Write-Output -InputObject $Model
}

function Get-SettingsContent ($Path) {
    # Return a JSON object from the text/JSON file passed
    try {
        $params = @{
            Path        = $Path
            ErrorAction = "Continue"
        }
        Write-LogFile -Message "Importing: $Path"
        $Settings = Get-Content @params | ConvertFrom-Json -ErrorAction "Stop"
    }
    catch {
        # If we have an error we won't get usable data
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
        Write-LogFile -Message "Set-RegistryOwner: $RootKey, $Key"
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                    Write-LogFile -Message "New registry path: $($Item.path)"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                Set-ItemProperty @params | Out-Null
                Write-LogFile -Message "Set registry property: $($Item.path); $($Item.name), $($Item.value)"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
        }
    }
}

function Remove-RegistryPath {
    # Set a registry value. Create the target key if it doesn't already exist
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)

    foreach ($Item in $Path) {
        try {
            if ($PSCmdlet.ShouldProcess($Item.path, "Remove-Item")) {
                $params = @{
                    Path        = $Item.path
                    Force       = $true
                    ErrorAction = "Continue"
                }
                Remove-Item @params | Out-Null
                Write-LogFile -Message "Remove registry path: $($Item.path)"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                $Result = Start-Process @params
                Write-LogFile -Message "Load default user: $RegPath"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                        Write-LogFile -Message "New registry path: $($Item.path)"
                    }
                }
                catch {
                    Write-LogFile -Message $_.Exception.Message -LogLevel 3
                }
                finally {
                    if ($null -ne $Result) {
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
                    Set-ItemProperty @params | Out-Null
                    Write-LogFile -Message "Set registry property: $($Item.path); $($Item.name) $($Item.value)"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
            }
        }
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                $Result = Start-Process @params
                Write-LogFile -Message "Unload default user: $DefaultUserPath"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
        }
    }
}

function Copy-File {
    # Copy a file from source to destination. Create the destination directory if it doesn't exist
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path, $Parent)
    foreach ($Item in $Path) {
        $Source = $(Join-Path -Path $Parent -ChildPath $Item.Source)
        Write-LogFile -Message "Source: $Source"
        Write-LogFile -Message "Destination: $($Item.Destination)"
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
                    Write-LogFile -Message "Copy file: $Source to $($Item.Destination)"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
            }
        }
        else {
        }
    }
}

function New-Directory {
    # Create a new directory
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Path)
    if (Test-Path -Path $Path -ErrorAction "Continue") {
        Write-LogFile -Message "Path exists: $Path"
    }
    else {
        try {
            if ($PSCmdlet.ShouldProcess($Path, "New-Item")) {
                $params = @{
                    Path        = $Path
                    ItemType    = "Directory"
                    ErrorAction = "Continue"
                }
                New-Item @params | Out-Null
                Write-LogFile -Message "New path: $Path"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                    Write-LogFile -Message "Remove path: $Path"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
            }
        }
    }
}

function Remove-Feature {
    # Remove a Windows feature
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Feature)

    if ($Feature.Count -ge 1) {
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
                    Write-LogFile -Message "Remove feature: $($_.FeatureName)"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
            }
        }
    }
}

function Remove-Capability {
    # Remove a Windows capability
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Capability)

    if ($Capability.Count -ge 1) {
        foreach ($Item in $Capability) {
            try {
                if ($PSCmdlet.ShouldProcess($Item, "Remove-WindowsCapability")) {
                    $params = @{
                        Name        = $Item
                        Online      = $true
                        ErrorAction = "Continue"
                    }
                    Remove-WindowsCapability @params | Out-Null
                    Write-LogFile -Message "Remove capability: $($Item)"
                }
            }
            catch {
                Write-LogFile -Message $_.Exception.Message -LogLevel 3
            }
        }
    }
}

function Remove-Package {
    # Remove AppX packages
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ($Package)

    if ($Package.Count -ge 1) {
        Write-LogFile -Message "Remove packages"
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
                        Write-LogFile -Message "Remove package: $($_.PackageName)"
                    }
                }
                catch {
                    Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                Write-LogFile -Message "Restart service: $Item"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                Get-Service -Name $Item -ErrorAction "Ignore" | Start-Service -ErrorAction "Ignore"
                Write-LogFile -Message "Start service: $Item"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
                Get-Service -Name $Item -ErrorAction "Ignore" | Stop-Service -Force -ErrorAction "Ignore"
                Write-LogFile -Message "Stop service: $Item"
            }
        }
        catch {
            Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
            Write-LogFile -Message "Import module: LanguagePackManagement"
            Import-Module -Name "LanguagePackManagement"
        }
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
    }

    try {
        if ($PSCmdlet.ShouldProcess($Language, "Install-Language")) {
            Write-LogFile -Message "Language pack install: $Language"
            $params = @{
                Language        = $Language
                CopyToSettings  = $true
                ExcludeFeatures = $false
            }
            Install-Language @params | Out-Null
        }
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
    }
}

function Set-SystemLocale {
    # Set system locale and regional settings
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([System.Globalization.CultureInfo] $Language)
    try {
        if ($PSCmdlet.ShouldProcess($Language, "Set locale")) {
            Write-LogFile -Message "Import module: International"
            Import-Module -Name "International"

            Write-LogFile -Message "Set-Culture: $($Language.Name)"
            Set-Culture -CultureInfo $Language

            Write-LogFile -Message "Set-WinSystemLocale: $($Language.Name)"
            Set-WinSystemLocale -SystemLocale $Language

            Write-LogFile -Message "Set-WinUILanguageOverride: $($Language.Name)"
            Set-WinUILanguageOverride -Language $Language

            Write-LogFile -Message "Set-WinUserLanguageList: $($Language.Name)"
            Set-WinUserLanguageList -LanguageList $Language.Name -Force

            $RegionInfo = New-Object -TypeName "System.Globalization.RegionInfo" -ArgumentList $Language
            Write-LogFile -Message "Set-WinHomeLocation: $($RegionInfo.GeoId)"
            Set-WinHomeLocation -GeoId $RegionInfo.GeoId

            # Cmdlet not available on Windows Server 2022 or below
            if (Get-Command -Name "Set-SystemPreferredUILanguage" -ErrorAction "SilentlyContinue") {
                Write-LogFile -Message "Set-SystemPreferredUILanguage: $($Language.Name)"
                Set-SystemPreferredUILanguage -Language $Language
            }

            # Cmdlet not available on Windows Server 2022 or below
            if (Get-Command -Name "Copy-UserInternationalSettingsToSystem" -ErrorAction "SilentlyContinue") {
                Write-LogFile -Message "Copy locale settings to system: $($Language.Name)"
                Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
            }
        }
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
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
            Write-LogFile -Message "Set-TimeZone: $($TimeZone)"
        }
    }
    catch {
        Write-LogFile -Message $_.Exception.Message -LogLevel 3
    }
}

function Get-IsOobeComplete {
    # https://oofhours.com/2023/09/15/detecting-when-you-are-in-oobe/
    $TypeDef = @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
namespace Api {
    public class Kernel32 {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int OOBEComplete(ref int bIsOOBEComplete);
    }
}
"@

    Add-Type -TypeDefinition $TypeDef -Language "CSharp"
    $IsOOBEComplete = $false
    [Void][Api.Kernel32]::OOBEComplete([ref] $IsOOBEComplete)
    return [System.Boolean]$IsOOBEComplete
}
