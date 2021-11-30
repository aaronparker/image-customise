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
ForEach ($item in $release) {
    ForEach ($asset in $item.assets) {
        If ($asset.browser_download_url -match $Filter) {
            $asset.browser_download_url
        }
    }
}
