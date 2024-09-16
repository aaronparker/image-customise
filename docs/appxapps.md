---
title: Remove Universal Windows Platform apps
summary:
authors:
    - Aaron Parker
---
[`Remove-AppxApps.ps1`](https://github.com/aaronparker/image-customise/blob/main/src/Remove-AppxApps.ps1) will remove Universal Windows Platform (UWP) / Microsoft Store apps from the local Windows OS.The script runs in an allow list or block list mode to either remove all but a specified list of applications or explicitly remove a specified list.

This allows you to optimise a Windows install or gold image by removing a specified list of AppX packages from the current user account and the local system to prevent new installs of in-built apps when new users log onto the system.

If the script is run elevated, it will remove provisioned packages from the system and packages from all user accounts. Otherwise only packages for the current user account will be removed.

## Other uses

`Remove-AppxApps.ps1` can also be used in other contexts, including with Microsoft Intune where it can be deployed to remove applications during a Windows Autopilot deployment. See [Use PowerShell scripts on Windows 10 devices in Intune](https://docs.microsoft.com/en-us/mem/intune/apps/intune-management-extension).

## Parameters

### Operation

Specify the AppX removal operation - either BlockList or AllowList.

### BlockList

Specify an array of AppX packages to 'BlockList' or remove from the current Windows instance, all other apps will remain installed. The script will use the BlockList by default. The default BlockList is primarily aimed at configuring AppX packages for physical PCs.

### AllowList

Specify an array of AppX packages to 'AllowList' or keep in the current Windows instance. All apps except this list will be removed from the current Windows instance. The default AllowList is primarily aimed at configuring AppX packages for virtual desktops.

## Examples

Remove the default list of BlockListed AppX packages stored in the function.

```powershell
PS C:\> .\Remove-AppxApps.ps1 -Operation BlockList
```

Remove the default list of AllowListed AppX packages stored in the function.

```powershell
PS C:\> .\Remove-AppxApps.ps1 -Operation AllowList
```

Remove a specific set of AppX packages a specified in the -BlockList argument.

```powershell
PS C:\> .\Remove-AppxApps.ps1 -Operation BlockList -BlockList "Microsoft.3DBuilder_8wekyb3d8bbwe", "Microsoft.XboxApp_8wekyb3d8bbwe"
```

Remove AppX packages from the system except those specified in the -AllowList argument.

```powershell
PS C:\> .\Remove-AppxApps.ps1 -Operation AllowList -AllowList "Microsoft.BingNews_8wekyb3d8bbwe", "Microsoft.BingWeather_8wekyb3d8bbwe"
```
