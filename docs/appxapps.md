---
title: Remove Universal Windows Platform / AppX apps
summary:
authors:
    - Aaron Parker
---
[`Remove-AppxApps.ps1`](https://github.com/aaronparker/defaults/blob/main/src/Remove-AppxApps.ps1) will remove Universal Windows Platform (UWP) / Microsoft Store apps from the local Windows OS. This script runs in two modes:

## Safe Package List

In this default mode, the script includes an explicit list of applications that it will keep, including packages that cannot be removed or are frameworks (packages that support other applications). **All other application packages will be removed**.

This mode should be run in [Windows OOBE](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/customize-oobe-in-windows-11) (1) (i.e. via Windows Autopilot or Device provisioning) or in a gold image, where the intention it to optimise the Windows installation by keeping only a core set of applications that provide valuable features to end-users.
{ .annotate }

1.  Windows OOBE stands for Windows Out-of-Box Experience. It's the setup process that occurs when you turn on a new Windows device for the first time or after resetting it to its factory settings. During OOBE, you're guided through various steps to personalize and configure your device, such as: connecting to a Wi-Fi network, setting up device preferences like region, keyboard layout, and privacy settings, and signing in with a Microsoft account.

This allows you to optimise a Windows install or gold image by removing all but a specified list of AppX packages from the the local system to prevent new installs of unwanted apps when new users log onto the system.

!!!warning

    It is not recommended to run this script on existing Windows PCs, as it will likely remove applications that users are actively using.

### Default Packages

This table lists the default packages that will be kept when `Remove-AppxApps.ps1`, all other packages will be removed.

| PackageFamilyName                                            | Description                                                                       |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe                 | Enable basic notes functionality. Supports Microsoft 365 accounts                 |
| Microsoft.Paint_8wekyb3d8bbwe                                | Provides basic image editing functionality                                        |
| Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe                 | Desktop automation tool                                                           |
| Microsoft.ScreenSketch_8wekyb3d8bbwe                         | Capture and annotate screenshots                                                  |
| Microsoft.Windows.Photos_8wekyb3d8bbwe                       | Basic image viewing. Supports Microsoft 365 accounts                              |
| Microsoft.WindowsAlarms_8wekyb3d8bbwe                        | Clock app with timers, alarms,  and world clock. Supports Microsoft 365 accounts  |
| Microsoft.WindowsCalculator_8wekyb3d8bbwe                    | Calculator app                                                                    |
| Microsoft.WindowsNotepad_8wekyb3d8bbwe                       | Notepad app                                                                       |
| Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe                 | Voice recording app                                                               |
| Microsoft.WindowsTerminal_8wekyb3d8bbwe                      | Essential terminal app                                                            |
| Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe                 | Microsoft Edge browser                                                            |
| Microsoft.ZuneMusic_8wekyb3d8bbwe                            | Windows Media Player,  video and music player                                     |
| Microsoft.WindowsStore_8wekyb3d8bbwe                         | System package, could affect functionality if removed                             |
| Microsoft.DesktopAppInstaller_8wekyb3d8bbwe                  | System package, could affect functionality if removed                             |
| Microsoft.ApplicationCompatibilityEnhancements_8wekyb3d8bbwe | System package, could affect functionality if removed                             |
| Microsoft.StorePurchaseApp_8wekyb3d8bbwe                     | System package, could affect functionality if removed                             |
| Microsoft.Wallet_8wekyb3d8bbwe                               | System package, could affect functionality if removed                             |
| MicrosoftWindows.CrossDevice_cw5n1h2txyewy                   | System package, could affect functionality if removed                             |
| MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy          | System package, could affect functionality if removed                             |
| Microsoft.WidgetsPlatformRuntime_8wekyb3d8bbwe               | System package, could affect functionality if removed                             |
| MicrosoftCorporationII.WinAppRuntime.Main.1.5_8wekyb3d8bbwe  | System package, could affect functionality if removed                             |
| MicrosoftCorporationII.WinAppRuntime.Singleton_8wekyb3d8bbwe | System package, could affect functionality if removed                             |
| Microsoft.MPEG2VideoExtension_8wekyb3d8bbwe                  | Video codec                                                                       |
| Microsoft.AV1VideoExtension_8wekyb3d8bbwe                    | Video codec                                                                       |
| Microsoft.AVCEncoderVideoExtension_8wekyb3d8bbwe             | Video codec                                                                       |
| Microsoft.HEIFImageExtension_8wekyb3d8bbwe                   | Image codec                                                                       |
| Microsoft.HEVCVideoExtension_8wekyb3d8bbwe                   | Video codec                                                                       |
| Microsoft.RawImageExtension_8wekyb3d8bbwe                    | Image codec                                                                       |
| Microsoft.VP9VideoExtensions_8wekyb3d8bbwe                   | Video codec                                                                       |
| Microsoft.WebMediaExtensions_8wekyb3d8bbwe                   | Image codec                                                                       |
| Microsoft.WebpImageExtension_8wekyb3d8bbwe                   | Image codec                                                                       |

## Targeted Package List

In the targeted mode, the script will remove a list of specified AppX packages, rather than any package except those specified. This mode is useful for running on an existing machine - e.g. existing Windows PCs managed with Intune, or used in a Windows feature upgrade.

## Validate Package Removal

`Remove-AppxApps.ps1` supports the `-WhatIf` parameter, so that you can see which packages will be removed from the local machine before running the script without the `-WhatIf` parameter.

[![Output from Remove-AppxApps.ps1 -WhatIf](assets/img/removeappx.png)](assets/img/removeappx.png)

## Parameters

### SafePackageList

An optional parameter that specifies a list of AppX package family names to be preserved during the removal process.

### Targeted

An optional switch parameter that, when specified, runs the script with a targeted list of AppX packages to be removed.

### TargetedPackageList

An optional parameter that specifies a targeted list of AppX package family names to be removed when the -Targeted switch is used.

## Examples

### Example 1

Remove all applications in the current Windows installation except for the default list of applications listed in `-SafePackages`, are non-removable or are package frameworks.

```powershell
PS C:\> .\Remove-AppxApps.ps1
```

Remove all applications in the current Windows installation except for those applications passed to `-SafePackages`, are non-removable or are package frameworks.

```powershell
$Packages = @(
        "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
        "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
        "Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe",
        "Microsoft.WindowsStore_8wekyb3d8bbwe",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
        "Microsoft.ApplicationCompatibilityEnhancements_8wekyb3d8bbwe",
        "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
        "Microsoft.Wallet_8wekyb3d8bbwe",
        "MicrosoftWindows.CrossDevice_cw5n1h2txyewy",
        "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
        "Microsoft.WidgetsPlatformRuntime_8wekyb3d8bbwe")
PS C:\> .\Remove-AppxApps.ps1 -SafePackages $Packages
```

### Example 2

Remove a set of applications in the current Windows installation listed in `-TargetedPackageList`.

```powershell
PS C:\> .\Remove-AppxApps.ps1 -Targeted
```
