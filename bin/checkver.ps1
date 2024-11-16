if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
# 打印$checkver和$dir
Write-Host "checkver: $checkver"  -ForegroundColor Red
Write-Host "dir: $dir" -ForegroundColor Red
Write-Host "& '$checkver' -dir '$dir' $($args | ForEach-Object { "$_ " })" -ForegroundColor Red
# exit 0

Invoke-Expression -command "& '$checkver' -dir '$dir' $($args | ForEach-Object { "$_ " })"
