---
title: Feature upgrades
summary:
authors:
    - Aaron Parker
---
Windows Enterprise Defaults supports running as a custom action at the end of a successful Windows feature upgrade - [Run custom actions during feature update](https://learn.microsoft.com/en-au/windows-hardware/manufacture/desktop/windows-setup-enable-custom-actions?view=windows-11).

When `Install-Defaults.ps1` runs, it copies the project files to `C:\WINDOWS\System32\update\run\f38de27b-799e-4c30-8a01-bfdedc622944`. This enables the solution to be re-run after the feature update is complete and ensure the desired system configuration is maintained. 

[![File Explorer showing the feature upgrade files](assets/img/feature.png)](assets/img/feature.png)

When a feature upgrade completes (e.g. Windows 11 23H2 to Windows 11 24H2), `success.cmd` is executed. This will re-run `Install-Defaults.ps1` and explicitly run `Remove-AppxApps.ps1` in [targeted mode](https://stealthpuppy.com/defaults/appxapps/#targeted-package-list). This removes a set of AppX applications that are often reinstalled during a feature update.

```batch
@ECHO OFF
SET SOURCE=C:\WINDOWS\System32\update\run\f38de27b-799e-4c30-8a01-bfdedc622944
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File "%SOURCE%\Remove-AppxApps.ps1" -Targeted
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File "%SOURCE%\Install-Defaults.ps1" -Path "%SOURCE%"
```
