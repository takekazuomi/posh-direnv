function Search-DirEnvRC {
    [CmdletBinding()]
    Param(
        [string]$Path = (Split-Path $pwd),
        [string]$FileName = $psenvrcBase
    )

    Write-Verbose "source_up: Looking for $($Path)\$($Filename)"
    if($Path -eq "") {
        Write-Verbose "source_up: File not found in tree"
    } elseif (Test-Path "$Path\$FileName" ) {
        Write-Verbose "source_up: found $($Path)\$($Filename)"
        Get-Content "$Path\$Filename" | Out-String | Invoke-Expression
    } else {
       return Search-DirEnvRC (Split-Path $Path) $FileName
    }
}
