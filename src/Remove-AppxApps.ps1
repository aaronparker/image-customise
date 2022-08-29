<#
        .SYNOPSIS
            Removes a specified list of AppX packages from the current system.

        .DESCRIPTION
            Removes a specified list of AppX packages from the current user account and the local system to prevent new installs of in-built apps when new users log onto the system.

            if the script is run elevated, it will remove provisioned packages from the system and packages from all user accounts. Otherwise only packages for the current user account will be removed.

        .PARAMETER Operation
            Specify the AppX removal operation - either BlockList or AllowList.

        .PARAMETER BlockList
            Specify an array of AppX packages to 'BlockList' or remove from the current Windows instance, all other apps will remain installed. The script will use the BlockList by default.

            The default BlockList is primarily aimed at configuring AppX packages for physical PCs.

        .PARAMETER AllowList
            Specify an array of AppX packages to 'AllowList' or keep in the current Windows instance. All apps except this list will be removed from the current Windows instance.

            The default AllowList is primarily aimed at configuring AppX packages for virtual desktops.

        .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation BlockList

            Remove the default list of BlockListed AppX packages stored in the function.

        .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation AllowList

            Remove the default list of AllowListed AppX packages stored in the function.

         .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation BlockList -BlockList "Microsoft.3DBuilder_8wekyb3d8bbwe", "Microsoft.XboxApp_8wekyb3d8bbwe"

            Remove a specific set of AppX packages a specified in the -BlockList argument.

         .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation AllowList -AllowList "Microsoft.BingNews_8wekyb3d8bbwe", "Microsoft.BingWeather_8wekyb3d8bbwe"

            Remove AppX packages from the system except those specified in the -AllowList argument.

        .NOTES
 	        NAME: Remove-AppxApps.ps1
	        VERSION: 3.0
	        AUTHOR: Aaron Parker
	        TWITTER: @stealthpuppy

        .LINK
            https://stealthpuppy.com
