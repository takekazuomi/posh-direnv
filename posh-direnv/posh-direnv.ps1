Set-Variable -Name "psenvrcBase" -Value ([string]"./.psenvrc") -Scope script -Option constant

#
# https://blogs.msdn.microsoft.com/powershell/2006/07/21/setting-the-console-title-to-be-your-current-working-directory/

function Set-DirEnvRc {
    [CmdletBinding()]
    Param(
        [switch]$Force
    )
    $p = (Resolve-Path "$pwd\$psenvrcBase" -ErrorAction SilentlyContinue).Path

    if (Test-Path Env:DIRENV_DIR) {
        Write-Verbose "DIRENV_DIR is set"
        if ( -Not $pwd.Path.ToLower().StartsWith($env:DIRENV_DIR.ToLower()) -or
            ($p -and $env:DIRENV_DIR -ne $pwd)) {
            Write-Verbose "Moved out of tree or new env requested"
            if(-Not $p) {
                Write-Host "psdirenv: unloading"
            }
            # Moved out of directory tree of current env so roll it back
            $diffs = [System.Text.Encoding]::Unicode.Getstring([System.Convert]::FromBase64String($env:DIRENV_DIFF))
            $diffs = ConvertFrom-Json($diffs)
            # Remove Extras
            foreach($envvar in $diffs.remove) {
                Write-Verbose "Removing: $($envvar.Name)"
                Remove-Item -Path "Env:$($envvar.Name)"
            }
            # Reset Others
            foreach($envvar in $diffs.changed) {
                Write-Verbose "Resetting: $($envvar.Name)"
                Set-Item -Path "Env:$($envvar.Name)" -Value $envvar.value
            }
            Remove-Item Env:DIRENV_DIR
            Remove-Item Env:DIRENV_DIFF
        }
    }

    if (-not $p) {
        Write-Verbose "$pwd\$psenvrcBase not find"
        return
    }

    if (-not $Force -and $env:DIRENV_DIR -eq $pwd) {
        Write-Verbose "$p already applyed"
        return
    }

    $origionalEnv = Get-ChildItem Env:
    Write-Host "psenvdir: loading $($p)"
    Get-Content "$p" | Out-String | Invoke-Expression
    $modifiedEnv = Get-ChildItem Env:
    $diffs = @{}
    $diff = Compare-Object $origionalEnv $modifiedEnv -Property Name, Value -CaseSensitive
    $diffs.changed = $diff | Where-Object -Property SideIndicator -CEQ "<="
    $present = $diffs.changed | Select-Object -ExpandProperty Name
    $diffs.remove = $diff | Where-Object -Property SideIndicator -CEQ "=>" | Where-Object { $_.Name -notin $present }
    Write-Host "psenvdir: export " -NoNewLine
    Write-Host (@(($diffs.remove | Select-Object -ExpandProperty Name | ForEach-Object {"+$($_)"})) + ($diffs.changed | Select-Object -ExpandProperty Name | ForEach-Object {"~$($_)"}))
    Set-Item -Path Env:DIRENV_DIR -Value $pwd.Path
    $diffs = $diffs | ConvertTo-Json -Compress
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($diffs)
    $diffs = [Convert]::ToBase64String($bytes)
    Set-Item -Path Env:DIRENV_DIFF -Value $diffs
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
