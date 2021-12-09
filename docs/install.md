---
title: Install Defaults
summary: 
authors:
    - Aaron Parker
---
## Download and Deploy

To use the scripts in an operating system deployment pipeline, download the zip file attached to the [latest release](https://github.com/aaronparker/image-customise/releases) and import the extracted files into your OS deployment solution (e.g. MDT, ConfigMgr, Packer etc.).

### Microsoft Intune

The solution is also provided in `.intunewin` format for use with Microsoft Intune. Settings for a Win32 package in Intune is maintained here: [App.json](https://github.com/aaronparker/image-customise/blob/main/App.json).

![Windows Custom Defaults as a Win32 application in Microsoft Intune](assets/img/intuneapp01.png)

## Download and Install

To simplify download and install during an automated image build pipeline, an install script is provided that can be executed with the following PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/aaronparker/image-customise/main/install.ps1"))
```

## Configuration Files

Configurations are implemented with `Install-Defaults.ps1`. This script reads configurations in JSON format and configures the local Windows instance with Windows feature states, registry settings, copies files into specified paths, imports a default Start menu, and modifies the default user profile.

Configurations are stored in the following JSON files with the logic to make changes to Windows includes in `Install-Defaults.ps1`:

* [Build.All.json](https://github.com/aaronparker/image-customise/blob/main/src/Build.All.json)
* [Machine.All.json](https://github.com/aaronparker/image-customise/blob/main/src/Machine.All.json)
* [Machine.Client.json](https://github.com/aaronparker/image-customise/blob/main/src/Machine.Client.json)
* [Machine.Server.json](https://github.com/aaronparker/image-customise/blob/main/src/Machine.Server.json)
* [User.All.json](https://github.com/aaronparker/image-customise/blob/main/src/User.All.json)
* [User.Client.json](https://github.com/aaronparker/image-customise/blob/main/src/User.Client.json)
* [User.Server.json](https://github.com/aaronparker/image-customise/blob/main/src/User.Machine.json)
* [User.Virtual.json](https://github.com/aaronparker/image-customise/blob/main/src/User.Virtual.json)

JSON files are gathered based on properties of the local Windows instance. The following keywords, used in the file names, ensure that the right JSON files are selected:

* `Client` - Windows 10 or Windows 11
* `Server` - Windows Server 2016, 2019, 2022
* `Virtual` - Virtual machines, e.g. Hyper-V, Azure, vSphere, Parallels etc.
* `All` - applies to all Windows instances

Each JSON file includes a `MininumBuild` property that can be used to ensure specific configurations only apply to a specific version of Windows or above. For example, the property might ensure that configurations only apply to Windows 10 version `10.0.19041` and above.
