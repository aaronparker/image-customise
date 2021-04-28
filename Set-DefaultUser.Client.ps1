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
    [Parameter()]    
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

# Configure the default Start menu
If (!(Test-Path("$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows"))) {
    New-Item -Value "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows" -ItemType "Directory" > $Null
}

try {
    $Layout = Resolve-Path -Path $(Join-Path -Path $Path -ChildPath "Windows10StartMenuLayout.xml")
    Write-Verbose -Message "Importing Start layout file: $Layout."
    Import-StartLayout -LayoutPath $Layout -MountPath "$($env:SystemDrive)\"
}
catch {
    Throw "Failed to import Start menu layout: [$Layout]."
}
