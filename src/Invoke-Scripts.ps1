#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
    .SYNOPSIS
    Configuration changes to a default install of Windows during provisioning.
  
    .NOTES
    NAME: Invoke-Scripts.ps1
    AUTHOR: Aaron Parker
    TWITTER: @stealthpuppy
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Guid = "f38de27b-799e-4c30-8a01-bfdedc622944",

    [Parameter(Mandatory = $False)]
    [System.String] $Publisher = "stealthpuppy",

    [Parameter(Mandatory = $False)]
    [System.String] $DisplayName = "Install detection for image customisations",
    
    [Parameter(Mandatory = $False)]
    [System.String] $RunOn = $(Get-Date -Format "yyyy-MM-dd")
)

$Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
$Version = (Get-ChildItem -Path $Path -Filter "VERSION.txt" -Recurse | Get-Content -Raw)
Write-Verbose -Message "Execution path: $Path."
Write-Verbose -Message "Customisation scripts version: $Version."

# Get system properties
Switch -Regex ((Get-WmiObject -Class "Win32_OperatingSystem").Caption) {
    "Microsoft Windows Server*" {
        $Platform = "Server"
    }
    "Microsoft Windows 10 Enterprise for Virtual Desktops" {
        #$Platform = "Multi"
        $Platform = "Client"
    }
    "Microsoft Windows 11 Enterprise for Virtual Desktops" {
        #$Platform = "Multi"
        $Platform = "Client"
    }
    "Microsoft Windows 10*" {
        $Platform = "Client"
    }
    "Microsoft Windows 11*" {
        $Platform = "Client"
    }
}
$Build = ([System.Environment]::OSVersion.Version).Build
If ((Get-WmiObject -Computer . -Class "Win32_ComputerSystem").Model -match "Parallels*|VMware*|Virtual*") {
    $Model = "Virtual"
}
Else {
    $Model = "Physical"
}

Write-Verbose -Message "Platform: $Platform."
Write-Verbose -Message "   Build: $Build."
Write-Verbose -Message "   Model: $Model."

# Gather scripts
try { $AllScripts = @(Get-ChildItem -Path $Path -Filter "*.All.ps1" -Recurse -ErrorAction "SilentlyContinue") } catch { Throw $_.Exception.Message }
try { $PlatformScripts = @(Get-ChildItem -Path $Path -Filter "*.$Platform.ps1" -Recurse -ErrorAction "SilentlyContinue") } catch { Throw $_.Exception.Message }
try { $BuildScripts = @(Get-ChildItem -Path $Path -Filter "*.$Build.ps1" -Recurse -ErrorAction "SilentlyContinue") } catch { Throw $_.Exception.Message }
try { $ModelScripts = @(Get-ChildItem -Path $Path -Filter "*.$Model.ps1" -Recurse -ErrorAction "SilentlyContinue") } catch { Throw $_.Exception.Message }

# Run all scripts
Write-Verbose -Message "Scripts: $(($AllScripts + $PlatformScripts + $BuildScripts + $ModelScripts).Count)."
ForEach ($script in ($AllScripts + $PlatformScripts + $BuildScripts + $ModelScripts)) {
    try {
        Write-Verbose -Message "Running script: $($script.FullName)."
        & $script.FullName -Path $Path
    }
    catch {
        Write-Warning -Message "Failed to run script: $($script.FullName)."
        Throw $_.Exception.Message
    }
}

# Set uninstall registry value for detecting in MDT / ConfigMgr etc.
$Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
reg add "$Key\{$Guid}" /v "DisplayName" /d $DisplayName /t REG_SZ /f
reg add "$Key\{$Guid}" /v "Publisher" /d $Publisher /t REG_SZ /f
reg add "$Key\{$Guid}" /v "DisplayVersion" /d $Version /t REG_SZ /f
reg add "$Key\{$Guid}" /v "RunOn" /d $RunOn /t REG_SZ /f
