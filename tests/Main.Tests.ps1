<#
    .SYNOPSIS
        Main Pester function tests.
#>
[OutputType()]
Param()

# Set variables
If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}

# Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
#$VerbosePreference = "Continue"
$ProgressPreference = "SilentlyContinue"
Push-Location -Path $([System.IO.Path]::Combine($projectRoot, "src")


BeforeDiscovery {
    # Get the scripts to test
    $Scripts = @(Get-ChildItem -Path $([System.IO.Path]::Combine($projectRoot, "src", "*.ps1")) -Include "Install-Defaults.ps1" -ErrorAction "SilentlyContinue")
    $testCase = $Scripts | ForEach-Object { @{file = $_ } }

    # Get the ScriptAnalyzer rules
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule
}


# All scripts validation
Describe "General project validation" {    
    It "Script <file.Name> should be valid PowerShell" -TestCases $testCase {
        param ($file)

        $file.FullName | Should -Exist

        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should -Be 0
    }

    It "Script <file.Name> should pass ScriptAnalyzer" -TestCases $testCase {
        param ($file)
        $analysis = Invoke-ScriptAnalyzer -Path  $file.FullName -ExcludeRule @("PSAvoidGlobalVars", "PSAvoidUsingWMICmdlet") -Severity @("Warning", "Error")   
        
        ForEach ($rule in $scriptAnalyzerRules) {
            If ($analysis.RuleName -contains $rule) {
                $analysis |
                Where-Object RuleName -EQ $rule -OutVariable failures |
                Out-Default
                $failures.Count | Should -Be 0
            }
        }
    }
}

# Per script tests
Describe "Script execution validation" -Tag "Windows" -ForEach $Scripts {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $script = $_
    }

    Context "Validate <script.Name>." {
        It "<script.Name> should execute OK" {
            Write-Host "Running script: $($script.FullName)."
            $Result = . $script.FullName -Verbose
            $Result | Should -Be 0
        }
    }
}
