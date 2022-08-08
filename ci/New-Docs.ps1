$OutFile = [System.IO.Path]::Combine("docs/registry.md")
$markdown = New-MDHeader -Text "Registry Settings" -Level 1
$markdown += "`n"

foreach ($file in (Get-ChildItem -Path "*.json")) {

    $json = Get-Content -Path $file.FullName | ConvertFrom-Json
    if ($Null -ne $json.Registry.Set) {
        $markdown += New-MDHeader -Text $file.Name -Level 2
        $markdown += "`n"
        $markdown += "Minimum build: $($json.MinimumBuild)`n"
        $markdown += "Maximum build: $($json.MaximumBuild)`n"
        if ($Null -ne $json.Registry.Type) {
            $markdown += "Type: $($json.Registry.Type)`n"
        }
        $markdown += "`n"
        $markdown += $json.Registry.Set | Select-Object -Property "path", "name", "value" | New-MDTable
        $markdown += "`n"
    }
}

($markdown.TrimEnd("`n")) | Out-File -FilePath $OutFile -Force -Encoding "Utf8"
