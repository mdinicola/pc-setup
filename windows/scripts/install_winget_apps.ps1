#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\apps\winget.json"
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"

Write-Information "Installing applications with winget"
Invoke-Program -ProgramPath winget -ArgumentList @(
    'import'
    "$ConfigFile",
    "--accept-package-agreements"
    "--accept-source-agreements"
)