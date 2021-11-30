
<#
    .SYNOPSIS
        Set a tag and push

    .NOTES

#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param()

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}

$Version = Get-Content -Path "$ProjectRoot/src/VERSION.TXT"
If ($Null -ne $Version) {
    git tag v$Version
    git push origin --tags
}
