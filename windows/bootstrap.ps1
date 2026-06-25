param(
    [switch]$DryRun,
    [string[]]$Tags
)

. "$PSScriptRoot\functions.ps1"

$tasks = @(
    @{
        Name = "Installing Apps"
        Tags = @("apps-main")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\apps.yaml" -DryRun:$DryRun
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

Invoke-TaggedTasks -Tasks $tasks -Tags $Tags -TagAliases $tagAliases -DryRun:$DryRun
