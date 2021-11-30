---
title: Introduction
summary: 
authors:
    - Aaron Parker
---
The PowerShell scripts hosted in this repository are used to customise a Windows 10, Windows 11, Windows Server 2016, Windows Server 2019 or Windows Server 2022 image. Primarily aimed at deployment of images for virtual desktops or provisioning physical PCs, the customisations will also work for Windows Server infrastructure roles.

## Download

To use the scripts in an operating system deployment pipeline, download the zip file attached to the [latest release](https://github.com/aaronparker/image-customise/releases) and import the extracted files into your OS deployment solution (e.g. MDT, ConfigMgr, Packer etc.).

To simplify downloading the scripts, the following PowerShell can be used:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/aaronparker/image-customise/main/install.ps1"))
```

## Installation

The customisations can be executed in an operating system deployment via various methods. For example, they can be imported into the Microsoft Deployment Toolkit as an application (see [Create a New Application in the Deployment Workbench](https://docs.microsoft.com/en-us/mem/configmgr/mdt/use-the-mdt#CreateaNewApplicationintheDeploymentWorkbench)), into Configuration Manager as an application as well (see [Create applications in Configuration Manager](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/create-applications)), packaged as a Win32 application and delivered via Microsoft Intune, or even run the scripts manually on a gold image.

## Supported Platforms

The scripts have been tested on Windows 10 (1809 and above), Windows 11, Windows Server 2016, Windows Server 2019, and Windows Server 2022. All scripts should work on any future versions of Windows as well.

Windows PowerShell only is supported - typically during operating system deployments, there should be no requirement for PowerShell 6 or above. While the scripts will likely work OK on PowerShell 6 or above, they are not actively tested on those versions.
