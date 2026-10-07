# Exercise the actual controlled SQL preparation branch without starting services.
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'playerbot-lifecycle-smoke.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw 'Harness parse failed.' }
$branch = $ast.Find({ param($node)
    $node -is [Management.Automation.Language.IfStatementAst] -and
    $node.Extent.Text.StartsWith('if ($ControlledLootRoll)') -and
    $node.Extent.Text.Contains('$controlledLoot = 990001')
}, $true)
if (-not $branch) { throw 'Controlled fixture branch missing.' }
$body = $branch.Clauses[0].Item2.Extent.Text
$prepare = [ScriptBlock]::Create($body.Substring(1, $body.Length - 2))
$testRoot = Join-Path $PSScriptRoot '../../build'
$stage = Join-Path $testRoot ('controlled-roll-check-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $stage)
function Invoke-TestSql([string]$sql) {
    if ($sql.StartsWith('SELECT COUNT(*) FROM characters.character_inventory')) { return $(if ($script:mode -eq 'bad-seed') { '0' } else { '2' }) }
    if ($sql.StartsWith('SELECT entry,lootid')) { return "11517`t11517" }
    if ($sql.StartsWith('SELECT COUNT(*) FROM world.creature WHERE')) { return $(if ($script:mode -eq 'ambiguous-spawn') { '2' } else { '1' }) }
    if ($sql.StartsWith('SELECT (SELECT COUNT(*)')) { return $(if ($script:mode -eq 'occupied-id') { '1' } else { '0' }) }
    if ($sql.StartsWith('START TRANSACTION;')) { $script:writes.Add($sql); return '' }
    throw 'Unexpected fixture query.'
}
foreach ($case in @('valid','bad-seed','ambiguous-spawn','occupied-id')) {
    $script:mode = $case
    $script:writes = [Collections.Generic.List[string]]::new()
    $failed = $false
    try { & $prepare } catch { $failed = $true }
    if ($case -eq 'valid') {
        if ($failed -or $script:writes.Count -ne 1) { throw 'Valid controlled setup failed.' }
        $write = $script:writes[0]
        if (-not $write.Contains('VALUES (990001,2866,0,100,0,0,1,0,1,1)') -or
            -not $write.Contains('WHERE entry=11517 AND lootid=11517; COMMIT;') -or
            $write -match 'DELETE|UPDATE characters') { throw 'Fixture mutation exceeded its bounded scope.' }
    }
    elseif (-not $failed -or $script:writes.Count) { throw "Unsafe fixture precondition accepted: $case" }
}
Write-Host 'Controlled loot fixture: 4 branch checks passed; no game/database services started.'
