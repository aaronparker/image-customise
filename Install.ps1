$Uri = "https://api.github.com/repos/aaronparker/defaults/releases/latest"
$Filter = "\.zip$"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$params = @{
    ContentType        = "application/vnd.github.v3+json"
    ErrorAction        = "SilentlyContinue"
    MaximumRedirection = 0
    DisableKeepAlive   = $true
    UseBasicParsing    = $true
    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    Uri                = $Uri
}
$release = Invoke-RestMethod @params
if ($null -ne $release) {
    foreach ($item in $release) {
        foreach ($asset in $item.assets) {
            if ($asset.browser_download_url -match $Filter) {
                $Uri = $asset.browser_download_url
            }
        }
    }
    $TmpDir = $([System.IO.Path]::Combine($Env:Temp, $(New-Guid)))
    New-Item -Path $TmpDir -ItemType "Directory" | Out-Null
    $OutFile = $([System.IO.Path]::Combine($TmpDir, $(Split-Path -Path $Uri -Leaf)))
    Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
    if (Test-Path -Path $OutFile) {
        Push-Location -Path $TmpDir
        Expand-Archive -Path $OutFile -DestinationPath $TmpDir -Force
        Get-ChildItem -Path $TmpDir -Recurse | Unblock-File
        & .\Remove-AppxApps.ps1
        & .\Install-Defaults.ps1
        Pop-Location
        Remove-Item -Path $TmpDir -Recurse -Force
    }
}
