param(
    [string[]]$Tags
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\functions\logging.ps1"
. "$PSScriptRoot\functions\tasks.ps1"
. "$PSScriptRoot\functions\tags.ps1"
. "$PSScriptRoot\functions\processes.ps1"

$scriptsDirectory = "$PSScriptRoot\scripts"

$tasks = @(
    @{
        Name = "Debloat Windows"
        Tags = @("debloat")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsDirectory\debloat.ps1"
        }
    },
    @{
        Name = "Installing Dev Apps"
        Tags = @("apps-dev")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\dev.yaml" -DryRun:$DryRun
        }
    },
    @{
        Name = "Installing Dev Apps (Optional)"
        Tags = @("apps-dev-optional")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\dev_optional.yaml" -DryRun:$DryRun
        }
    },
    @{
        Name = "Configure Brave Settings"
        Tags = @("brave-browser")
        Action = {
            Invoke-WingetConfigure -File "configs\settings\brave_browser.yaml" -DryRun:$DryRun
        }
    }
)

$tagAliases = @{
    "all" = @("apps-main", "apps-dev", "apps-dev-optional", "brave-browser")
    "apps" = @("apps-main", "apps-dev")
    "apps-full" = @("apps-main", "apps-dev", "apps-dev-optional")
    "dev" = @("apps-dev")
    "dev-full" = @("apps-dev", "apps-dev-optional")
    "browser" = @("brave-browser")
    "settings" = @("brave-browser")
}

Invoke-TaggedTask -Tasks $tasks -Tags $Tags -TagAliases $tagAliases
