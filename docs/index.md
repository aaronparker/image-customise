---
title: Introduction
summary: 
authors:
    - Aaron Parker
---
Windows Customised Defaults is a solution for customising a Windows image to change the settings from the Microsoft defaults to something more enterprise ready. The solution will update the Windows default profile, including configuring the default Start menu, and configure Windows feature states.

Windows Customised Defaults supports Windows 10, Windows 11, Windows Server 2016, Windows Server 2019 and Windows Server 2022, and supports both physical PCs and virtual machine images. Primarily aimed at deployment provisioning physical PCs or virtual desktops gold images, the customisations will also work for Windows Server infrastructure roles.

## Usage

The customisations can be executed in an operating system deployment via various methods. For example, they can be imported into the Microsoft Deployment Toolkit as an application (see [Create a New Application in the Deployment Workbench](https://docs.microsoft.com/en-us/mem/configmgr/mdt/use-the-mdt#CreateaNewApplicationintheDeploymentWorkbench)), into Configuration Manager as an application as well (see [Create applications in Configuration Manager](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/create-applications)), packaged as a Win32 application and delivered via Microsoft Intune, executed in an image pipeline using [Azure Image Builder](https://docs.microsoft.com/en-us/azure/virtual-machines/image-builder-overview) or [Packer](https://www.packer.io/), and even run manually on a virtual machine gold image.

For the end-user, the default Windows desktop should look similar to this:

![Default Windows 10 desktop](assets/img/defaultstartmenu.png)

## Supported Platforms

The scripts are tested on Windows 10 (1809 and above), Windows 11, Windows Server 2016, Windows Server 2019, and Windows Server 2022. All scripts should work on any future versions of Windows as well; however, testing before rolling out in production is recommended.

Windows PowerShell only is supported - typically during operating system deployments, there should be no requirement for PowerShell 6 or above. While the scripts will likely work OK on PowerShell 6 or above, they are not actively tested on those versions.
