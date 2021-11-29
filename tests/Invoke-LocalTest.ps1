<#
    .SYNOPSIS
        Run local Pester tests
#>
[OutputType()]
Param()

# Invoke Pester tests
Invoke-Pester -Path (Join-Path -Path $PWD -ChildPath "*.Tests.ps1") -PassThru -ExcludeTag "Windows"
Write-Host ""
