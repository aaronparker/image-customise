<#
    .SYNOPSIS
        AppVeyor pre-deploy script.
#> 
[OutputType()]
Param()

# Line break for readability in AppVeyor console
Write-Host ""

# Make sure we're using the Main branch and that it's not a pull request
# Environmental Variables Guide: https://www.appveyor.com/docs/environment-variables/
If ($env:APPVEYOR_REPO_BRANCH -ne 'main') {
    Write-Warning -Message "Skipping version increment and push for branch $env:APPVEYOR_REPO_BRANCH"
}
ElseIf ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0) {
    Write-Warning -Message "Skipping version increment and push for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
}
Else {

    If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
        # AppVeyor Testing
        $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    }
    Else {
        # Local Testing 
        $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    }
    
    # Tests success, push to GitHub
    If ($res.FailedCount -eq 0) {
        Try {
            [System.String] $newVersion = New-Object -TypeName "System.Version" -ArgumentList ((Get-Date -Format "yyMM"), (Get-Date -Format "dd"), $env:APPVEYOR_BUILD_NUMBER)
            Write-Output -InputObject "New Version: $newVersion"
            
            # Update the version string in VERSION.txt
            $VersionTxt = [System.IO.Path]::Combine($projectRoot, "src", "VERSION.txt")
            $newVersion | Out-File -FilePath $VersionTxt -Encoding "utf8" -Force -NoNewline

            # Update major version format appveyor.yml as month changes
            $yml = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath "appveyor.yml"
            $replaceString = "version: .*\.\{build\}"
            $versionString = "version: $(Get-Date -Format "yyMM").$(Get-Date -Format "dd").{build}"
            (Get-Content -Path $yml) -replace $replaceString, $versionString | Set-Content -Path $yml
        }
        Catch {
            Throw $_
        }

        # Publish the new version back to Main on GitHub
        Try {
            # Set up a path to the git.exe cmd, import posh-git to give us control over git
            $env:Path += ";$env:ProgramFiles\Git\cmd"
            Import-Module posh-git -ErrorAction Stop

            # Dot source Invoke-Process.ps1. Prevent 'RemoteException' error when running specific git commands
            . $projectRoot\ci\Invoke-Process.ps1

            # Configure the git environment
            git config --global credential.helper store
            Add-Content -Path (Join-Path -Path $env:USERPROFILE -ChildPath ".git-credentials") -Value "https://$($env:GitHubKey):x-oauth-basic@github.com`n"
            git config --global user.email "$($env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL)"
            git config --global user.name "$($env:APPVEYOR_REPO_COMMIT_AUTHOR)"
            git config --global core.autocrlf true
            git config --global core.safecrlf false

            # Push changes to GitHub
            Invoke-Process -FilePath "git" -ArgumentList "checkout main"
            git add --all
            git status
            git commit -s -m "AppVeyor validate: $newVersion"
            Invoke-Process -FilePath "git" -ArgumentList "push origin main"
            Write-Host "$module $newVersion pushed to GitHub." -ForegroundColor Cyan
        }
        Catch {
            # Sad panda; it broke
            Write-Warning -Message "Push to GitHub failed."
            Throw $_
        }
    }
}

# Line break for readability in AppVeyor console
Write-Host ""
