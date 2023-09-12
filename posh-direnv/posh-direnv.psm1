
## Load Scripts ###############################################################
Get-ChildItem "$PSScriptRoot/*.ps1" |
    ? { $_.Name -notlike "*.Tests.*" } |
    % { . $_.PSPath }

## Prompt Adjustment ##########################################################

if (Test-Path Function:\PromptBackup) {
    Write-Host "Backup Prompt function name is duplicated" -ForegroundColor Cyan
}

if (Test-Path Function:\Prompt) {
    Rename-Item Function:\Prompt global:PromptBackup
}

function global:Prompt {
    try {
        Set-DirEnvRc | Out-Null

        # Fall back on existing Prompt function
        if (Test-Path Function:\PromptBackup) {
            PromptBackup
        }
    }
    catch {
        Write-Host "Error in .psenvrc. $($_.Exception.Message) >" -ForegroundColor Red
        # Fall back on existing Prompt function
        if (Test-Path Function:\PromptBackup) {
            PromptBackup
        }
    }
}

## Aliases ####################################################################
New-Alias source_up Search-DirEnvRC -Force

## Exports ####################################################################
Export-ModuleMember `
    -Function `
        Set-DirEnvRc, `
        Edit-DirEnvRc, `
        New-DirEnvRc, `
        Initialize-AllowList, `
        Compare-DirEnvRc, `
        Approve-DirEnvRc, `
        Deny-DirEnvRc, `
        Repair-DirEnvAuth, `
        Prompt

