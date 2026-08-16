#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\debloat\winutil.json"
)

$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"

Write-Information "Debloating system using WinUtil"
Invoke-WinUtil -ConfigFile "$ConfigFile"