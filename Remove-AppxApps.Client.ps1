<#
        .SYNOPSIS
            Removes a specified list of AppX packages from the current system.
 
        .DESCRIPTION
            Removes a specified list of AppX packages from the current user account and the local system to prevent new installs of in-built apps when new users log onto the system.

            If the script is run elevated, it will remove provisioned packages from the system and packages from all user accounts. Otherwise only packages for the current user account will be removed.

        .PARAMETER Operation
            Specify the AppX removal operation - either Blocklist or Allowlist. 

        .PARAMETER Blocklist
            Specify an array of AppX packages to 'Blocklist' or remove from the current Windows instance, all other apps will remain installed. The script will use the Blocklist by default.

            The default Blocklist is primarily aimed at configuring AppX packages for physical PCs.
  
        .PARAMETER Allowlist
            Specify an array of AppX packages to 'Allowlist' or keep in the current Windows instance. All apps except this list will be removed from the current Windows instance.

            The default Allowlist is primarily aimed at configuring AppX packages for virtual desktops.

        .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation Blocklist
            
            Remove the default list of Blocklisted AppX packages stored in the function.
 
        .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation Allowlist
            
            Remove the default list of Allowlisted AppX packages stored in the function.

         .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation Blocklist -Blocklist "Microsoft.3DBuilder_8wekyb3d8bbwe", "Microsoft.XboxApp_8wekyb3d8bbwe"
            
            Remove a specific set of AppX packages a specified in the -Blocklist argument.
 
         .EXAMPLE
            PS C:\> .\Remove-AppxApps.ps1 -Operation Allowlist -Allowlist "Microsoft.BingNews_8wekyb3d8bbwe", "Microsoft.BingWeather_8wekyb3d8bbwe"
            
            Remove AppX packages from the system except those specified in the -Allowlist argument.

        .NOTES
 	        NAME: Remove-AppxApps.ps1
	        VERSION: 3.0
	        AUTHOR: Aaron Parker
	        TWITTER: @stealthpuppy
 
        .LINK
            https://stealthpuppy.com
