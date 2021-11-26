# Windows Image Customisation scripts

![Build status](https://github.com/aaronparker/image-customise/actions/workflows/validate-scripts.yml/badge.svg)

[![PSScriptAnalyzer](https://github.com/aaronparker/image-customise/actions/workflows/powershell-analysis.yml/badge.svg)](https://github.com/aaronparker/image-customise/actions/workflows/powershell-analysis.yml)

The scripts in `/src` are used to customise a Windows 10/11, Windows Server 2016/2019/2022 image with default user customisations, in-box application removal/updates, and OS configurations. Aimed at deployment for physical PCs and virtual desktop gold images, the customisations will also work for Windows Server infrastructure roles.

Documentation is found here: [https://stealthpuppy.com/image-customise/](https://stealthpuppy.com/image-customise/).

## Invoke-Scripts

All scripts should be invoked by `src\Invoke-Scripts.ps1` so that the scripts for each platform are detected and invoked appropriately. `Invoke-Scripts.ps1` invokes scripts based on the script name and the target platform:

* Scripts to run on all platforms - scripts named `*.All.ps1`
* Windows 10/11 vs. Windows Server - scripts named `*.Server.ps1` or `*.Client.ps1`
* Windows 10/11 or Windows Server build - scripts named `*.{Build}.ps1` (e.g., `*.19042.ps1`)
* Virtual machines - scripts named `*.Virtual.ps1`
