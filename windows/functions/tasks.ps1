function Get-SelectedTask {
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

function Get-TaskTag {
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

function Invoke-Task {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Section "$Name"

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    & $Action

    $sw.Stop()

    Write-Information "Completed in $($sw.Elapsed.ToString('mm\:ss'))"
}

function Invoke-TaggedTask {
    param(
        [Parameter(Mandatory)]
        [array]$Tasks,
        [string[]]$Tags,
        [hashtable]$TagAliases = @{}
    )

    $requestedTags = Get-NormalizedTag -Tags $Tags
    if (-not $requestedTags) {
        $requestedTags = @("all")
    }

    $knownTags = Get-TaskTag -Tasks $Tasks
    $normalizedAliases = Get-NormalizedTagAlias -TagAliases $TagAliases
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

    $expandedTags = Expand-Tag -Tags $requestedTags -TagAliases $normalizedAliases
    $invalidAliasTags = @(
        $expandedTags | Where-Object {
            $_ -notin $knownTags
        } | Sort-Object -Unique
    )

    if ($invalidAliasTags) {
        Write-Error "Tag alias configuration references unknown tag(s): $($invalidAliasTags -join ', '). Available task tags: $($knownTags -join ', ')"
        exit 1
    }

    Write-Information "Running tags: $($requestedTags -join ', ')"

    if (Compare-Object -ReferenceObject $requestedTags -DifferenceObject $expandedTags) {
        Write-Information "Expanded tags: $($expandedTags -join ', ')"
    }

    $selectedTasks = Get-SelectedTask -Tasks $Tasks -Tags $expandedTags

    foreach ($task in $selectedTasks) {
        Invoke-Task $task.Name $task.Action
    }
}