#description: Updates all installed Microsoft Store apps
#execution mode: Combined
#tags: Image, Optimise, Store

function Update-StoreApp {
    <#
        .SYNOPSIS
            Updates Microsoft Store apps by package family name.

        .DESCRIPTION
            This script updates Microsoft Store apps by package family name using the
            Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT API.

        .PARAMETER PackageFamilyName
            Specifies the package family names of the apps to be updated. By default, it includes a list of commonly installed Microsoft Store apps.

        .EXAMPLE
            PS C:\> Update-StoreApp -PackageFamilyName "Microsoft.WindowsTerminal_8wekyb3d8bbwe", "Microsoft.WindowsCalculator_8wekyb3d8bbwe"

            Updates the specified Microsoft Store apps.

        .EXAMPLE
            PS C:\> Get-AppxPackage | Where-Object { $_.NonRemovable -eq $false -and $_.IsFramework -eq $false } | Update-StoreApp

            Use Get-AppxPackage to find all installed apps that are not removable and not framework apps, and then updates them.

        .NOTES
            - This script requires Windows PowerShell 5.1 or later.
            - The script may have problems when run with PowerShell Core (pwsh) on some platforms. It is recommended to run it with legacy Windows PowerShell (powershell.exe)
            - The script uses the Add-Type cmdlet to load the System.Runtime.WindowsRuntime assembly and enable the Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT type
            - The script uses the Await function to convert WinRT tasks to .NET tasks and wait for their completion
            - The script uses the UpdateAppByPackageFamilyNameAsync method of the AppInstallManager class to request updates for the specified apps
            - The script periodically checks the update status and displays a progress bar until the update is completed
            - The script can be run as system (i.e. to use when creating a gold image)

            Source: https://github.com/microsoft/winget-cli/discussions/1738
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.ArrayList] $PackageFamilyName = (
            "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
            "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
            "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",
            "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
            "Microsoft.Paint_8wekyb3d8bbwe",
            "Microsoft.WindowsAlarms_8wekyb3d8bbwe".
            "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe",
            "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
            "Microsoft.WindowsStore_8wekyb3d8bbwe")
    )

    begin {
        if ((Get-CimInstance -ClassName "CIM_OperatingSystem").Caption -match "Microsoft Windows Server*") {
            Write-Warning -Message "This script is not intended to be run on Windows Server."
            exit
        }

        if ($PSVersionTable.PSVersion.Major -ne 5) {
            $Msg = "This script has problems in pwsh on some platforms; please run it with legacy Windows PowerShell."
            throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
        }

        # https://fleexlab.blogspot.com/2018/02/using-winrts-iasyncoperation-in.html
        Add-Type -AssemblyName "System.Runtime.WindowsRuntime"
        $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | `
                Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

        function Await($WinRtTask, $ResultType) {                
            $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
            $netTask = $asTask.Invoke($null, @($WinRtTask))
            $netTask.Wait(-1) | Out-Null
            $netTask.Result
        }
    }

    process {
        try {
            # https://docs.microsoft.com/uwp/api/windows.applicationmodel.store.preview.installcontrol.appinstallmanager?view=winrt-22000
            # We need to tell PowerShell about this WinRT API before we can call it
            Write-Verbose -Message "Enabling Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT type"
            [Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager, Windows.ApplicationModel.Store.Preview, ContentType = WindowsRuntime] | Out-Null
            $AppManager = New-Object -TypeName "Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager"

            foreach ($App in $PackageFamilyName) {
                try {
                    Write-Verbose -Message "Requesting an update for: $App"
                    $updateOp = $AppManager.UpdateAppByPackageFamilyNameAsync($App)
                    $updateResult = Await $updateOp ([Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallItem])
                    while ($true) {
                        if ($null -eq $updateResult) {
                            Write-Verbose -Message "Update is null. It must already be completed (or there was no update)."
                            break
                        }

                        if ($null -eq $updateResult.GetCurrentStatus()) {
                            Write-Verbose -Message "Current status is null."
                            break
                        }

                        Write-Progress -Activity $App -Status "Updating" -PercentComplete $updateResult.GetCurrentStatus().PercentComplete
                        if ($updateResult.GetCurrentStatus().PercentComplete -eq 100) {
                            break
                        }
                        Start-Sleep -Seconds 3
                    }
                    Write-Progress -Activity $App -Status "Updating" -Completed
                }
                catch [System.AggregateException] {
                    # If the thing is not installed, we can't update it. In this case, we get an
                    # ArgumentException with the message "Value does not fall within the expected
                    # range." I cannot figure out why *that* is the error in the case of "app is
                    # not installed"... perhaps we could be doing something different/better, but
                    # I'm happy to just let this slide for now.
                    $problem = $_.Exception.InnerException # we'll just take the first one
                    Write-Verbose -Message "Error updating app $($App): $problem"
                }
                catch {
                    Write-Error -Message "Unexpected error updating app $($App): $($_.Exception.Message)"
                }
            }
        }
        catch {
            throw $_
        }
    }
}

# Get-AppxPackage to find all installed apps that are not removable and not framework apps, and then updates them
Get-AppxPackage | `
    Where-Object { $_.NonRemovable -eq $false -and $_.IsFramework -eq $false } | `
    Update-StoreApp
