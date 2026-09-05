#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\debloat\winutil.json",
    [string]$LogFolder = ""
)

$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\processes.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "debloat" -LogFolder "$LogFolder"

try {
    Write-LogMessage "Debloating system using WinUtil"
    Invoke-WinUtil -ConfigFile "$ConfigFile"
}
finally {
    Stop-Logging
}