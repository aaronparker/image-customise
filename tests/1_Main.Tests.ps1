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
    if (Test-Path -Path env:GITHUB_WORKSPACE) {
        $ProjectRoot = $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src"))
    }
    else {
        # Local Testing
        $Parent = ((Get-Item -Path $(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
        $ProjectRoot = $([System.IO.Path]::Combine($Parent, "src"))
    }

    # Get the scripts to test
    $Scripts = @(Get-ChildItem -Path $ProjectRoot -Include "*.ps1" -Recurse)
    $TestCases = $Scripts | ForEach-Object { @{File = $_ } }
}

# All scripts validation
Describe "General project validation" {
    Context "Script should validate OK: <File.Name>" -ForEach $TestCases {
        BeforeAll {
            # Renaming the automatic $_ variable to $application to make it easier to work with
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
    BeforeAll {
        $ModuleFile = Get-ChildItem -Path $ProjectRoot -Include "Install-Defaults.psm1" -Recurse
    }

    Context "Module should validate OK" {
        It "Script should exist" {
            $ModuleFile.FullName | Should -Exist
        }

        It "Script should be valid PowerShell" {
            $contents = Get-Content -Path $ModuleFile.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It "Should import OK" {
            { Import-Module -Name $ModuleFile -Force } | Should -Not -Throw
       }
    }
}
