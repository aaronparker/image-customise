#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Configuration changes to a default install of Windows during provisioning.

    .NOTES
    NAME: Remove-Defaults.ps1
    AUTHOR: Aaron Parker, Insentra
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944",

    [Parameter(Mandatory = $False)]
    [System.String] $FeatureUpdatePath = "$env:SystemRoot\System32\Update\Run\$Guid"
)
try {
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$Guid}"
    if (Test-Path -Path $RegPath) {
        Remove-Item -Path $RegPath -Force -ErrorAction "Continue"
    }

    if (Test-Path -Path $FeatureUpdatePath) {
        Remove-Item -Path $FeatureUpdatePath -Recurse -Force -ErrorAction "Continue"
    }
}
catch {
    throw $_
}
return 0
