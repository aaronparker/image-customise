#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Configuration changes to a default install of Windows during provisioning.

    .NOTES
    NAME: Invoke-Scripts.ps1
    AUTHOR: Aaron Parker, Insentra
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944"
)
try {
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$Guid}"
    If (Test-Path -Path $RegPath -ErrorAction "SilentlyContinue") {
        Remove-Item -Path $RegPath -Force
    }
}
catch {
    $_
    Exit 1
}
Exit 0
