function Get-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [string]$KeyPath,

        [Parameter(Mandatory)]
        [string]$KeyName
    )

    if (-not (Test-Path -Path $KeyPath)) {
        return $null
    }

    $key = Get-Item -Path $KeyPath

    try {
        return @{
            Value = $key.GetValue($KeyName)
            Type  = $key.GetValueKind($KeyName).ToString()
        }
    }
    catch {
        return $null
    }
}

function Set-RegistryValue {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$KeyPath,

        [Parameter(Mandatory)]
        [string]$KeyName,

        [Parameter(Mandatory)]
        [ValidateSet(
            'String',
            'ExpandString',
            'Binary',
            'DWord',
            'MultiString',
            'QWord'
        )]
        [string]$Type,

        [Parameter(Mandatory)]
        $Value
    )

    $currentRecord = Get-RegistryValue -KeyPath $KeyPath -KeyName $KeyName

    if (
        $null -ne $currentRecord -and
        $currentRecord.Value -eq $Value -and
        $currentRecord.Type -eq $Type
    ) {
        Write-LogMessage "Registry key $KeyPath\$KeyName already has value $Value.  Nothing to do"
        return $false
    }

    if ($null -ne $currentRecord) {
        Write-LogMessage "Changing registry key $KeyPath\$KeyName from $($currentRecord.Value) to $Value"
        if ($PSCmdlet.ShouldProcess("$KeyPath\$KeyName", 'Set registry key')) {
            Set-ItemProperty `
                -Path $KeyPath `
                -Name $KeyName `
                -Value $Value
        }
    }
    else {
        Write-LogMessage "Creating registry key $KeyPath\$KeyName with type $Type and value $Value"
        if ($PSCmdlet.ShouldProcess("$KeyPath\$KeyName", 'Set registry key')) {
            New-Item -Path $KeyPath -Force | Out-Null

            New-ItemProperty `
                -Path $KeyPath `
                -Name $KeyName `
                -PropertyType $Type `
                -Value $Value `
                -Force |
                Out-Null
        }
    }

    return $true
}