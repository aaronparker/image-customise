<#
    .SYNOPSIS
        AppVeyor tests script.
#>
[OutputType()]
Param()

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
If (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {

    # Configure the test environment
    $testsPath = Join-Path -Path $projectRoot -ChildPath "tests"
    $testOutput = Join-Path -Path $projectRoot -ChildPath "TestsResults.xml"
    $testConfig = [PesterConfiguration] @{
        Run        = @{
            Path     = $testsPath
            PassThru = $True
        }
        TestResult = @{
            OutputFormat = "NUnitXml"
            OutputFile   = $testOutput
        }
        Show = "Default"
    }
    Write-Host "Tests path:      $testsPath."
    Write-Host "Output path:     $testOutput."

    # Invoke Pester tests
    $res = Invoke-Pester -Configuration $testConfig


    # Invoke Pester tests
    <#$params = @{
        Path         = $([System.IO.Path]::Combine($projectRoot, "tests"))
        OutputFormat = "NUnitXml"
        OutputFile   = $([System.IO.Path]::Combine($projectRoot, "TestsResults.xml"))
        PassThru     = $True
    }
    $res = Invoke-Pester @params
    If ($res.FailedCount -gt 0) { Throw "$($res.FailedCount) tests failed." }
    #>
}
Else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in AppVeyor console
Write-Host ""
