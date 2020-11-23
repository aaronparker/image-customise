#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Configuration changes to a default install of Windows during provisioning.
  
    .NOTES
    NAME: Invoke-Scripts.ps1
    AUTHOR: Aaron Parker, Insentra
#>
[CmdletBinding()]
Param ()

# Get system properties
Switch -Regex ((Get-WmiObject Win32_OperatingSystem).Caption) {
    "Microsoft Windows Server*" {
        $Platform = "Server"
    }
    "Microsoft Windows 10 Enterprise for Virtual Desktops" {
        $Platform = "Multi"
    }
    "Microsoft Windows 10*" {
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

# Gather scripts
$AllScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.All.ps1") -ErrorAction SilentlyContinue)
$PlatformScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Platform.ps1") -ErrorAction SilentlyContinue)
$BuildScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Build.ps1") -ErrorAction SilentlyContinue)
$ModelScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Model.ps1") -ErrorAction SilentlyContinue)

# Run all scripts
ForEach ($script in ($AllScripts + $PlatformScripts + $BuildScripts + $ModelScripts)) {
    Try {
        Write-Verbose "Running script: $($script.FullName)."
        . $script.FullName
    }
    Catch {
        Write-Warning -Message "Failed to run script: $($script.FullName)."
        Throw $_.Exception.Message
    }
}

# Set uninstall registry value for detecting in MDT / ConfigMgr etc.
$guid = "f38de27b-799e-4c30-8a01-bfdedc622944"
$DisplayName = "Install detection for Image customisations"
$RunOn = Get-Date
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$guid}" /v "DisplayName" /d $DisplayName /t REG_SZ /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$guid}" /v "Publisher" /d "stealthpuppy" /t REG_SZ /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$guid}" /v "DisplayVersion" /d "1.0.0" /t REG_SZ /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{$guid}" /v "RunOn" /d $RunOn /t REG_SZ /f
