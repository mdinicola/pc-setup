function Write-Section {
    param(
        [Parameter(Mandatory)]
        [string]$SectionName
    )

    Write-LogMessage ""
    Write-LogMessage ("=" * 80)
    Write-LogMessage " $SectionName"
    Write-LogMessage ("=" * 80)
    Write-LogMessage ""
}

function Write-LogMessage {
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Message,

        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    if ($Level -eq 'WARN') {
        Write-Warning "$Message"
    }
    elseif ($Level -eq 'ERROR') {
        Write-Error "$Message"
    }
    else {
        Write-Host "$Message"
    }
}

function Get-DefaultLogFolder {
    $currentTimestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    return "C:\temp\logs\pc-setup\$currentTimestamp"
}

function Start-Logging {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$LogFolder = "",
        [string]$LogFile = ""
    )

    if ([string]::IsNullOrEmpty($LogFile)) {
        if ([string]::IsNullOrEmpty($LogFolder)) {
            # use default log folder if not provided
            $LogFile = "$(Get-DefaultLogFolder)\$Name.txt"
        }
        else {
            $LogFile = "$LogFolder\$Name.txt"
        }
    }
    
    $logDirectory = Split-Path -Path "$LogFile"

    # Create log folder if it does not exist
    New-Item -Path "$logDirectory" -ItemType Directory -Force | Out-Null

    # # Stop existing transcripts in this session to avoid conflicts
    # try {
    #     Stop-Transcript -ErrorAction Stop
    # }
    # catch {
    #     if ($_.Exception.Message -notmatch 'not currently transcribing') {
    #         throw
    #     }
    # }
    
    Start-Transcript -Path "$LogFile" -Append
}

function Stop-Logging {
    Stop-Transcript
}