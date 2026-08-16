#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"

Write-Information "Opening WinUtil GUI"
Invoke-WinUtil