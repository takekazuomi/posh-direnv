Get-ChildItem "$PSScriptRoot/*.ps1" |
    ? { $_.Name -notlike "*.Tests.*" } |
    % { . $_.PSPath }


if (Test-Path Function:\PromptBackup) {
    Write-Host "Backup Prompt function name is duplicationed" -ForegroundColor Cyan
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
    }
}

Export-ModuleMember `
    -Function @(
    'Set-DirEnvRc'
    'Edit-DirEnvRc'
    'New-DirEnvRc'
)

