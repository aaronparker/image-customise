---
title: Install Defaults
summary: 
authors:
    - Aaron Parker
---
All scripts should be invoked by `Invoke-Scripts.ps1` so that those scripts for each platform are detected and invoked appropriately. `Invoke-Scripts.ps1` determines which scripts to run based on various   invokes scripts based on the script name and the target platform:

## Any Platform

Scripts with `.All.ps1` in the file name will be executed on any version of Windows. These scripts will include configuration changes that will apply to any version or SKU of Windows, including Windows 10 and Windows Server.

## Client or Server

`Get-WmiObject -Class "Win32_OperatingSystem"` is used to determine the SKU or edition of Windows and determine whether the local operating system is a client or server OS. Scripts with either `.Client.ps1` or `.Server.ps1` in the file name will then be invoked.

To see the output on a specific OS, use the following command:

```powershell
PS C:\> (Get-WmiObject -Class "Win32_OperatingSystem").Caption
Microsoft Windows 10 Enterprise
PS C:\>
```

`Invoke-Scripts.ps1` uses the following code to return whether the local OS is a client or server edition:

```powershell
Switch -Regex ((Get-WmiObject -Class "Win32_OperatingSystem").Caption) {
    "Microsoft Windows Server*" {
        $Platform = "Server"
    }
    "Microsoft Windows 10 Enterprise for Virtual Desktops" {
        $Platform = "Client"
    }
    "Microsoft Windows 11 Enterprise for Virtual Desktops" {
        $Platform = "Client"
    }
    "Microsoft Windows 10*" {
        $Platform = "Client"
    }
    "Microsoft Windows 11*" {
        $Platform = "Client"
    }
}
```

## Windows Build

Scripts that implement Windows build specific configurations will be determined from the current build number, of course, with: `([System.Environment]::OSVersion.Version).Build`. Scripts with matching build numbers in the file name (e.g. `.19041.ps1`) will be invoked.

## Hardware Platform

Some scripts might need to be used to implement different configurations based on whether the Windows OS is running on a physical or virtual platform. For example, `Set-DefaultUser.Virtual.ps1` will remove transparency effects from the Start menu and taskbar for better performance when over a remote virtual desktop.

```powershell
If ((Get-WmiObject -Computer . -Class "Win32_ComputerSystem").Model -match "Parallels*|VMware*|Virtual*") {
    $Model = "Virtual"
}
Else {
    $Model = "Physical"
}
```
