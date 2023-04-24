<#
    .SYNOPSIS
        Creates a .intunewin file for the customise scripts that can be uploaded into Intune as a Win32 application
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [System.String] $Path = $PWD,

    [Parameter(Mandatory = $false)]
    [System.String] $TempPath = "$Env:Temp\Intune",

    [Parameter(Mandatory = $false)]
    [System.String] $PackagePath = $(Join-Path -Path $Path -ChildPath "src"),

    [Parameter(Mandatory = $false)]
    [System.String] $PackageOutput = $(Join-Path -Path $Path -ChildPath "releases")
)

#region Setup package paths
Write-Information -InformationAction "Continue" -MessageData "Package path: $PackagePath."
if (!(Test-Path -Path $PackagePath)) { New-Item -Path $PackagePath -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null }

Write-Information -InformationAction "Continue" -MessageData "Output path: $PackageOutput."
if (!(Test-Path -Path $PackageOutput)) { New-Item -Path $PackageOutput -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null }
#endregion

#region Package the app
# Download the Intune Win32 wrapper
if (!(Test-Path -Path $TempPath)) { New-Item -Path $TempPath -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null }
$Win32Wrapper = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe"
$wrapperBin = Join-Path -Path $TempPath -ChildPath $(Split-Path -Path $Win32Wrapper -Leaf)
$params = @{
    Uri             = $Win32Wrapper
    OutFile         = $wrapperBin
    UseBasicParsing = $true
    ErrorAction     = "Stop"
}
Invoke-WebRequest @params
#endregion

#region Create the package
$Executable = Join-Path -Path $PackagePath -ChildPath "Install-Defaults.ps1"
Write-Information -InformationAction "Continue" -MessageData "Package path: $($PackagePath)."
Write-Information -InformationAction "Continue" -MessageData "Executable path:  $($Executable)."
$params = @{
    FilePath     = $wrapperBin
    ArgumentList = "-c $PackagePath -s $Executable -o $PackageOutput -q"
    Wait         = $true
    NoNewWindow  = $true
    ErrorAction  = "Stop"
}
Start-Process @params

$params = @{
    Path        = $PackageOutput
    Filter      = "*.intunewin"
    ErrorAction = "Stop"
}
$IntuneWinFile = Get-ChildItem
Write-Information -InformationAction "Continue" -MessageData "Found package: $($IntuneWinFile.FullName)."
#endregion

#region Zip the src folder
$params = @{
    Path            = "$PackagePath\*"
    DestinationPath = "$PackageOutput\image-customise.zip"
    ErrorAction     = "Stop"
}
Compress-Archive @params
#endregion

# Output what's been created in the releases folder
Write-Information -InformationAction "Continue" -MessageData ""
Get-ChildItem -Path $PackageOutput
