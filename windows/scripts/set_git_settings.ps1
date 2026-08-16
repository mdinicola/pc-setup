param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\settings\git.json"
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"

$configSettings = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

Write-Information "Refreshing path env var"
$env:Path = Get-EnvironmentPath

# Error out if git cannot be found
$git = Get-Command 'git' -CommandType Application -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Error "Git is not installed or is not available"
    exit 1
}

Write-Information "Applying git settings"

foreach ($setting in $configSettings) {
    Write-Information "Setting $($setting.name) to $($setting.value)"
    Invoke-Program -ProgramPath git -ArgumentList @(
        'config'
        "--$($setting.scope)",
        "$($setting.name)",
        "$($setting.value)"
    )
}