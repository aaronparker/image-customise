<#
    .SYNOPSIS
        Main Pester function tests.
#>
[OutputType()]
Param()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $ScriptsFolder = Join-Path -Path $projectRoot -ChildPath "src"
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $ScriptsFolder = Join-Path -Path $projectRoot -ChildPath "src"
}

# Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
#$VerbosePreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# All scripts validation
Describe "General project validation" {
    $scripts = Get-ChildItem -Path $ScriptsFolder -Filter *.ps1
    Write-Host "Found $($scripts.count) scripts."

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | ForEach-Object { @{file = $_ } }
    It "Script <file> should be valid PowerShell" -TestCases $testCase {
        param($file)
        $file.FullName | Should Exist

        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule
    It "<file> should pass ScriptAnalyzer" -TestCases $testCase {
        param($file)
        $analysis = Invoke-ScriptAnalyzer -Path $file.FullName -ExcludeRule @('PSAvoidUsingWMICmdlet') -Severity @('Warning', 'Error')   
        
        ForEach ($rule in $scriptAnalyzerRules) {
            If ($analysis.RuleName -contains $rule) {
                $analysis |
                Where-Object RuleName -EQ $rule -OutVariable failures |
                Out-Default
                $failures.Count | Should Be 0
            }
        }
    }
}

# Gather scripts to test
Push-Location -Path $ScriptsFolder
$Scripts = @(Get-ChildItem -Path (Join-Path -Path $ScriptsFolder -ChildPath "*.ps1") -Exclude Invoke-Scripts.ps1 -ErrorAction "SilentlyContinue")

# Per script tests
Describe "Script execution validation" -Tag "Windows" {
    ForEach ($script in $Scripts) {
        Write-Host "`tRunning: $script" -ForegroundColor Gray
        It "$($script.Name) should not Throw" {
            { . $script.FullName -Path $ScriptsFolder -Verbose } | Should -Not -Throw
        }
    }
}
