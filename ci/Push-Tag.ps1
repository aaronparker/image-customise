<#
    .SYNOPSIS
        Set a tag and push
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

$Path = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
$Version = Get-Content -Path "$Path/src/VERSION.TXT"
if ($null -ne $Version) {
    git tag v$Version
    git push origin --tags
}
