# Exercise wait policy without evaluating the service-starting harness.
$ErrorActionPreference = 'Stop'
$errors = $null
$tokens = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $PSScriptRoot 'playerbot-lifecycle-smoke.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parser errors.' }
foreach ($name in @('Wait-For', 'Wait-ForHuman')) {
    $definition = $ast.Find({
        param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }.GetNewClosure(), $true)
    if (-not $definition) { throw "Missing function $name." }
    Invoke-Expression $definition.Extent.Text
}
$worldWorker = $null
$stage = [IO.Path]::GetTempPath()
# Do not use the machine temp root's real stop.request. Test-Path is mocked.
$script:stopRequested = $false
function Test-Path { param($LiteralPath) return $script:stopRequested }
function Start-Sleep { param($Milliseconds) }
function Assert-That($condition, $message) { if (-not $condition) { throw $message } }

$Interactive = $false
Wait-For { $true } 1 'immediate condition'
$script:iterations = 0
$Interactive = $true
Wait-For { ++$script:iterations -ge 3 } 0 'unbounded successful wait'
Assert-That ($script:iterations -eq 3) 'Zero timeout did not continue until success.'
$script:stopRequested = $true
$cancelled = $false
try { Wait-For { $false } 0 'manual cancellation' }
catch [OperationCanceledException] { $cancelled = $true }
Assert-That $cancelled 'Interactive stop did not cancel the wait.'
$script:stopRequested = $false
$worldWorker = [pscustomobject]@{ Process = [pscustomobject]@{ HasExited = $true } }
$exited = $false
try { Wait-For { $true } 0 'dead worldserver' }
catch { $exited = $_.Exception.Message -like 'Worldserver exited*' }
Assert-That $exited 'Worldserver exit did not interrupt interactive wait.'
$worldWorker = $null
$Interactive = $false
$timedOut = $false
try { Wait-For { $false } -1 'expired deadline' }
catch { $timedOut = $_.Exception.Message -like 'Timed out waiting*' }
Assert-That $timedOut 'Bounded mode did not retain deadline failure.'

# Capture the wrapper's timeout argument rather than waiting in real time.
function Wait-For { param($condition, $seconds, $description) $script:observedSeconds = $seconds }
$Interactive = $false
Wait-ForHuman { $true } 240 'bounded human step'
Assert-That ($script:observedSeconds -eq 240) 'Automated human-step deadline changed.'
$Interactive = $true
Wait-ForHuman { $true } 240 'interactive human step'
Assert-That ($script:observedSeconds -eq 0) 'Interactive human step retained a deadline.'
Write-Host 'Harness wait policy: 7 checks passed; no game or database services started.'
