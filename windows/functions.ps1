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

function Get-NormalizedTagAliases {
    param(
        [hashtable]$TagAliases
    )

    $normalizedAliases = @{}

    foreach ($aliasName in @($TagAliases.Keys)) {
        $normalizedAliasName = $aliasName.Trim().ToLowerInvariant()
        $normalizedAliases[$normalizedAliasName] = Get-NormalizedTags -Tags $TagAliases[$aliasName]
    }

    $normalizedAliases
}

function Expand-Tags {
    param(
        [Parameter(Mandatory)]
        [string[]]$Tags,

        [Parameter(Mandatory)]
        [hashtable]$TagAliases
    )

    @(
        $Tags | ForEach-Object {
            if ($TagAliases.ContainsKey($_)) {
                $TagAliases[$_]
            }
            else {
                $_
            }
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

        [hashtable]$TagAliases = @{},

        [switch]$DryRun
    )

    $requestedTags = Get-NormalizedTags -Tags $Tags
    if (-not $requestedTags) {
        $requestedTags = @("all")
    }

    $knownTags = Get-TaskTags -Tasks $Tasks
    $normalizedAliases = Get-NormalizedTagAliases -TagAliases $TagAliases
    $knownAliases = @($normalizedAliases.Keys | Sort-Object -Unique)
    $knownInputs = @($knownTags + $knownAliases | Sort-Object -Unique)
    $unknownTags = @(
        $requestedTags | Where-Object {
            $_ -notin $knownInputs
        } | Sort-Object -Unique
    )

    if ($unknownTags) {
        Write-Error "Unknown tag(s): $($unknownTags -join ', '). Available tags: $($knownInputs -join ', ')"
        exit 1
    }

    $expandedTags = Expand-Tags -Tags $requestedTags -TagAliases $normalizedAliases
    $invalidAliasTags = @(
        $expandedTags | Where-Object {
            $_ -notin $knownTags
        } | Sort-Object -Unique
    )

    if ($invalidAliasTags) {
        Write-Error "Tag alias configuration references unknown tag(s): $($invalidAliasTags -join ', '). Available task tags: $($knownTags -join ', ')"
        exit 1
    }

    if ($DryRun) {
        Write-Section "Running in TEST mode"
    }
    else {
        Write-Section "Running in REAL RUN mode"
    }

    Write-Host "Running tags: $($requestedTags -join ', ')"

    if (Compare-Object -ReferenceObject $requestedTags -DifferenceObject $expandedTags) {
        Write-Host "Expanded tags: $($expandedTags -join ', ')"
    }

    $selectedTasks = Get-SelectedTasks -Tasks $Tasks -Tags $expandedTags

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
    else {
        $args += @(
            "--nowarn"
        )
    }

    $args += @(
        "--file", $File,
        "--accept-configuration-agreements",
        "--disable-interactivity"
    )

    winget @args
}
