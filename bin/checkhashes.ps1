if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir

Write-Host "checkhashes: $checkhashes"  -ForegroundColor Red
Write-Host "dir: $dir" -ForegroundColor Red
Write-Host "& '$checkhashes' -Dir '$dir' $($args | ForEach-Object { "$_ " })" -ForegroundColor Red
# exit 0
Invoke-Expression -Command "& '$checkhashes' -Dir '$dir' $($args | ForEach-Object { "$_ " })"
