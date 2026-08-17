#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\apps\winget.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "apps_winget" -LogFolder "$LogFolder"

try {
    Write-LogMessage "Installing applications with winget"
    Invoke-Program -ProgramPath winget -ArgumentList @(
        'import'
        "$ConfigFile"
        "--accept-package-agreements"
        "--accept-source-agreements"
    )
}
finally {
    Stop-Logging
}