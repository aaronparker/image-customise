#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets the language and regional settings for the system.

.DESCRIPTION
    This script installs the specified language pack, sets the locale and regional settings,
    and configures the system to use the specified language.

.PARAMETER Language
    Specifies the language to install and set as the system language. The default value is "en-AU".

.PARAMETER TimeZone
    Specifies the time zone to set for the system. The default value is "AUS Eastern Standard Time".

.NOTES
    - This script requires the "LanguagePackManagement" and "International" modules to be imported.
    - Administrative privileges are required to run this script.

.EXAMPLE
    Set-Language -Language "en-US" -TimeZone "Pacific Standard Time"
    This example installs the English (United States) language pack and sets the time zone to Pacific Standard Time.
#>
[CmdletBinding(SupportsShouldProcess = $false)]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $Language = "en-AU",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [System.String] $TimeZone = "AUS Eastern Standard Time"
)

try {
    # Install the language pack
    Import-Module -Name "LanguagePackManagement"
    $params = @{
        Language        = $Language
        CopyToSettings  = $true
        ExcludeFeatures = $false
    }
    Install-Language @params

    # Set locale and regional settings
    Import-Module -Name "International"
    Set-TimeZone -Name $TimeZone
    Set-Culture -CultureInfo $Language
    Set-WinSystemLocale -SystemLocale $Language
    Set-WinUILanguageOverride -Language $Language
    Set-WinUserLanguageList -LanguageList $Language -Force
    $RegionInfo = New-Object -TypeName "System.Globalization.RegionInfo" -ArgumentList $Language
    Set-WinHomeLocation -GeoId $RegionInfo.GeoId
    Set-SystemPreferredUILanguage -Language $Language
}
catch {
    # Exit 0 so that we don't hold up Autopilot
    exit 0
}
