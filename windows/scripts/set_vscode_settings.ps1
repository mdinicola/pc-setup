param(
    [string]$ConfigFile = "$PSScriptRoot\..\..\common\files\vscode_settings.json"
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

$destinationConfigFolder = "$env:APPDATA\Code\User"
$destinationConfigFile = "$destinationConfigFolder\settings.json"

if (Test-Path -Path "$destinationConfigFile" -PathType Leaf) {
    Write-Information "VS Code settings file already exists.  Nothing to do"
    exit 0
}

Write-Information "Writing VS Code settings to $destinationConfigFile"

# create config folder if it does not exist
New-Item -Path "$destinationConfigFolder" -ItemType Directory -Force | Out-Null
Copy-Item -Path "$ConfigFile" -Destination "$destinationConfigFile"