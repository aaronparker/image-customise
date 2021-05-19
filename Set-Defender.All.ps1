#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Enables Microsoft Defender recommended settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

# Defender settings. DisableRealtimeMonitoring is not explicitly set so that it can be disabled during OS deployment
# https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps
<#
If (Get-Module -Name "ConfigDefender" -ListAvailable -ErrorAction "SilentlyContinue") {
    try {
        $params = @{
            PUAProtection                    = "Enabled"
            MAPSReporting                    = "Advanced"
            DisableBehaviorMonitoring        = $False
            DisableIntrusionPreventionSystem = $False
            DisableIOAVProtection            = $False
            DisableScriptScanning            = $False
            DisableArchiveScanning           = $False
            DisableEmailScanning             = $False
            SubmitSamplesConsent             = "SendSafeSamples"
            ErrorAction                      = "SilentlyContinue"
        }
        Set-MpPreference @params
    }
    catch {
        Write-Error -Message "Set-MpPreference failed with: $($_.Exception.Message)."
    }
}
#>
