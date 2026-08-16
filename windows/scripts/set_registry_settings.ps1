#Requires -RunAsAdministrator

param(
    [string]$ConfigFile = "$PSScriptRoot\..\config\settings\registry.json"
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\registry.ps1"

$configSettings = Get-Content "$ConfigFile" -Raw | ConvertFrom-Json

$restartWindowsExplorer = $false

Write-Information "Applying settings to Windows Registry"

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
    Write-Information "Restarting Windows Explorer"
    
    taskkill.exe /F /IM "explorer.exe"
    Start-Process "explorer.exe"
}