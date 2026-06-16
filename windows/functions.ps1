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

function Invoke-Task {
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

function Get-TaskTags {
    param(
        [Parameter(Mandatory)]
        [array]$Tasks
    )

    @(
        $Tasks | ForEach-Object {
            $_.Tags
        } | ForEach-Object {
            $_.ToLowerInvariant()
        } | Sort-Object -Unique
    )
}

function Get-SelectedTasks {
    param(
        [Parameter(Mandatory)]
        [array]$Tasks,

        [string[]]$Tags
    )

    if (-not $Tags) {
        return @($Tasks)
    }

    @(
        $Tasks | Where-Object {
            $taskTags = @($_.Tags | ForEach-Object { $_.ToLowerInvariant() })
            @($taskTags | Where-Object { $_ -in $Tags }).Count -gt 0
        }
    )
}

function Invoke-TaggedTasks {
    param(
        [Parameter(Mandatory)]
        [array]$Tasks,

        [string[]]$Tags,

        [switch]$DryRun
    )

    $requestedTags = Get-NormalizedTags -Tags $Tags
    $knownTags = Get-TaskTags -Tasks $Tasks
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
        Write-Host "Running all tasks"
    }

    $selectedTasks = Get-SelectedTasks -Tasks $Tasks -Tags $requestedTags

    foreach ($task in $selectedTasks) {
        Invoke-Task $task.Name $task.Action
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
