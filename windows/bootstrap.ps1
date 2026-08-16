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
        Name = "Install WinGet Apps"
        Tags = @("apps-winget")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsDirectory\install_winget_apps.ps1"
        }
    },
    @{
        Name = "Install Scoop Apps"
        Tags = @("apps-scoop")
        Action = {
            Invoke-Program -ProgramPath "$scriptsDirectory\install_scoop_apps.ps1"
        }
    },
    @{
        Name = "Install Mise Apps"
        Tags = @("apps-mise")
        Action = {
            Invoke-Program -ProgramPath "$scriptsDirectory\install_mise_apps.ps1"
        }
    },
    @{
        Name = "Set Registry Settings"
        Tags = @("settings-registry")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsDirectory\set_registry_settings.ps1"
        }
    },
    @{
        Name = "Set Git Settings"
        Tags = @("settings-git")
        Action = {
            Invoke-Program -ProgramPath "$scriptsDirectory\set_git_settings.ps1"
        }
    },
    @{
        Name = "Set VS Code Settings"
        Tags = @("settings-vscode")
        Action = {
            Invoke-Program -ProgramPath "$scriptsDirectory\set_vscode_settings.ps1"
        }
    },
    @{
        Name = "Set OpenTofu Settings"
        Tags = @("settings-opentofu")
        Action = {
            Invoke-Program -ProgramPath "$scriptsDirectory\set_opentofu_settings.ps1"
        }
    },
    @{
        Name = "Run WinUtil"
        Tags = @("winutil-interactive")
        Action = {
            Invoke-ElevatedScript -ScriptPath "$scriptsDirectory\run_winutil.ps1"
        }
    }
)

$tagAliases = @{
    "all" = @("debloat", "settings-registry", "apps-winget", "apps-scoop", "apps-mise", 
        "settings-git", "settings-vscode", "settings-opentofu")
    "apps" = @("apps-winget", "apps-scoop", "apps-mise")
    "settings" = @("settings-registry", "settings-git", "settings-vscode", "settings-opentofu")
}

Invoke-TaggedTask -Tasks $tasks -Tags $Tags -TagAliases $tagAliases
