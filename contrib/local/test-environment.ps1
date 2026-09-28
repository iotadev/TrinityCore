# Shared input validation only; sourcing this file does not start services.
function Resolve-TestDirectory([string]$Path, [string]$Base, [string]$Label) {
    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Label must be supplied explicitly." }
    $candidate = if ([IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $Base $Path }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) { throw "$Label directory does not exist." }
    return (Resolve-Path -LiteralPath $candidate).Path
}

function Assert-TestFiles([string]$Directory, [string[]]$Names, [string]$Label) {
    foreach ($name in $Names) {
        if (-not (Test-Path -LiteralPath (Join-Path $Directory $name) -PathType Leaf)) {
            throw "$Label is missing required file: $name"
        }
    }
}

function Resolve-TestSeed([string]$Path, [string]$Repository, [switch]$AllowPlayerbot) {
    $resolved = Resolve-TestDirectory $Path $Repository 'Seed'
    $buildRoot = [IO.Path]::GetFullPath((Join-Path $Repository 'build'))
    $parent = Split-Path $resolved -Parent
    $name = Split-Path $resolved -Leaf
    $validName = $name -like 'runtime-smoke-*' -or ($AllowPlayerbot -and $name -like 'playerbot-smoke-*')
    if (-not $parent.Equals($buildRoot, [StringComparison]::OrdinalIgnoreCase) -or -not $validName) {
        throw 'Seed must be a disposable smoke-test directory directly under this repository build directory.'
    }
    # Reject linked fixtures rather than traversing into an unrelated database.
    foreach ($item in @((Get-Item -LiteralPath $resolved), (Get-Item -LiteralPath $parent))) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Seed and build directories must not be links.' }
    }
    Assert-TestFiles $resolved @('mysql-data/auto.cnf','mysql-error.log','test-db-credentials.json','worldserver.conf') 'Seed'
    if ((Get-Item -LiteralPath (Join-Path $resolved 'mysql-data')).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Seed database directory must not be a link.'
    }
    if (-not (Select-String -LiteralPath (Join-Path $resolved 'mysql-error.log') -SimpleMatch 'Shutdown complete' -Quiet)) {
        throw 'Seed database has no clean-shutdown evidence.'
    }
    return $resolved
}

function Read-TestCredentials([string]$SeedDirectory) {
    $path = Join-Path $SeedDirectory 'test-db-credentials.json'
    Assert-TestFiles $SeedDirectory @('test-db-credentials.json') 'Seed'
    try { $credential = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw 'Seed credential file is not valid JSON.' }
    if ($credential.host -ne '127.0.0.1' -or $credential.port -ne 13306 -or
        $credential.user -ne 'cata_smoke' -or [string]::IsNullOrWhiteSpace($credential.password)) {
        throw 'Seed credentials must describe the expected disposable loopback database.'
    }
    return $credential
}
