function Invoke-Program {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProgramPath,

        [string[]]$ArgumentList = @()
    )

    & $ProgramPath @ArgumentList

    if ($LASTEXITCODE -ne 0) {
        throw "'$filePath' failed with exit code $LASTEXITCODE"
    }
}

function Invoke-ElevatedScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [string[]]$ArgumentList = @()
    )

    $PowerShellExe = if ($PSVersionTable.PSEdition -eq 'Core') {
        'pwsh.exe'
    }
    else {
        'powershell.exe'
    }

    $processArgumentList = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        "`"$ScriptPath`""
    ) + $ArgumentList

    $process = Start-Process `
        -FilePath "$PowerShellExe" `
        -Verb RunAs `
        -ArgumentList $processArgumentList `
        -Wait `
        -PassThru

    if ($process.ExitCode -ne 0) {
        throw "Elevated script failed with exit code $($process.ExitCode)."
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
        Write-Information "Running WinUtil with config file: $ConfigFile"
        & ([ScriptBlock]::Create((Invoke-RestMethod https://christitus.com/win))) -Config "$ConfigFile"
    }
}