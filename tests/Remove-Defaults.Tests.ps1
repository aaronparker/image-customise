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

Describe "Uninstall script execution validation" {
    BeforeAll {
        $Script = Get-ChildItem -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src")) -Include "Remove-Defaults.ps1" -Recurse
    }

    Context "Validate <script.Name>." {
        It "<script.Name> should execute OK" {
            Push-Location -Path $([System.IO.Path]::Combine($env:GITHUB_WORKSPACE, "src"))
            & $Script.FullName | Should -Be 0
            Pop-Location
        }
    }
}
