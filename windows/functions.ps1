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