---
title: Introduction
summary:
authors:
    - Aaron Parker
---
Windows Enterprise Defaults is a solution for customising a Windows PC or image to change settings from the Microsoft defaults to make Windows enterprise ready. Microsoft's defaults suit the lowest common denominator for home, small business and enterprises, but an enterprise-ready Windows desktop requires some adjustments to the Windows and the default user environment.

Windows Enterprise Defaults simplifies making those changes to Windows, including - updating the Windows default profile, including the default Start menu and taskbar, the Windows user environment and Explorer settings, configures Windows feature states and removes in-box application packages. Windows Enterprise Defaults is not a "de-bloater", while it makes changes to Windows including removing in-box applications, the approach is to make sensible changes to Windows without crippling the end-user experience.

Windows 10, Windows 11, Windows Server 2016 to Windows Server 2025 are supported on both physical PCs and virtual machine images (Azure Virtual Desktop, Windows 365 etc.). Aimed at deployment provisioning physical PCs or virtual desktops gold images, the customisations will also work for Windows Server infrastructure roles.

## Usage

The customisations are intended for operating system deployment via various methods, including:

* Imported into the Microsoft Deployment Toolkit as an application for use during Lite Touch deployments - [Create a New Application in the Deployment Workbench](https://docs.microsoft.com/en-us/mem/configmgr/mdt/use-the-mdt#CreateaNewApplicationintheDeploymentWorkbench)
* Imported into Configuration Manager for use during Zero Touch deployments: - [Create applications in Configuration Manager](https://docs.microsoft.com/en-us/mem/configmgr/apps/deploy-use/create-applications)
* Packaged as a Win32 application and delivered via Microsoft Intune during Windows Autopilot - [Win32 app management in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management)
* Executed in a virtual machine image pipeline using [Azure Image Builder](https://docs.microsoft.com/en-us/azure/virtual-machines/image-builder-overview) or [Packer](https://www.packer.io/) when building a gold image
* Or even run manually on a Windows PC or virtual machine gold image if you're not using automation at all

## Results

This package will configure the Windows image ready for the enterprise and the end-user. Here's the default Windows 11 desktop:

![Default Windows 11 desktop](assets/img/before1080.png)

And here's a Windows 11 desktop after customisation:

![Customised Windows 11 desktop](assets/img/after1080.png)

## Supported Platforms

The solution is tested on Windows 10 (1809 and above), Windows 11, Windows Server 2016-2025. All scripts should work on any future versions of Windows; however, testing before rolling out in production is recommended.

!!! note ""

    Windows PowerShell only is supported - typically during operating system deployments, there should be no strict requirement for PowerShell 6 or above. While the scripts will likely work OK on PowerShell 6+, they are not actively tested on those versions.

---
[Laptop Settings](https://icons8.com/icon/iSNxtIhB8C9B/laptop-settings) by [Icons8](https://icons8.com).
