<#
    .SYNOPSIS
        Main Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param()

BeforeDiscovery {
}

# Per script tests
Describe "Install script execution validation" {
    BeforeAll {
        $Script = Get-ChildItem -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src")) -Include "Install-Defaults.ps1" -Recurse
    }

    Context "Validate <script.Name>." {
        It "<script.Name> should execute OK" {
            Push-Location -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src"))
            $params = @{
                Language = "en-AU"
                TimeZone = "AUS Eastern Standard Time"
            }
            & $Script.FullName -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src")) @params | Should -Be 0
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
