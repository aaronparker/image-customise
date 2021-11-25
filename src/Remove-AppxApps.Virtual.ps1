<#
    .SYNOPSIS
        Call Remove-AppxApps.ps1 for virtualised client Windows operating systems.
  
    .NOTES
        AUTHOR: Aaron Parker
        TWITTER: @stealthpuppy
#>
[CmdletBinding()]
param ()

# Run Remove-AppxApps.ps1 in block list mode
$Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
& (Join-Path -Path $Path -ChildPath "Remove-AppxApps.ps1") -Operation "AllowList"
