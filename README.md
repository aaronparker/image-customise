# Windows Image Customisation scripts

[![Build status](https://ci.appveyor.com/api/projects/status/hf5m780p8w431bc0/branch/main?svg=true)](https://ci.appveyor.com/project/aaronparker/image-customise/branch/main)

These scripts are used to customise a Windows 10, Windows Server 2016 or Windows Server 2019 image. Primarily aimed at deployment for physical PCs and virtual desktops, however, the customisations will also work for Windows Server infrastructure roles.

## Invoke-Scripts

All scripts should be invoked by `Invoke-Scripts.ps1` so that the scripts for each platform are detected and invoked appropriately. `Invoke-Scripts.ps1` invokes scripts based on the script name and the target platform:

* Scripts to run on all platforms - scripts named `*.All.ps1`
* Windows 10 vs. Windows Server - scripts named `*.Server.ps1` or `*.Client.ps1`
* Windows 10 / Windows Server build - scripts named `*.{Build}.ps1` (e.g., `*.18362.ps1`)
* Virtual machines - scripts named `*.Virtual.ps1`

### Scripts

Key scripts include:

* `Remove-AppxApps.Client.ps1` - removes default Universal Windows Platform apps (AppX). Runs in BlockList or AllowList mode
* `Remove-AppxApps.Virtual.ps1` - removes additional Universal Windows Platform apps (AppX) on virtual machines
* `Set-DefaultUser.Client.ps1`, `Set-DefaultUser.Server.ps1`, `Set-DefaultUser.All.ps1` - configures the default user profile
* `Set-DefaultUser.Virtual.ps1` - sets additional default profile optimisations for virtual machines
* `Set-Defender.*.ps1` - enables Microsoft Defender settings
* `Set-Machine.*.ps1` - configures machine level settings
