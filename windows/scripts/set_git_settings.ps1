param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\settings\git.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "settings_git" -LogFolder "$LogFolder"

try {
    $configSettings = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

    Write-LogMessage "Refreshing path env var"
    $env:Path = Get-EnvironmentPath

    # Error out if git cannot be found
    $git = Get-Command 'git' -CommandType Application -ErrorAction SilentlyContinue
    if (-not $git) {
        Write-Error "Git is not installed or is not available"
        exit 1
    }

    Write-LogMessage "Applying git settings"

    foreach ($setting in $configSettings) {
        Write-LogMessage "Setting $($setting.name) to $($setting.value)"
        Invoke-Program -ProgramPath git -ArgumentList @(
            'config'
            "--$($setting.scope)"
            "$($setting.name)"
            "$($setting.value)"
        )
    }
}
finally {
    Stop-Logging
}