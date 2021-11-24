---
title: Introduction
summary: 
authors:
    - Aaron Parker
---
# Windows Image Customisation scripts

The PowerShell scripts hosted in this repository are used to customise a Windows 10, Windows 11, Windows Server 2016, Windows Server 2019 or Windows Server 2022 image. Primarily aimed at deployment of images for virtual desktops or provisioning physical PCs, the customisations will also work for Windows Server infrastructure roles.

## Download

To use the scripts in an operating system deployment pipeline, download [the zip file](https://github.com/aaronparker/image-customise/archive/refs/heads/main.zip) of the repository and import the extracted files into your OS deployment solution (e.g. MDT, ConfigMgr, Packer etc.).

You only need to keep the scripts and files in the `src` folder in the repository. All other files and folders are not required.

To simplify downloading the scripts, the following PowerShell can be used:

```powershell
$ZipFile = "https://github.com/aaronparker/image-customise/archive/refs/heads/main.zip"
Invoke-WebRequest -URI $ZipFile -OutFile ".\main.zip"
Expand-Archive -Path ".\main.zip" -DestinationPath ".\image-customise"
Get-ChildItem -Path ".\image-customise\src" -Recurse | Unblock-File
```

## Installation

The scripts can be executed in an operating system deployment via various methods. For example, they can be imported into the Microsoft Deployment Toolkit as an application (see [Create a New Application in the Deployment Workbench](https://docs.microsoft.com/en-us/mem/configmgr/mdt/use-the-mdt#CreateaNewApplicationintheDeploymentWorkbench)), into Configuration Manager as an application as well (see [Create applications in Configuration Manager](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/create-applications)) or even run the scripts manually on a gold image.

## Supported Platforms

The scripts have been tested on Windows 10 (1809 and above), Windows Server 2016 and Windows Server 2019. All scripts should work on any future versions of Windows as well.

Windows PowerShell only is supported - typically during operating system deployments, there should be no requirement for PowerShell 6 or above. While the scripts will likely work OK on PowerShell 6 or above, they are not actively tested on those versions.
