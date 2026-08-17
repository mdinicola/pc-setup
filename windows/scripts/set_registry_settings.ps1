#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\settings\registry.json",
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\registry.ps1"
. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "settings_registry" -LogFolder "$LogFolder"

try {
    $configSettings = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

    $restartWindowsExplorer = $false

    Write-LogMessage "Applying settings to Windows Registry"

    foreach ($setting in $configSettings) {
        $result = Set-RegistryValue `
            -Description $setting.description `
            -KeyPath $setting.keyPath `
            -KeyName $setting.keyName `
            -Type $setting.type `
            -Value $setting.value

        if ($result -eq $true) {
            $restartWindowsExplorer = $true
        }
    }

    if ($restartWindowsExplorer) {
        Write-LogMessage "Restarting Windows Explorer"
        
        taskkill.exe /F /IM "explorer.exe"
        Start-Process "explorer.exe"
    }
}
finally {
    Stop-Logging
}