param(
    [string[]]$Tags
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\functions\logging.ps1"
. "$PSScriptRoot\functions\tasks.ps1"
. "$PSScriptRoot\functions\tags.ps1"
. "$PSScriptRoot\functions\processes.ps1"

$scriptsFolder = "$PSScriptRoot\scripts"
$logFolder = Get-DefaultLogFolder

$tasks = @(
    @{
        Name = "Debloat Windows"
        Tags = @("debloat")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsFolder\debloat.ps1" -Parameters @(
                '-LogFolder'
                "$logFolder"
            )
        }
    },
    @{
        Name = "Install WinGet Apps"
        Tags = @("apps-winget")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsFolder\install_winget_apps.ps1" -Parameters @(
                '-LogFolder'
                "$logFolder"
            )
        }
    },
    @{
        Name = "Install Scoop Apps"
        Tags = @("apps-scoop")
        Action = {
            Invoke-Script -ScriptPath "$scriptsFolder\install_scoop_apps.ps1" -Parameters @{
                LogFolder = "$logFolder"
            }
        }
    },
    @{
        Name = "Install Mise Apps"
        Tags = @("apps-mise")
        Action = {
            Invoke-Script -ScriptPath "$scriptsFolder\install_mise_apps.ps1" -Parameters @{
                LogFolder = "$logFolder"
            }
        }
    },
    @{
        Name = "Set Registry Settings"
        Tags = @("settings-registry")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsFolder\set_registry_settings.ps1" -Parameters @(
                '-LogFolder'
                "$logFolder"
            )
        }
    },
    @{
        Name = "Set Git Settings"
        Tags = @("settings-git")
        Action = {
            Invoke-Script -ScriptPath "$scriptsFolder\set_git_settings.ps1" -Parameters @{
                LogFolder = "$logFolder"
            }
        }
    },
    @{
        Name = "Set VS Code Settings"
        Tags = @("settings-vscode")
        Action = {
            Invoke-Script -ScriptPath "$scriptsFolder\set_vscode_settings.ps1" -Parameters @{
                LogFolder = "$logFolder"
            }
        }
    },
    @{
        Name = "Set OpenTofu Settings"
        Tags = @("settings-opentofu")
        Action = {
            Invoke-Script -ScriptPath "$scriptsFolder\set_opentofu_settings.ps1" -Parameters @{
                LogFolder = "$logFolder"
            }
        }
    },
    @{
        Name = "Run WinUtil"
        Tags = @("winutil-interactive")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsFolder\run_winutil.ps1"
        }
    }
)

$tagAliases = @{
    "all" = @("debloat", "settings-registry", "apps-winget", "apps-scoop", "apps-mise", 
        "settings-git", "settings-vscode", "settings-opentofu")
    "apps" = @("apps-winget", "apps-scoop", "apps-mise")
    "settings" = @("settings-registry", "settings-git", "settings-vscode", "settings-opentofu")
}

Start-Logging -Name "bootstrap" -LogFolder "$logFolder"

try {
    Invoke-TaggedTask -Tasks $tasks -Tags $Tags -TagAliases $tagAliases
}
finally {
    Stop-Logging
}
