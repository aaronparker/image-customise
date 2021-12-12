---
title: Install Defaults
summary: 
authors:
    - Aaron Parker
---
## Download the Latest Release

To use the scripts in an operating system deployment pipeline, download the zip file attached to the [latest release](https://github.com/aaronparker/image-customise/releases) (`image-customise.zip`) and import the extracted files into your OS deployment solution (e.g., MDT, ConfigMgr, Packer etc.).

![Windows Custom Defaults release hosted on GitHub](assets/img/githubrelease.png)

## Download and Install

To simplify download and install during an automated image build pipeline, an [install script](https://raw.githubusercontent.com/aaronparker/image-customise/main/Install.ps1) is provided that can be executed with the following PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/aaronparker/image-customise/main/Install.ps1"))
```

This will download the latest release in zip format, extract the archive and execute on the local Windows instance.

### Microsoft Intune

The solution is also provided in `.intunewin` format to enable direct import into Microsoft Intune without requiring re-packaging.

Settings for a Win32 package in Intune is maintained here: [App.json](https://github.com/aaronparker/image-customise/blob/main/App.json).

![Windows Custom Defaults as a Win32 application in Microsoft Intune](assets/img/intuneapp01.png)
