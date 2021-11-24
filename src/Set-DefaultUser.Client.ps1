#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings - imports a default Start menu layout
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    https://stealthpuppy.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

Switch -Regex ((Get-WmiObject -Class "Win32_OperatingSystem").Caption) {
    "Microsoft Windows 10*" {
        $StartMenuFile = "Windows10StartMenuLayout.xml"
    }
    "Microsoft Windows 11*" {
        $StartMenuFile = "Windows11StartMenuLayout.xml"
    }
    Default {
        "Windows10StartMenuLayout.xml"
    }
}

# Configure the default Start menu
try {
    $params = @{
        Path        = "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell"
        ItemType    = "Directory"
        ErrorAction = "SilentlyContinue"
    }
    New-Item @params > $Null
    $Layout = Get-ChildItem -Path $Path -Filter $StartMenuFile -Recurse
    Write-Verbose -Message "Importing Start layout file: $Layout."
    Import-StartLayout -LayoutPath $Layout.FullName -MountPath "$($env:SystemDrive)\"
}
catch {
    Throw "Failed to import Start menu layout: $Layout."
}

# Configure Microsoft Teams defaults
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
