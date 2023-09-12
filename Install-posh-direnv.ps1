$targetPath = $env:PSModulePath.Split(";")[0]

$moduleName = "posh-direnv"

Remove-Module $moduleName 

if (Test-Path -PathType Container "$targetPath") {
    Remove-Item -Recurse -Force -Confirm:$false "$targetPath/$moduleName" -ErrorAction SilentlyContinue
}

Copy-Item -Recurse "$PSScriptRoot/$moduleName" "$targetPath/"

Import-Module $moduleName -Force

