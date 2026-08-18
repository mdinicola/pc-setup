if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
}

Import-Module PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path "$PSScriptRoot\.." -Recurse