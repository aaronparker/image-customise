---
title: Customise the Default Profile
summary: 
authors:
    - Aaron Parker
---
Customising the default user profile is an important step in configuring the default environment that will user see at first sign-in.

Configuring the default profile allows the administrator to reduce noise for the end-user while still allowing them to customise their environment afterwards. This is a better approach that enforcing settings via Group Policy and this will also work for Azure AD joined scenarios.

The approach used by these scripts is to make changes directly to the default user profile found at `C:\Users\Default`. When users sign into Windows for the first time, their profile starts as a copy of the default profile, thus it will pick up the customisations.

## All Windows SKUs

Imports registry settings into the default profile by mounting the registry file at `C:\Users\Default\ntuser.dat` and importing a set of registry values that apply to all Windows Server and Windows 10/11 SKUs.

## Windows Server

Imports registry settings into the default profile including preventing Server Manager from opening at sign-in, and turning off transparency effects.

The script will also import a Start menu and taskbar layout for both Remote Desktop Session Hosts (`WindowsRDSStartMenuLayout.xml`) and standard infrastructure servers (`WindowsServerStartMenuLayout.xml`).

## Windows 10 or Windows 11

Imports a Start menu and taskbar layout (`Windows10StartMenuLayout.xml` or `Windows11StartMenuLayout.xml`) and add a default configuration file for Microsoft Teams (`desktop-config.json`).

These settings are imported into the default profile via direct file copies. The source file and destination are defined in the JSON sources as in the examples below. Here Windows 10 and Windows 11 default Start menu and taskbar layouts are defined in the included files and are copied to the specified destination.

```json
"Windows10": [
    {
        "Source": "Windows10StartMenuLayout.xml",
        "Destination": "C:\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\Shell\\LayoutModification.xml"
    }
],
"Windows11": [
    {
        "Source": "Windows11StartMenuLayout.json",
        "Destination": "C:\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\Shell\\LayoutModification.json"
    },
    {
        "Source": "Windows11TaskbarLayout.xml",
        "Destination": "C:\\Users\\Default\\AppData\\Local\\Microsoft\\Windows\\Shell\\LayoutModification.xml"
    },
    {
        "Source": "Windows11Start.bin",
        "Destination": "C:\\Users\\Default\\AppData\\Local\\Packages\\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\\LocalState\\start.bin"
    }
]
```

## Virtual Machines

Imports registry settings in the default profile to support Windows running in a virtual machine, typically VDI scenarios. This includes disabling transparency effects, windows dragging and animations, and disabling background applications.
