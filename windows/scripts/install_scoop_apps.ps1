param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\apps\scoop.json"
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"

$config = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

Write-Information "Refreshing path env var"
$env:Path = Get-EnvironmentPath

# Install scoop if not installed
if (Test-Path -Path "$HOME\scoop" -PathType Container) {
    Write-Information "Scoop is already installed. Skipping installation"
}
else {
    Write-Information "Installing Scoop"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Add scoop shims folder to session path if it is not in system path already
$scoopShimsPath = "$HOME\scoop\shims"
if (-not (Test-FolderInEnvironmentPath -FolderPath "$scoopShimsPath")) {
    $env:Path = "$scoopShimsPath;$env:Path"
}

# Error out if scoop cannot be found
$scoop = Get-Command 'scoop' -CommandType Application -ErrorAction SilentlyContinue
if (-not $scoop) {
    Write-Error "Scoop is not installed or is not available"
    exit 1
}

Write-Information "Adding extras bucket"
Invoke-Program -ErrorAction SilentlyContinue -ProgramPath scoop -ArgumentList @(
    'bucket'
    'add',
    'extras'
)

# Install Scoop Applications
Write-Information "Installing scoop applications"

foreach ($app in $config.apps) {
    $appName = $app.name

    Write-Information "Installing app $appName"
    Invoke-Program -ProgramPath scoop -ArgumentList @(
        'install'
        "$appName"
    )
}