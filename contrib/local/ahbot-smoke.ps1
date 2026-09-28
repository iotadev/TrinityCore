param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Seed,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$MySqlHome,
    [string]$BuildDirectory = 'build/bin/RelWithDebInfo', [string]$DataDirectory,
    [switch]$CheckBuyer,
    [switch]$CheckSupplyProfile,
    [switch]$CheckTurnover
)

# Native Cata AHBot seller proof against a COPY of a disposable, cleanly
# stopped database. Never point this at an installed or live server database.
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'test-environment.ps1')
$mysqlHome = Resolve-TestDirectory $MySqlHome $repo 'MySqlHome'
$built = Resolve-TestDirectory $BuildDirectory $repo 'BuildDirectory'
Assert-TestFiles $mysqlHome @('bin/mysql.exe','bin/mysqld.exe','bin/libcrypto-3-x64.dll','bin/libssl-3-x64.dll') 'MySqlHome'
Assert-TestFiles $built @('worldserver.exe') 'BuildDirectory'
if ($DataDirectory) { $gameData = Resolve-TestDirectory $DataDirectory $repo 'DataDirectory' }
$seedPath = Resolve-TestSeed $Seed $repo
Assert-TestFiles $seedPath @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll','libmysql.dll') 'Seed'

$stage = Join-Path $repo ('build/ahbot-smoke-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$mysqlExe = Join-Path $mysqlHome 'bin/mysql.exe'
$mysqlServerExe = Join-Path $mysqlHome 'bin/mysqld.exe'
$workers = [Collections.Generic.List[object]]::new()
$worldWorker = $null
$mysqlWorker = $null
$dbReady = $false
$supplyProfileTest = $CheckSupplyProfile -or $CheckTurnover

function Start-Worker([string]$exe, [string[]]$arguments, [string]$label) {
    $psi = [Diagnostics.ProcessStartInfo]::new($exe)
    $psi.WorkingDirectory = $stage
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    foreach ($argument in $arguments) { $psi.ArgumentList.Add($argument) }
    [void]$psi.Environment.Remove('PATH')
    $outFile = [IO.FileStream]::new((Join-Path $stage "$label.stdout.log"), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, [IO.FileOptions]::Asynchronous)
    $errFile = [IO.FileStream]::new((Join-Path $stage "$label.stderr.log"), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, [IO.FileOptions]::Asynchronous)
    try { $process = [Diagnostics.Process]::Start($psi) }
    catch { $outFile.Dispose(); $errFile.Dispose(); throw }
    $worker = [pscustomobject]@{ Process=$process; OutFile=$outFile; ErrFile=$errFile; OutTask=$process.StandardOutput.BaseStream.CopyToAsync($outFile); ErrTask=$process.StandardError.BaseStream.CopyToAsync($errFile) }
    $workers.Add($worker)
    Write-Host "Started $label (PID $($process.Id))"
    return $worker
}

function Invoke-TestSql([string]$sql) {
    $psi = [Diagnostics.ProcessStartInfo]::new($mysqlExe)
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    foreach ($argument in @('--no-defaults','--protocol=TCP','--host=127.0.0.1','--port=13306','--user=cata_smoke','--batch','--skip-column-names','--connect-timeout=3')) { $psi.ArgumentList.Add($argument) }
    [void]$psi.Environment.Remove('PATH')
    $psi.Environment['MYSQL_PWD'] = $credential.password
    $process = [Diagnostics.Process]::Start($psi)
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $process.StandardInput.WriteLine($sql)
    $process.StandardInput.Close()
    if (-not $process.WaitForExit(30000)) { $process.Kill(); throw 'Test SQL timed out.' }
    if ($process.ExitCode -ne 0) { throw "Test SQL failed: $($stderr.Result)" }
    return $stdout.Result.Trim()
}

function Send-WorldCommand([string]$command) {
    if ($worldWorker.Process.HasExited) { throw 'Worldserver exited before command.' }
    $worldWorker.Process.StandardInput.WriteLine($command)
    $worldWorker.Process.StandardInput.Flush()
    Write-Host "Sent world command: $command"
}

function Wait-For([scriptblock]$condition, [int]$seconds, [string]$description) {
    $deadline = (Get-Date).AddSeconds($seconds)
    do {
        if ($null -ne $worldWorker -and $worldWorker.Process.HasExited) { throw "Worldserver exited while waiting for $description." }
        if (& $condition) { return }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $deadline)
    throw "Timed out waiting for $description."
}

function Set-ConfigValue([string]$text, [string]$key, [string]$value) {
    $pattern = '(?m)^' + [regex]::Escape($key) + '\s*=.*$'
    if ([regex]::IsMatch($text, $pattern))
        { return [regex]::Replace($text, $pattern, "$key = $value") }
    return $text + "`r`n$key = $value`r`n"
}

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 13306)
try { $listener.Start() } finally { $listener.Stop() }
$credentialPath = Join-Path $seedPath 'test-db-credentials.json'
$credential = Read-TestCredentials $seedPath

