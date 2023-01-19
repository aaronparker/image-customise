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
    $Scripts = @(Get-ChildItem -Path $ProjectRoot -Include "*.ps*" -Recurse)
    $TestCases = $Scripts | ForEach-Object { @{File = $_ } }
}

# Per script tests
Describe "Install script execution validation" -Tag "Windows" {
    BeforeAll {
        $Script = Get-ChildItem -Path $ProjectRoot -Include "Install-Defaults.ps1" -Recurse
    }

    Context "Validate <script.Name>." {
        It "<script.Name> should execute OK" {
            Push-Location -Path $ProjectRoot
            Write-Host "Running script: $($Script.FullName)."
            & $Script.FullName -Path $ProjectRoot | Should -Be 0
            Pop-Location
        }
    }
}

Describe "Feature update script copy works" {
    BeforeAll {

        $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944"
        $FeatureUpdatePath = "$env:SystemRoot\System32\Update\Run\$Guid"
        $Files = @("$FeatureUpdatePath\Install-Defaults.ps1",
            "$FeatureUpdatePath\Remove-AppxApps.ps1",
            "$Env:SystemRoot\Setup\SetupComplete.cmd")
    }

    Context "Target directory exists" {
        It "FeatureUpdates should exist" {
            Test-Path -Path "$FeatureUpdatePath" | Should -BeTrue
        }
    }

    Context "Each script should exist" -ForEach $Files {
        It "$_ should exist" {
            Test-Path -Path $_ | Should -BeTrue
        }
    }
}