#>
[CmdletBinding(SupportsShouldProcess = $True, DefaultParameterSetName = "Blocklist")]
Param (
    [Parameter(Mandatory = $False, ParameterSetName = "Blocklist", HelpMessage = "Specify whether the operation is a Blocklist or Allowlist.")]
    [Parameter(Mandatory = $False, ParameterSetName = "Allowlist", HelpMessage = "Specify whether the operation is a Blocklist or Allowlist.")]
    [ValidateSet('Blocklist', 'Allowlist')]
    [System.String] $Operation = "Blocklist",

    [Parameter(Mandatory = $False, ParameterSetName = "Blocklist", HelpMessage = "Specify an AppX package or packages to remove.")]
    [System.String[]] $Blocklist = (
        "7EE7776C.LinkedInforWindows_w1wdnht996qgy", # LinkedIn
        "king.com.CandyCrushSodaSaga_kgqvnymyfvs32", # Candy Crush
        "king.com.CandyCrushFriends_kgqvnymyfvs32", # Candy Crush Friends
        "king.com.FarmHeroesSaga_kgqvnymyfvs32", # Farm Heroes Saga
        "Microsoft.3DBuilder_8wekyb3d8bbwe", # 3D Builder
        "Microsoft.BingFinance_8wekyb3d8bbwe", # Bing Finance
        "Microsoft.BingNews_8wekyb3d8bbwe", # Microsoft News
        "Microsoft.BingSports_8wekyb3d8bbwe", # Bing Sports
        "Microsoft.BingWeather_8wekyb3d8bbwe", # Weather
        "Microsoft.GetHelp_8wekyb3d8bbwe", # Get Help
        "Microsoft.Messaging_8wekyb3d8bbwe", # Messaging
        "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe", # Solitaire
        "Microsoft.Office.Desktop_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.Access_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.Excel_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.Outlook_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.PowerPoint_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.Publisher_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.Office.Desktop.Word_8wekyb3d8bbwe", # Office 365 desktop application. Will prevent Office 365 ProPlus install
        "Microsoft.OneConnect_8wekyb3d8bbwe", # Mobile Plans
        "Microsoft.People_8wekyb3d8bbwe", # People
        "Microsoft.SkypeApp_kzf8qxf38zg5c", # Skype
        "Microsoft.windowscommunicationsapps_8wekyb3d8bbwe", # Mail, Calendar
        "Microsoft.WindowsPhone_8wekyb3d8bbwe", # Phone
        "Microsoft.XboxApp_8wekyb3d8bbwe", # Xbox Console Companion
        "Microsoft.XboxGameCallableUI_cw5n1h2txyewy", # Xbox UI
        "Microsoft.XboxGameOverlay_8wekyb3d8bbwe", # Xbox UI
        "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe", # Xbox Game Bar
        "Microsoft.ZuneMusic_8wekyb3d8bbwe", # Zune Music
        "Microsoft.ZuneVideo_8wekyb3d8bbwe", # Zune Video
        # "Microsoft.Getstarted_8wekyb3d8bbwe",                 # Windows Tips
        "Microsoft.Microsoft3DViewer_8wekyb3d8bbwe",          # 3D Viewer
        # "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe",         # Office 365 hub
        # "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe",       # Stick Notes
        "Microsoft.MixedReality.Portal_8wekyb3d8bbwe",        # Mixed Reality Portal
        # "Microsoft.MSPaint_8wekyb3d8bbwe",                    # Paint 3D
        # "Microsoft.Office.OneNote_8wekyb3d8bbwe",             # Microsoft OneNote
        # "Microsoft.PPIProjection_cw5n1h2txyewy",              # Connect (Miracast)
        "Microsoft.Print3D_8wekyb3d8bbwe",                    # Print 3D
        # "Microsoft.ScreenSketch_8wekyb3d8bbwe",               # Snip & Sketch
        # "Microsoft.Windows.Photos_8wekyb3d8bbwe",             # Photos
        # "Microsoft.WindowsAlarms_8wekyb3d8bbwe",              # Alarms
        # "Microsoft.WindowsCalculator_8wekyb3d8bbwe",          # Calculator
        # "Microsoft.WindowsCamera_8wekyb3d8bbwe",              # Camera
        "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe",         # Feedback Hub
        # "Microsoft.WindowsMaps_8wekyb3d8bbwe",                # Maps
        # "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe",       # Voice Recorder
        "Microsoft.YourPhone_8wekyb3d8bbwe"                   # Your Phone
    ),

    [Parameter(Mandatory = $False, ParameterSetName = "Allowlist", HelpMessage = "Specify an AppX package or packages to keep, removing all others.")]
    [System.String[]] $Allowlist = (
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
        "Microsoft.StorePurchaseApp_8wekyb3d8bbwe",
        "Microsoft.Wallet_8wekyb3d8bbwe",
        "Microsoft.VP9VideoExtensions_8wekyb3d8bbwe",
        "Microsoft.WebMediaExtensions_8wekyb3d8bbwe",
        "Microsoft.MPEG2VideoExtension_8wekyb3d8bbwe",
        "Microsoft.HEVCVideoExtension_8wekyb3d8bbwe",
        "Microsoft.HEIFImageExtension_8wekyb3d8bbwe",
        "Microsoft.WebpImageExtension_8wekyb3d8bbwe",
        "Microsoft.WindowsStore_8wekyb3d8bbwe"
    )
)

#region Functions
Function Edit-ProtectedApp {
    <# Filter out a set of apps that we'll never try to remove #>
    Param (
        [Parameter(Mandatory = $False)]
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
            "Microsoft.VCLibs*"
        ),
        [Parameter(Mandatory = $False)]
        [System.String[]] $PackageList
    )
    [System.Array] $FilteredList = @()
    ForEach ($package in $PackageList) {
        $appMatch = $False
        ForEach ($app in $ProtectList) {
            If ($package -match $app) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Excluding package from removal: [$package]"
                $appMatch = $True
            }
        }
        If ($appMatch -eq $False) { $FilteredList += $package }
    }
    Write-Output -InputObject $FilteredList
}
#endregion

