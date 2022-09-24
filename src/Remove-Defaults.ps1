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
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944"
)
try {
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$Guid}"
    if (Test-Path -Path $RegPath -ErrorAction "SilentlyContinue") {
        Remove-Item -Path $RegPath -Force -ErrorAction "SilentlyContinue"
    }

    $FilePath = @("$Env:SystemRoot\Setup\Scripts\Install-Defaults.ps1",
        "$Env:SystemRoot\Setup\Scripts\Install-Defaults.psm1",
        "$Env:SystemRoot\Setup\Scripts\Remove-AppxApps.ps1",
        "$Env:SystemRoot\Setup\Scripts\*.json")
    foreach ($File in $FilePath) {
        Remove-Item -Path $File -Force -ErrorAction "SilentlyContinue"
    }
}
catch {
    throw $_
    exit 1
}
exit 0
