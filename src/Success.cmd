@ECHO OFF
cd /d %~dp0
if %PROCESSOR_ARCHITECTURE% == x86 (
    %SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File ".\Install-Defaults.ps1"
) else (
    %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File ".\Install-Defaults.ps1"
)
