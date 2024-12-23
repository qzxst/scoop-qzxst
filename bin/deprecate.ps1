# 弃用bucket中的json
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
process {
    # $manifest is required and must be a file with .json extension
    Write-Host "移动的文件---$Manifest,移动到的目录---$Dir" -ForegroundColor Red
    if ($Experimental) {
        $Dir = $PSScriptRoot + "\..\experimental"
    }
    $movedDirName = Split-Path $Dir -Leaf
    Write-Host "params: $Manifest, $Dir, $Deprecated, $Experimental"+"movedDirName: $movedDirName" -ForegroundColor Red
    if (-not $Manifest) {
        Write-Error "Manifest is required."
        return
    }

    # Move-Item -Path $Manifest -Destination $Dir
    foreach ($man in $Manifest) {
        if (-not ($man.EndsWith('.json'))) {
            $man += '.json'
        }
        $man = Resolve-Path $man
        $folder = Split-Path $man -Parent
        $file = Split-Path $man -Leaf

        Write-Host "Manifest: $man" -ForegroundColor Green
        Write-Host "Folder: $folder" -ForegroundColor Green
        Write-Host "File: $file" -ForegroundColor Green

        if (-not (Test-Path $man)) {
            Write-Host "Manifest not found: $man" -ForegroundColor Red
            continue
        }

        $result = Read-Host "是否移动文件 $man 到 $Dir (y/n)"
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
