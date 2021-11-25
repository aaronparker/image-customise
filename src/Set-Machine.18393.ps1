#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    https://stealthpuppy.com
#>
[CmdletBinding()]
param (
    [Parameter()]
    [System.String] $Path = $PSScriptRoot
)

# Run Remove-AppxApps.ps1 in block list mode
Write-Verbose -Message "Execution path: $Path."

# Remove Windows capabilities
$Capabilities = @(#"Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0",
    "Microsoft.Windows.WordPad~~~~0.0.1.0",
    "Print.Fax.Scan~~~~0.0.1.0",
    "Print.Management.Console~~~~0.0.1.0")
ForEach ($Capability in $Capabilities) {
    try {    
        $params = @{
            Name        = $Capability
            Online      = $True
            ErrorAction = "SilentlyContinue"
        }
        Remove-WindowsCapability @params
    }
    catch {
        Throw "Failed removing capability: [$Capability]."
    }
}
