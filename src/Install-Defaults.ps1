#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
    .SYNOPSIS
    Implements Configuration changes to a default install of Windows to enable an enterprise ready installation.

    .PARAMETER Path
    Path to where the scripts and configuration files are located.

    .PARAMETER Guid
    A GUID string that identifies the solution installation for detection via the Uninstall key in the Windows registry.

    .PARAMETER Publisher
    String that represents the publisher information that will be stored in the Uninstall key in the Windows registry.

    .PARAMETER RunOn
    Date time stamp that will be stored in the Uninstall key in the Windows registry.

    .PARAMETER Project
    A string that defines the name for the solution. This string will be used for the custom event log to track the installation and stored in the Windows registry.

    .PARAMETER Helplink
    A string that defines a URL for the solution. This string will be written to the Uninstall key in the Windows registry.

    .PARAMETER Properties
    An array of string values used for source categories in the Windows event log.

    .PARAMETER AppxMode
    A string that defines the mode to remove AppX packages from Windows. Accepts 'Block' or 'Allow' - Block removes a defined list of packages. Allow removes all packages except for a defined list.

    .PARAMETER FeatureUpdatePath
    A directory path in which the solution will be copied into to enable running during Windows feature updates.

    .PARAMETER Language
    A CultureInfo value that defines the locale / language configuration to install and configure for Windows.

    .PARAMETER TimeZone
    A string that is the StandardName or DaylightName properties of the TimeZoneInfo object. Use 'Get-TimeZone -ListAvailable' to list available time zones.

    .EXAMPLE
    PS C:\image-defaults> .\Install-Defaults.ps1 -Language "en-AU" -TimeZone "AUS Eastern Standard Time" -Verbose

    .NOTES
    NAME: Install-Defaults.ps1
    AUTHOR: Aaron Parker
    TWITTER: @stealthpuppy
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Path = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Publisher = "stealthpuppy",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $RunOn = $(Get-Date -Format "yyyy-MM-dd"),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Project = "Customised Defaults",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Helplink = "https://stealthpuppy.com/image-customise/",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String[]] $Properties = @("General", "Registry", "Paths", "StartMenu", "Features", "Capabilities", "Packages", "AppX", "Language", "Services"),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $AppxMode = "Block",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $FeatureUpdatePath = "$env:SystemRoot\System32\Update\Run\$Guid",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.Globalization.CultureInfo] $Language,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $TimeZone
)

