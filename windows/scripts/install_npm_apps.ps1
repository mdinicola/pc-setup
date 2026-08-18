param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\apps\npm.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "apps_npm" -LogFolder "$LogFolder"

try {
    $config = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

    Write-LogMessage "Refreshing path env var"
    $env:Path = Get-EnvironmentPath

    # Error out if npm cannot be found
    $npm = Get-Command 'npm' -CommandType Application -ErrorAction SilentlyContinue
    if (-not $npm) {
        Write-Error "npm is not installed or is not available"
        exit 1
    }

    # Install NPM Applications
    Write-LogMessage "Installing npm applications"

    foreach ($app in $config) {
        Write-LogMessage "Installing app $app"
        Invoke-Program -ProgramPath npm -ArgumentList @(
            'install'
            '--global'
            "$app"
        )
    }
}
finally {
    Stop-Logging
}