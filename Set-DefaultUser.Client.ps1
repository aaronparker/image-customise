#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings - imports a default Start menu layout
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

# Configure the default Start menu
If (!(Test-Path -Path "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows")) {
    New-Item -Path "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows" -ItemType "Directory" > $Null
}

try {
    $Layout = Get-ChildItem -Path $Path -Filter "Windows10StartMenuLayout.xml" -Recurse
    Write-Verbose -Message "Importing Start layout file: $Layout."
    Import-StartLayout -LayoutPath $Layout.FullName -MountPath "$($env:SystemDrive)\"
}
catch {
    Throw "Failed to import Start menu layout: $Layout."
}

# Configure Microsoft Teams defaults
$Target = "$env:SystemDrive\Users\Default\AppData\Roaming\Microsoft\Teams"
If (!(Test-Path -Path $Target)) {
    New-Item -Path $Target -ItemType "Directory" > $Null
}

try {
    $Config = Get-ChildItem -Path $Path -Filter "desktop-config.json" -Recurse
    Write-Verbose -Message "Copy Teams config file file: $($Config.FullName)."
    $params = @{
        Path        = $Config.FullName
        Destination = $Target
        ErrorAction = "SilentlyContinue"
    }
    Copy-Item @params
}
catch {
    Throw "Failed to copy Microsoft Teams default config: $($Config.FullName)."
}
