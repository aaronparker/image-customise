<#
    Update the App.json for packages
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
param (
    [Parameter()]
    [System.String] $Path,

    [Parameter()]
    [System.String] $Version
)

# Get the content
$AppData = Get-Content -Path $Path | ConvertFrom-Json

# If the version that Evergreen returns is higher than the version in the manifest
if ([System.Version]$Version -ge [System.Version]$AppData.PackageInformation.Version) {

    # Update the manifest with the application setup file
    Write-Host -ForegroundColor "Cyan" "Update package."
    $AppData.PackageInformation.Version = $Version
    $AppData.Information.DisplayName = "Windows Customised Defaults $Version"

    # Step through each DetectionRule to update version properties
    for ($i = 0; $i -le $AppData.DetectionRule.Count - 1; $i++) {

        if ("Value" -in ($AppData.DetectionRule[$i] | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            $AppData.DetectionRule[$i].Value = $Version
        }

        if ("VersionValue" -in ($AppData.DetectionRule[$i] | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            $AppData.DetectionRule[$i].VersionValue = $Version
        }

        if ("ProductVersion" -in ($AppData.DetectionRule[$i] | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            $AppData.DetectionRule[$i].ProductVersion = $Version
        }
    }

    # Write the application manifest back to disk
    Write-Host -ForegroundColor "Cyan" "Output: $Path."
    $AppData | ConvertTo-Json | Out-File -FilePath $Path -Force
}
elseif ([System.Version]$Version -lt [System.Version]$AppData.PackageInformation.Version) {
    Write-Host -ForegroundColor "Cyan" "$($Version) less than $($AppData.PackageInformation.Version)."
}
else {
    Write-Host -ForegroundColor "Cyan" "Could not compare package version."
}
