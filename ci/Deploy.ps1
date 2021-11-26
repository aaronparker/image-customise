<#
    .SYNOPSIS
        Update version number and push to GitHub
#> 
[OutputType()]
Param()

# Line break for readability in the console
Write-Host ""

If (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
    $projectRoot = Resolve-Path -Path $env:GITHUB_WORKSPACE
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
    
try {
    [System.String] $newVersion = New-Object -TypeName "System.Version" -ArgumentList ((Get-Date -Format "yyMM"), (Get-Date -Format "dd"), $env:GITHUB_RUN_NUMBER)
    Write-Output -InputObject "New Version: $newVersion"
            
    # Update the version string in VERSION.txt
    $VersionTxt = [System.IO.Path]::Combine($projectRoot, "src", "VERSION.txt")
    $newVersion | Out-File -FilePath $VersionTxt -Encoding "ascii" -Force -NoNewline
    [System.Environment]::SetEnvironmentVariable("NEWVERSION", $newVersion)
}
catch {
    throw $_
}

# Publish the new version back to Main on GitHub
try {
    # Set up a path to the git.exe cmd, import posh-git to give us control over git
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    Import-Module posh-git -ErrorAction Stop

    # Dot source Invoke-Process.ps1. Prevent 'RemoteException' error when running specific git commands
    . $projectRoot\ci\Invoke-Process.ps1

    # Configure the git environment
    git config --global credential.helper store
    git remote set-url --push origin "https://$($env:GITHUB_ACTOR):$($env:GITHUB_TOKEN)@github.com/$($env:GITHUB_REPOSITORY).git"
    #git config --global user.email aaron@stealthpuppy.com
    #git config --global user.name "Aaron Parker"
    git config --global core.autocrlf true
    git config --global core.safecrlf false

    # Push changes to GitHub
    Invoke-Process -FilePath "git" -ArgumentList "checkout main"
    git add --all
    git tag "v$newVersion"
    git status
    git commit -s -m "$newVersion"
    Invoke-Process -FilePath "git" -ArgumentList "push origin main"
}
catch {
    # Sad panda; it broke
    Write-Warning -Message "Push to GitHub failed."
    Throw $_
}
Write-Host "$module $newVersion pushed to GitHub."


# Line break for readability in console
Write-Host ""
