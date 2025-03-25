<#
    .SYNOPSIS
    Removes unnecessary AppX packages from the system while preserving a list of safe packages.

    .DESCRIPTION
    This script removes AppX packages from all users and provisioned packages on the system, except for those specified in `$SafePackages`.
    The default list of packages provide baseline functionality and should work in desktops using FSLogix Profile Container.
    It also handles package removal differently based on whether the system is running Windows 10 or Windows 11.
    Additionally, it deletes specific registry keys related to Outlook and DevHome updates if the script is run with elevated privileges.

    .PARAMETER SafePackages
    An optional parameter that specifies a list of AppX package family names to be preserved during the removal process.
    By default, it includes common desktop apps, system applications, and image/video codecs.

    .EXAMPLE
    .\Remove-AppxApps.ps1
    Runs the script with the default list of safe packages and removes all other removable AppX packages.

    .EXAMPLE
    .\Remove-AppxApps.ps1 -SafePackages @("Microsoft.WindowsCalculator_8wekyb3d8bbwe")
    Runs the script while preserving only the specified package (`Microsoft.WindowsCalculator_8wekyb3d8bbwe`) and removes all other removable AppX packages.

    .NOTES
    - WARNING: If run on an existing desktop, this script may remove applications that users rely on.
    - Use this script in OOBE (Windows Autopilot) and gold images only
    - The script must be run with elevated privileges to remove provisioned packages and delete specific registry keys.
    - The script checks the operating system version to determine whether it is running on Windows 10 or Windows 11 and adjusts the removal process accordingly.
    - The `ShouldProcess` cmdlet is used to confirm actions before removing packages.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [System.Collections.ArrayList] $SafePackages = @(
        # Common desktop apps
        "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe",
        "Microsoft.Paint_8wekyb3d8bbwe",
        "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe",
        "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.Windows.Photos_8wekyb3d8bbwe",
        "Microsoft.WindowsAlarms_8wekyb3d8bbwe",
        "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
        "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe",
        "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
        "Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe",
        "Microsoft.ZuneMusic_8wekyb3d8bbwe",

        # System applications
        "Microsoft.WindowsStore_8wekyb3d8bbwe",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
        "Microsoft.ApplicationCompatibilityEnhancements_8wekyb3d8bbwe",
        "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
        "Microsoft.Wallet_8wekyb3d8bbwe",
        "MicrosoftWindows.CrossDevice_cw5n1h2txyewy",
        "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
        "Microsoft.WidgetsPlatformRuntime_8wekyb3d8bbwe",

        # Image & video codecs
        "Microsoft.MPEG2VideoExtension_8wekyb3d8bbwe",
        "Microsoft.AV1VideoExtension_8wekyb3d8bbwe",
        "Microsoft.AVCEncoderVideoExtension_8wekyb3d8bbwe",
        "Microsoft.HEIFImageExtension_8wekyb3d8bbwe",
        "Microsoft.HEVCVideoExtension_8wekyb3d8bbwe",
        "Microsoft.RawImageExtension_8wekyb3d8bbwe",
        "Microsoft.VP9VideoExtensions_8wekyb3d8bbwe",
        "Microsoft.WebMediaExtensions_8wekyb3d8bbwe",
        "Microsoft.WebpImageExtension_8wekyb3d8bbwe")
)

begin {
    # Get elevated status. if elevated we'll remove packages from all users and provisioned packages
    [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
process {
    # Remove all AppX packages, except for packages that can't be removed, frameworks, and the safe packages list
    $AppxPackages = Get-AppxPackage -AllUsers | `
        Where-Object { $_.NonRemovable -eq $False -and $_.IsFramework -eq $False -and $_.PackageFamilyName -notin $SafePackages }

    # Check if we're running on Windows 11
    if ([System.Environment]::OSVersion.Version -ge [System.Version]"10.0.22000") {
        $AppxPackages | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.PackageFullName, "Remove Appx package")) {
                Remove-AppxPackage -Package $_.PackageFullName -AllUsers:$Elevated
                $_.PackageFamilyName | Write-Output
            }
        }
    }
    else {
        if ($Elevated) {
            # Windows 10
            $ProvisionedPackages = Get-AppxProvisionedPackage -Online
            $PackagesToRemove = $ProvisionedPackages | Where-Object { $_.DisplayName -in $AppxPackages.Name }
            $PackagesToRemove | ForEach-Object {
                if ($PSCmdlet.ShouldProcess($_.PackageName, "Remove Appx package")) {    
                    Remove-AppxProvisionedPackage -Package $_.PackageName -Online -AllUsers
                    $_.PackageName | Write-Output
                }
            }
        }
        else {
            Write-Error -Message "This script must be run elevated to remove provisioned packages."
        }
    }

    # Delete registry keys that govern the installation of Outlook and DevHome
    if ($Elevated) {
        try {
            reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" /f *>$null
            reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" /f *>$null
            reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" /f *>$null
            reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate" /f *>$null
            reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\MS_Outlook" /f *>$null
        }
        catch {
        }
    }
}
end {
}
