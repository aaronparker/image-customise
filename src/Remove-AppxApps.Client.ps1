<#
    .SYNOPSIS
        Call Remove-AppxApps.ps1 for standard client Windows operating systems.
  
    .NOTES
        AUTHOR: Aaron Parker
        TWITTER: @stealthpuppy
#>
[CmdletBinding()]
param (
    [Parameter()]
    [System.String] $Path = $PSScriptRoot
)

# Run Remove-AppxApps.ps1 in block list mode
& (Join-Path -Path $Path -ChildPath "Remove-AppxApps.ps1") -Operation "BlockList"
