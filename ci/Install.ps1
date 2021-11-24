<#
    .SYNOPSIS
        AppVeyor install script.
#>
[OutputType()]
Param()

# Set variables
If (Test-Path -Path "$env:GITHUB_WORKSPACE") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}
$tests = Join-Path $projectRoot "tests"
$output = Join-Path $projectRoot "TestsResults.xml"

# Echo variables
Write-Host ""
Write-Host "OS version:      $((Get-WmiObject Win32_OperatingSystem).Caption)"
Write-Host ""
Write-Host "ProjectRoot:     $projectRoot."
Write-Host "Project name:    $module."
Write-Host "Tests path:      $tests."
Write-Host "Output path:     $output."

# Line break for readability in AppVeyor console
Write-Host ""
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()

# Install packages
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208" -Force -ErrorAction "SilentlyContinue"
If (Get-PSRepository -Name "PSGallery" | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}
#If ([Version]((Find-Module -Name Pester).Version) -gt (Get-Module -Name Pester).Version) {
#    Install-Module -Name "Pester" -SkipPublisherCheck -Force -MaximumVersion "4.10.1"
#}
If ([Version]((Find-Module -Name PSScriptAnalyzer).Version) -gt (Get-Module -Name PSScriptAnalyzer).Version) {
    Install-Module -Name "PSScriptAnalyzer" -SkipPublisherCheck -Force
}
If ([Version]((Find-Module -Name posh-git).Version) -gt (Get-Module -Name posh-git).Version) {
    Install-Module -Name "posh-git" -Force
}