#region Restart if running in a 32-bit session
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {

        # Create a string from the passed parameters
        [System.String]$ParameterString = ""
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            $ParameterString += " -$($Parameter.Key) $($Parameter.Value)"
        }

        # Execute the script in a 64-bit process with the passed parameters
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`"$ParameterString"
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell."
        Write-Verbose -Message "File path: $ProcessPath."
        Write-Verbose -Message "Arguments: $Arguments."
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $true
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
    }
}
#endregion

# Get start time of the script
$StartTime = Get-Date

# Splat WhatIf and Verbose preferences to pass to functions
$prefs = @{
    WhatIf  = $WhatIfPreference
    Verbose = $VerbosePreference
}

# Configure working path
if ($Path.Length -eq 0) { $WorkingPath = $PWD.Path } else { $WorkingPath = $Path }
Push-Location -Path $WorkingPath
Write-Verbose -Message "Execution path: $WorkingPath."

#region Import functions
try {
    $ModuleFile = $(Join-Path -Path $PSScriptRoot -ChildPath "Install-Defaults.psm1")
    Test-Path -Path $ModuleFile -PathType "Leaf" -ErrorAction "Stop" | Out-Null
    Import-Module -Name $ModuleFile -Force -ErrorAction "Stop"
}
catch {
    throw $_
}
#endregion

# Setup logging
New-ScriptEventLog -EventLog $Project -Property $Properties

# Start logging
$PSProcesses = Get-CimInstance -ClassName "Win32_Process" -Filter "Name = 'powershell.exe'" | Select-Object -Property "CommandLine"
foreach ($Process in $PSProcesses) {
    $Object = [PSCustomObject]@{Name = "CommandLine"; Value = $Process.CommandLine; Result = 0 }
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

$DisplayVersion = Get-ChildItem -Path $WorkingPath -Include "VERSION.txt" -Recurse | Get-Content -Raw
Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Script version"; Value = $DisplayVersion; Result = 0 })

#region Gather configs
$AllConfigs = @(Get-ChildItem -Path $WorkingPath -Include "*.All.json" -Recurse -ErrorAction "Continue")
$ModelConfigs = @(Get-ChildItem -Path $WorkingPath -Include "*.$Model.json" -Recurse -ErrorAction "Continue")
$BuildConfigs = @(Get-ChildItem -Path $WorkingPath -Include "*.$Build.json" -Recurse -ErrorAction "Continue")
$PlatformConfigs = @(Get-ChildItem -Path $WorkingPath -Include "*.$Platform.json" -Recurse -ErrorAction "Continue")
Write-Verbose -Message "Found: $(($AllConfigs + $ModelConfigs + $BuildConfigs + $PlatformConfigs).Count) configs."

# Implement the settings defined in each config file
foreach ($Config in ($AllConfigs + $PlatformConfigs + $BuildConfigs + $ModelConfigs)) {

    # Read the settings JSON
    Write-Verbose "Running config: $($Config.FullName)"
    $Settings = Get-SettingsContent -Path $Config.FullName @prefs
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Config file"; Value = $Config.Name; Result = 0 })

    # Implement the settings only if the local build is greater or equal that what's specified in the JSON
    if ([System.Version]$OSVersion -ge [System.Version]$Settings.MinimumBuild) {
        if ([System.Version]$OSVersion -le [System.Version]$Settings.MaximumBuild) {

            #region Implement each setting in the JSON
            if ($Settings.Registry.ChangeOwner.Length -gt 0) {
                foreach ($Item in $Settings.Registry.ChangeOwner) {
                    Set-RegistryOwner -RootKey $Item.Root -Key $Item.Key -Sid $Item.Sid @prefs
                }
            }
            switch ($Settings.Registry.Type) {
                "DefaultProfile" {
                    Set-DefaultUserProfile -Setting $Settings.Registry.Set @prefs; break
                }
                "Direct" {
                    Set-Registry -Setting $Settings.Registry.Set @prefs; break
                }
                default {
                    Write-ToEventLog -Property "Registry" -Object ([PSCustomObject]@{Name = "Registry"; Value = "Skipped"; Result = 0 })
                }
            }

            switch ($Settings.StartMenu.Type) {
                "Server" {
                    if ((Get-WindowsFeature -Name $Settings.StartMenu.Feature).InstallState -eq "Installed") {
                        Copy-File -Path $Settings.StartMenu.Exists -Parent $WorkingPath @prefs
                    }
                    else {
                        Copy-File -Path $Settings.StartMenu.NotExists -Parent $WorkingPath @prefs
                    }
                }
                "Client" {
                    Copy-File -Path $Settings.StartMenu.$OSName -Parent $WorkingPath @prefs
                }
            }

            Copy-File -Path $Settings.Files.Copy -Parent $WorkingPath @prefs
            Remove-Path -Path $Settings.Paths.Remove @prefs
            Remove-Feature -Feature $Settings.Features.Disable @prefs
            Remove-Capability -Capability $Settings.Capabilities.Remove @prefs
            Remove-Package -Package $Settings.Packages.Remove @prefs
            Stop-NamedService -Service $Settings.Services.Stop @prefs
            Start-NamedService -Service $Settings.Services.Start @prefs
            Restart-NamedService -Service $Settings.Services.Restart @prefs
            #endregion
        }
        else {
            Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = $Config.FullName; Value = "Skipped maximum version"; Result = 0 })
        }
    }
    else {
        Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = $Config.FullName; Value = "Skipped minimum version"; Result = 0 })
    }
}
#endregion

#region If on a client OS, remove AppX applications
if ($Platform -eq "Client") {

    # Run the script to remove AppX/UWP apps; Get the script location
    $Script = Get-ChildItem -Path $WorkingPath -Include "Remove-AppxApps.ps1" -Recurse -ErrorAction "Continue"
    if ($null -eq $Script) {
        $Object = [PSCustomObject]@{Name = "$WorkingPath\Remove-AppxApps.ps1"; Value = "Script not found"; Result = 1 }
        Write-ToEventLog -Property "AppX" -Object $Object
    }
    else {
        Write-ToEventLog -Property "AppX" -Object ([PSCustomObject]@{Name = "Run script"; Value = $Script.FullName; Result = 0 })
        switch ($AppxMode) {
            "Block" { $Apps = & $Script.FullName -Operation "BlockList" @prefs; break }
            "Allow" { $Apps = & $Script.FullName -Operation "AllowList" @prefs; break }
        }
        $RemovedApps = $Apps | Where-Object { $_.State -eq "Removed" }
        $Object = [PSCustomObject]@{Name = "Removed AppX apps "; Value = ($RemovedApps.Name | Select-Object -Unique); Result = 0 }
        Write-ToEventLog -Property "AppX" -Object $Object
    }
}
#endregion

#region Set system language, locale and regional settings
if ($PSBoundParameters.ContainsKey('Language')) {
    if ($Platform -eq "Client") {
        # Set language support by installing the specified language pack
        Install-SystemLanguage -Language $Language
        Set-SystemLocale -Language $Language
    }
    else {
        Set-SystemLocale -Language $Language
    }
}
else {
    Write-Verbose -Message "-Language parameter not specified. Skipping install language support."
    Write-ToEventLog -Property "Language" -Object ([PSCustomObject]@{Name = "Install language"; Value = "Skipped"; Result = 0 })
}

if ($PSBoundParameters.ContainsKey('TimeZone')) {
    Set-TimeZoneUsingName -TimeZone $TimeZone
}
else {
    Write-Verbose -Message "-TimeZone parameter not specified. Skipping set time zone."
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Set time zone"; Value = "Skipped"; Result = 0 })
}
#endregion

# Copy the source files for use with upgrades
if ($FeatureUpdatePath -eq $WorkingPath) {
    $Object = [PSCustomObject]@{Name = "Copy to $FeatureUpdatePath"; Value = "Skipping file copy"; Result = 1 }
    Write-ToEventLog -Property "General" -Object $Object
}
else {
    try {
        New-Item -Path $FeatureUpdatePath -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" | Out-Null
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "New-Item"; Value = $FeatureUpdatePath; Result = 0 })
        Copy-Item -Path "$WorkingPath\*.*" -Destination $FeatureUpdatePath -Recurse -ErrorAction "SilentlyContinue"
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "Copy-Item $WorkingPath\*.*"; Value = $FeatureUpdatePath; Result = 0 })
    }
    catch {
        $Msg = $_.Exception.Message
        Write-ToEventLog -Property "Paths" -Object ([PSCustomObject]@{Name = "Copy to $FeatureUpdatePath"; Value = $Msg; Result = 1 })
    }
}

# Set uninstall registry value for detecting as an installed application
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
New-Item -Path "$Key\{$Guid}" -Type "RegistryKey" -Force -ErrorAction "Continue" | Out-Null
if ($PSCmdlet.ShouldProcess("Set uninstall key values")) {
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayName" -Value $Project -Type "String" -Force -ErrorAction "Continue" | Out-Null
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "Publisher" -Value $Publisher -Type "String" -Force -ErrorAction "Continue" | Out-Null
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "DisplayVersion" -Value $DisplayVersion -Type "String" -Force -ErrorAction "Continue" | Out-Null
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "RunOn" -Value $RunOn -Type "String" -Force -ErrorAction "Continue" | Out-Null
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "SystemComponent" -Value 1 -Type "DWord" -Force -ErrorAction "Continue" | Out-Null
    Set-ItemProperty -Path "$Key\{$Guid}" -Name "HelpLink" -Value $HelpLink -Type "String" -Force -ErrorAction "Continue" | Out-Null
}

#region Write last entry to the event log and output success or failure event
$EndTime = $StartTime - (Get-Date)
$WarningEntries = Get-EventLog -LogName $Project | `
    Where-Object { $_.EntryType -eq "Warning" -and $_.TimeGenerated -ge $StartTime.AddMinutes( - ($EndTime.Minutes)) }
if ($WarningEntries.Count -gt 0) {
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Install-Defaults.ps1 complete"; Value = "Error"; Result = 1 })
    Write-Output -InputObject $WarningEntries.Message
    return 1
}
else {
    Write-ToEventLog -Property "General" -Object ([PSCustomObject]@{Name = "Install-Defaults.ps1 complete"; Value = "Success"; Result = 0 })
    return 0
}
#endregion
