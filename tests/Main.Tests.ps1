<#
    .SYNOPSIS
        Main Pester function tests.
#>
[OutputType()]
Param()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}

# Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
$VerbosePreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Describe "General project validation" {
    $scripts = Get-ChildItem -Path $projectRoot -Filter *.ps1
    Write-Host "Found $($scripts.count) scripts."

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | ForEach-Object { @{file = $_ } }
    It "Script <file> should be valid PowerShell" -TestCases $testCase {
        param($file)
        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule
    It "<file> should pass ScriptAnalyzer" -TestCases $testCase {
        param($file)
        $analysis = Invoke-ScriptAnalyzer -Path  $file.fullname -ExcludeRule @('PSAvoidGlobalVars', 'PSAvoidUsingConvertToSecureStringWithPlainText', 'PSAvoidUsingWMICmdlet') -Severity @('Warning', 'Error')   
        
        ForEach ($rule in $scriptAnalyzerRules) {
            If ($analysis.RuleName -contains $rule) {
                $analysis |
                Where-Object RuleName -EQ $rule -outvariable failures |
                Out-Default
                $failures.Count | Should Be 0
            }
        }
    }
}

# Gather scripts
Switch -Regex ((Get-WmiObject Win32_OperatingSystem).Caption) {
    "Microsoft Windows Server*" {
        $Platform = "Server"
    }
    "Microsoft Windows 10 Enterprise for Virtual Desktops" {
        $Platform = "Multi"
    }
    "Microsoft Windows 10*" {
        $Platform = "Client"
    }
}
$Build = ([System.Environment]::OSVersion.Version).Build
If ((Get-WmiObject -Computer . -Class "Win32_ComputerSystem").Model -match "Parallels*|VMware*|Virtual*") {
    $Model = "Virtual"
}
Else {
    $Model = "Physical"
}
$AllScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.All.ps1") -ErrorAction SilentlyContinue)
$PlatformScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Platform.ps1") -ErrorAction SilentlyContinue)
$BuildScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Build.ps1") -ErrorAction SilentlyContinue)
$ModelScripts = @(Get-ChildItem -Path (Join-Path -Path $PWD -ChildPath "*.$Model.ps1") -ErrorAction SilentlyContinue)

Describe 'Script execute validation' -Tag "Windows" {
    ForEach ($script in ($AllScripts + $PlatformScripts + $BuildScripts + $ModelScripts)) {
        Write-Host "Running: $script" -ForegroundColor Cyan
        It 'Script should not Throw' {
            { . $script } | Should Not Throw
        }
    }
}
