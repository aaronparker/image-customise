#Requires -RunAsAdministrator
<#
    .SYNOPSIS
    Set machine level settings.
  
    .NOTES
    AUTHOR: Aaron Parker
 
    .LINK
    http://stealthpuppy.com
#>

# Remove Windows capabilities
$Capabilities = $("Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0", "Microsoft.Windows.WordPad~~~~0.0.1.0", `
        "Print.Fax.Scan~~~~0.0.1.0", "Print.Management.Console~~~~0.0.1.0")
ForEach ($Capability in $Capabilities) {
    try {    
        Remove-WindowsCapability -Online -Name $Capability -ErrorAction "SilentlyContinue"
    }
    catch {
        Throw "Failed removing capability: [$Capability]."
    }
}
