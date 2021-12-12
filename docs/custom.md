---
title: Customise
summary: 
authors:
    - Aaron Parker
---
To customise the solution, download the [latest release](https://github.com/aaronparker/image-customise/releases) in `.zip` format and extract the archive. You should then see a folder listing similar to the following.

![A folder listing of the Windows Custom Default files](assets/img/src.png)

In most cases, you may want to customise the default Start menu; however, you may also have a requirement to add or remove registry settings.

## Registry settings

Registry settings should be laid out in the following format:

```json
{
    "MininumBuild": "10.0.14393",
    "Registry": {
        "Type": "DefaultProfile",
        "Set": [
            {
                "path": "HKCU:\\Software\\Microsoft\\TabletTip\\1.7",
                "name": "TipbandDesiredVisibility",
                "value": 0,
                "type": "DWord"
            }
        ]
    }
}
```

Settings and values that can be used here are:

* `MininumBuild` - used to ensure that the specified registry settings are only implemented if the Windows instance is equal to or greater than the specified version number
* `Registry` - a required property
* `Type` - this property supports `DefaultProfile` or `Direct`, tell the solution to implement the array of registry entries listed in `Set` to be applied directly against the path specified or the the default profile
* `Set` - tells the solution to set the array of registry entries

Each registry entry must include `path`, `name`, `value` and `type`. The Type property are registry entry types that are expected by [`Set-ItemProperty`](https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries).

## Registry paths

Registry paths can be specified with `HKLM:` or `HKCU:`. Registry entries with paths in `HKLM` should not be included with the `Type` property set to `DefaultProfile`.

## Files and Folders

The solution supports the removal of target directories and coping of files into a target directory.

```json
{
    "MininumBuild": "10.0.14393",
    "Paths": {
        "Remove": [
            "$env:PUBLIC\\Music\\Sample Music",
            "$env:PUBLIC\\Pictures\\Sample Pictures",
            "$env:PUBLIC\\Videos\\Sample Videos",
            "$env:PUBLIC\\Recorded TV\\Sample Media",
            "$env:SystemDrive\\Logs"
        ],
        "Copy": [
            {
                "Source": "desktop-config.json",
                "Destination": "$env:SystemDrive\\Users\\Default\\AppData\\Roaming\\Microsoft\\Teams"
            }
        ]
    }
}
```

Settings and values that can be used here are:

* `MininumBuild` - used to ensure that the specified file or folder actions are only implemented if the Windows instance is equal to or greater than the specified version number
* `Remove` - specified an array of paths to remove from the image if the path exists
* `Copy` - specifies an array of source and destination paths. The source must be located within the solution's source directory.

## Enabling Services

The solution can enable services if a dependent feature exists. For example, the following snippet will enable the Windows Audio and Windows Search services if the Remote Desktop Session Host feature exists.

```json
{
    "MininumBuild": "10.0.14393",
    "Services": {
        "Feature": "RDS-RD-Server",
        "Enable": [
            "Audiosrv",
            "WSearch"
        ]
    }
}
```

## Windows Features

Windows feature states can be configured using the following JSON:

```json
{
    "MininumBuild": "10.0.14393",
    "Features": {
        "Disable": [
            "Printing-XPSServices-Features",
            "SMB1Protocol",
            "WorkFolders-Client",
            "FaxServicesClientPackage",
            "WindowsMediaPlayer"
        ]
    },
    "Capabilities": {
        "Remove": [
            "App.Support.QuickAssist~~~~0.0.1.0",
            "Media.WindowsMediaPlayer~~~~0.0.12.0",
            "XPS.Viewer~~~~0.0.1.0"
        ],
    },
    "Packages": {
        "Remove": [
            "Microsoft-Windows-MediaPlayer-Package*"
        ]
    }
}
```

* `MininumBuild` - used to ensure that the specified file or folder actions are only implemented if the Windows instance is equal to or greater than the specified version number
* `Features / Disable` - disables Windows features. Accepts feature names retrieved with `Get-WindowsOptionalFeature -Online`
* `Capabilities / Remove` - removes Windows capabilities. Accepts capability names retrieved with `Get-WindowsCapability -Online`
* `Packages / Remove` - removes Windows packages. Accepts package names retrieved with `Get-WindowsPackage -Online`
