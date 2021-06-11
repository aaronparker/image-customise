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

`Set-DefaultUser.All.ps1` implements registry settings into the default profile by mounting the registry file at `C:\Users\Default\ntuser.dat` and importing a set of registry values that apply to all Windows Server and Windows 10 SKUs.

## Windows Server

`Set-DefaultUser.Server.ps1` implements registry settings into the default profile including preventing Server Manager from opening at sign-in, and turning off transparency effects. This script will also import a Start menu and taskbar layout for both Remote Desktop Session Hosts (`WindowsRDSStartMenuLayout.xml`) and standard infrastructure servers (`WindowsServerStartMenuLayout.xml`).

## Windows 10

`Set-DefaultUser.Client.ps1` imports a Start menu and taskbar layout (`Windows10StartMenuLayout.xml`) and add a default configuration file for Microsoft Teams (`desktop-config.json`).

## Virtual Machines

`Set-DefaultUser.Virtual.ps1` will implement registry settings in the default profile to support Windows running in a virtual machine, typically for VDI scenarios. This includes disabling transparency effects, windows dragging and animations, and disabling background applications.
