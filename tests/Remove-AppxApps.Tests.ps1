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
}

Describe "Remove-AppxApps script execution validation" {
    BeforeAll {
        $Script = Get-ChildItem -Path $ProjectRoot -Include "Remove-AppxApps.ps1" -Recurse
    }

    Context "Validate <script.Name>." {
        It "<script.Name> should execute OK" {
            Push-Location -Path $ProjectRoot
            { & $Script.FullName } | Should -Not -Throw
            Pop-Location
        }
    }
}
