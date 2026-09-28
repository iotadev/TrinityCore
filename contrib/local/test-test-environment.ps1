# Service-free checks of portable path and fixture validation.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'test-environment.ps1')
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('cata-test-environment-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $testRoot)
function Assert-True($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Assert-Rejected([scriptblock]$Operation) {
    $rejected = $false
    try { [void](& $Operation) } catch { $rejected = $true }
    Assert-True $rejected 'Invalid fixture was accepted.'
}
try {
    $build = Join-Path $testRoot 'build'
    $seed = Join-Path $build 'runtime-smoke-fixture'
    [void](New-Item -ItemType Directory -Path (Join-Path $seed 'mysql-data'))
    foreach ($name in @('mysql-data/auto.cnf','worldserver.conf')) { [IO.File]::WriteAllText((Join-Path $seed $name), 'test fixture') }
    [IO.File]::WriteAllText((Join-Path $seed 'mysql-error.log'), 'Shutdown complete')
    $credentials = Join-Path $seed 'test-db-credentials.json'
    $valid = @{host='127.0.0.1';port=13306;user='cata_smoke';password='synthetic-test-only'} | ConvertTo-Json
    [IO.File]::WriteAllText($credentials, $valid)
    Assert-True ((Resolve-TestSeed 'build/runtime-smoke-fixture' $testRoot) -eq $seed) 'Relative seed failed.'
    Assert-True ((Resolve-TestSeed $seed $testRoot) -eq $seed) 'Absolute seed failed.'
    Assert-True ((Read-TestCredentials $seed).password -eq 'synthetic-test-only') 'Seed credentials were not used.'
    Assert-Rejected { Resolve-TestDirectory '' $testRoot 'Required' }
    Assert-Rejected { Resolve-TestSeed '' $testRoot }
    $outside = Join-Path $testRoot 'runtime-smoke-outside'
    [void](New-Item -ItemType Directory -Path $outside)
    Assert-Rejected { Resolve-TestSeed $outside $testRoot }
    $missing = Join-Path $build 'runtime-smoke-incomplete'
    [void](New-Item -ItemType Directory -Path $missing)
    Assert-Rejected { Resolve-TestSeed $missing $testRoot }
    Assert-Rejected { Read-TestCredentials $missing }
    [IO.File]::WriteAllText($credentials, '{invalid')
    Assert-Rejected { Read-TestCredentials $seed }
    [IO.File]::WriteAllText($credentials, (@{host='example.invalid';port=13306;user='cata_smoke';password='synthetic-test-only'} | ConvertTo-Json))
    Assert-Rejected { Read-TestCredentials $seed }
    [IO.File]::WriteAllText($credentials, $valid)
    [IO.File]::WriteAllText((Join-Path $seed 'mysql-error.log'), 'not stopped')
    Assert-Rejected { Resolve-TestSeed $seed $testRoot }
    foreach ($script in @('ahbot-smoke.ps1','playerbot-lifecycle-smoke.ps1')) {
        $parameters = (Get-Command (Join-Path $PSScriptRoot $script)).Parameters
        foreach ($name in @('Seed','MySqlHome')) {
            Assert-True (@($parameters[$name].Attributes | Where-Object { $_ -is [Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count -gt 0) "$script does not require $name."
        }
    }
    Write-Host 'Path, seed, credential isolation and required-parameter checks passed; no services started.'
}
finally {
    # Only this generated temporary fixture is eligible for cleanup.
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if (-not $resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path $resolved -Leaf) -notlike 'cata-test-environment-*') { throw 'Unexpected test cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
