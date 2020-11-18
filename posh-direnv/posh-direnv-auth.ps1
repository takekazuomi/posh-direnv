# Managed the allowed .psenvrc file list
Set-Variable -Name "psenvrcAuthDir" -Value (Join-Path $env:HOME .direnv) -Scope script -Option constant
[System.Collections.ArrayList]$global:psenvrcAllowList = @()

function Initialize-AllowList {
    $exists = $false
    if($psenvrcAuthDir -and (Test-Path $psenvrcAuthDir)) {
        $global:psenvrcAllowList = @(Get-ChildItem -File -Path $psenvrcAuthDir | Foreach-Object {$_.Name})
    } else {
        Write-Verbose "No Files Authorised"
        $d = New-Item -Path $psenvrcAuthDir -ItemType "directory"
        $d.Attributes = $d.Attributes -bor "Hidden"
    }
}

function Compare-DirEnvRc {
    [CmdletBinding()]
    Param(
        [string]$PsEnvRcFile
    )
    $rcFileAllowed = $false
    if(-not $global:psenvrcAllowList) {
        Write-Verbose "Need to initalise allow list"
        [void](Initialize-AllowList)
    }
    if($global:psenvrcAllowList -ccontains (Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash -and
        ((Get-Content (Join-Path $psenvrcAuthDir (Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash) -First 1) -eq $PsEnvRcFile)) {
            $rcFileAllowed = $true
    }
    return $rcFileAllowed
}

function Approve-DirEnvRc {
    [CmdletBinding()]
    Param(
        [string]$PsEnvRcFile = (Join-Path $pwd $psenvrcBase)
    )

    $firstCreation = $false
    if(-not $global:psenvrcAllowList) {
        Write-Verbose "Need to initalise allow list"
        Initialize-AllowList
    }

    if($psenvrcAuthDir -and (-not (Test-Path $psenvrcAuthDir))) {
        $d = New-Item -Path $psenvrcAuthDir -ItemType "directory"
        $d.Attributes = $d.Attributes -bor "Hidden"
    }
    Add-Content (Join-Path $psenvrcAuthDir (Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash) $PsEnvRcFile
    Initialize-AllowList
}

function Deny-DirEnvRc {
    [CmdletBinding()]
    Param(
        [string]$PsEnvRcFile = (Join-Path $pwd $psenvrcBase)
    )

    $firstCreation = $false
    if(-not $global:psenvrcAllowList) {
        Write-Verbose "Need to initalise allow list"
        Initialize-AllowList
    }

    $global:psenvrcAllowList.Remove((Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash)
    if($psenvrcAuthDir -and (Test-Path (Join-Path $psenvrcAuthDir (Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash))) {
        Remove-Item -Force (Join-Path $psenvrcAuthDir (Get-FileHash $PsEnvRcFile -Algorithm SHA256).Hash)
    }
    Initialize-AllowList
}

function Repair-DirEnvAuth {
    [CmdletBinding()]
    Param(
    )

    $currentFiles = Get-ChildItem -File -Path $psenvrcAuthDir | Foreach-Object { $_.FullName }

    foreach($file in $currentFiles) {
        $allowedFile = Get-Content $file
        if(Test-Path $allowedFile) {
            $allowedHash = (Get-FileHash $allowedFile -Algorithm SHA256).Hash
            if($allowedHash -ne (Split-Path -Leaf $file)) {
                Write-Verbose "$($allowedHash) != $(Split-Path -Leaf $file)"
                Write-Verbose "Removing: $($file)"
                Remove-Item $file -Force
            }
        } else {
            Write-Verbose "File Not Found removing: $($file)"
            Remove-Item $file -Force
        }
    }
}