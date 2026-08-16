function Get-EnvironmentPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    return "$machinePath;$userPath"
}

function Test-FolderInEnvironmentPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )
    
    $FolderPath = $FolderPath.TrimEnd('\')

    $environmentPath = Get-EnvironmentPath -split ';' |
        Where-Object { $_ } |
        ForEach-Object { $_.Trim().TrimEnd('\') }
    
    return $environmentPaths -contains $Path
}

function Get-EnvironmentVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )

    [Environment]::GetEnvironmentVariable($Name, $Scope)
}


function Set-EnvironmentVariable {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value,

        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )

    Write-Information "Setting $Scope environment variable $Name to $Value"
    [Environment]::SetEnvironmentVariable($Name, $Value, $Scope) | Out-Null
}