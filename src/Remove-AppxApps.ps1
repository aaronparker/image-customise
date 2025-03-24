<#
    .SYNOPSIS
    Removes unnecessary AppX packages and specific registry keys related to Outlook and DevHome updates.

    .DESCRIPTION
    This script removes all AppX packages from the system except for those that are non-removable, frameworks,
    or explicitly listed in the `$SafePackages` parameter. Additionally, it deletes specific registry keys that
    govern the installation of Outlook and DevHome updates.

    .PARAMETER SafePackages
    An optional parameter that specifies a list of AppX package family names that should not be removed.
    By default, it includes a predefined list of safe packages.

    .EXAMPLE
    .\Remove-AppxApps.ps1
    Removes all removable AppX packages except for those listed in the `$SafePackages` parameter and deletes specific registry keys.

    .EXAMPLE
    .\Remove-AppxApps.ps1 -SafePackages @("Microsoft.WindowsCalculator_8wekyb3d8bbwe")
    Removes all removable AppX packages except for the Windows Calculator and deletes specific registry keys.

    .NOTES
    - This script uses `Get-AppxPackage` to retrieve the list of installed AppX packages and `Remove-AppxPackage` to remove them.
    - The script also uses the `reg delete` command to remove specific registry keys.
    - Ensure you run this script with administrative privileges to allow package removal and registry modifications.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [System.Collections.ArrayList] $SafePackages = @(
        "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe",
        "Microsoft.Paint_8wekyb3d8bbwe",
        "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe",
        "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.Windows.Photos_8wekyb3d8bbwe",
        "Microsoft.WindowsAlarms_8wekyb3d8bbwe",
        "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
        "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe",
        "Microsoft.WindowsStore_8wekyb3d8bbwe",
        "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
        "Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe",
        "Microsoft.ApplicationCompatibilityEnhancements_8wekyb3d8bbwe",
        "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
        "MicrosoftWindows.CrossDevice_cw5n1h2txyewy",
        "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
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
    $AppxPackages = Get-AppxPackage | `
        Where-Object { $_.NonRemovable -eq $False -and $_.IsFramework -eq $False -and $_.PackageFamilyName -notin $SafePackages }
    $AppxPackages | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.PackageFullName, "Remove Appx package")) {
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers:$Elevated
            $_ | Select-Object -ExpandProperty "PackageFamilyName" | Write-Output
        }
    }

    # Delete registry keys that govern the installation of Outlook and DevHome
    if ($Elevated) {
        try {
            reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" /f 2>$null
            reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" /f 2>$null
            reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" /f 2>$null
            reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate" /f 2>$null
        }
        catch {
        }
    }
}
end {
}