#>
[CmdletBinding(SupportsShouldProcess = $True, DefaultParameterSetName = "BlockList")]
param (
    [parameter(Mandatory = $False, ParameterSetName = "BlockList", HelpMessage = "Specify whether the operation is a BlockList or AllowList.")]
    [parameter(Mandatory = $False, ParameterSetName = "AllowList", HelpMessage = "Specify whether the operation is a BlockList or AllowList.")]
    [ValidateSet('BlockList', 'AllowList')]
    [System.String] $Operation = "BlockList",

    [parameter(Mandatory = $False, ParameterSetName = "BlockList", HelpMessage = "Specify an AppX package or packages to remove.")]
    [System.String[]] $BlockList = (
        "7EE7776C.LinkedInforWindows_w1wdnht996qgy",
        "Clipchamp.Clipchamp_yxz26nhyzhsrt",
        "king.com.CandyCrushFriends_kgqvnymyfvs32",
        "king.com.CandyCrushSodaSaga_kgqvnymyfvs32",
        "king.com.FarmHeroesSaga_kgqvnymyfvs32",
        "Microsoft.3DBuilder_8wekyb3d8bbwe",
        "Microsoft.BingFinance_8wekyb3d8bbwe",
        "Microsoft.BingNews_8wekyb3d8bbwe",
        "Microsoft.BingSports_8wekyb3d8bbwe",
        "Microsoft.BingWeather_8wekyb3d8bbwe",
        "Microsoft.GamingApp_8wekyb3d8bbwe",
        "Microsoft.GetHelp_8wekyb3d8bbwe",
        # "Microsoft.Getstarted_8wekyb3d8bbwe",
        # "Microsoft.HEIFImageExtension_8wekyb3d8bbwe",
        "Microsoft.Messaging_8wekyb3d8bbwe",
        "Microsoft.Microsoft3DViewer_8wekyb3d8bbwe",
        # "Microsoft.MicrosoftAccessoryCenter_8wekyb3d8bbwe",
        # "Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe",
        # "Microsoft.MicrosoftJournal_8wekyb3d8bbwe",
        # "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe",
        "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe",
        # "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe",
        "Microsoft.MSPaint_8wekyb3d8bbwe",
        "Microsoft.MixedReality.Portal_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.Access_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.Excel_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.Outlook_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.PowerPoint_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.Publisher_8wekyb3d8bbwe",
        "Microsoft.Office.Desktop.Word_8wekyb3d8bbwe",
        "Microsoft.OneConnect_8wekyb3d8bbwe",
        # "Microsoft.OneDriveSync_8wekyb3d8bbwe",
        # "Microsoft.Paint_8wekyb3d8bbwe",
        "Microsoft.People_8wekyb3d8bbwe",
        # "Microsoft.PPIProjection_cw5n1h2txyewy",
        # "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe",
        "Microsoft.Print3D_8wekyb3d8bbwe",
        # "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.SkypeApp_kzf8qxf38zg5c",
        # "Microsoft.Todos_8wekyb3d8bbwe",
        # "Microsoft.VP9VideoExtensions_8wekyb3d8bbwe",
        # "Microsoft.WebMediaExtensions_8wekyb3d8bbwe",
        # "Microsoft.WebpImageExtension_8wekyb3d8bbwe",
        # "Microsoft.Windows.Photos_8wekyb3d8bbwe",
        # "Microsoft.WindowsAlarms_8wekyb3d8bbwe",
        # "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
        "Microsoft.WindowsCamera_8wekyb3d8bbwe",
        "Microsoft.windowscommunicationsapps_8wekyb3d8bbwe",
        "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe",
        # "Microsoft.WindowsMaps_8wekyb3d8bbwe",
        # "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "Microsoft.WindowsPhone_8wekyb3d8bbwe",
        # "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe",
        # "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
        "Microsoft.XboxApp_8wekyb3d8bbwe",
        "Microsoft.XboxGameOverlay_8wekyb3d8bbwe",
        "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe",
        "Microsoft.YourPhone_8wekyb3d8bbwe",
        "Microsoft.ZuneMusic_8wekyb3d8bbwe",
        # "Microsoft.ZuneVideo_8wekyb3d8bbwe",
        # "MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe",
        "MicrosoftTeams_8wekyb3d8bbwe",
        "Disney.37853FC22B2CE_6rarf9sa4v8jt",
        "SpotifyAB.SpotifyMusic_zpdnekdrzrea0"
    ),

    [parameter(Mandatory = $False, parameterSetName = "AllowList", HelpMessage = "Specify an AppX package or packages to keep, removing all others.")]
    [System.String[]] $AllowList = (
        "Microsoft.549981C3F5F10_8wekyb3d8bbwe",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
        "Microsoft.Wallet_8wekyb3d8bbwe",
        "Microsoft.VP9VideoExtensions_8wekyb3d8bbwe",
        "Microsoft.WebMediaExtensions_8wekyb3d8bbwe",
        "Microsoft.MPEG2VideoExtension_8wekyb3d8bbwe",
        "Microsoft.HEVCVideoExtension_8wekyb3d8bbwe",
        "Microsoft.HEifImageExtension_8wekyb3d8bbwe",
        "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
        "Microsoft.WebpImageExtension_8wekyb3d8bbwe",
        "Microsoft.WindowsStore_8wekyb3d8bbwe",
        "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
        "Microsoft.Winget.Source_8wekyb3d8bbwe",
        "MicrosoftCorporationII.WindowsAppRuntime.Main.1.0_8wekyb3d8bbwe",
        "Microsoft.WindowsAppRuntime.Singleton_8wekyb3d8bbwe",
        "Microsoft.WinAppRuntime.DDLM.3.469.1654.0-x6_8wekyb3d8bbwe",
        "Microsoft.WinAppRuntime.DDLM.3.469.1654.0-x8_8wekyb3d8bbwe",
        "Microsoft.XboxGameCallableUI_cw5n1h2txyewy"
    ),

    [parameter(Mandatory = $False)]
    [System.String] $Path = $PSScriptRoot
)

