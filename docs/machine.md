---
title: Machine settings
summary:
authors:
    - Aaron Parker
---
Machine specific settings are implemented to configure the local Windows OS with various settings for roles. Settings include:

## All Windows SKUs

* Updating some user interface fonts to use `Tahoma` instead of `MS Sans Serif`. This purely cosmetic and is implemented to reduce the number of fonts used in the Windows interface. Note that this configuration does not survive `sysprep /generalize`
* Removes several folders that are typically found in a default Windows install that are not required
* Adds the `DisableEdgeDesktopShortcutCreation` setting to prevent Microsoft Edge from placing a shortcut on the desktop - this should no longer be an issue if using a version of Windows with Edge already in the image

## Windows Server

* Enables the Windows Search and Audio services if the Remote Desktop Session Host role is enabled. This uses a specification in the JSON that will enable a list of services, if a specified Windows feature is enabled:

```json
"Services": {
    "Feature": "RDS-RD-Server",
    "Enable": [
        "Audiosrv",
        "WSearch"
    ]
}
```

## Windows 10 and Windows 11

* Disables the following features that are not used on most end-user desktops: `Printing-XPSServices-Features`, `SMB1Protocol`, `WorkFolders-Client`, `FaxServicesClientPackage`, `WindowsMediaPlayer`. A set of features to disable can be listed in the JSON as shown below.

```json
"Features": {
        "Disable": [
            "Printing-XPSServices-Features",
            "SMB1Protocol",
            "WorkFolders-Client",
            "FaxServicesClientPackage",
            "WindowsMediaPlayer"
        ]
    }
```

!!! note ""

    `WindowsMediaPlayer` is included by default with the expectation that you are deploying an alternative, modern media player, such as VLC Player. Removal of the Windows Media Player may affect some media playback features.

* Removes the following capabilities that are not used on most enterprise end-user desktops: `App.Support.QuickAssist~~~~0.0.1.0`, `Media.WindowsMediaPlayer~~~~0.0.12.0`, `XPS.Viewer~~~~0.0.1.0`. Capabilities to remove can be listed in the JSON as below:

```json
"Capabilities": {
    "Remove": [
        "App.Support.QuickAssist~~~~0.0.1.0",
        "Media.WindowsMediaPlayer~~~~0.0.12.0",
        "XPS.Viewer~~~~0.0.1.0"
    ]
}
```

## Windows 10 19041 and above

Windows 10 2004 (10.0.19041) and above will include the following configuration changes:

* Removes the following capabilities that are not used on most end-user desktops: `Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0`, `Microsoft.Windows.WordPad~~~~0.0.1.0`, `Print.Fax.Scan~~~~0.0.1.0`, `Print.Management.Console~~~~0.0.1.0`. Capabilities to remove from a specific Windows build, or higher, can be listed in the JSON as below:

```json
{
    "MinimumBuild": "10.0.19041",
    "Capabilities": {
        "Remove": [
            "Microsoft.Windows.WordPad~~~~0.0.1.0",
            "Print.Fax.Scan~~~~0.0.1.0",
            "Print.Management.Console~~~~0.0.1.0"
        ]
    }
}
```
