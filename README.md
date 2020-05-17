# Windows Image Customisation scripts

[![Build status](https://ci.appveyor.com/api/projects/status/hf5m780p8w431bc0?svg=true)](https://ci.appveyor.com/project/aaronparker/image-customise)
[![Build status](https://ci.appveyor.com/api/projects/status/hf5m780p8w431bc0/branch/master?svg=true)](https://ci.appveyor.com/project/aaronparker/image-customise/branch/master)

These scripts are used to customise a Windows 10, Windows Server 2016 or Windows Server 2019 image. Primarily for deployment with virtual desktops, however, the customisations will work for Windows Server infrastructure roles as well. All scripts should be invoked by `Invoke-Scripts.ps1` so that the scripts for each platform are invoked.

`Invoke-Scripts.ps1` invokes scripts based on the script name and the target plaform:

* Scripts to run on all platforms - scripts named *.All.ps1
* Windows 10 vs. Windows Server - scripts named *.Server.ps1 or *.Client.ps1
* Windows 10 / Windows Server build - scripts named *.{Build}.ps1 (e.g. *.18362.ps1)

## Scripts

Key scripts include:

* `Remove-AppxApps.Client.ps1` - removes default Universal Windows Platform apps (AppX). Runs in Blacklist or Whitelist mode
* `Set-DefaultUser.Client.ps1`, `Set-DefaultUser.Server.ps1`, `Set-DefaultUser.All.ps1` - configures the default user profile
