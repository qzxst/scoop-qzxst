function Expand-InnoArchive2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]
        $Path,
        [Parameter(Position = 1)]
        [String]
        $DestinationPath = (Split-Path $Path),
        [String]
        $ExtractDir,
        [Parameter(ValueFromRemainingArguments = $true)]
        [String]
        $Switches,
        [Switch]
        $Removal
    )
    $LogPath = "$(Split-Path $Path)\innounp.log"
    $ArgList = @('-x', "-d`"$DestinationPath`"", "`"$Path`"", '-y')
    switch -Regex ($ExtractDir) {
        "^[^{].*" { $ArgList += "-c{app}\$ExtractDir" }
        "^{.*" { $ArgList += "-c$ExtractDir" }

        Default { $ArgList += "-c{app}" }
    }
    if ($Switches) {
        $ArgList += (-split $Switches)
    }
    Write-Host "arglist: $ArgList" -ForegroundColor Yellow
    return
    $Status = Invoke-ExternalCommand (Get-HelperPath -Helper Innounp) $ArgList -LogPath $LogPath
    if (!$Status) {
        abort "Failed to extract files from $Path.`nLog file:`n  $(friendly_path $LogPath)`n$(new_issue_msg $app $bucket 'decompress error')"
    }
    if (Test-Path $LogPath) {
        Remove-Item $LogPath -Force
    }
    if ($Removal) {
        # Remove original archive file
        Remove-Item $Path -Force
    }
}
Export-ModuleMember `
    -Function `
    Expand-InnoArchive2
