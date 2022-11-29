<#
    .SYNOPSIS
        Main Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param()

BeforeDiscovery {
    # Set variables
    if (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
        $ProjectRoot = $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src"))
    }
    else {
        # Local Testing
        $Parent = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
        $ProjectRoot = $([System.IO.Path]::Combine($Parent, "src"))
    }

    # Get the scripts to test
    $Scripts = @(Get-ChildItem -Path $ProjectRoot -Include "Install-Defaults.ps*" -Recurce)
    $testCase = $Scripts | ForEach-Object { @{file = $_ } }
}

# All scripts validation
Describe "General project validation" -ForEach $Scripts {
    BeforeAll {
        # Renaming the automatic $_ variable to $application to make it easier to work with
        $file = $_
    }

    Context "Project should validate OK" {
        It "Script <file.Name> should exist" -TestCases $testCase {
            param ($file)
            $file.FullName | Should -Exist
        }

        It "Script <file.Name> should be valid PowerShell" -TestCases $testCase {
            param ($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }

    Context "Module should validate OK" {
        It "Should import OK" {
            Import-Module -Name $(Join-Path -Path $ProjectRoot -ChildPath "Install-Defaults.psm1") | Should -Not -Throw
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
            Push-Location -Path $ProjectRoot
            Write-Host "Running script: $($script.FullName)."
            $Result = . $script.FullName -Path $ProjectRoot -Verbose
            $Result | Should -Be 0
            Pop-Location
        }
    }
}

Describe "Feature update script copy works" {
    BeforeAll {
        $Files = @("$Env:SystemRoot\Setup\Scripts\Install-Defaults.ps1",
            "$Env:SystemRoot\Setup\Scripts\Remove-AppxApps.ps1",
            "$Env:SystemRoot\Setup\SetupComplete.cmd")
    }

    Context "Target directory exists" {
        It "FeatureUpdates should exist" {
            Test-Path -Path "$Env:SystemRoot\Setup\Scripts" | Should -BeTrue
        }
    }

    Context "Each script should exist" -ForEach $Files {
        It "$_ should exist" {
            Test-Path -Path $_ | Should -BeTrue
        }
    }
}
