<#
    .SYNOPSIS
        Run local Pester tests
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
Param()

# Invoke Pester tests
Invoke-Pester -Path (Join-Path -Path $PWD -ChildPath "*.Tests.ps1") -PassThru -ExcludeTag "Windows"
Write-Host ""
