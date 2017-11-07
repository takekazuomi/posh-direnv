Set-Variable -Name "psenvrcBase" -Value ([string]"./.psenvrc") -Scope script -Option constant
Set-Variable -Name "PoshDirEnvHistory" -Value ([hashtable]@{}) -Scope global

# 
# https://blogs.msdn.microsoft.com/powershell/2006/07/21/setting-the-console-title-to-be-your-current-working-directory/

function Set-DirEnvRc {
    [CmdletBinding()]
    Param(
        [switch]$Force
    )
    $p = (Resolve-Path "$pwd\$psenvrcBase" -ErrorAction SilentlyContinue).Path

    if (-not $p) {
        Write-Verbose "$pwd\$psenvrcBase not find"
        return
    }

    if (-not $Force -and $PoshDirEnvHistory[$p]) {
        Write-Verbose "$p already applyed"
        return
    }
    
    Get-Content "$p" | Out-String | Invoke-Expression 
    $PoshDirEnvHistory[$p] = $true
}

function Edit-DirEnvRc {
    [CmdletBinding()]
    Param(
        [switch]$Force
    )
    $p = (Resolve-Path "$pwd\$psenvrcBase" -ErrorAction SilentlyContinue).Path
    if (-not $p) {
        New-DirEnvRc
        $p = (Resolve-Path "$pwd\$psenvrcBase" -ErrorAction SilentlyContinue).Path
    }
    
    $t = Get-ItemPropertyValue -Path $p -Name LastWriteTime

    if ("$env:EDITOR" -and (Test-Path "$env:EDITOR")) {
        &"$env:EDITOR" $p
        $t2 = Get-ItemPropertyValue -Path $p -Name LastWriteTime

        if ($t2 -gt $t) {
            Set-DirEnvRc -Force
            Write-Verbose "$p updated"
        }
    }
    else {
        notepad $p
    }
}

function New-DirEnvRc {
    [CmdletBinding()]
    Param(
        [switch]$Force
    )
    
    New-Item "$pwd\$psenvrcBase" -Force:$Force | Out-Null
}
