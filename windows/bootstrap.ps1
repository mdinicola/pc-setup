param(
    [switch]$DryRun,
    [string[]]$Tags
)

. "$PSScriptRoot\functions.ps1"

$steps = @(
    @{
        Name = "Installing Apps"
        Tags = @("apps")
        File = "configs\apps\apps.yaml"
    },
    @{
        Name = "Installing Dev Apps"
        Tags = @("dev")
        File = "configs\apps\dev.yaml"
    },
    @{
        Name = "Installing Dev Apps (Optional)"
        Tags = @("dev-optional")
        File = "configs\apps\dev_optional.yaml"
    },
    @{
        Name = "Configure Brave Settings"
        Tags = @("brave", "settings")
        File = "configs\settings\brave_browser.yaml"
    }
)

$requestedTags = @(
    $Tags | ForEach-Object {
        $_ -split ","
    } | ForEach-Object {
        $_.Trim().ToLowerInvariant()
    } | Where-Object {
        $_
    }
)

$knownTags = @(
    $steps | ForEach-Object {
        $_.Tags
    } | ForEach-Object {
        $_.ToLowerInvariant()
    } | Sort-Object -Unique
)

$unknownTags = @(
    $requestedTags | Where-Object {
        $_ -notin $knownTags
    } | Sort-Object -Unique
)

if ($unknownTags) {
    Write-Error "Unknown tag(s): $($unknownTags -join ', '). Available tags: $($knownTags -join ', ')"
    exit 1
}

if ($DryRun) {
    Write-Section "Running in TEST mode"
}
else {
    Write-Section "Running in REAL RUN mode"
}

if ($requestedTags) {
    Write-Host "Running tags: $($requestedTags -join ', ')"
}
else {
    Write-Host "Running all steps"
}

$selectedSteps = @(
    if ($requestedTags) {
        $steps | Where-Object {
            $stepTags = @($_.Tags | ForEach-Object { $_.ToLowerInvariant() })
            @($stepTags | Where-Object { $_ -in $requestedTags }).Count -gt 0
        }
    }
    else {
        $steps
    }
)

foreach ($step in $selectedSteps) {
    Invoke-Step $step.Name {
        Invoke-WingetConfigure -File $step.File -DryRun:$DryRun
    }
}
