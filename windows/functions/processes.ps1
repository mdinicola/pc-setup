function Invoke-Program {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProgramPath,

        [string[]]$ArgumentList = @()
    )

    & $ProgramPath @ArgumentList

    if ($LASTEXITCODE -ne 0) {
        throw "'$ProgramPath' failed with exit code $LASTEXITCODE"
    }
}

function Invoke-Script {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [hashtable]$Parameters = @{}
    )

    try {
        & $ScriptPath @Parameters
    }
    catch {
        throw "'$ScriptPath' failed: $_"
    }
}

function Invoke-ElevatedScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [string[]]$Parameters = @()
    )

    $PowerShellExe = if ($PSVersionTable.PSEdition -eq 'Core') {
        'pwsh.exe'
    }
    else {
        'powershell.exe'
    }

    $processParameters = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        "`"$ScriptPath`""
    ) + $Parameters

    $process = Start-Process `
        -FilePath "$PowerShellExe" `
        -Verb RunAs `
        -ArgumentList $processParameters `
        -Wait `
        -PassThru

    if ($process.ExitCode -ne 0) {
        throw "$ScriptPath failed with exit code $($process.ExitCode)."
    }
}

# Runs WinUtil tool by Chris Titus to debloat Windows
# https://github.com/christitustech/winutil
function Invoke-WinUtil {
    param(
        [string]$ConfigFile = ""
    )

    if ([string]::IsNullOrEmpty($ConfigFile)) {
        Invoke-RestMethod https://christitus.com/win | Invoke-Expression
    }
    else {
        Write-LogMessage "Running WinUtil with config file: $ConfigFile"
        & ([ScriptBlock]::Create((Invoke-RestMethod https://christitus.com/win))) -Config "$ConfigFile"
    }
}