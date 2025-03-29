
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
$Markdown = New-MDHeader -Text "Registry Settings" -Level 1
$Markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Registry.Set) {
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Registry.Set | Select-Object -Property  @{ Name = "path"; Expression = { $_.path -replace "\\", " \" } }, "name", "value", "note" | New-MDTable -Shrink
        $Markdown += "`n"
    }

    if ($null -ne $json.Registry.Remove) {
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Registry.Remove | Select-Object -Property  @{ Name = "path"; Expression = { $_.path -replace "\\", " \" } }, "note" | New-MDTable -Shrink
        $Markdown += "`n"
    }
}
($Markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Capabilities and features
#>
$OutFile = [System.IO.Path]::Combine("docs/features.md")
$Markdown = New-MDHeader -Text "Removed Capabilities and Features" -Level 1
$Markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Capabilities.Remove) {
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Capabilities.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Capability" = $_
            }
        } | New-MDTable -Shrink
        $Markdown += "`n"
    }

    if ($null -ne $json.Features.Disable) {
        $Markdown += "`n"
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Features.Disable | ForEach-Object {
            [PSCustomObject]@{
                "Feature" = $_
            }
        } | New-MDTable -Shrink
        $Markdown += "`n"
    }

    if ($null -ne $json.Packages.Remove) {
        $Markdown += "`n"
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Packages.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Feature" = $_
            }
        } | New-MDTable -Shrink
        $Markdown += "`n"
    }
}
($Markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Paths
#>
$OutFile = [System.IO.Path]::Combine("docs/paths.md")
$Markdown = New-MDHeader -Text "Removed Paths" -Level 1
$Markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Paths.Remove) {
        $Markdown += "`n"
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Paths.Remove | ForEach-Object {
            [PSCustomObject]@{
                "Path" = $_
            }
        } | New-MDTable -Shrink
        $Markdown += "`n"
    }
}
($Markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Services
#>
$OutFile = [System.IO.Path]::Combine("docs/services.md")
$Markdown = New-MDHeader -Text "Services" -Level 1
$Markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Services.Enable) {
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Services.Enable | ForEach-Object {
            [PSCustomObject]@{
                "Service" = $_
            }
        } | New-MDTable -Shrink
        $Markdown += "`n"
    }
}
($Markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"

<#
    Files
#>
$OutFile = [System.IO.Path]::Combine("docs/files.md")
$Markdown = New-MDHeader -Text "Files" -Level 1
$Markdown += "`n"
foreach ($file in $Configs) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($null -ne $json.Files.Copy) {
        $Markdown += New-MDHeader -Text $file.Name -Level 2
        $Markdown += "`n"
        $Markdown += "**$($json.Description)**`n`n"
        $Table = [PSCustomObject]@{
            "Minimum build" = $json.MinimumBuild
            "Maximum build" = $json.MaximumBuild
        }
        if ($null -ne $json.Registry.Type) {
            $Table | Add-Member -MemberType "NoteProperty" -Name "Type" -Value $json.Registry.Type
        }
        $Markdown += $Table | New-MDTable -Shrink
        $Markdown += "`n"
        $Markdown += $json.Files.Copy | New-MDTable -Shrink
        $Markdown += "`n"
    }
}
($Markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"
