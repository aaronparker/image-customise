<#
    .SYNOPSIS
        Run local Pester tests
#>
[OutputType()]
Param()

# Invoke Pester tests and upload results to AppVeyor
Invoke-Pester -Path (Join-Path -Path $PWD -ChildPath "*.Tests.ps1") -PassThru -ExcludeTag "Windows"
Write-Host ""
