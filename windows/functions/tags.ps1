function Get-NormalizedTag {
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

function Get-NormalizedTagAlias {
    param(
        [hashtable]$TagAliases
    )

    $normalizedAliases = @{}

    foreach ($aliasName in @($TagAliases.Keys)) {
        $normalizedAliasName = $aliasName.Trim().ToLowerInvariant()
        $normalizedAliases[$normalizedAliasName] = Get-NormalizedTag -Tags $TagAliases[$aliasName]
    }

    $normalizedAliases
}

function Expand-Tag {
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