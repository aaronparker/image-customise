
<#
    .SYNOPSIS
        Creates a .intunewin file for the customise scripts that can be uploaded into Intune as a Win32 application

    .NOTES

#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
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
Write-Verbose -Message "Package path: $PackagePath."
If (!(Test-Path -Path $PackagePath)) { New-Item -Path $PackagePath -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null }

$PackageOutput = $(Join-Path -Path $projectRoot -ChildPath "releases")
Write-Verbose -Message "Output path: $PackageOutput."
If (!(Test-Path -Path $PackageOutput)) { New-Item -Path $PackageOutput -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null }
#endregion

#region Package the app
try {
    # Download the Intune Win32 wrapper
    If (!(Test-Path -Path $Path)) { New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null }
    $Win32Wrapper = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe"
    $wrapperBin = Join-Path -Path $Path -ChildPath $(Split-Path -Path $Win32Wrapper -Leaf)
    $params = @{
        Uri             = $Win32Wrapper
        OutFile         = $wrapperBin
        UseBasicParsing = $True
    }
    Invoke-WebRequest @params
}
catch [System.Exception] {
    Throw "Failed to download IntuneWinAppUtil.exe with: $($_.Exception.Message)"
}

try {
    # Create the package
    $Executable = Join-Path -Path $PackagePath -ChildPath "Install-Defaults.ps1"
    Write-Verbose -Message "Package path: $($PackagePath)."
    Write-Verbose -Message "Executable path:  $($Executable)."
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
    $params = @{
        Path        = $PackageOutput
        Filter      = "*.intunewin"
        ErrorAction = "SilentlyContinue"
    }
    $IntuneWinFile = Get-ChildItem
}
catch {
    Throw "Failed to find an Intunewin package in $PackageOutput with: $($_.Exception.Message)"
}
Write-Verbose -Message "Found package: $($IntuneWinFile.FullName)."
#endregion

try {
    $params = @{
        Path            = "$PackagePath\*"
        DestinationPath = "$PackageOutput\image-customise.zip"
        ErrorAction     = "SilentlyContinue"
    }
    Compress-Archive @params
}
catch {
    Throw "Failed to compress scripts with: $($_.Exception.Message)"
}
