function Write-Section {
    param(
        [string]$Title
    )

    Write-Host ""
    Write-Host ("=" * 80)
    Write-Host " $Title"
    Write-Host ("=" * 80)
    Write-Host ""
}

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Section "$Name"

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    & $Action

    $sw.Stop()

    Write-Host "✓ Completed in $($sw.Elapsed.ToString('mm\:ss'))"
}

function Get-NormalizedTags {
    param(
        [string[]]$Tags
    )

    @(
        $Tags | ForEach-Object {
            $_ -split ","
        } | ForEach-Object {
            $_.Trim().ToLowerInvariant()
        } | Where-Object {
            $_
        }
    )
}

function Get-StepTags {
    param(
        [Parameter(Mandatory)]
        [array]$Steps
    )

    @(
        $Steps | ForEach-Object {
            $_.Tags
        } | ForEach-Object {
            $_.ToLowerInvariant()
        } | Sort-Object -Unique
    )
}

function Get-SelectedSteps {
    param(
        [Parameter(Mandatory)]
        [array]$Steps,

        [string[]]$Tags
    )

    if (-not $Tags) {
        return @($Steps)
    }

    @(
        $Steps | Where-Object {
            $stepTags = @($_.Tags | ForEach-Object { $_.ToLowerInvariant() })
            @($stepTags | Where-Object { $_ -in $Tags }).Count -gt 0
        }
    )
}

function Invoke-TaggedSteps {
    param(
        [Parameter(Mandatory)]
        [array]$Steps,

        [string[]]$Tags,

        [switch]$DryRun
    )

    $requestedTags = Get-NormalizedTags -Tags $Tags
    $knownTags = Get-StepTags -Steps $Steps
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

    $selectedSteps = Get-SelectedSteps -Steps $Steps -Tags $requestedTags

    foreach ($step in $selectedSteps) {
        Invoke-Step $step.Name $step.Action
    }
}

function Invoke-WingetConfigure {
    param(
        [Parameter(Mandatory)]
        [string]$File,

        [switch]$DryRun
    )

    $args = @("configure")

    if ($DryRun) {
        $args += "test"
    }

    $args += @(
        "--file", $File,
        "--accept-configuration-agreements",
        "--nowarn",
        "--disable-interactivity"
    )

    winget @args
}
