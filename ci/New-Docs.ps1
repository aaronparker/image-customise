
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String] $Path
)
$Configs = Get-ChildItem -Path "$Path\*.json" -Recurse

<#
    Registry settings
#>
$OutFile = [System.IO.Path]::Combine("docs/registry.md")
$markdown = New-MDHeader -Text "Registry Settings" -Level 1
$markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Registry.Set) {
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        if ($null -ne $json.Registry.Type) {
            $markdown += "Type: $($json.Registry.Type)`n"
        }
        $markdown += "`n"
        $markdown += $json.Registry.Set | Select-Object -Property  @{ Name = "path"; Expression = { $_.path -replace "\\", " \" } }, "name", "value", "note" | New-MDTable -Shrink
        $markdown += "`n"
    }

    if ($null -ne $json.Registry.Remove) {
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        if ($null -ne $json.Registry.Type) {
            $markdown += "Type: $($json.Registry.Type)`n"
        }
        $markdown += "`n"
        $markdown += $json.Registry.Remove | Select-Object -Property  @{ Name = "path"; Expression = { $_.path -replace "\\", " \" } }, "note" | New-MDTable -Shrink
        $markdown += "`n"
    }
}
($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Capabilities and features
#>
$OutFile = [System.IO.Path]::Combine("docs/features.md")
$markdown = New-MDHeader -Text "Removed Capabilities and Features" -Level 1
$markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Capabilities.Remove) {
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        $markdown += $json.Capabilities.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Capability" = $_
            }
        } | New-MDTable -Shrink
        $markdown += "`n"
    }

    if ($null -ne $json.Features.Disable) {
        $markdown += "`n"
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        $markdown += $json.Features.Disable | ForEach-Object {
            [PSCustomObject]@{
                "Feature" = $_
            }
        } | New-MDTable -Shrink
        $markdown += "`n"
    }

    if ($null -ne $json.Packages.Remove) {
        $markdown += "`n"
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        $markdown += $json.Packages.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Feature" = $_
            }
        } | New-MDTable -Shrink
        $markdown += "`n"
    }
}
($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Paths
#>
$OutFile = [System.IO.Path]::Combine("docs/paths.md")
$markdown = New-MDHeader -Text "Removed Paths" -Level 1
$markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Paths.Remove) {
        $markdown += "`n"
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        $markdown += $json.Paths.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Path" = $_
            }
        } | New-MDTable -Shrink
        $markdown += "`n"
    }
}
($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Services
#>
$OutFile = [System.IO.Path]::Combine("docs/services.md")
$markdown = New-MDHeader -Text "Services" -Level 1
$markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Services.Enable) {
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        $markdown += $json.Services.Enable | ForEach-Object {
            [PSCustomObject]@{
                "Service" = $_
            }
        } | New-MDTable -Shrink
        $markdown += "`n"
    }
}
($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"
