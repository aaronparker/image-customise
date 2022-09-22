$OutFile = [System.IO.Path]::Combine("docs/registry.md")
$markdown = New-MDHeader -Text "Registry Settings" -Level 1
$markdown += "`n"

foreach ($file in (Get-ChildItem -Path "*.json" -Recurse)) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($Null -ne $json.Registry.Set) {
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n`n"
        if ($Null -ne $json.Registry.Type) {
            $markdown += "Type: $($json.Registry.Type)`n"
        }
        $markdown += "`n"
        $markdown += $json.Registry.Set | Select-Object -Property  @{ Name = "path"; Expression = { $_.path -replace "\\", " \" }}, "name", "value", "note" | New-MDTable -Shrink
        $markdown += "`n"
    }
}

($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"
