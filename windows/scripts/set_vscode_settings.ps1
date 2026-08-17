param(
    [string]$ConfigFile = "$PSScriptRoot\..\..\common\files\vscode_settings.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "settings_vscode" -LogFolder "$LogFolder"

try {
    $destinationConfigFolder = "$env:APPDATA\Code\User"
    $destinationConfigFile = "$destinationConfigFolder\settings.json"

    if (Test-Path -Path "$destinationConfigFile" -PathType Leaf) {
        Write-LogMessage "VS Code settings file already exists.  Nothing to do"
        exit 0
    }

    Write-LogMessage "Writing VS Code settings to $destinationConfigFile"

    # create config folder if it does not exist
    New-Item -Path "$destinationConfigFolder" -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$ConfigFile" -Destination "$destinationConfigFile"
}
finally {
    Stop-Logging
}