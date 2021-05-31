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
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = $(Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent)
)

Write-Verbose -Message "Execution path: $Path."

# Registry Commands
$RegCommands =
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg" /d "Tahoma" /t REG_SZ /f',
'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes" /v "MS Shell Dlg 2" /d "Tahoma" /t REG_SZ /f'

# Process Registry Commands
ForEach ($Command in $RegCommands) {
    try {
        Write-Verbose -Message "reg $Command"
        $params = @{
            FilePath     = "$Env:SystemRoot\System32\reg.exe"
            ArgumentList = $Command
            Wait         = $True
            NoNewWindow  = $True
            WindowStyle  = "Hidden"
            ErrorAction  = "SilentlyContinue"
        }
        Start-Process @params
    }
    catch {
        Throw "Failed to run: [$Command]."
    }   
}

# Remove specified paths
$Paths = 
"$env:PUBLIC\Music\Sample Music",
"$env:PUBLIC\Pictures\Sample Pictures",
"$env:PUBLIC\Videos\Sample Videos",
"$env:PUBLIC\Recorded TV\Sample Media",
"$env:SystemDrive\Logs"
ForEach ($Path in $Paths) {
    If (Test-Path -Path $Path) { Remove-Item $Path -Recurse -Force }
}
