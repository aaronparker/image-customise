<#
    .SYNOPSIS
        Call Remove-AppxApps.ps1 for virtualised client Windows operating systems.
  
    .NOTES
        AUTHOR: Aaron Parker
        TWITTER: @stealthpuppy
#>
[CmdletBinding()]
param (
    [Parameter()]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

# Run Remove-AppxApps.ps1 in block list mode
& (Join-Path -Path $Path -ChildPath "Remove-AppxApps.ps1") -Operation "AllowList"
