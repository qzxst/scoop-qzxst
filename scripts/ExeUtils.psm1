function Expand-InnoArchive2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]
        $Path,
        [Parameter(Position = 1)]
        [String]
        $DestinationPath = (Split-Path $Path),
        [Array]
        $ExtractDir,
        [Parameter(ValueFromRemainingArguments = $true)]
        [String]
        $Switches,
        [Switch]
        $Removal
    )
    $LogPath = "$(Split-Path $Path)\innounp.log"
    $ArgList = @('-x', "-d`"$DestinationPath`"", "`"$Path`"", '-y')
    $cArg = ''
    foreach ($dir in $ExtractDir) {
        $argListTemp = $ArgList
        switch -Regex ($dir) {
            '^[^{].*' { $cArg = "-c{app}\$dir" }
            '^{.*' { $cArg = "-c$dir" }
            Default { $cArg = '-c{app}' }
        }
        if ($Switches) {
            $argListTemp += (-split $Switches)
        }
        $argListTemp += $cArg
        Write-Host "arglist: $ArgListTemp" -ForegroundColor Yellow
        $Status = Invoke-ExternalCommand (Get-HelperPath -Helper Innounp) $argListTemp -LogPath $LogPath
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
}
function Invoke-ExternalCommand2 {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true,
            Position = 0)]
        [Alias('Path')]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath,
        [Parameter(Position = 1)]
        [Alias('Args')]
        [String[]]
        $ArgumentList,
        [Parameter(ParameterSetName = 'UseShellExecute')]
        [Switch]
        $RunAs,
        [Parameter(ParameterSetName = 'UseShellExecute')]
        [Switch]
        $Quiet,
        [Alias('Msg')]
        [String]
        $Activity,
        [Alias('cec')]
        [Hashtable]
        $ContinueExitCodes,
        [Parameter(ParameterSetName = 'Default')]
        [Alias('Log')]
        [String]
        $LogPath
    )
    if ($Activity) {
        Write-Host "$Activity " -NoNewline
    }
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo.FileName = $FilePath
    $Process.StartInfo.UseShellExecute = $false
    $redirectToLogFile = $false
    if ($LogPath) {
        if ($FilePath -match '^msiexec(.exe)?$') {
            $ArgumentList += "/lwe `"$LogPath`""
        } else {
            $redirectToLogFile = $true
            $Process.StartInfo.RedirectStandardOutput = $true
            $Process.StartInfo.RedirectStandardError = $true
        }
    }
    if ($RunAs) {
        $Process.StartInfo.UseShellExecute = $true
        $Process.StartInfo.Verb = 'RunAs'
    }
    if ($Quiet) {
        $Process.StartInfo.UseShellExecute = $true
        $Process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    }
    if ($ArgumentList.Length -gt 0) {
        if ($FilePath -match '^((cmd|cscript|wscript|msiexec)(\.exe)?|.*\.(bat|cmd|js|vbs|wsf))$') {
            $Process.StartInfo.Arguments = $ArgumentList -join ' '
        } elseif ($Process.StartInfo.PSObject.Properties.Name -contains 'ArgumentList') {
            # ArgumentList is supported in PowerShell 6.1 and later (built on .NET Core 2.1+)
            # ref-1: https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.processstartinfo.argumentlist?view=net-6.0
            # ref-2: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell?view=powershell-7.2#net-framework-vs-net-core
            $ArgumentList | ForEach-Object { $Process.StartInfo.ArgumentList.Add($_) }
        } else {
            # escape arguments manually in lower versions, refer to https://docs.microsoft.com/en-us/previous-versions/17w5ykft(v=vs.85)
            $escapedArgs = $ArgumentList | ForEach-Object {
                # escape N consecutive backslash(es), which are followed by a double quote, to 2N consecutive ones
                $s = $_ -replace '(\\+)"', '$1$1"'
                # escape N consecutive backslash(es), which are at the end of the string, to 2N consecutive ones
                $s = $s -replace '(\\+)$', '$1$1'
                # escape double quotes
                $s = $s -replace '"', '\"'
                # https://github.com/ScoopInstaller/Scoop/issues/5231#issuecomment-1295840608
                $s
            }
            $Process.StartInfo.Arguments = $escapedArgs -join ' '
            Write-Host $Process.StartInfo.Arguments
        }
    }
    try {
        [void]$Process.Start()
    } catch {
        if ($Activity) {
            Write-Host 'error.' -ForegroundColor DarkRed
        }
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
        return $false
    }
    if ($redirectToLogFile) {
        # we do this to remove a deadlock potential
        # ref: https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.process.standardoutput?view=netframework-4.5#remarks
        $stdoutTask = $Process.StandardOutput.ReadToEndAsync()
        $stderrTask = $Process.StandardError.ReadToEndAsync()
    }
    $Process.WaitForExit()
    if ($redirectToLogFile) {
        Out-UTF8File -FilePath $LogPath -Append -InputObject $stdoutTask.Result
        Out-UTF8File -FilePath $LogPath -Append -InputObject $stderrTask.Result
    }
    if ($Process.ExitCode -ne 0) {
        if ($ContinueExitCodes -and ($ContinueExitCodes.ContainsKey($Process.ExitCode))) {
            if ($Activity) {
                Write-Host 'done.' -ForegroundColor DarkYellow
            }
            Write-Host $ContinueExitCodes[$Process.ExitCode] -ForegroundColor DarkYellow
            return $true
        } else {
            if ($Activity) {
                Write-Host 'error.' -ForegroundColor DarkRed
            }
            Write-Host "Exit code was $($Process.ExitCode)!" -ForegroundColor DarkRed
            return $false
        }
    }
    if ($Activity) {
        Write-Host 'done.' -ForegroundColor Green
    }
    return $true
}
Export-ModuleMember `
    -Function `
    Expand-InnoArchive2,
Invoke-ExternalCommand2

