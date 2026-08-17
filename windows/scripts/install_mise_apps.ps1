param(
    [string]$ConfigFile = "$PSScriptRoot\..\..\common\files\mise.global.toml",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "apps_mise" -LogFolder "$LogFolder"

try {
    Write-LogMessage "Refreshing path env var"
    $env:Path = Get-EnvironmentPath

    # Add scoop shims folder to session path if it is not in system path already
    $scoopShimsPath = "$HOME\scoop\shims"
    if (-not (Test-FolderInEnvironmentPath -FolderPath "$scoopShimsPath")) {
        $env:Path = "$scoopShimsPath;$env:Path"
    }

    # Error out if mise cannot be found
    $mise = Get-Command 'mise' -CommandType Application -ErrorAction SilentlyContinue
    if (-not $mise) {
        Write-Error "Mise is not installed or is not available"
        exit 1
    }

    $destinationConfigFolder = "$HOME\.config\mise"
    $destinationConfigFile = "$destinationConfigFolder\config.toml"

    # Configure mise
    if (Test-Path -Path "$destinationConfigFile" -PathType Leaf) {
        Write-LogMessage "Mise config file already exists.  Skipping configuration"
    }
    else {
        Write-LogMessage "Writing mise config file to $destinationConfigFile"
        New-Item -Path "$destinationConfigFolder" -ItemType Directory -Force | Out-Null
        Copy-Item -Path "$ConfigFile" -Destination "$destinationConfigFile"
    }

    Write-LogMessage "Installing mise applications and tools"
    Invoke-Program -ProgramPath mise -ArgumentList @('install')
}
finally {
    Stop-Logging
}