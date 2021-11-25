
<#
    .SYNOPSIS
        Creates a .intunewin file for the customise scripts that can be uploaded into Intune as a Win32 application

    .NOTES

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = "$Env:Temp\Intune"
)

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
 
#region Setup package paths
$PackagePath = Join-Path -Path $projectRoot -ChildPath "src"
Write-Host -ForegroundColor "Cyan" "Package path: $PackagePath."
If (!(Test-Path -Path $PackagePath)) { New-Item -Path $PackagePath -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null }

$PackageOutput = Join-Path -Path $Path -ChildPath "Output"
Write-Host -ForegroundColor "Cyan" "Output path: $PackageOutput."
If (!(Test-Path -Path $PackageOutput)) { New-Item -Path $PackageOutput -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null }
#endregion

#region Package the app
# Download the Intune Win32 wrapper
$Win32Wrapper = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe"
$wrapperBin = Join-Path -Path $Path -ChildPath (Split-Path -Path $Win32Wrapper -Leaf)
try {
    $params = @{
        Uri             = $Win32Wrapper
        OutFile         = $wrapperBin
        UseBasicParsing = $True
    }
    Invoke-WebRequest @params
}
catch [System.Exception] {
    Throw "Failed to Microsoft Win32 Content Prep Tool with: $($_.Exception.Message)"
}

# Create the package
$Executable = Join-Path -Path $PackagePath -ChildPath "Invoke-Scripts.ps1"
try {
    Write-Host -ForegroundColor "Cyan" "Package path: $($PackagePath)."
    Write-Host -ForegroundColor "Cyan" "Executable path:  $($Executable)."
    $params = @{
        FilePath     = $wrapperBin
        ArgumentList = "-c $PackagePath -s $Executable -o $PackageOutput -q"
        Wait         = $True
        NoNewWindow  = $True
    }
    Start-Process @params
}
catch [System.Exception] {
    Throw "Failed to convert to an Intunewin package with: $($_.Exception.Message)"
}
try {
    $IntuneWinFile = Get-ChildItem -Path $PackageOutput -Filter "*.intunewin" -ErrorAction "SilentlyContinue"
}
catch {
    Throw "Failed to find an Intunewin package in $PackageOutput with: $($_.Exception.Message)"
}
Write-Host -ForegroundColor "Cyan" "Found package: $($IntuneWinFile.FullName)."
#endregion
