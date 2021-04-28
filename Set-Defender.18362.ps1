#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set Microsoft Defender settings specific to Windows 10 1903 and above
  
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

# Process Registry Commands
$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /d 5 /t REG_DWORD /f'
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose -Message "reg $Command"
        $params = @{
            FilePath     = "$Env:SystemRoot\System32\reg.exe"
            ArgumentList = $Command
            Wait         = $True
            WindowStyle  = "Hidden"
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params
    }
    catch {
        Throw "Failed to run: [$Command]."
    }
}
