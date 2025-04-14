@ECHO OFF
SET SOURCE=C:\WINDOWS\System32\update\run\f38de27b-799e-4c30-8a01-bfdedc622944
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File "%SOURCE%\Remove-AppxApps.ps1" -Targeted
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File "%SOURCE%\Install-Defaults.ps1" -Path "%SOURCE%"
