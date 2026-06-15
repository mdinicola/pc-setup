param(
    [switch]$DryRun
)

. "$PSScriptRoot\functions.ps1"

if ($DryRun) {
    Write-Section "Running in TEST mode"
}
else {
    Write-Section "Running in REAL RUN mode"
}

Invoke-Step "Installing Apps" {
    Invoke-WingetConfigure -File "configs\apps\apps.yaml" -DryRun:$DryRun
}

Invoke-Step "Installing Dev Apps" {
    Invoke-WingetConfigure -File "configs\apps\dev.yaml" -DryRun:$DryRun
}

Invoke-Step "Installing Dev Apps (Optional)" {
    Invoke-WingetConfigure -File "configs\apps\dev_optional.yaml" -DryRun:$DryRun
}

Invoke-Step "Configure Brave Settings" {
    Invoke-WingetConfigure -File "configs\settings\brave_browser.yaml" -DryRun:$DryRun
}