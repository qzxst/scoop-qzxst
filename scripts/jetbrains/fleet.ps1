param([Parameter(Mandatory)][String] $dir, [Parameter(Mandatory)][String] $persist_dir)

if (!(Test-Path "$persist_dir\app\Fleet.cfg")) {
    info 'Copying Fleet.cfg file...'

    $current = (Split-Path $dir | Join-Path -ChildPath 'current') -replace '\\', '/'
    $filePath = "$dir\app\Fleet.cfg"

    $newLines = @(
        "java-options=-Dfleet.config.path=$current/profile/config",
        "java-options=-Dfleet.caches.path=$current/profile/caches",
        "java-options=-Dfleet.log.path=$current/profile/log"
    )

    Add-Content -Path $filePath -Value $newLines -Encoding 'Ascii' -Force
}
