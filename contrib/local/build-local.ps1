param(
    [string]$BuildDirectory = 'build',
    [string]$Configuration = 'RelWithDebInfo',
    [string[]]$Targets = @('worldserver'),
    [switch]$Configure,
    [switch]$RunTests
)

# Normalize only build/test children, without changing the calling shell.
# Some launchers supply both Path and PATH; older MSBuild rejects that pair.
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$build = Join-Path $repo $BuildDirectory
if (-not (Test-Path -LiteralPath $build -PathType Container)) {
    throw "Build directory does not exist: $build"
}

$inherited = [Environment]::GetEnvironmentVariables('Process')
$pathKeys = @($inherited.Keys | Where-Object { $_ -ieq 'Path' })
if (-not $pathKeys.Count) { throw 'No process Path is available.' }
$preferredKey = if ($pathKeys -ccontains 'PATH') { 'PATH' } else { $pathKeys[0] }
$cleanPath = [string]$inherited[$preferredKey]

function Invoke-LocalTool([string]$Name, [string[]]$ToolArguments) {
    $tool = (Get-Command $Name -CommandType Application -ErrorAction Stop).Source
    $start = [Diagnostics.ProcessStartInfo]::new($tool)
    $start.UseShellExecute = $false
    $start.WorkingDirectory = $repo
    [void]$start.Environment.Remove('PATH')
    $start.Environment['Path'] = $cleanPath
    foreach ($argument in $ToolArguments) { $start.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "$Name failed with exit code $($process.ExitCode)." }
    }
    finally { $process.Dispose() }
}

if ($Configure) {
    Invoke-LocalTool 'cmake' @('-S', $repo, '-B', $build)
}

Invoke-LocalTool 'cmake' (@('--build', $build, '--config', $Configuration, '--target') + $Targets + @('--', '/m:1', '/p:UseMultiToolTask=false', '/p:MultiProcessorCompilation=false'))

if ($RunTests) {
    Invoke-LocalTool 'ctest' @('--test-dir', $build, '-C', $Configuration, '--output-on-failure')
}
