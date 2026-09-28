param()
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$checkpoint = Join-Path $repo ('build/source-checkpoint-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$sourceCopy = Join-Path $checkpoint 'source'
[void](New-Item -ItemType Directory -Path $sourceCopy)
Push-Location $repo
try {
    $paths = @(& git -c core.quotepath=false ls-files --cached --others --exclude-standard)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inventory source files.' }
    $paths = @($paths | Sort-Object -Unique)
    $manifest = [Collections.Generic.List[string]]::new()
    $missing = [Collections.Generic.List[string]]::new()
    foreach ($relative in $paths) {
        $original = [IO.Path]::GetFullPath((Join-Path $repo $relative))
        if (-not $original.StartsWith($repo + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Source path escaped repository: $relative"
        }
        if (-not (Test-Path -LiteralPath $original -PathType Leaf)) {
            $missing.Add($relative)
            continue
        }
        $destination = Join-Path $sourceCopy $relative
        [void](New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($destination)) -Force)
        Copy-Item -LiteralPath $original -Destination $destination
        $before = (Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash
        $copied = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
        if ($before -ne $copied) { throw "Snapshot hash mismatch: $relative" }
        $manifest.Add("$copied  $relative")
    }
    [IO.File]::WriteAllLines((Join-Path $checkpoint 'SOURCE_MANIFEST.sha256'), $manifest)
    [IO.File]::WriteAllLines((Join-Path $checkpoint 'MISSING_TRACKED_PATHS.txt'), $missing)
    & git bundle create (Join-Path $checkpoint 'history.bundle') --all
    if ($LASTEXITCODE -ne 0) { throw 'History bundle creation failed.' }
    & git bundle verify (Join-Path $checkpoint 'history.bundle')
    if ($LASTEXITCODE -ne 0) { throw 'History bundle verification failed.' }
    $head = & git rev-parse HEAD
    $branch = & git branch --show-current
    [IO.File]::WriteAllLines((Join-Path $checkpoint 'CHECKPOINT.txt'), @(
        "HEAD=$head", "BRANCH=$branch", "FILES=$($manifest.Count)",
        'Local preservation only; not approved for publication.',
        'source/ overlays history.bundle HEAD, including untracked source.',
        'Missing tracked paths must be removed explicitly when restoring.',
        'Ignored build/runtime data and local active configs are excluded.'
    ))
    Write-Host "Verified local source checkpoint: $checkpoint"
    Write-Host "Copied and hash-verified $($manifest.Count) files; absent tracked paths: $($missing.Count)."
}
finally { Pop-Location }
