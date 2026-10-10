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
    # Exercise the wrapper's actual exclusive lock without invoking compilers.
    $lockTokens = $null; $lockErrors = $null
    $lockAst = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'build-local.ps1'), [ref]$lockTokens, [ref]$lockErrors)
    Assert-True ($lockErrors.Count -eq 0) 'Build wrapper has syntax errors.'
    $lockFunction = $lockAst.Find({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Open-LocalBuildLock'
    }, $true)
    Assert-True ($null -ne $lockFunction) 'Build wrapper lock not found.'
    . ([scriptblock]::Create($lockFunction.Extent.Text))
    $otherBuild = Join-Path $testRoot 'other-build'
    [void](New-Item -ItemType Directory -Path $otherBuild)
    $firstLock = Open-LocalBuildLock $build
    try {
        Assert-Rejected { Open-LocalBuildLock $build }
        $independentLock = Open-LocalBuildLock $otherBuild
        $independentLock.Dispose()
    } finally { $firstLock.Dispose() }
    $reacquiredLock = Open-LocalBuildLock $build
    $reacquiredLock.Dispose()
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
    # Exercise the real writer's bounded quest-gate prefix in memory, without
    # invoking its filesystem writes or starting a database/game process.
    $questTokens = $null; $questErrors = $null
    $questAst = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot 'playerbot-lifecycle-smoke.ps1'), [ref]$questTokens, [ref]$questErrors)
    Assert-True ($questErrors.Count -eq 0) 'Quest fixture harness parse failed.'
    $questWriter = $questAst.Find({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Write-TestWorldConfig'
    }, $true)
    $questResetStatements = @($questWriter.Body.EndBlock.Statements | Where-Object {
        $_ -is [Management.Automation.Language.AssignmentStatementAst] -and
        ($_.Extent.Text.Contains('Playerbots\.Quest\.') -or $_.Extent.Text.Contains('Playerbots.Quest.AcceptShared.Enabled'))
    })
    Assert-True ($questResetStatements.Count -eq 2) 'Quest gate reset statements not found.'
    $questReset = [scriptblock]::Create((($questResetStatements | ForEach-Object { $_.Extent.Text }) -join [Environment]::NewLine))
    foreach ($questEnabled in @($false, $true)) {
        $QuestFixture = $questEnabled
        $QuestAbandon = $false
        $text = "Playerbots.Quest.AcceptShared.Enabled = 1`r`n  Playerbots.Quest.AcceptNpc.Enabled = 1`r`nPlayerbots.Quest.AcceptShared.Enabled = 1`r`n Playerbots.Quest.Reward.Enabled = 1`r`n Playerbots.Quest.Inspection.Enabled = 1`r`n Playerbots.Quest.Share.Enabled = 1`r`nUnrelated = preserved`r`n"
        $text += "Playerbots.Quest.Abandon.Enabled = 1`r`n Playerbots.Quest.SyncLootWithPlayer.Enabled = 1`r`nPlayerbots.Quest.SyncLootWithPlayer.Enabled = 1`r`n"
        . $questReset
        Assert-True ([regex]::Matches($text, '(?m)^Playerbots\.Quest\.Abandon\.Enabled = 0\r?$').Count -eq 1) 'Ordinary quest fixture enabled abandonment.'
        foreach ($questGate in @('AcceptShared', 'AcceptNpc', 'Reward', 'Inspection', 'Share', 'SyncLootWithPlayer')) {
            $questEntries = [regex]::Matches($text, "(?m)^Playerbots\.Quest\.$questGate\.Enabled = ([01])\r?$")
            Assert-True ($questEntries.Count -eq 1 -and $questEntries[0].Groups[1].Value -eq [string][int]$questEnabled) 'Inherited quest gate was not replaced.'
        }
        Assert-True ($text.Contains('Unrelated = preserved')) 'Quest fixture changed unrelated configuration.'
    }
    $QuestAbandon = $true
    . $questReset
    Assert-True ([regex]::Matches($text, '(?m)^Playerbots\.Quest\.Abandon\.Enabled = 1\r?$').Count -eq 1) 'Explicit abandonment fixture opt-in was not applied.'
    $questReader = $questAst.Find({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Read-TestQuestState'
    }, $true)
    . ([scriptblock]::Create($questReader.Extent.Text))
    function Invoke-TestSql([string]$query) {
        Assert-True ($query.StartsWith('SELECT guid,quest,status ') -and $query.EndsWith('LIMIT 126;')) 'Quest evidence query is not bounded/read-only.'
        return $questFixtureRows
    }
    $questFixtureRows = ''
    Assert-True (@(Read-TestQuestState '2,3,4,5,6').Count -eq 0) 'Empty quest state was not preserved.'
    $questFixtureRows = "2`t9193`t3`r`n4`t9193`t1`r`n5`t9193`t5"
    $questRead = @(Read-TestQuestState '2,3,4,5,6')
    Assert-True ($questRead.Count -eq 3 -and $questRead[0].Guid -eq 2 -and $questRead[0].Quest -eq 9193 -and $questRead[1].Status -eq 1 -and $questRead[2].Status -eq 5) 'Native quest rows were parsed incorrectly.'
    $questFixtureRows = "2`t9193`t0"
    Assert-Rejected { Read-TestQuestState '2,3,4,5,6' }
    $questFixtureRows = ((1..126 | ForEach-Object { "2`t$_`t3" }) -join "`n")
    Assert-Rejected { Read-TestQuestState '2,3,4,5,6' }
    Assert-Rejected { Read-TestQuestState '2,3,4,5,6); DELETE FROM characters.character_queststatus;' }
    $rewardReader = $questAst.Find({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Read-TestRewardState'
    }, $true)
    . ([scriptblock]::Create($rewardReader.Extent.Text))
    function Invoke-TestSql([string]$query) {
        Assert-True ($query.StartsWith('SELECT ') -and $query -match ' LIMIT \d+;$') 'Reward evidence query is not bounded/read-only.'
        if ($rewardMode -eq 'empty') { return '' }
        if ($rewardMode -eq 'malformed') { return "2`tbad`t1" }
        if ($rewardMode -eq 'over-limit') { return ((1..501 | ForEach-Object { "2`t$_`t1" }) -join "`n") }
        if ($query.StartsWith('SELECT guid,quest,active')) { return "2`t9193`t1" }
        if ($query.StartsWith('SELECT c.guid,i.itemEntry')) {
            Assert-True ($query.Contains('i.owner_guid=c.guid')) 'Inventory ownership is not joined to native mapping.'
            return "2`t9758`t3"
        }
        if ($query.StartsWith('SELECT guid,level,xp,money')) { return "2`t20`t500`t4294967296" }
        throw 'Unexpected reward evidence query.'
    }
    $rewardMode = 'empty'
    $rewardRead = Read-TestRewardState '2,3,4,5,6'
    Assert-True ($rewardRead.Rewarded.Count -eq 0 -and $rewardRead.InventoryTotals.Count -eq 0) 'Empty reward state was not preserved.'
    $rewardMode = 'valid'
    $rewardRead = Read-TestRewardState '2,3,4,5,6'
    Assert-True ($rewardRead.Rewarded[0].Quest -eq 9193 -and $rewardRead.InventoryTotals[0].Entry -eq 9758 -and $rewardRead.Characters[0].Money -eq [uint64]4294967296) 'Reward evidence fields lost identity or numeric range.'
    $rewardMode = 'malformed'
    Assert-Rejected { Read-TestRewardState '2,3,4,5,6' }
    $rewardMode = 'over-limit'
    Assert-Rejected { Read-TestRewardState '2,3,4,5,6' }
    Assert-Rejected { Read-TestRewardState '2,3,4,5,6); DELETE FROM characters.characters;' }
    # Source-order regression for the native handler, separate from gameplay
    # proof: clearing sharing state also clears its GUID, so capture must precede it.
    $nativeQuestHandler = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../../src/server/game/Handlers/QuestHandler.cpp') -Raw
    $confirmStart = $nativeQuestHandler.IndexOf('void WorldSession::HandleQuestConfirmAccept(')
    $confirmEnd = $nativeQuestHandler.IndexOf('void WorldSession::HandleQuestgiverCompleteQuest(', $confirmStart)
    Assert-True ($confirmStart -ge 0 -and $confirmEnd -gt $confirmStart) 'Native confirmation handler not found.'
    $confirmBody = $nativeQuestHandler.Substring($confirmStart, $confirmEnd - $confirmStart)
    $captureAt = $confirmBody.IndexOf('ObjectGuid const sharerGuid = _player->GetPlayerSharingQuest();')
    $clearAt = $confirmBody.IndexOf('_player->ClearQuestSharingInfo();')
    $lookupAt = $confirmBody.IndexOf('ObjectAccessor::FindPlayer(sharerGuid)')
    Assert-True ($captureAt -ge 0 -and $captureAt -lt $clearAt -and $clearAt -lt $lookupAt) 'Native confirmation lost its sharer identity before lookup.'
    foreach ($nativeCheck in @('IsInSameRaidWith(originalPlayer)', 'IsActiveQuest(packet.QuestID)', 'CanTakeQuest(quest, true)', 'CanAddQuest(quest, true)')) {
        Assert-True ($confirmBody.Contains($nativeCheck)) 'Native confirmation admission guard was removed.'
    }
    # Native availability polarity: ordinary non-pooled quests are active too.
    # Keep the guard paired with the actual pool-manager contract, not gameplay proof.
    $nativePlayer = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../../src/server/game/Entities/Player/Player.cpp') -Raw
    $shareStart = $nativePlayer.IndexOf('bool Player::CanShareQuest(')
    $shareEnd = $nativePlayer.IndexOf('void Player::SetQuestStatus(', $shareStart)
    Assert-True ($shareStart -ge 0 -and $shareEnd -gt $shareStart) 'Native share admission function not found.'
    $shareBody = $nativePlayer.Substring($shareStart, $shareEnd - $shareStart)
    Assert-True ($shareBody.Contains('if (!sQuestPoolMgr->IsQuestActive(quest_id))')) 'Native sharing rejects active quests instead of inactive ones.'
    foreach ($nativeCheck in @('HasFlag(QUEST_FLAGS_SHARABLE)', 'm_QuestStatus.find(quest_id)', 'QUEST_PARTY_MSG_CANT_BE_SHARED_TODAY')) {
        Assert-True ($shareBody.Contains($nativeCheck)) 'Native share admission guard was removed.'
    }
    $nativePools = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../../src/server/game/Pools/QuestPools.cpp') -Raw
    $poolStart = $nativePools.IndexOf('bool QuestPoolMgr::IsQuestActive(')
    Assert-True ($poolStart -ge 0) 'Native quest availability function not found.'
    $poolBody = $nativePools.Substring($poolStart)
    Assert-True ($poolBody -match 'if \(it == _poolLookup.end\(\)\)[^\r\n]*\s+return true;') 'Non-pooled native quest availability contract changed.'
    Assert-True ($poolBody.Contains('activeQuests.find(questId) != it->second->activeQuests.end()')) 'Pooled native quest availability contract changed.'
    Write-Host 'Environment, bounded quest evidence, native confirmation and share-availability guards passed; no services started.'
}
finally {
    # Only this generated temporary fixture is eligible for cleanup.
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if (-not $resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path $resolved -Leaf) -notlike 'cata-test-environment-*') { throw 'Unexpected test cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
