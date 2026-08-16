function Write-Section {
    param(
        [string]$SectionName
    )

    Write-Information ""
    Write-Information ("=" * 80)
    Write-Information " $SectionName"
    Write-Information ("=" * 80)
    Write-Information ""
}