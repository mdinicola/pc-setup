param(
    [switch]$DryRun,
    [string[]]$Tags
)

. "$PSScriptRoot\functions.ps1"

$tasks = @(
    @{
        Name = "Installing Apps"
        Tags = @("apps")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\apps.yaml" -DryRun:$DryRun
        }
    },
    @{
        Name = "Installing Dev Apps"
        Tags = @("dev")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\dev.yaml" -DryRun:$DryRun
        }
    },
    @{
        Name = "Installing Dev Apps (Optional)"
        Tags = @("dev-optional")
        Action = {
            Invoke-WingetConfigure -File "configs\apps\dev_optional.yaml" -DryRun:$DryRun
        }
    },
    @{
        Name = "Configure Brave Settings"
        Tags = @("brave", "settings")
        Action = {
            Invoke-WingetConfigure -File "configs\settings\brave_browser.yaml" -DryRun:$DryRun
        }
    }
)

Invoke-TaggedTasks -Tasks $tasks -Tags $Tags -DryRun:$DryRun
