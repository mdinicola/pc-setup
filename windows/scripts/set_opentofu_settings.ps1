$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\envvars.ps1"

$pluginCacheFolder = "$HOME\.terraform.d\plugin-cache"
$pluginCacheEnvVarName = "TF_PLUGIN_CACHE_DIR"

New-Item -Path "$pluginCacheFolder" -ItemType Directory -Force | Out-Null

if ((Get-EnvironmentVariable -Name "$pluginCacheEnvVarName") -ne "$pluginCacheFolder") {
    Set-EnvironmentVariable -Name "$pluginCacheEnvVarName" -Value "$pluginCacheFolder" -Scope User
}
else {
    Write-Information "Environment variable $pluginCacheEnvVarName is already set.  Nothing to do"
}