---
title: Install Defaults
summary: 
authors:
    - Aaron Parker
---
## Download and Install

To simplify download and install during an automated image build pipeline, an install script is provided that can be executed with the following PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/aaronparker/image-customise/main/install.ps1"))
```

## Download and Deploy

To use the scripts in an operating system deployment pipeline, download the zip file attached to the [latest release](https://github.com/aaronparker/image-customise/releases) and import the extracted files into your OS deployment solution (e.g. MDT, ConfigMgr, Packer etc.).

### Microsoft Intune

The solution is also provided in `.intunewin` format for use with Microsoft Intune. Settings for a Win32 package in Intune is maintained here: [App.json](https://github.com/aaronparker/image-customise/blob/main/App.json).

![Windows Custom Defaults as a Win32 application in Microsoft Intune](assets/img/intuneapp01.png)