try {
    New-Item -ItemType Directory -Path $stage | Out-Null
    Set-Acl -LiteralPath $stage -AclObject (Get-Acl -LiteralPath $seedPath)
    Write-Host "TEST DIRECTORY: $stage"
    Copy-Item -LiteralPath (Join-Path $seedPath 'mysql-data') -Destination (Join-Path $stage 'mysql-data') -Recurse
    Copy-Item -LiteralPath $credentialPath -Destination (Join-Path $stage 'test-db-credentials.json')
    New-Item -ItemType Directory -Path (Join-Path $stage 'logs') | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $stage 'modules') | Out-Null
    [IO.File]::WriteAllText((Join-Path $stage 'modules/ahbot.conf'), "[worldserver]`r`nAuctionHouseBot.ModuleConfigProbe = 1`r`n", [Text.UTF8Encoding]::new($false))
    foreach ($name in @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll','libmysql.dll')) { Copy-Item -LiteralPath (Join-Path $seedPath $name) -Destination $stage }
    foreach ($name in @('libcrypto-3-x64.dll','libssl-3-x64.dll')) { Copy-Item -LiteralPath (Join-Path $mysqlHome "bin/$name") -Destination $stage }
    Copy-Item -LiteralPath (Join-Path $built 'worldserver.exe') -Destination $stage
    if (Test-Path -LiteralPath (Join-Path $built 'worldserver.pdb')) { Copy-Item -LiteralPath (Join-Path $built 'worldserver.pdb') -Destination $stage }

    $mysqlWorker = Start-Worker $mysqlServerExe @('--no-defaults',"--basedir=$mysqlHome",("--datadir="+(Join-Path $stage 'mysql-data')),'--bind-address=127.0.0.1','--port=13306','--mysqlx=OFF','--skip-name-resolve','--skip-log-bin','--lower-case-table-names=1','--innodb-buffer-pool-size=512M','--innodb-redo-log-capacity=1G','--innodb-flush-log-at-trx-commit=2','--max-allowed-packet=256M',("--log-error="+(Join-Path $stage 'mysql-error.log'))) 'mysql'
    $deadline = (Get-Date).AddSeconds(90)
    do {
        if ($mysqlWorker.Process.HasExited) { throw 'Cloned MySQL exited before ready.' }
        try { $dbReady = (Invoke-TestSql 'SELECT 1;') -eq '1' } catch { $dbReady = $false }
        if (-not $dbReady) { Start-Sleep -Milliseconds 500 }
    } while (-not $dbReady -and (Get-Date) -lt $deadline)
    if (-not $dbReady) { throw 'Cloned MySQL did not become ready.' }

    $identity = Invoke-TestSql "SELECT a.id, c.guid, c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='CATASMOKE' AND c.name='Testone';"
    $fields = $identity -split "`t"
    if ($fields.Count -ne 3 -or $fields[2] -ne '0') { throw "Expected one offline CATASMOKE/Testone character; found: $identity" }
    $accountId = [uint32]$fields[0]
    $characterGuid = [uint32]$fields[1]
    $playerGuid = 0
    if ($CheckBuyer) {
        $playerIdentity = Invoke-TestSql "SELECT guid, name FROM characters.characters WHERE account<>$accountId AND online=0 ORDER BY guid LIMIT 1;"
        $playerFields = $playerIdentity -split "`t"
        if ($playerFields.Count -ne 2) {
            $playerGuid = 1 + [uint32](Invoke-TestSql 'SELECT COALESCE(MAX(guid), 0) FROM characters.characters;')
            $playerAccountId = 1000000 + [uint32](Invoke-TestSql 'SELECT COALESCE(MAX(id), 0) FROM auth.account;')
            $columns = (Invoke-TestSql "SELECT COLUMN_NAME FROM information_schema.columns WHERE table_schema='characters' AND table_name='characters' ORDER BY ORDINAL_POSITION;") -split "`r?`n"
            $tick = [char]96
            $quotedColumns = $columns | ForEach-Object { "$tick$_$tick" }
            $selectExpressions = foreach ($column in $columns) {
                switch ($column) {
                    'guid' { "$playerGuid" }
                    'account' { "$playerAccountId" }
                    'name' { "'Ahbuyer'" }
                    'online' { '0' }
                    default { "$tick$column$tick" }
                }
            }
            $cloneSql = 'INSERT INTO characters.characters (' + ($quotedColumns -join ',') + ') SELECT ' + ($selectExpressions -join ',') + " FROM characters.characters WHERE guid=$characterGuid;"
            [void](Invoke-TestSql $cloneSql)
            $playerIdentity = Invoke-TestSql "SELECT guid, name FROM characters.characters WHERE guid=$playerGuid AND account=$playerAccountId;"
            $playerFields = $playerIdentity -split "`t"
        }
        if ($playerFields.Count -ne 2) { throw 'Could not prepare an offline non-bot character in the disposable clone.' }
        $playerGuid = [uint32]$playerFields[0]
        Write-Host "Buyer check will use non-bot seller $($playerFields[1]) (GUID $playerGuid)."
    }
    $seedAuctionCount = [uint32](Invoke-TestSql 'SELECT COUNT(*) FROM characters.auctionhouse;')
    Write-Host "Clearing $seedAuctionCount pre-existing auctions from the disposable clone only."
    [void](Invoke-TestSql 'USE characters; DELETE ab FROM auctionbidders ab JOIN auctionhouse ah ON ah.id=ab.id; DELETE ii FROM item_instance ii JOIN auctionhouse ah ON ah.itemguid=ii.guid; DELETE FROM auctionhouse;')
    if ((Invoke-TestSql 'SELECT COUNT(*) FROM characters.auctionhouse;') -ne '0') { throw 'Disposable auction table did not clear.' }

    $config = [IO.File]::ReadAllText((Join-Path $seedPath 'worldserver.conf'))
    if ($DataDirectory) {
        $config = [regex]::Replace($config, '(?m)^DataDir\s*=.*$', [Text.RegularExpressions.MatchEvaluator]{ param($match) 'DataDir = "' + $gameData.Replace('\','/') + '"' })
    }
    $config = [regex]::Replace($config, '(?m)^MySQLExecutable\s*=.*$', [Text.RegularExpressions.MatchEvaluator]{ param($match) 'MySQLExecutable = "' + $mysqlExe.Replace('\','/') + '"' })
    $logsDir = (Join-Path $stage 'logs').Replace('\','/')
    $catalogPath = Join-Path $stage 'ahbot-market-catalog.csv'
    $catalogConfigPath = $catalogPath.Replace('\','/')
    $expectedAuctionCount = if ($supplyProfileTest) { 120 } else { 12 }
    $amountGray = if ($supplyProfileTest) { 10 } else { 2 }
    $amountWhite = if ($supplyProfileTest) { 40 } else { 4 }
    $amountGreen = if ($supplyProfileTest) { 40 } else { 4 }
    $amountBlue = if ($supplyProfileTest) { 25 } else { 2 }
    $amountPurple = if ($supplyProfileTest) { 5 } else { 0 }
    $config = Set-ConfigValue $config 'LogsDir' ('"' + $logsDir + '"')
    $config = Set-ConfigValue $config 'Modules.ConfigDirectory' '"modules"'
    $settings = [ordered]@{
        'Playerbots.Dev.Enabled' = '0'
        'Logger.ahbot' = '2,Console Server'
        'AuctionHouseBot.Account' = "$accountId"
        'AuctionHouseBot.Update.Interval' = '1'
        'AuctionHouseBot.Seller.Enabled' = '1'
        'AuctionHouseBot.Buyer.Enabled' = '0'
        'AuctionHouseBot.Items.Crafted' = '1'
        'AuctionHouseBot.SupplyProfile.Enabled' = $(if ($supplyProfileTest) { '1' } else { '0' })
        'AuctionHouseBot.SupplyProfile.Commodity.MaxAuctionsPerItem' = '1'
        'AuctionHouseBot.SupplyProfile.Equipment.MaxAuctionsPerItem' = '1'
        'AuctionHouseBot.SupplyProfile.Other.MaxAuctionsPerItem' = '1'
        'AuctionHouseBot.SupplyProfile.Commodity.Weight' = '45'
        'AuctionHouseBot.SupplyProfile.Equipment.Weight' = '40'
        'AuctionHouseBot.SupplyProfile.Other.Weight' = '15'
        'AuctionHouseBot.SupplyProfile.Commodity.StackWeight.Single' = '20'
        'AuctionHouseBot.SupplyProfile.Commodity.StackWeight.Quarter' = '25'
        'AuctionHouseBot.SupplyProfile.Commodity.StackWeight.Half' = '25'
        'AuctionHouseBot.SupplyProfile.Commodity.StackWeight.Full' = '30'
        'AuctionHouseBot.MarketCatalog.File' = ('"' + $catalogConfigPath + '"')
        'AuctionHouseBot.MinTime' = '6'
        'AuctionHouseBot.MaxTime' = $(if ($CheckTurnover) { '18' } else { '6' })
        'AuctionHouseBot.Alliance.Items.Amount.Ratio' = '0'
        'AuctionHouseBot.Horde.Items.Amount.Ratio' = '0'
        'AuctionHouseBot.Neutral.Items.Amount.Ratio' = '100'
        'AuctionHouseBot.ItemsPerCycle.Boost' = '20'
        'AuctionHouseBot.ItemsPerCycle.Normal' = '20'
        'AuctionHouseBot.Items.Amount.Gray' = "$amountGray"
        'AuctionHouseBot.Items.Amount.White' = "$amountWhite"
        'AuctionHouseBot.Items.Amount.Green' = "$amountGreen"
        'AuctionHouseBot.Items.Amount.Blue' = "$amountBlue"
        'AuctionHouseBot.Items.Amount.Purple' = "$amountPurple"
        'AuctionHouseBot.Items.Amount.Orange' = '0'
        'AuctionHouseBot.Items.Amount.Yellow' = '0'
    }
    foreach ($entry in $settings.GetEnumerator()) { $config = Set-ConfigValue $config $entry.Key $entry.Value }
    [IO.File]::WriteAllText((Join-Path $stage 'worldserver.conf'), $config, [Text.UTF8Encoding]::new($false))

    $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'world'
    $serverLog = Join-Path $stage 'logs/Server.log'
    Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'worldserver readiness'
    if (-not (Select-String -LiteralPath $serverLog -Pattern 'Loaded module config .*ahbot\.conf' -Quiet)) {
        throw 'mod-ahbot active configuration was not loaded by the staged worldserver.'
    }
    Wait-For { (Test-Path $catalogPath) -and (Get-Item -LiteralPath $catalogPath).Length -gt 100 } 30 'AHBot market catalog export'

    $catalog = @(Import-Csv -LiteralPath $catalogPath)
    if ($catalog.Count -eq 0) { throw 'AHBot market catalog contained no items.' }
    $catalogIds = @($catalog | ForEach-Object { [uint32]$_.item_id })
    if (($catalogIds | Sort-Object -Unique).Count -ne $catalog.Count) { throw 'AHBot market catalog contained duplicate item IDs.' }
    $eligibleCatalog = @($catalog | Where-Object { $_.seller_eligible -eq '1' })
    $craftedCatalog = @($catalog | Where-Object { $_.is_profession_crafted -eq '1' })
    $additionalCraftedCatalog = @($craftedCatalog | Where-Object { $_.seller_eligible -eq '0' })
    if ($eligibleCatalog.Count -eq 0) { throw 'AHBot market catalog contained no seller-eligible items.' }
    if ($craftedCatalog.Count -eq 0) { throw 'AHBot market catalog contained no profession-crafted candidates.' }
    if ($eligibleCatalog | Where-Object { [uint32]$_.item_id -in @(6343, 6345, 6376) }) { throw 'AHBot seller-eligible catalog included a configured force-excluded item.' }

    $catalogSummary = foreach ($row in $catalog) {
        $requiredLevel = [int]$row.required_level
        $levelBand = if ($requiredLevel -le 0) { '0' }
            elseif ($requiredLevel -le 20) { '1-20' }
            elseif ($requiredLevel -le 40) { '21-40' }
            elseif ($requiredLevel -le 60) { '41-60' }
            elseif ($requiredLevel -le 70) { '61-70' }
            elseif ($requiredLevel -le 80) { '71-80' }
            else { '81-85+' }
        [pscustomobject]@{
            item_class = $row.item_class
            item_subclass = $row.item_subclass
            quality = $row.quality
            level_band = $levelBand
            market_segment = $row.market_segment
            configured_segment_weight = $row.configured_segment_weight
            configured_item_ceiling = $row.configured_item_ceiling
            supply_profile_enabled = $row.supply_profile_enabled
            stack_policy = $row.stack_policy
            source = $row.source
            profession_crafted = $row.is_profession_crafted
            seller_eligible = $row.seller_eligible
        }
    }
    $catalogSummary | Group-Object item_class,item_subclass,quality,level_band,market_segment,configured_segment_weight,configured_item_ceiling,supply_profile_enabled,stack_policy,source,profession_crafted,seller_eligible | ForEach-Object {
        $first = $_.Group[0]
        [pscustomobject]@{
            item_class = $first.item_class
            item_subclass = $first.item_subclass
            quality = $first.quality
            level_band = $first.level_band
            market_segment = $first.market_segment
            configured_segment_weight = $first.configured_segment_weight
            configured_item_ceiling = $first.configured_item_ceiling
            supply_profile_enabled = $first.supply_profile_enabled
            stack_policy = $first.stack_policy
            source = $first.source
            profession_crafted = $first.profession_crafted
            seller_eligible = $first.seller_eligible
            items = $_.Count
        }
    } | Sort-Object @{ Expression = { [int]$_.seller_eligible }; Descending = $true },
        @{ Expression = { [int]$_.item_class } }, @{ Expression = { [int]$_.item_subclass } },
        @{ Expression = { [int]$_.quality } }, level_band, source |
        Export-Csv -LiteralPath (Join-Path $stage 'ahbot-market-catalog-summary.csv') -NoTypeInformation
    Write-Host "AHBot catalog exported $($eligibleCatalog.Count) seller-eligible entries and $($additionalCraftedCatalog.Count) additional profession-crafted candidates ($($catalog.Count) unique items total)."

    Wait-For { [uint32](Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE itemowner=$characterGuid;") -eq $expectedAuctionCount } 120 "all $expectedAuctionCount AHBot seller auctions"

    # Exercise the live command path. The legacy setter accidentally used a
    # lower-bound operation here, turning 100 into 10,000 and flooding supply.
    Send-WorldCommand 'ahbot ratio neutral 100'
    Start-Sleep -Seconds 2
    Send-WorldCommand 'ahbot ratio 0 0 100'
    Start-Sleep -Seconds 2
    $realizedAuctionCount = [uint32](Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE itemowner=$characterGuid;")
    if ($realizedAuctionCount -ne $expectedAuctionCount) { throw "AHBot did not preserve the $expectedAuctionCount-listing target after a 100% runtime ratio; found $realizedAuctionCount auctions." }

    if ($supplyProfileTest) {
        $distinctItemCount = [uint32](Invoke-TestSql "SELECT COUNT(DISTINCT ii.itemEntry) FROM characters.auctionhouse ah JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid;")
        if ($distinctItemCount -ne $expectedAuctionCount) {
            throw "Supply-profile ceiling of one was violated: $realizedAuctionCount listings used $distinctItemCount distinct item entries."
        }
        Write-Host "Supply-profile ceiling proof retained $distinctItemCount distinct entries across $realizedAuctionCount listings."

        $catalogByItemId = @{}
        foreach ($row in $eligibleCatalog) { $catalogByItemId[[uint32]$row.item_id] = $row }
        $segmentCounts = @{ commodity = 0; equipment = 0; other = 0 }
        $stackShapes = @{ single = 0; quarter = 0; half = 0; full = 0 }
        $listedItems = (Invoke-TestSql "SELECT ii.itemEntry, ii.count FROM characters.auctionhouse ah JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid ORDER BY ah.id;") -split "`r?`n"
        foreach ($listedItem in $listedItems) {
            if (-not $listedItem) { continue }
            $listedFields = $listedItem -split "`t"
            $listedItemId = [uint32]$listedFields[0]
            $stackCount = [uint32]$listedFields[1]
            $catalogRow = $catalogByItemId[$listedItemId]
            $segment = $catalogRow.market_segment
            if (-not $segmentCounts.ContainsKey($segment)) { throw "Listed item $listedItemId has unknown market segment '$segment'." }
            ++$segmentCounts[$segment]

            if ($segment -eq 'equipment' -and $stackCount -ne 1) {
                throw "Equipment item $listedItemId used stack $stackCount instead of one."
            }
            if ($segment -eq 'commodity') {
                $maxStack = [uint32]$catalogRow.max_stack
                $quarterStack = [math]::Min($maxStack, [math]::Max(2, [math]::Ceiling($maxStack / 4.0)))
                $halfStack = [math]::Min($maxStack, [math]::Max(2, [math]::Ceiling($maxStack / 2.0)))
                $allowedStacks = @(1, [uint32]$quarterStack, [uint32]$halfStack, $maxStack) | Sort-Object -Unique
                if ($stackCount -notin $allowedStacks) {
                    throw "Commodity item $listedItemId used invalid stack $stackCount; allowed shapes are $($allowedStacks -join ',')."
                }
                if ($stackCount -eq 1) { ++$stackShapes.single }
                elseif ($stackCount -eq $maxStack) { ++$stackShapes.full }
                elseif ($stackCount -eq $quarterStack) { ++$stackShapes.quarter }
                else { ++$stackShapes.half }
            }
        }
        $expectedSegmentCounts = @{ commodity = 54; equipment = 48; other = 18 }
        foreach ($segment in $expectedSegmentCounts.Keys) {
            if ($segmentCounts[$segment] -ne $expectedSegmentCounts[$segment]) {
                throw "Supply-profile segment target failed for ${segment}: expected $($expectedSegmentCounts[$segment]), found $($segmentCounts[$segment])."
            }
        }
        Write-Host "Supply-profile segment targets realized commodity=$($segmentCounts.commodity), equipment=$($segmentCounts.equipment), other=$($segmentCounts.other)."
        Write-Host "Commodity stack shapes realized single=$($stackShapes.single), quarter=$($stackShapes.quarter), half=$($stackShapes.half), full=$($stackShapes.full)."
    }

    $lifetimeFields = (Invoke-TestSql "SELECT MIN(time - UNIX_TIMESTAMP()), MAX(time - UNIX_TIMESTAMP()), COUNT(DISTINCT time) FROM characters.auctionhouse WHERE itemowner=$characterGuid;") -split "`t"
    if ($lifetimeFields.Count -ne 3) { throw "Could not read AHBot lifetime distribution: $($lifetimeFields -join ', ')." }
    if ($CheckTurnover) {
        if ([int]$lifetimeFields[0] -lt 19800 -or [int]$lifetimeFields[1] -gt 66600 -or [int]$lifetimeFields[2] -lt 2) {
            throw "AHBot did not honor the configured staggered 6-18 hour lifetime; remaining-second bounds/distinct expirations were $($lifetimeFields -join ', ')."
        }
        Write-Host "Turnover lifetime distribution spans $($lifetimeFields[0])-$($lifetimeFields[1]) remaining seconds across $($lifetimeFields[2]) distinct expiration timestamps."
    }
    elseif ([int]$lifetimeFields[0] -lt 19800 -or [int]$lifetimeFields[1] -gt 22200) {
        throw "AHBot did not honor the configured six-hour lifetime; remaining-second bounds were $($lifetimeFields[0]), $($lifetimeFields[1])."
    }

    Send-WorldCommand 'ahbot status all'
    $summary = Invoke-TestSql "SELECT ah.houseid, COUNT(*), MIN(ah.buyoutprice), MAX(ah.buyoutprice), COUNT(DISTINCT ii.itemEntry) FROM characters.auctionhouse ah JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid GROUP BY ah.houseid ORDER BY ah.houseid;"
    $orphans = Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse ah LEFT JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid AND ii.guid IS NULL;"
    if ($orphans -ne '0') { throw "AHBot created $orphans auction rows without item instances." }
    Write-Host "AHBot seller realized $realizedAuctionCount of $expectedAuctionCount requested listings."
    Write-Host "Database summary (house, auctions, min buyout, max buyout, distinct items):`n$summary"

    Send-WorldCommand 'server shutdown 0'
    if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Worldserver did not shut down within 60 seconds.' }
    if ($worldWorker.Process.ExitCode -ne 0) { throw "Worldserver exited with $($worldWorker.Process.ExitCode)." }
    Write-Host 'Native Cata AHBot seller smoke test passed with clean shutdown.'

    if ($CheckTurnover) {
        $turnoverRemovalCount = 24
        $initialMaxAuctionId = [uint32](Invoke-TestSql "SELECT COALESCE(MAX(id), 0) FROM characters.auctionhouse WHERE itemowner=$characterGuid;")
        [void](Invoke-TestSql "USE characters; CREATE TEMPORARY TABLE turnover_remove AS SELECT id, itemguid FROM auctionhouse WHERE itemowner=$characterGuid ORDER BY id LIMIT $turnoverRemovalCount; DELETE ab FROM auctionbidders ab JOIN turnover_remove tr ON tr.id=ab.id; DELETE ah FROM auctionhouse ah JOIN turnover_remove tr ON tr.id=ah.id; DELETE ii FROM item_instance ii JOIN turnover_remove tr ON tr.itemguid=ii.guid;")
        $postRemovalCount = [uint32](Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE itemowner=$characterGuid;")
        if ($postRemovalCount -ne ($expectedAuctionCount - $turnoverRemovalCount)) {
            throw "Turnover setup expected $($expectedAuctionCount - $turnoverRemovalCount) retained listings after removing $turnoverRemovalCount; found $postRemovalCount."
        }
        Write-Host "Turnover setup removed $turnoverRemovalCount listings while worldserver was stopped; $postRemovalCount retained listings remain."

        if (Test-Path $serverLog) {
            Move-Item -LiteralPath $serverLog -Destination (Join-Path $stage 'logs/Server-turnover-initial.log')
        }
        $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'turnover-world'
        Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'turnover worldserver readiness'
        Wait-For { [uint32](Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE itemowner=$characterGuid;") -eq $expectedAuctionCount } 120 "turnover refill to $expectedAuctionCount AHBot auctions"

        $refillMaxAuctionId = [uint32](Invoke-TestSql "SELECT COALESCE(MAX(id), 0) FROM characters.auctionhouse WHERE itemowner=$characterGuid;")
        if ($refillMaxAuctionId -le $initialMaxAuctionId) {
            throw "Turnover refill did not create new auction IDs; initial maximum was $initialMaxAuctionId and refill maximum was $refillMaxAuctionId."
        }
        $refillDistinctItemCount = [uint32](Invoke-TestSql "SELECT COUNT(DISTINCT ii.itemEntry) FROM characters.auctionhouse ah JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid;")
        if ($refillDistinctItemCount -ne $expectedAuctionCount) {
            throw "Turnover refill violated the per-item ceiling: $expectedAuctionCount listings used $refillDistinctItemCount distinct item entries."
        }
        $refillSegmentCounts = @{ commodity = 0; equipment = 0; other = 0 }
        $refillItemIds = (Invoke-TestSql "SELECT ii.itemEntry FROM characters.auctionhouse ah JOIN characters.item_instance ii ON ii.guid=ah.itemguid WHERE ah.itemowner=$characterGuid ORDER BY ah.id;") -split "`r?`n"
        foreach ($refillItemIdText in $refillItemIds) {
            if (-not $refillItemIdText) { continue }
            $refillItemId = [uint32]$refillItemIdText
            $refillSegment = $catalogByItemId[$refillItemId].market_segment
            if (-not $refillSegmentCounts.ContainsKey($refillSegment)) { throw "Refilled item $refillItemId has unknown market segment '$refillSegment'." }
            ++$refillSegmentCounts[$refillSegment]
        }
        foreach ($segment in $expectedSegmentCounts.Keys) {
            if ($refillSegmentCounts[$segment] -ne $expectedSegmentCounts[$segment]) {
                throw "Turnover refill segment target failed for ${segment}: expected $($expectedSegmentCounts[$segment]), found $($refillSegmentCounts[$segment])."
            }
        }
        Write-Host "Turnover refill restored $expectedAuctionCount distinct listings with new auction IDs and exact commodity=$($refillSegmentCounts.commodity), equipment=$($refillSegmentCounts.equipment), other=$($refillSegmentCounts.other) targets."

        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Turnover worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Turnover worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'Native Cata AHBot turnover refill test passed with clean shutdown.'
    }

    if ($CheckBuyer) {
        if (Test-Path $serverLog) {
            $sellerLogName = if ($CheckTurnover) { 'Server-turnover-refill.log' } else { 'Server-seller.log' }
            Move-Item -LiteralPath $serverLog -Destination (Join-Path $stage "logs/$sellerLogName")
        }
        $auctionIds = @((Invoke-TestSql "SELECT id FROM characters.auctionhouse WHERE itemowner=$characterGuid ORDER BY id LIMIT 2;") -split "`r?`n" | ForEach-Object { [uint32]$_ })
        if ($auctionIds.Count -ne 2) { throw 'Seller phase did not leave two auctions for the capped buyer check.' }
        $auctionIdList = $auctionIds -join ','
        [void](Invoke-TestSql "UPDATE characters.auctionhouse SET itemowner=$playerGuid, startbid=1, buyoutprice=1, buyguid=0, lastbid=0 WHERE id IN ($auctionIdList);")

        $buyerSettings = [ordered]@{
            'AuctionHouseBot.Seller.Enabled' = '0'
            'AuctionHouseBot.Alliance.Items.Amount.Ratio' = '0'
            'AuctionHouseBot.Horde.Items.Amount.Ratio' = '0'
            'AuctionHouseBot.Neutral.Items.Amount.Ratio' = '0'
            'AuctionHouseBot.Buyer.Enabled' = '1'
            'AuctionHouseBot.Buyer.Alliance.Enabled' = '0'
            'AuctionHouseBot.Buyer.Horde.Enabled' = '0'
            'AuctionHouseBot.Buyer.Neutral.Enabled' = '1'
            'AuctionHouseBot.Buyer.Recheck.Interval' = '0'
            'AuctionHouseBot.Update.Interval' = '10'
            'AuctionHouseBot.Buyer.EvaluationsPerCycle.Normal' = '2'
            'AuctionHouseBot.Buyer.EvaluationsPerCycle.Boost' = '2'
            'AuctionHouseBot.Buyer.ActionsPerCycle' = '1'
        }
        foreach ($entry in $buyerSettings.GetEnumerator()) { $config = Set-ConfigValue $config $entry.Key $entry.Value }
        [IO.File]::WriteAllText((Join-Path $stage 'worldserver.conf'), $config, [Text.UTF8Encoding]::new($false))

        $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'buyer-world'
        Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'buyer worldserver readiness'
        Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE id IN ($auctionIdList);") -eq '1' } 60 'one capped AHBot buyout'

        $remainingAuctionCount = [uint32](Invoke-TestSql "SELECT COUNT(*) FROM characters.auctionhouse WHERE id IN ($auctionIdList);")
        if ($remainingAuctionCount -ne 1) { throw "AHBot action cap did not leave exactly one of auctions $auctionIdList after the first buyer cycle." }
        if (-not (Select-String -LiteralPath $serverLog -Pattern 'AHBot buyer cycle: house=0 .*bought=1 .*action_limit=1 evaluation_limit=2' -Quiet)) {
            throw 'AHBot buyer did not emit the expected capped-cycle diagnostic.'
        }
        Write-Host "Native Cata AHBot buyer bought one of disposable auctions $auctionIdList and retained one under the per-cycle action cap."

        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Buyer worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Buyer worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'Native Cata AHBot buyer smoke test passed with clean shutdown.'
    }
} finally {
    if ($null -ne $worldWorker -and -not $worldWorker.Process.HasExited) {
        try { Send-WorldCommand 'server shutdown 0'; [void]$worldWorker.Process.WaitForExit(45000) } catch { }
    }
    if ($dbReady) { try { [void](Invoke-TestSql 'SHUTDOWN;') } catch { } }
    foreach ($worker in $workers) {
        if (-not $worker.Process.HasExited -and -not $worker.Process.WaitForExit(15000)) { $worker.Process.Kill(); $worker.Process.WaitForExit() }
        try { [void]$worker.OutTask.GetAwaiter().GetResult(); [void]$worker.ErrTask.GetAwaiter().GetResult() } catch { }
        $worker.OutFile.Dispose()
        $worker.ErrFile.Dispose()
    }
    Write-Host "Test-owned processes stopped; evidence retained in $stage"
}
