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

    $expandedTags = @()

    foreach ($tag in $Tags) {
        $tagsToAdd = if ($TagAliases.ContainsKey($tag)) {
            @($TagAliases[$tag])
        }
        else {
            @($tag)
        }

        foreach ($tagToAdd in $tagsToAdd) {
            if ($tagToAdd -notin $expandedTags) {
                $expandedTags += $tagToAdd
            }
        }
    }

    @(
        $expandedTags
    )
}
