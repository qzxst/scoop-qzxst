<#
.SYNOPSIS
    Update manifest, commit and push.
.DESCRIPTION
    Use as vscode task:
        1. Open manifest in editor
        1. Press CTRL+SHIFT+B or CTRL+F9 (IntelliJ)
        1. Be surprised
.PARAMETER Manifest
    Full Path to manifest. (vscode ${file})
.PARAMETER Dir

.PARAMETER Deprecated
    Move the file to the deprecated directory and add it to git
.PARAMETER Experimental
    Move the file to the experimental directory and add it to git

#>
param(
    [Alias('App')]
    [String[]] $Manifest,
    [String] $Dir = $PSScriptRoot + "\..\deprecated",
    [Switch] $Deprecated,
    [Switch] $Experimental
)
begin {
    foreach ($man in $Manifest) {
        if (-not (Test-Path $man)) {
            # remove the item from the array
            $Manifest = $Manifest | Where-Object { $_ -ne $man }
            Write-Host "Manifest not found: $man" -ForegroundColor Red
            continue
        }
    }
    if (-not $Manifest) {
        Write-Error "Manifest is required."
        return
    }
    # $manifest is required and must be a file with .json extension
    Write-Host "files---$Manifest,dir---$Dir" -ForegroundColor Green
    if ($Experimental) {
        $Dir = $PSScriptRoot + "\..\experimental"
    }
    $movedDirName = Split-Path $Dir -Leaf
    Write-Host "params: $Manifest, $Dir, $Deprecated, $Experimental"+"movedDirName: $movedDirName" -ForegroundColor Red
}
process {

    # Move-Item -Path $Manifest -Destination $Dir
    foreach ($man in $Manifest) {
        $man = Resolve-Path $man
        $folder = Split-Path $man -Parent
        $file = Split-Path $man -Leaf
        Write-Host "Manifest: $man" -ForegroundColor Green
        Write-Host "Folder: $folder" -ForegroundColor Green
        Write-Host "File: $file" -ForegroundColor Green

        $result = Read-Host "move $man to $Dir (y/n)"
        $result = $result.ToLower()
        if ($result -eq 'y') {
            Move-Item -Path $man -Destination $Dir
        }
        $moved = @(git status -s)

        if ($moved -match "$movedDirName") {
            $message = "$file`: is Moved to $movedDirName"
            git add  "$movedDirName/$file"
            Write-Host 'Commiting' -ForegroundColor Green
            git commit --message $message --only "*$file"
            $exit = $LASTEXITCODE
            if ($exit -gt 0) {
                Write-Host 'Pre-commit hook failed.' -ForegroundColor Red
                exit $exit
            }
            Write-Host 'Pushing' -ForegroundColor Green
            git push

            Write-Host 'DONE' -ForegroundColor Yellow
        } else {
            Write-Host 'No Moved' -ForegroundColor Yellow
        }
        exit
    }
}

end { Write-Host 'DONE' -ForegroundColor Yellow }
