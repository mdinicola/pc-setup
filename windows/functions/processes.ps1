function Invoke-Program {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ProgramPath,

        [string[]]$ArgumentList = @(),

        [int[]]$AllowedExitCodes = @(0)
    )

    & $ProgramPath @ArgumentList
    $exitCode = $LASTEXITCODE

    if ($exitCode -notin $AllowedExitCodes) {
        throw "'$ProgramPath' failed with exit code $exitCode"
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingInvokeExpression',
        '',
        Justification = 'Invoke-Expression is used in the official install documentation'
    )]
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

function Install-Scoop {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingInvokeExpression',
        '',
        Justification = 'Invoke-Expression is used in the official install documentation'
    )]
    param()

    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}