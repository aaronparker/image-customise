---
title: Configure Machine settings
summary: 
authors:
    - Aaron Parker
---
Machine specific settings are implemented with scripts named `Set-Machine.*.ps1`. These will configure the local Windows OS with various settings for roles.

## All Windows SKUs

`Set-Machine.All.ps1` implements only a few settings including:

* Updating some user interface fonts to use `Tahoma` instead of `MS Sans Serif`. This purely cosmetic and is implemented to reduce the number of fonts used in the Windows interface. Note that this configuration does not survive `sysprep /generalize`
* Removes several folders that are typically found in a default Windows install that are not required

## Windows Server

`Set-Machine.Server.ps1` configures the local Windows OS with settings that are primarily aimed at Remote Desktop Session Hosts:

* Adds the `DisableEdgeDesktopShortcutCreation` setting to prevent Microsoft Edge from placing a shortcut on the desktop
* Enables the Windows Search and Audio services if the Remote Desktop Session Host role is enabled

## Windows 10

`Set-Machine.Client.ps1` configures the local Windows OS with several settings:

* Adds the `DisableEdgeDesktopShortcutCreation` setting to prevent Microsoft Edge from placing a shortcut on the desktop
* Adds the `EnableFirstLogonAnimation` setting to disable the Windows 10 first logon animation
* Disables the following features that are not used on most end-user desktops: `Printing-XPSServices-Features`, `SMB1Protocol`, `WorkFolders-Client`, `FaxServicesClientPackage`, `WindowsMediaPlayer`
* Removes the following capabilities that are not used on most end-user desktops: `App.Support.QuickAssist~~~~0.0.1.0`, `MathRecognizer~~~~0.0.1.0`, `Media.WindowsMediaPlayer~~~~0.0.12.0`, `XPS.Viewer~~~~0.0.1.0`

## Windows 10 19041 and above

On Windows 2004 (10.0.19041) and above `Set-Machine.19041.ps1`, `Set-Machine.19042.ps1`, etc., will make the following configuration changes:

* Removes the following capabilities that are not used on most end-user desktops: `Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0`, `Microsoft.Windows.WordPad~~~~0.0.1.0`, `Print.Fax.Scan~~~~0.0.1.0`, `Print.Management.Console~~~~0.0.1.0`
