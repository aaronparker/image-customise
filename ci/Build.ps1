<#
    .SYNOPSIS
        AppVeyor build script.
#>
[OutputType()]
Param()

If (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {
    # Do something
}
Else {
    Write-Warning -Message "Required variable does not exist: $projectRoot."
}

# Build the markdown
$string = @()
$string += "# GitHub Variables"
$string += " "
$string += "| Variable | Value |"
$string += "|:--|:--|"
$string += "| GITHUB_WORKFLOW | $env:GITHUB_WORKFLOW |"
$string += "| GITHUB_RUN_ID | $env:GITHUB_RUN_ID |"
$string += "| GITHUB_RUN_NUMBER | $env:GITHUB_RUN_NUMBER |"
$string += "| GITHUB_JOB | $env:GITHUB_JOB |"
$string += "| GITHUB_ACTION | $env:GITHUB_ACTION |"
$string += "| GITHUB_ACTION_PATH | $env:GITHUB_ACTION_PATH |"
$string += "| GITHUB_ACTIONS | $env:GITHUB_ACTIONS |"
$string += "| GITHUB_ACTOR | $env:GITHUB_ACTOR |"
$string += "| GITHUB_REPOSITORY | $env:GITHUB_REPOSITORY |"
$string += "| GITHUB_EVENT_NAME | $env:GITHUB_EVENT_NAME |"
$string += "| GITHUB_EVENT_PATH | $env:GITHUB_EVENT_PATH |"
$string += "| GITHUB_WORKSPACE | $env:GITHUB_WORKSPACE |"
$string += "| GITHUB_SHA | $env:GITHUB_SHA |"
$string += "| GITHUB_REF | $env:GITHUB_REF |"
$string += "| GITHUB_REF_NAME | $env:GITHUB_REF_NAME |"
$string += "| GITHUB_REF_PROTECTED | $env:GITHUB_REF_PROTECTED |"
$string += "| GITHUB_REF_TYPE | $env:GITHUB_REF_TYPE |"
$string += "| GITHUB_HEAD_REF | $env:GITHUB_HEAD_REF |"
$string += "| GITHUB_BASE_REF | $env:GITHUB_BASE_REF |"
$string += "| GITHUB_SERVER_URL | $env:GITHUB_SERVER_URL |"
$string += "| GITHUB_API_URL | $env:GITHUB_API_URL |"
$string += "| GITHUB_GRAPHQL_URL | $env:GITHUB_GRAPHQL_URL |"
$string += "| RUNNER_NAME | $env:RUNNER_NAME |"
$string += "| RUNNER_OS | $env:RUNNER_OS |"
$string += "| RUNNER_TEMP | $env:RUNNER_TEMP |"
$string += "| RUNNER_TOOL_CACHE | $env:RUNNER_TOOL_CACHE |"

# Write $string out to $Path
$Path = "$projectRoot\ci\Variables.md"
$string | Out-File -FilePath $Path -Force



GITHUB_WORKFLOW
GITHUB_RUN_ID
GITHUB_RUN_NUMBER
GITHUB_JOB
GITHUB_ACTION
GITHUB_ACTION_PATH
GITHUB_ACTIONS
GITHUB_ACTOR
GITHUB_REPOSITORY
GITHUB_EVENT_NAME
GITHUB_EVENT_PATH
GITHUB_WORKSPACE
GITHUB_SHA
GITHUB_REF
GITHUB_REF_NAME
GITHUB_REF_PROTECTED
GITHUB_REF_TYPE
GITHUB_HEAD_REF
GITHUB_BASE_REF
GITHUB_SERVER_URL
GITHUB_API_URL
GITHUB_GRAPHQL_URL
RUNNER_NAME
RUNNER_OS
RUNNER_TEMP
RUNNER_TOOL_CACHE