# Get elevated status. If elevated we'll remove packages from all users and provisioned packages
[System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If ($Elevated) { Write-Verbose -Message "$($MyInvocation.MyCommand): Running with elevated privileges. Removing provisioned packages as well." }

Switch ($Operation) {
    "Blocklist" {
        # Filter list if it contains apps from the $protectList
        $packagesToRemove = Edit-ProtectedApp -PackageList $Blocklist
    }
    "Allowlist" {
        Write-Warning -Message "$($MyInvocation.MyCommand): Allowlist action may break stuff."
        If ($Elevated) {
            # Get packages from the current system for all users
            Write-Verbose -Message "$($MyInvocation.MyCommand): Enumerating all users apps."
            $packagesAllUsers = Get-AppxPackage -AllUsers -PackageTypeFilter Main, Resource | `
                Where-Object { $_.NonRemovable -eq $False } | Select-Object -Property PackageFamilyName
        }
        Else {
            # Get packages for the current user
            Write-Verbose -Message "$($MyInvocation.MyCommand): Enumerating current user apps only."
            $packagesAllUsers = Get-AppxPackage -PackageTypeFilter Main, Resource | `
                Where-Object { $_.NonRemovable -eq $False } | Select-Object -Property PackageFamilyName
        }
        # Select unique packages
        $uniquePackagesAllUsers = $packagesAllUsers.PackageFamilyName | Sort-Object -Unique

        If ($Null -ne $uniquePackagesAllUsers) {
            # Filter out the Allowlisted apps
            Write-Verbose -Message "$($MyInvocation.MyCommand): Filtering Allowlisted apps."
            $packagesWithoutAllowlist = Compare-Object -ReferenceObject $uniquePackagesAllUsers -DifferenceObject $Allowlist -PassThru

            # Filter list if it contains apps from the $protectList
            $packagesToRemove = Edit-ProtectedApp -PackageList $packagesWithoutAllowlist
        }
        Else {
            $packagesToRemove = $Null
        }
    }
}

# Remove the apps; Walk through each package in the array
ForEach ($app in $packagesToRemove) {
           
    # Get the AppX package object by passing the string to the left of the underscore
    # to Get-AppxPackage and passing the resulting package object to Remove-AppxPackage
    $Name = ($app -split "_")[0]
    Write-Verbose -Message "$($MyInvocation.MyCommand): Evaluating: [$Name]."
    If ($Elevated) {
        $package = Get-AppxPackage -Name $Name -AllUsers
    }
    Else {
        $package = Get-AppxPackage -Name $Name
    }
    If ($package) {
        If ($PSCmdlet.ShouldProcess($package.PackageFullName, "Remove User app")) {
            try {
                $package | Remove-AppxPackage -ErrorAction SilentlyContinue
            }
            catch [System.Exception] {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove: [$($package.PackageFullName)]."
                Throw $_.Exception.Message
                Break
            }
            finally {
                $removedPackage = New-Object -TypeName System.Management.Automation.PSObject
                $removedPackage | Add-Member -Type "NoteProperty" -Name 'RemovedPackage' -Value $app
                Write-Output -InputObject $removedPackage
            }
        }
    }

    # Remove the provisioned package as well, completely from the system
    If ($Elevated) {
        $package = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq (($app -split "_")[0])
        If ($package) {
            If ($PSCmdlet.ShouldProcess($package.PackageName, "Remove Provisioned app")) {
                try {
                    $action = Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction SilentlyContinue
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove: [$($package.PackageName)]."
                    Throw $_.Exception.Message
                    Break
                }
                finally {
                    $removedPackage = New-Object -TypeName System.Management.Automation.PSObject
                    $removedPackage | Add-Member -Type "NoteProperty" -Name 'RemovedProvisionedPackage' -Value $app
                    Write-Output -InputObject $removedPackage
                    If ($action.RestartNeeded -eq $True) { Write-Warning -Message "$($MyInvocation.MyCommand): Reboot required: [$($package.PackageName)]" }
                }
            }
        }
    }
}
