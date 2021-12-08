$Uri = "https://api.github.com/repos/aaronparker/image-customise/releases/latest"
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
If ($Null -ne $release) {
    ForEach ($item in $release) {
        ForEach ($asset in $item.assets) {
            If ($asset.browser_download_url -match $Filter) {
                $Uri = $asset.browser_download_url
            }
        }
    }
    $TmpDir = [System.IO.Path]::Combine($Env:Temp, $(New-Guid))
    New-Item -Path $TmpDir -ItemType "Directory" > $Null
    $OutFile = [System.IO.Path]::Combine($TmpDir, $(Split-Path -Path $Uri -Leaf))
    Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
    If (Test-Path -Path $OutFile -ErrorAction "SilentlyContinue") {
        Push-Location -Path $TmpDir
        Expand-Archive -Path $OutFile -DestinationPath $TmpDir -Force
        & [System.IO.Path]::Combine($TmpDir, "Install-Defaults.ps1")
        Pop-Location
        Remove-Item -Path $TmpDir -Recurse -Force
    }
}
