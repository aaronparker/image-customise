#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
    .SYNOPSIS
    Example script that calls Install-Defaults.ps1 to pass language and timezone settings
#>
[CmdletBinding(SupportsShouldProcess = $false)]
param ()

#region Restart if running in a 32-bit session
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {

        # Create a string from the passed parameters
        [System.String]$ParameterString = ""
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            $ParameterString += " -$($Parameter.Key) $($Parameter.Value)"
        }

        # Execute the script in a 64-bit process with the passed parameters
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`"$ParameterString"
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Write-Verbose -Message "Restarting in 64-bit PowerShell"
        Write-Verbose -Message "File path: $ProcessPath"
        Write-Verbose -Message "Arguments: $Arguments"
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $true
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
    }
}
#endregion

Set-Location -Path $PSScriptRoot
& "$PSScriptRoot\Install-Defaults.ps1" -Language "en-GB" -TimeZone "GMT Standard Time"