begin {
    Write-Verbose -Message "Execution path: $Path."

    #region functions
    function Edit-ProtectedApp {
        <# Filter out a set of apps that we'll never try to remove #>
        param (
            [parameter(Mandatory = $False)]
            [System.String[]] $ProtectList = (
                "Microsoft.WindowsStore_8wekyb3d8bbwe",
                "Microsoft.MicrosoftEdge_8wekyb3d8bbwe",
                "Microsoft.Windows.Cortana_cw5n1h2txyewy",
                "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
                "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
                "Microsoft.Wallet_8wekyb3d8bbwe",
                "Microsoft.Advertising.Xaml*",
                "Microsoft.NET*",
                "Microsoft.Services*",
                "Microsoft.UI*",
                "Microsoft.VCLibs*",
                "Microsoft.XboxGameCallableUI*"
            ),
            [parameter(Mandatory = $False)]
            [System.String[]] $PackageList
        )
        [System.Array] $FilteredList = @()
        foreach ($package in $PackageList) {
            $appMatch = $False
            foreach ($app in $ProtectList) {
                if ($package -match $app) {
                    Write-Verbose -Message "Excluding package from removal: [$package]"
                    $appMatch = $True
                }
            }
            if ($appMatch -eq $False) { $FilteredList += $package }
        }
        Write-Output -InputObject $FilteredList
    }
    #endregion

    # Get elevated status. if elevated we'll remove packages from all users and provisioned packages
    [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($Elevated) { Write-Verbose -Message "Running with elevated privileges. Removing provisioned packages as well." }

    switch ($Operation) {
        "BlockList" {
            # Filter list if it contains apps from the $protectList
            $packagesToRemove = Edit-ProtectedApp -PackageList $BlockList
        }
        "AllowList" {
            Write-Warning -Message "AllowList action may break stuff."
            if ($Elevated) {
                # Get packages from the current system for all users
                Write-Verbose -Message "Enumerating all users apps."
                $packagesAllUsers = Get-AppxPackage -AllUsers -PackageTypeFilter "Main", "Resource" | `
                    Where-Object { $_.NonRemovable -eq $False } | Select-Object -Property "PackageFamilyName"
            }
            else {
                # Get packages for the current user
                Write-Verbose -Message "Enumerating current user apps only."
                $packagesAllUsers = Get-AppxPackage -PackageTypeFilter "Main", "Resource" | `
                    Where-Object { $_.NonRemovable -eq $False } | Select-Object -Property "PackageFamilyName"
            }
            # Select unique packages
            $uniquePackagesAllUsers = $packagesAllUsers.PackageFamilyName | Sort-Object -Unique

            if ($Null -ne $uniquePackagesAllUsers) {
                # Filter out the AllowListed apps
                Write-Verbose -Message "Filtering AllowListed apps."
                $packagesWithoutAllowList = Compare-Object -ReferenceObject $uniquePackagesAllUsers -DifferenceObject $AllowList -PassThru

                # Filter list if it contains apps from the $protectList
                $packagesToRemove = Edit-ProtectedApp -PackageList $packagesWithoutAllowList
            }
            else {
                $packagesToRemove = $Null
            }
        }
    }
}

process {
    # Remove the apps; Walk through each package in the array
    foreach ($app in $packagesToRemove) {

        # Get the AppX package object by passing the string to the left of the underscore
        # to Get-AppxPackage and passing the resulting package object to Remove-AppxPackage
        $Name = ($app -split "_")[0]
        try {
            # if ($Elevated) {
            #     Write-Verbose -Message "Get package for all users: [$Name]."
            #     $Value = "Removed"; $Status = 0; $Msg = "None"
            #     if ($PSCmdlet.ShouldProcess($Name, "Remove All User app")) {
            #         Get-AppxPackage -Name $Name -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction "SilentlyContinue"
            #     }
            # }
            # else {
                Write-Verbose -Message "Get package: [$Name]."
                $Value = "Removed"; $Status = 0; $Msg = "None"
                if ($PSCmdlet.ShouldProcess($Name, "Remove User app")) {
                    Get-AppxPackage -Name $Name | Remove-AppxPackage -ErrorAction "SilentlyContinue"
                }
            #}
        }
        catch [System.Exception] {
            $Value = "Failed"; $Status = 1; $Msg = $_.Exception.Message
        }
        $Output = [PSCustomObject]@{
            Name   = $Name
            Value  = $Value
            Status = $Status
            Error  = $Msg
        }
        Write-Output -InputObject $output
    }

    # Remove the provisioned package as well, completely from the system
    if ($Elevated) {
        try {
            $Value = "Removed"; $Status = 0; $Msg = "None"
            if ($PSCmdlet.ShouldProcess($package.PackageName, "Remove Provisioned app")) {
                Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq (($app -split "_")[0]) } | `
                    Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction "SilentlyContinue"
            }
        }
        catch [System.Exception] {
            $Value = "Failed"; $Status = 1; $Msg = $_.Exception.Message
        }
        $Output = [PSCustomObject]@{
            Name   = $Name
            Value  = $Value
            Status = $Status
            Error  = $Msg
        }
        Write-Output -InputObject $output
        if ($action.RestartNeeded -eq $True) { Write-Warning -Message "Reboot required: [$($package.PackageName)]" }
    }
}

end {}
