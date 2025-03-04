param([Parameter(Mandatory)][String] $dir, [Parameter(Mandatory)][String] $persist_dir)

if (!(Test-Path "$persist_dir\bin\idea.properties")) {
    info 'Copying idea.properties file...'

    $current = (Split-Path $dir | Join-Path -ChildPath 'current') -replace '\\', '/'

    $CONT = Get-Content "$dir\bin\idea.properties"
    $CONT = $CONT -replace '^#\s*(idea.config.path=).*$', "`$1$current/profile/config"
    $CONT = $CONT -replace '^#\s*(idea.system.path=).*$', "`$1$current/profile/system"
    $CONT = $CONT -replace '^#\s*(idea.plugins.path=).*$', "`$1$current/profile/plugins"
    $CONT = $CONT -replace '^#\s*(idea.log.path=).*$', "`$1$current/profile/log"

    Set-Content -LiteralPath "$dir\bin\idea.properties" -Value $CONT -Encoding 'Ascii' -Force
}
