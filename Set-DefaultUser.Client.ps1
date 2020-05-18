#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set default user profile settings - imports a default Start menu layout
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Configure the default Start menu
If (!(Test-Path("$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows"))) { New-Item -Value "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows" -ItemType Directory }
try {
    $Layout = Resolve-Path -Path ".\Windows10StartMenuLayout.xml"
    Import-StartLayout -LayoutPath $Layout -MountPath "$($env:SystemDrive)\"
}
catch {
    Throw "Failed to import Start menu layout: [$Layout]."
}
