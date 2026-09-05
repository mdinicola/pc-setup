param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\apps\scoop.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\envvars.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "apps_scoop" -LogFolder "$LogFolder"

try {
    $config = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

    Write-LogMessage "Refreshing path env var"
    $env:Path = Get-EnvironmentPath

    # Install scoop if not installed
    if (Test-Path -Path "$HOME\scoop" -PathType Container) {
        Write-LogMessage "Scoop is already installed. Skipping installation"
    }
    else {
        Write-LogMessage "Installing Scoop"
        Install-Scoop
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

    foreach ($bucket in $config.buckets) {
        # Remove the buckets first because scoop might throw git merge conflicts otherwise
        Write-LogMessage "Removing $($bucket.name) bucket"
        Invoke-Program -ProgramPath scoop -ArgumentList @(
            'bucket'
            'rm'
            "$($bucket.name)"
        ) -AllowedExitCodes @(0, 1)
        
        Write-LogMessage "Adding $($bucket.name) bucket"
        if ($bucket.url) {
            Invoke-Program -ProgramPath scoop -ArgumentList @(
                'bucket'
                'add'
                "$($bucket.name)"
                "$($bucket.url)"
            )
        }
        else {
            Invoke-Program -ProgramPath scoop -ArgumentList @(
                'bucket'
                'add'
                "$($bucket.name)"
            )
        }
        
    }

    # Install Scoop Applications
    Write-LogMessage "Installing scoop applications"

    foreach ($app in $config.apps) {
        $appName = $app.name

        Write-LogMessage "Installing app $appName"
        Invoke-Program -ProgramPath scoop -ArgumentList @(
            'install'
            "$appName"
        )
    }
}
finally {
    Stop-Logging
}