---
title: Home
summary: 
authors:
    - Aaron Parker
---
# Windows Image Customisation scripts

The PowerShell scripts hosted in the repository are used to customise a Windows 10, Windows Server 2016 or Windows Server 2019 image. Primarily aimed at deployment for physical PCs and virtual desktops, however, the customisations will also work for Windows Server infrastructure roles.

## Download

To use the scripts in an operating system deployment pipeline, download [the zip file](https://github.com/aaronparker/image-customise/archive/refs/heads/main.zip) of the repository and import the extracted files into your OS deployment solution (e.g. MDT, ConfigMgr, Packer etc.).

You only need to keep the `.ps1`, `.json`, `.xml` and `version.txt` files in the root of the repository. All other files and folders are not required.

To simplify downloading the scripts and keeping only what you need, the following PowerShell can be used:

```powershell
$ZipFile = "https://github.com/aaronparker/image-customise/archive/refs/heads/main.zip"
Invoke-WebRequest -URI $ZipFile -OutFile ".\main.zip"
Expand-Archive -Path ".\main.zip" -DestinationPath ".\image-customise"
Get-ChildItem -Path ".\image-customise" -Recurse -Exclude "*.ps1", "*.xml", "*.json", "version.txt" | Remove-Item -Confirm:$False -Recurse
Get-ChildItem -Path ".\image-customise" -Recurse | Unblock-File
```

## Installation

The scripts can be executed in an operating system deployment via various methods. For example, they can be imported into the Microsoft Deployment Toolkit as an application (see [Create a New Application in the Deployment Workbench](https://docs.microsoft.com/en-us/mem/configmgr/mdt/use-the-mdt#CreateaNewApplicationintheDeploymentWorkbench)), into Configuration Manager as an application as well (see [Create applications in Configuration Manager](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/create-applications)) or even run the scripts manually on a gold image.
