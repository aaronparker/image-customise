<#
    .SYNOPSIS
        Main Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param()

BeforeDiscovery {
    # Get the scripts to test
    $Scripts = @(Get-ChildItem -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src")) -Include "*.ps1" -Recurse)
    $ModuleFiles = Get-ChildItem -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src")) -Include "Install-Defaults.psm1" -Recurse
}

# All scripts validation
Describe "General project validation" {
    Context "Script should validate OK: <File.Name>" -ForEach $Scripts {
        BeforeAll {
            $File = $_
        }

        It "Script should exist: <File.Name>" {
            $File.FullName | Should -Exist
        }

        It "Script should be valid PowerShell: <File.Name>" {
            $contents = Get-Content -Path $File.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }
}

Describe "Validate module file: Install-Defaults.psm1" {
    Context "Module should validate OK: <File.Name>" -ForEach $ModuleFiles {
        BeforeAll {
            $File = $_
        }

        It "Script should exist" {
            $File.FullName | Should -Exist
        }

        It "Script should be valid PowerShell" {
            $contents = Get-Content -Path $File.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It "Should import OK" {
            { Import-Module -Name $File -Force } | Should -Not -Throw
        }
    }
}
