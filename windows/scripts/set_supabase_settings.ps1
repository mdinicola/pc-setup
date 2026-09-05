param(
    [string]$LogFolder = ""
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

. "$PSScriptRoot\..\functions\logging.ps1"

Start-Logging -Name "settings_supabase" -LogFolder "$LogFolder"

try {
    # Error out if git cannot be found
    $supabase = Get-Command 'supabase' -CommandType Application -ErrorAction SilentlyContinue
    if (-not $supabase) {
        Write-Error "Supabase is not installed or is not available"
        exit 1
    }

    $status = supabase telemetry status

    if ($status -match 'disabled') {
        Write-LogMessage "Supabase telemetry already disabled.  Nothing to do"
    }
    else {
        Write-LogMessage "Disabling supabase telemetry"
        Invoke-Program -ProgramPath supabase -ArgumentList @(
            'telemetry'
            "disable"
        )
    }

}
finally {
    Stop-Logging
}