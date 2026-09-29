param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Seed,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$MySqlHome,
    [string]$BuildDirectory = 'build/bin/RelWithDebInfo', [string]$DataDirectory, [string]$ClassDumpDirectory, [switch]$SkipBot, [switch]$ModuleConfig,
    [switch]$Interactive,
    [switch]$CheckRosterOnly,
    [ValidateRange(0, 600)][int]$IdleSeconds = 125,
    [ValidateRange(0, 600)][int]$PostStopSeconds = 0,
    [ValidateSet(1, 7, 20)][int]$BotLevel = 1,
    [switch]$CheckDuplicateStart, [switch]$CheckAdmissionRejects,
    [switch]$CheckAdmissionMatrix, [switch]$CheckPersistence,
    [switch]$CheckPendingLoad, [switch]$CheckDrainTimeout,
    [switch]$CheckClientCollision, [switch]$CheckFollow, [switch]$CheckCombat, [switch]$CheckTwoBots, [switch]$CheckFullParty, [switch]$ReuseFullPartyFixture, [switch]$PrepareClassFixture, [switch]$MixedParty, [switch]$WaitForStrike, [switch]$WaitForTargetDeath, [switch]$WaitForLeash, [switch]$ObserveFollow, [switch]$PlayAssist, [switch]$CheckDungeonJoin,
    [switch]$EngineWarriorBuff, [switch]$EngineWarriorCombat, [switch]$EngineMageCombat, [switch]$EnginePriestHeal,
    [ValidateSet('account_tutorial','character_aura')][string]$PendingTable = 'account_tutorial')

# PB-00/PB-01/PB-02 proofs against a COPY of a disposable, cleanly stopped database.
# Never use an existing server installation or a live database as the seed.
$ErrorActionPreference = 'Stop'
if ($Interactive -and -not $CheckFullParty) { throw '-Interactive currently requires -CheckFullParty.' }
if ($MixedParty -and -not $CheckFullParty) { throw '-MixedParty requires -CheckFullParty.' }
if ($ClassDumpDirectory -and (-not $MixedParty -or $ReuseFullPartyFixture)) { throw '-ClassDumpDirectory requires -MixedParty without -ReuseFullPartyFixture.' }
if ($CheckRosterOnly -and (-not $CheckFullParty -or $Interactive)) { throw '-CheckRosterOnly requires -CheckFullParty without -Interactive.' }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'test-environment.ps1')
$mysqlHome = Resolve-TestDirectory $MySqlHome $repo 'MySqlHome'
$built = Resolve-TestDirectory $BuildDirectory $repo 'BuildDirectory'
Assert-TestFiles $mysqlHome @('bin/mysql.exe','bin/mysqld.exe','bin/libcrypto-3-x64.dll','bin/libssl-3-x64.dll') 'MySqlHome'
Assert-TestFiles $built @('worldserver.exe') 'BuildDirectory'
if ($DataDirectory) { $gameData = Resolve-TestDirectory $DataDirectory $repo 'DataDirectory' }
$allowPlayerbotSeed = $CheckCombat -or $SkipBot -or $CheckTwoBots -or $CheckFullParty -or $PrepareClassFixture
$seedPath = Resolve-TestSeed $Seed $repo -AllowPlayerbot:$allowPlayerbotSeed
if ($ClassDumpDirectory) {
    $classDumpSource = Resolve-TestDirectory $ClassDumpDirectory $repo 'ClassDumpDirectory'
    $buildRoot = [IO.Path]::GetFullPath((Join-Path $repo 'build'))
    if (-not (Split-Path $classDumpSource -Parent).Equals($buildRoot, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Split-Path $classDumpSource -Leaf).StartsWith('playerbot-smoke-', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'ClassDumpDirectory must be a disposable playerbot-smoke directory directly under this repository build directory.'
    }
    if ((Get-Item -LiteralPath $classDumpSource).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'ClassDumpDirectory must not be a link.' }
    Assert-TestFiles $classDumpSource @('mage-template.dump','priest-template.dump') 'ClassDumpDirectory'
    foreach ($dumpName in @('mage-template.dump','priest-template.dump')) {
        $dump = Get-Item -LiteralPath (Join-Path $classDumpSource $dumpName)
        if ($dump.Attributes -band [IO.FileAttributes]::ReparsePoint -or $dump.Length -eq 0) { throw "Class dump $dumpName must be a nonempty regular file." }
    }
}
if ($CheckClientCollision -or $CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
    Assert-TestFiles $built @('authserver.exe') 'BuildDirectory'
    Assert-TestFiles $seedPath @('authserver.conf') 'Seed'
}
Assert-TestFiles $seedPath @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll','libmysql.dll') 'Seed'
if ($CheckTwoBots -and ($SkipBot -or $CheckCombat -or $CheckFollow -or $CheckClientCollision -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout)) { throw '-CheckTwoBots must run without another lifecycle-check switch.' }
if ($CheckFullParty -and ($SkipBot -or $CheckCombat -or $CheckFollow -or $CheckTwoBots -or $CheckClientCollision -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout)) { throw '-CheckFullParty must run without another lifecycle-check switch.' }
if ($PrepareClassFixture -and ($SkipBot -or $CheckCombat -or $CheckFollow -or $CheckTwoBots -or $CheckFullParty -or $CheckClientCollision -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout -or $ReuseFullPartyFixture)) { throw '-PrepareClassFixture must run without another lifecycle-check switch.' }
if ($ReuseFullPartyFixture -and (-not $CheckFullParty -or -not (Test-Path -LiteralPath (Join-Path $seedPath 'world-prep.stdout.log')))) { throw '-ReuseFullPartyFixture requires -CheckFullParty and a stopped fixture with recorded preparation.' }
if ($CheckDrainTimeout -and ($CheckPendingLoad -or $SkipBot -or $CheckAdmissionRejects -or $PendingTable -ne 'character_aura')) {
    throw 'The drain-timeout check requires only -CheckDrainTimeout -PendingTable character_aura.'
}
if ($CheckClientCollision -and ($SkipBot -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout)) {
    throw 'The client-collision check must run without another lifecycle-check switch.'
}
if ($CheckFollow -and ($SkipBot -or $CheckClientCollision -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout)) {
    throw 'The follow check must run without another lifecycle-check switch.'
}
if ($CheckCombat -and ($SkipBot -or $CheckFollow -or $CheckClientCollision -or $CheckDuplicateStart -or $CheckAdmissionRejects -or $CheckAdmissionMatrix -or $CheckPersistence -or $CheckPendingLoad -or $CheckDrainTimeout)) {
    throw 'The combat check must run without another lifecycle-check switch.'
}
if ($WaitForStrike -and -not $CheckCombat) { throw '-WaitForStrike requires -CheckCombat.' }
if ($WaitForTargetDeath -and -not $CheckCombat) { throw '-WaitForTargetDeath requires -CheckCombat.' }
if ($WaitForLeash -and -not $CheckCombat) { throw '-WaitForLeash requires -CheckCombat.' }
if ($ObserveFollow -and -not $CheckCombat) { throw '-ObserveFollow requires -CheckCombat.' }
if ($PlayAssist -and -not $CheckCombat) { throw '-PlayAssist requires -CheckCombat.' }
if ($CheckDungeonJoin -and (-not $CheckCombat -or $BotLevel -ne 20)) { throw '-CheckDungeonJoin requires -CheckCombat -BotLevel 20.' }
if ($EngineWarriorBuff -and (-not $ModuleConfig -or -not $CheckCombat -or -not $PlayAssist -or $BotLevel -ne 20)) { throw '-EngineWarriorBuff requires -ModuleConfig -CheckCombat -PlayAssist -BotLevel 20.' }
if (($EngineWarriorCombat -or $EngineMageCombat -or $EnginePriestHeal) -and (-not $ModuleConfig -or -not $CheckFullParty -or -not $MixedParty)) {
    throw 'Warrior/Mage/Priest combat engine checks require -ModuleConfig -CheckFullParty -MixedParty.'
}
if ($BotLevel -ne 1 -and (-not $CheckCombat -or (-not $PlayAssist -and -not $CheckDungeonJoin))) { throw '-BotLevel 7 or 20 requires -CheckCombat and a play mode.' }
if ([int]$WaitForStrike.IsPresent + [int]$WaitForTargetDeath.IsPresent + [int]$WaitForLeash.IsPresent + [int]$ObserveFollow.IsPresent + [int]$PlayAssist.IsPresent + [int]$CheckDungeonJoin.IsPresent -gt 1) { throw 'Choose one combat wait mode.' }
$stage = Join-Path $repo ('build/playerbot-smoke-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$mysqlExe = Join-Path $mysqlHome 'bin/mysql.exe'
$mysqlServerExe = Join-Path $mysqlHome 'bin/mysqld.exe'
$workers = [Collections.Generic.List[object]]::new()
$worldWorker = $null
$authWorker = $null
$mysqlWorker = $null
$lockWorker = $null
$dbReady = $false

function Start-Worker([string]$exe, [string[]]$arguments, [string]$label, [hashtable]$environment = @{}) {
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
    foreach ($key in $environment.Keys) { $psi.Environment[$key] = $environment[$key] }
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

function Write-TestWorldConfig([string]$text) {
    if ($ModuleConfig) {
        $moduleDirectory = Join-Path $stage 'modules'
        [void](New-Item -ItemType Directory -Path $moduleDirectory -Force)
        $botLines = [regex]::Matches($text, '(?m)^Playerbots\.Dev\.[^\r\n]*') | ForEach-Object Value
        $text = [regex]::Replace($text, '(?m)^Playerbots\.Dev\.[^\r\n]*\r?\n?', '')
        $text = [regex]::Replace($text, '(?m)^Modules\.ConfigDirectory\s*=.*\r?\n?', '')
        $text += "`r`nModules.ConfigDirectory = modules`r`n"
        [IO.File]::WriteAllText((Join-Path $moduleDirectory 'playerbots.conf'), "[playerbots]`r`n" + ($botLines -join "`r`n") + "`r`n", [Text.UTF8Encoding]::new($false))
    }
    [IO.File]::WriteAllText((Join-Path $stage 'worldserver.conf'), $text, [Text.UTF8Encoding]::new($false))
}

function Wait-For([scriptblock]$condition, [int]$seconds, [string]$description) {
    $deadline = (Get-Date).AddSeconds($seconds)
    do {
        if ($Interactive -and (Test-Path -LiteralPath (Join-Path $stage 'stop.request'))) {
            throw [OperationCanceledException]::new('Interactive stop requested; shutting down test-owned services.')
        }
        if ($null -ne $worldWorker -and $worldWorker.Process.HasExited) { throw "Worldserver exited while waiting for $description." }
        if (& $condition) { return }
        Start-Sleep -Milliseconds 500
    } while ($seconds -eq 0 -or (Get-Date) -lt $deadline)
    throw "Timed out waiting for $description."
}

function Wait-ForHuman([scriptblock]$condition, [int]$seconds, [string]$description) {
    Wait-For $condition $(if ($Interactive) { 0 } else { $seconds }) $description
}

foreach ($port in ($(if ($CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) { @(13306, 8085, 8086, 3724) } else { @(13306, 18085) + $(if ($CheckClientCollision) { 13724 }) }))) {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port)
    try { $listener.Start() } finally { $listener.Stop() }
}
$credentialPath = Join-Path $seedPath 'test-db-credentials.json'
$credential = Read-TestCredentials $seedPath

try {
    New-Item -ItemType Directory -Path $stage | Out-Null
    # Preserve the private evidence directory's access boundary on the clone.
    # The caller may own the new directory while an older seed has a different
    # owner; copying that owner would require a privilege we do not need.
    $stageAcl = Get-Acl -LiteralPath $stage
    $seedAcl = Get-Acl -LiteralPath $seedPath
    $seedAcl.SetOwner($stageAcl.GetOwner([Security.Principal.NTAccount]))
    Set-Acl -LiteralPath $stage -AclObject $seedAcl
    Write-Host "TEST DIRECTORY: $stage"
    Copy-Item -LiteralPath (Join-Path $seedPath 'mysql-data') -Destination (Join-Path $stage 'mysql-data') -Recurse
    Copy-Item -LiteralPath $credentialPath -Destination (Join-Path $stage 'test-db-credentials.json')
    New-Item -ItemType Directory -Path (Join-Path $stage 'logs') | Out-Null
    foreach ($name in @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll','libmysql.dll')) { Copy-Item -LiteralPath (Join-Path $seedPath $name) -Destination $stage }
    # MySQL 8.0.46's libmysql.dll imports OpenSSL 3 even though this
    # worldserver build itself imports OpenSSL 4. Stage both ABI versions.
    foreach ($name in @('libcrypto-3-x64.dll','libssl-3-x64.dll')) { Copy-Item -LiteralPath (Join-Path $mysqlHome "bin/$name") -Destination $stage }
    Copy-Item -LiteralPath (Join-Path $built 'worldserver.exe') -Destination $stage
    if (Test-Path -LiteralPath (Join-Path $built 'worldserver.pdb')) { Copy-Item -LiteralPath (Join-Path $built 'worldserver.pdb') -Destination $stage }
    if ($CheckClientCollision -or $CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
        Copy-Item -LiteralPath (Join-Path $built 'authserver.exe') -Destination $stage
        if (Test-Path -LiteralPath (Join-Path $built 'authserver.pdb')) { Copy-Item -LiteralPath (Join-Path $built 'authserver.pdb') -Destination $stage }
    }
    $config = [IO.File]::ReadAllText((Join-Path $seedPath 'worldserver.conf'))
    if ($DataDirectory) {
        $config = [regex]::Replace($config, '(?m)^DataDir\s*=.*$', [Text.RegularExpressions.MatchEvaluator]{ param($match) 'DataDir = "' + $gameData.Replace('\','/') + '"' })
    }
    $config = [regex]::Replace($config, '(?m)^MySQLExecutable\s*=.*$', [Text.RegularExpressions.MatchEvaluator]{ param($match) 'MySQLExecutable = "' + $mysqlExe.Replace('\','/') + '"' })
    if ($config -notmatch '(?m)^Playerbots\.Dev\.GreetingOnJoin\s*=') {
        $config += "`r`nPlayerbots.Dev.GreetingOnJoin = 1`r`n"
    }
    $logsDir = (Join-Path $stage 'logs').Replace('\','/')
    $config = [regex]::Replace($config, '(?m)^LogsDir\s*=.*$', 'LogsDir = "' + $logsDir + '"')
    if ($CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
        $config = [regex]::Replace($config, '(?m)^WorldServerPort\s*=.*$', 'WorldServerPort = 8085')
    }
    if ($CheckClientCollision -or $CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
        $authConfig = [IO.File]::ReadAllText((Join-Path $seedPath 'authserver.conf'))
        $authConfig = [regex]::Replace($authConfig, '(?m)^LogsDir\s*=.*$', 'LogsDir = "' + $logsDir + '"')
        if ($CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
            $authConfig = [regex]::Replace($authConfig, '(?m)^RealmServerPort\s*=.*$', 'RealmServerPort = 3724')
        }
        [IO.File]::WriteAllText((Join-Path $stage 'authserver.conf'), $authConfig, [Text.UTF8Encoding]::new($false))
    }

    $mysqlWorker = Start-Worker $mysqlServerExe @('--no-defaults',"--basedir=$mysqlHome",("--datadir="+(Join-Path $stage 'mysql-data')),'--bind-address=127.0.0.1','--port=13306','--mysqlx=OFF','--skip-name-resolve','--skip-log-bin','--lower-case-table-names=1','--innodb-buffer-pool-size=512M','--innodb-redo-log-capacity=1G','--innodb-flush-log-at-trx-commit=2','--max-allowed-packet=256M',("--log-error="+(Join-Path $stage 'mysql-error.log'))) 'mysql'
    $deadline = (Get-Date).AddSeconds(90)
    do {
        if ($mysqlWorker.Process.HasExited) { throw 'Cloned MySQL exited before ready.' }
        try { $dbReady = (Invoke-TestSql 'SELECT 1;') -eq '1' } catch { $dbReady = $false }
        if (-not $dbReady) { Start-Sleep -Milliseconds 500 }
    } while (-not $dbReady -and (Get-Date) -lt $deadline)
    if (-not $dbReady) { throw 'Cloned MySQL did not become ready.' }

    if ($CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
        [void](Invoke-TestSql "UPDATE auth.realmlist SET port=8085, address='127.0.0.1', localAddress='127.0.0.1' WHERE id=1;")
    }

    $identity = Invoke-TestSql "SELECT a.id, c.guid, c.class, c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='CATASMOKE' AND c.name='Testone';"
    $fields = $identity -split "`t"
    if ($fields.Count -ne 4 -or $fields[2] -ne '1' -or $fields[3] -ne '0') { throw "Expected one offline Warrior on CATASMOKE; found: $identity" }
    $accountId = [uint32]$fields[0]
    $characterGuid = [uint32]$fields[1]
    Write-Host "Using isolated account $accountId, Warrior GUID $characterGuid."
    if ($BotLevel -ne 1) {
        $baselineLevel = Invoke-TestSql "SELECT level FROM characters.characters WHERE guid=$characterGuid AND online=0;"
        if ($baselineLevel -ne '1') { throw "Level-$BotLevel combat fixture requires an offline level-1 Warrior; found level $baselineLevel." }
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.character_spell WHERE guid=$characterGuid AND spell IN (34428,772,6673);") -ne '0') {
            throw "Level-$BotLevel combat fixture already has a trained Warrior spell."
        }
        $trainedSpells = @(34428, 772)
        if ($BotLevel -eq 20) { $trainedSpells += 6673 }
        $spellRows = ($trainedSpells | ForEach-Object { "($characterGuid,$_,1,0)" }) -join ','
        [void](Invoke-TestSql "UPDATE characters.characters SET level=$BotLevel, xp=0 WHERE guid=$characterGuid AND online=0 AND level=1;")
        [void](Invoke-TestSql "INSERT INTO characters.character_spell (guid, spell, active, disabled) VALUES $spellRows;")
        Write-Host "Cloned fixture only: Testone set to level $BotLevel with trained spell IDs $($trainedSpells -join ', ')."
    }
    if ($CheckDungeonJoin) {
        $human = Invoke-TestSql "SELECT a.id, c.guid, c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='PB01HUMAN' AND c.name='Test';"
        $humanFields = $human -split "`t"
        if ($humanFields.Count -ne 3 -or $humanFields[2] -ne '0') { throw "Dungeon fixture needs offline Test; found: $human" }
        [void](Invoke-TestSql "UPDATE characters.characters SET level=20, xp=0 WHERE guid=$($humanFields[1]) AND online=0;")
        [void](Invoke-TestSql "INSERT INTO auth.account_access (AccountID, SecurityLevel, RealmID) VALUES ($($humanFields[0]), 3, -1) ON DUPLICATE KEY UPDATE SecurityLevel=3;")
        Write-Host 'Cloned fixture only: Test set to level 20 with temporary GM access for the dungeon-entry teleport.'
    }
    if ($CheckTwoBots) {
        $second = Invoke-TestSql "SELECT a.id, c.guid, c.class, c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='PB01HUMAN' AND c.name='Test';"
        $secondFields = $second -split "`t"
        if ($secondFields.Count -ne 4 -or $secondFields[2] -ne '1' -or $secondFields[3] -ne '0' -or $secondFields[0] -eq "$accountId" -or $secondFields[1] -eq "$characterGuid") { throw "Second fixture needs a distinct offline Warrior; found: $second" }
        $secondAccountId = [uint32]$secondFields[0]
        $secondGuid = [uint32]$secondFields[1]
        # The dungeon-entry clone grants this test account GM access. Restore
        # player security only in the disposable copy for bot admission.
        [void](Invoke-TestSql "DELETE FROM auth.account_access WHERE AccountID=$secondAccountId;")
        Write-Host "Cloned fixture only: second Warrior GUID $secondGuid on account $secondAccountId has player security."
    }
    if ($CheckFullParty) {
        $human = Invoke-TestSql "SELECT a.id, c.guid, c.class, c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='PB01HUMAN' AND c.name='Test';"
        $humanFields = $human -split "`t"
        if ($humanFields.Count -ne 4 -or $humanFields[3] -ne '0') { throw "Full-party fixture needs an offline human character named Test; found: $human" }
        $humanGuid = [uint32]$humanFields[1]
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.group_member WHERE memberGuid IN ($characterGuid,$humanGuid);") -ne '0') { throw 'Full-party seed already has party membership; use a pre-party disposable seed.' }
        $botHomebind = Invoke-TestSql "SELECT mapId, posX, posY, posZ FROM characters.character_homebind WHERE guid=$characterGuid;"
        $botHomebindFields = $botHomebind -split "`t"
        if ($botHomebindFields.Count -ne 4 -or $botHomebindFields[0] -ne '530') { throw "Expected a safe Eversong homebind; found: $botHomebind" }
        [void](Invoke-TestSql "UPDATE characters.characters SET map=530, instance_id=0, position_x=$($botHomebindFields[1]), position_y=$($botHomebindFields[2]), position_z=$($botHomebindFields[3]) WHERE guid IN ($characterGuid,$humanGuid) AND online=0;")
        [void](Invoke-TestSql "UPDATE characters.characters SET level=20, xp=0 WHERE guid=$humanGuid AND online=0;")
        [void](Invoke-TestSql "INSERT INTO auth.account_access (AccountID, SecurityLevel, RealmID) VALUES ($($humanFields[0]), 3, -1) ON DUPLICATE KEY UPDATE SecurityLevel=3;")

        $fullPartyBots = @([pscustomobject]@{ Slot=1; Account=$accountId; Guid=$characterGuid; Name='Testone' })
        if (-not $ReuseFullPartyFixture) {
            # Export/import through the core so cloned characters receive fresh
            # GUIDs and related records. Everything stays in $stage.
            $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.(Enabled|AccountId[2-4]?|CharacterGuid[2-4]?)\s*=.*\r?\n?', '')
            $prepConfig = $config + "`r`nPlayerbots.Dev.Enabled = 0`r`n"
            Write-TestWorldConfig $prepConfig
            $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'world-prep'
            $prepLog = Join-Path $stage 'logs/Server.log'
            Wait-For { (Test-Path $prepLog) -and (Select-String -LiteralPath $prepLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'fixture-preparation worldserver'
            Send-WorldCommand 'pdump write bot-template.dump Testone'
            Wait-For { (Test-Path (Join-Path $stage 'bot-template.dump')) -and (Get-Item (Join-Path $stage 'bot-template.dump')).Length -gt 0 } 30 'Warrior character dump'
        }
        $botSpecs = @(@(2,'PB01BOT2','Testtwo',1), @(3,'PB01BOT3','Testthree',1), @(4,'PB01BOT4','Testfour',1))
        if ($MixedParty) {
            $botSpecs = @(@(2,'PB01BOT2','Testtwo',1), @(3,'PB01MAGE','Botmage',8), @(4,'PB01PRIEST','Botpriest',5))
            foreach ($classSource in $(if ($ReuseFullPartyFixture) { @() } else { @(@('Testmage',8,'mage-template.dump'), @('Testpriest',5,'priest-template.dump')) })) {
                $sourceName = $classSource[0]; $sourceClass = $classSource[1]; $dumpName = $classSource[2]
                if ($ClassDumpDirectory) {
                    Copy-Item -LiteralPath (Join-Path $classDumpSource $dumpName) -Destination (Join-Path $stage $dumpName)
                }
                else {
                    if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.characters c JOIN auth.account a ON a.id=c.account WHERE a.username='PB01HUMAN' AND c.name='$sourceName' AND c.class=$sourceClass AND c.online=0;") -ne '1') { throw "Missing saved class fixture $sourceName." }
                    Send-WorldCommand "pdump write $dumpName $sourceName"
                    Wait-For { (Test-Path (Join-Path $stage $dumpName)) -and (Get-Item (Join-Path $stage $dumpName)).Length -gt 0 } 30 "class dump $sourceName"
                }
            }
        }
        foreach ($botSpec in $botSpecs) {
            $slot = [int]$botSpec[0]; $botAccountName = [string]$botSpec[1]; $botName = [string]$botSpec[2]
            $expectedClass = [int]$botSpec[3]
            $reuseSecond = $MixedParty -and $slot -eq 2 -and
                (Invoke-TestSql "SELECT COUNT(*) FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='PB01BOT2' AND c.name='Testtwo' AND c.class=1 AND c.online=0;") -eq '1'
            if (-not $ReuseFullPartyFixture -and -not $reuseSecond) {
                if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='$botAccountName';") -ne '0') { throw "Disposable bot account $botAccountName already exists." }
                Send-WorldCommand "account create $botAccountName PB01local!"
                Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='$botAccountName';") -eq '1' } 30 "bot account $slot creation"
                $dumpName = if ($MixedParty -and $slot -eq 3) { 'mage-template.dump' } elseif ($MixedParty -and $slot -eq 4) { 'priest-template.dump' } else { 'bot-template.dump' }
                Send-WorldCommand "pdump load $dumpName $botAccountName $botName"
                Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM characters.characters WHERE name='$botName';") -eq '1' } 60 "bot character $slot import"
            }
            $row = Invoke-TestSql "SELECT a.id,c.guid,c.class,c.online FROM auth.account a JOIN characters.characters c ON c.account=a.id WHERE a.username='$botAccountName' AND c.name='$botName';"
            $fields = $row -split "`t"
            if ($fields.Count -ne 4 -or $fields[2] -ne "$expectedClass" -or $fields[3] -ne '0') { throw "Bot $slot does not match offline class $expectedClass`: $row" }
            $fullPartyBots += [pscustomobject]@{ Slot=$slot; Account=[uint32]$fields[0]; Guid=[uint32]$fields[1]; Name=$botName }
        }
        if (-not $ReuseFullPartyFixture) {
            if ($MixedParty) {
                # Prior death tests may leave the human and Warrior fixtures
                # dead. Use the core's offline resurrection path, not SQL
                # health/corpse edits, before admitting any bot sessions.
                Send-WorldCommand 'revive Test'
                foreach ($bot in $fullPartyBots) { Send-WorldCommand "revive $($bot.Name)" }
            }
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000) -or $worldWorker.Process.ExitCode -ne 0) { throw 'Fixture-preparation worldserver did not stop cleanly.' }
            Move-Item -LiteralPath $prepLog -Destination (Join-Path $stage 'logs/Server-prep.log')
            if ($MixedParty) {
                foreach ($bot in $fullPartyBots | Where-Object Slot -ge 3) {
                    $botGuid = $bot.Guid
                    $spells = if ($bot.Slot -eq 3) { @(133,116,2136,122) } else { @(17,2061,2050,139,21562) }
                    $spellRows = ($spells | ForEach-Object { "($botGuid,$_,1,0)" }) -join ','
                    [void](Invoke-TestSql "UPDATE characters.characters SET level=20,xp=0 WHERE guid=$botGuid AND online=0; INSERT INTO characters.character_spell (guid,spell,active,disabled) VALUES $spellRows ON DUPLICATE KEY UPDATE active=1,disabled=0; UPDATE auth.account SET expansion=3 WHERE id=$($bot.Account);")
                }
                Write-Host 'Disposable copy only: two Warriors, level-20 Mage and Priest prepared. Original class characters unchanged.'
            }
            else { Write-Host 'Cloned fixture only: three fresh bot accounts and Warrior imports prepared.' }
        }
        else { Write-Host 'Cloned fixture only: reusing the verified offline bot roster.' }
        # Normalize every offline member, including the reused Testtwo. A saved
        # dungeon map must not carry into the outdoor invitation fixture.
        $rosterGuids = ($fullPartyBots.Guid -join ',')
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.group_member WHERE memberGuid IN ($rosterGuids);") -ne '0') {
            throw 'Full-party bot roster has existing group membership; use a pre-party disposable seed.'
        }
        [void](Invoke-TestSql "UPDATE characters.characters SET map=530, instance_id=0, position_x=$($botHomebindFields[1]), position_y=$($botHomebindFields[2]), position_z=$($botHomebindFields[3]) WHERE guid IN ($rosterGuids) AND online=0;")
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.characters WHERE guid IN ($rosterGuids) AND online=0 AND map=530 AND instance_id=0;") -ne '4') {
            throw 'Full-party fixture did not normalize all four offline bots.'
        }
    }
    if ($CheckAdmissionRejects) {
        $badGuid = [uint32]999999999
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.characters WHERE guid=$badGuid;") -ne '0') { throw 'Negative-test GUID already exists.' }
        foreach ($case in @(
            @{ Label='world-disabled'; Enabled=0; Guid=$characterGuid; Description='feature-off admission' },
            @{ Label='world-badguid'; Enabled=1; Guid=$badGuid; Description='unknown-character admission' }
        )) {
            $caseConfig = $config + "`r`nPlayerbots.Dev.Enabled = $($case.Enabled)`r`nPlayerbots.Dev.AccountId = $accountId`r`nPlayerbots.Dev.CharacterGuid = $($case.Guid)`r`n"
            Write-TestWorldConfig $caseConfig
            $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') $case.Label
            $caseOutput = Join-Path $stage "$($case.Label).stdout.log"
            $serverLog = Join-Path $stage 'logs/Server.log'
            Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 "$($case.Description) worldserver readiness"
            Send-WorldCommand 'server playerbotdev start'
            Wait-For { (Select-String -LiteralPath $caseOutput -Pattern 'PB-00 start rejected' -Quiet) } 15 "$($case.Description) rejection"
            if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw "$($case.Description) unexpectedly changed the Warrior online state." }
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw "$($case.Description) worldserver did not shut down within 60 seconds." }
            if ($worldWorker.Process.ExitCode -ne 0) { throw "$($case.Description) worldserver exited with $($worldWorker.Process.ExitCode)." }
            Move-Item -LiteralPath $serverLog -Destination (Join-Path $stage "logs/Server-$($case.Label).log")
            Write-Host "$($case.Description) rejected; Warrior remained offline; shutdown clean."
        }
    }
    # A prior disposable stage can already contain generated settings.
    $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.(Enabled|AccountId[2-4]?|CharacterGuid[2-4]?)\s*=.*\r?\n?', '')
    $config += "`r`nPlayerbots.Dev.Enabled = $([int](-not $PrepareClassFixture))`r`nPlayerbots.Dev.AccountId = $accountId`r`nPlayerbots.Dev.CharacterGuid = $characterGuid`r`n"
    if ($EngineWarriorBuff) {
        $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.EngineWarriorBuff\s*=.*\r?\n?', '')
        $config += "Playerbots.Dev.EngineWarriorBuff = 1`r`n"
    }
    if ($EngineWarriorCombat) {
        $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.EngineWarriorCombat\s*=.*\r?\n?', '')
        $config += "Playerbots.Dev.EngineWarriorCombat = 1`r`n"
    }
    if ($EngineMageCombat) {
        $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.EngineMageCombat\s*=.*\r?\n?', '')
        $config += "Playerbots.Dev.EngineMageCombat = 1`r`n"
    }
    if ($EnginePriestHeal) {
        $config = [regex]::Replace($config, '(?m)^Playerbots\.Dev\.EnginePriestHeal\s*=.*\r?\n?', '')
        $config += "Playerbots.Dev.EnginePriestHeal = 1`r`n"
    }
    if ($CheckTwoBots) { $config += "Playerbots.Dev.AccountId2 = $secondAccountId`r`nPlayerbots.Dev.CharacterGuid2 = $secondGuid`r`n" }
    if ($CheckFullParty) {
        foreach ($bot in $fullPartyBots | Where-Object Slot -gt 1) {
            $config += "Playerbots.Dev.AccountId$($bot.Slot) = $($bot.Account)`r`nPlayerbots.Dev.CharacterGuid$($bot.Slot) = $($bot.Guid)`r`n"
        }
    }
    Write-TestWorldConfig $config

    $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'world'
    $serverLog = Join-Path $stage 'logs/Server.log'
    Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'worldserver readiness'
    if ($CheckClientCollision -or $CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) {
        $authWorker = Start-Worker (Join-Path $stage 'authserver.exe') @('-c','authserver.conf') 'auth'
        Start-Sleep -Seconds 2
        if ($authWorker.Process.HasExited) { throw 'Authserver exited before the client-collision check.' }
        $authSocket = [Net.Sockets.TcpClient]::new()
        try { $authSocket.Connect('127.0.0.1', $(if ($CheckFollow -or $CheckCombat -or $CheckFullParty -or $PrepareClassFixture) { 3724 } else { 13724 })) } finally { $authSocket.Dispose() }
    }
    if ($PrepareClassFixture) {
        if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='PB01HUMAN';") -ne '1') { throw 'Class preparation requires the disposable PB01HUMAN account.' }
        Write-Host 'CLASS FIXTURE READY: log into the isolated Cata realm as PB01HUMAN / PB01local!.'
        Write-Host 'Create a Blood Elf Mage named Testmage and a Blood Elf Priest named Testpriest, then log out of both. Do not use a live realm.'
        Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM characters.characters c JOIN auth.account a ON a.id=c.account WHERE a.username='PB01HUMAN' AND c.name='Testmage' AND c.class=8 AND c.online=0;") -eq '1' } 600 'saved offline Mage Testmage'
        Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM characters.characters c JOIN auth.account a ON a.id=c.account WHERE a.username='PB01HUMAN' AND c.name='Testpriest' AND c.class=5 AND c.online=0;") -eq '1' } 600 'saved offline Priest Testpriest'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000) -or $worldWorker.Process.ExitCode -ne 0) { throw 'Class-fixture worldserver did not shut down cleanly.' }
        Write-Host "MAGE AND PRIEST SAVED: disposable class fixture is $stage"
        return
    }
    if ($CheckCombat) {
        $humanAccount = 'PB01HUMAN'
        $humanPassword = 'PB01local!'
        if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='$humanAccount';") -ne '1') { throw 'Combat seed needs the disposable human account from the successful follow check.' }
        $existingHuman = Invoke-TestSql "SELECT c.guid, c.online FROM characters.characters c JOIN auth.account a ON a.id=c.account WHERE a.username='$humanAccount' AND c.name='Test' LIMIT 1;"
        $humanFields = $existingHuman -split "`t"
        if ($humanFields.Count -ne 2 -or $humanFields[1] -ne '0') { throw "Combat seed needs the offline human character Test; found: $existingHuman" }
        $humanGuid = [uint32]$humanFields[0]
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'bot in world'
        Write-Host "COMBAT READY: log into the existing character Test as $humanAccount / $humanPassword."
        Wait-For { (Invoke-TestSql "SELECT online, map FROM characters.characters WHERE guid=$humanGuid;") -eq "1$([char]9)530" } 600 'human character in world on map 530'
        Send-WorldCommand "server playerbotdev follow $humanGuid"
        Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-01: Testone following Test' -Quiet) } 20 'follow accepted before combat'
        if ($ObserveFollow) {
            Write-Host 'FOLLOW TRACE ACTIVE: walk the route near the pillar and stairs, then log out of Test within three minutes. No attack will be requested.'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 180 'human logout after follow trace'
            Send-WorldCommand 'server playerbotdev stop'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'bot logout'
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Follow-trace worldserver did not shut down within 60 seconds.' }
            if ($worldWorker.Process.ExitCode -ne 0) { throw "Follow-trace worldserver exited with $($worldWorker.Process.ExitCode)." }
            Write-Host 'PB-01 follow trace captured; inspect sampled positions before drawing a pathing conclusion.'
            return
        }
        if ($CheckDungeonJoin) {
            Write-Host 'DUNGEON JOIN: invite Testone to your party. Use .tele RagefireChasm, then walk through the dungeon portal normally.'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-PARTY: Testone joined' -Quiet) } 120 'bot joined the human party'
            Wait-For { (Invoke-TestSql 'SELECT COUNT(*) FROM characters.group_instance gi JOIN characters.instance i ON i.id=gi.instance WHERE i.map=389;') -ne '0' } 240 'party bound to Ragefire Chasm'
            Start-Sleep -Seconds 3
            Send-WorldCommand 'server playerbotdev joininstance 389'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-PARTY: Testone entered dungeon map 389 instance' -Quiet) } 60 'bot dungeon transfer'
            Write-Host 'DUNGEON COMBAT: confirm Testone follows inside Ragefire Chasm, then make two or three ordinary pulls. Let Testone engage at least once before you log out.'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone auto-assisting' -Quiet) } 180 'bot auto-assist inside Ragefire Chasm'
            Write-Host 'DUNGEON AUTO-ASSIST RECORDED: finish observing the fight, then log out of Test.'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 180 'human logout after dungeon join'
            Send-WorldCommand 'server playerbotdev stop'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'bot logout'
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Dungeon-join worldserver did not shut down within 60 seconds.' }
            if ($worldWorker.Process.ExitCode -ne 0) { throw "Dungeon-join worldserver exited with $($worldWorker.Process.ExitCode)." }
            Write-Host 'PB-PARTY dungeon transfer, auto-assist, and clean shutdown passed; visual behavior still requires player confirmation.'
            return
        }
        if ($PlayAssist) {
            Write-Host 'AUTO-ASSIST PLAY: select and fight nearby hostile creatures. Testone should join only after you enter combat. Log out of Test when finished (within five minutes).'
            if ($BotLevel -eq 20) { Write-Host 'LEVEL-20 CHECK: fight at least one creature; the run requires a Battle Shout cast-start log. Confirm the buff in the client separately.' }
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 300 'human logout after auto-assist play'
            $assisted = Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone auto-assisting' -Quiet
            $battleShoutStarted = $BotLevel -eq 20 -and (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone began Battle Shout on Testone' -Quiet)
            $engineRouted = $EngineWarriorBuff -and (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-ENGINE: Testone Warrior buff routed through engine' -Quiet)
            Send-WorldCommand 'server playerbotdev stop'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'bot logout'
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Auto-assist worldserver did not shut down within 60 seconds.' }
            if ($worldWorker.Process.ExitCode -ne 0) { throw "Auto-assist worldserver exited with $($worldWorker.Process.ExitCode)." }
            if (-not $assisted) { throw 'No accepted auto-assist engagement was recorded during the play session.' }
            if ($BotLevel -eq 20 -and -not $battleShoutStarted) { throw 'No accepted Battle Shout cast was recorded during the level-20 play session.' }
            if ($EngineWarriorBuff -and -not $engineRouted) { throw 'No Warrior engine-buff routing was recorded during the play session.' }
            Write-Host 'PB-02 auto-assist engagement and clean shutdown passed; visual behavior still requires player confirmation.'
            return
        }
        if ($WaitForLeash) {
            Write-Host 'Select a nearby hostile creature that can survive several seconds. Attack will be requested in 20 seconds; run away from Testone as soon as it starts.'
        }
        else {
            Write-Host 'Select a nearby hostile creature and leave it selected. PB-02 attack will be requested in 20 seconds.'
        }
        Start-Sleep -Seconds 20
        Send-WorldCommand 'server playerbotdev attack'
        Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone attacking' -Quiet) } 20 'attack accepted'
        if ($WaitForLeash) {
            Write-Host 'ATTACK ACTIVE: move more than 35 yards from Testone now; waiting up to 60 seconds for automatic leash disengage.'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone exceeded combat leash; returning to follow' -Quiet) } 60 'automatic combat-leash cease'
            Write-Host 'LEASH HANDLED: combat stopped. Log out of Test to finish.'
        }
        elseif ($WaitForTargetDeath) {
            Write-Host 'ATTACK ACTIVE: let the bot finish this creature; waiting up to 90 seconds for target-death return-to-follow.'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone target died; returning to follow' -Quiet) } 90 'automatic target-death cease'
            Write-Host 'TARGET DEATH HANDLED: the bot returned to follow. Log out of Test to finish.'
        }
        elseif ($WaitForStrike) {
            Write-Host 'ATTACK ACTIVE: waiting up to 60 seconds for a legal Strike cast. Keep a nearby hostile creature selected and the bot engaged.'
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone began Strike on' -Quiet) } 60 'legal Warrior Strike cast'
            Write-Host 'STRIKE ACCEPTED: the core accepted the bot spell cast.'
        }
        else {
            Write-Host 'ATTACK ACTIVE: watch for the Warrior to chase and swing. Cease-fire will be requested in 5 seconds.'
            Start-Sleep -Seconds 5
        }
        if (-not ($WaitForTargetDeath -or $WaitForLeash)) {
            Send-WorldCommand 'server playerbotdev cease'
            Send-WorldCommand 'server playerbotdev status'
            Write-Host 'CEASE REQUESTED: confirm the Warrior stops attacking and returns to follow. Then log out of Test.'
        }
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 180 'human logout'
        Send-WorldCommand 'server playerbotdev stop'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'bot logout'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Combat-check worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Combat-check worldserver exited with $($worldWorker.Process.ExitCode)." }
        if ($WaitForLeash) {
            Write-Host 'PB-02 combat-leash/automatic-cease lifecycle passed; visual follow still requires player confirmation.'
        }
        elseif ($WaitForTargetDeath) {
            Write-Host 'PB-02 target-death/automatic-cease lifecycle passed; visual follow still requires player confirmation.'
        }
        else {
            Write-Host 'PB-02 attack/cease lifecycle passed; visual combat still requires player confirmation.'
        }
        return
    }
    if ($CheckFollow) {
        $humanAccount = 'PB01HUMAN'
        $humanPassword = 'PB01local!'
        if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='$humanAccount';") -ne '0') { throw 'Disposable human account already exists in seed.' }
        Send-WorldCommand "account create $humanAccount $humanPassword"
        Wait-For { (Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='$humanAccount';") -eq '1' } 20 'disposable human account creation'
        [void](Invoke-TestSql "UPDATE auth.account SET expansion=3 WHERE username='$humanAccount';")
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'bot in world'
        Write-Host "FOLLOW READY: log into the Cata client as $humanAccount / $humanPassword, create a Blood Elf character, and enter the world."
        $script:humanGuid = 0
        Wait-For {
            $human = Invoke-TestSql "SELECT c.guid FROM characters.characters c JOIN auth.account a ON a.id=c.account WHERE a.username='$humanAccount' AND c.online=1 AND c.map=530 LIMIT 1;"
            if ($human) { $script:humanGuid = [uint32]$human; return $true }
            return $false
        } 600 'human Blood Elf in world on map 530'
        Send-WorldCommand "server playerbotdev follow $humanGuid"
        Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch "PB-01: Testone following" -Quiet) } 20 'follow accepted'
        Write-Host 'FOLLOW ACTIVE: move the human character on clear terrain for about 30 seconds; watch whether Testone follows.'
        Start-Sleep -Seconds 30
        Send-WorldCommand 'server playerbotdev hold'
        Send-WorldCommand 'server playerbotdev status'
        Write-Host 'HOLD ACTIVE: confirm Testone stops. After a moment, follow will resume; then log out of the human character.'
        Start-Sleep -Seconds 10
        Send-WorldCommand "server playerbotdev follow $humanGuid"
        Wait-For { @(Select-String -LiteralPath $serverLog -SimpleMatch 'PB-01: Testone following').Count -ge 2 } 20 'follow resumed'
        Write-Host 'FOLLOW RESUMED: log out of the human character now.'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 180 'human logout'
        Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-01: follow target left bot map; holding' -Quiet) } 20 'automatic hold on logout'
        Send-WorldCommand 'server playerbotdev status'
        Send-WorldCommand 'server playerbotdev stop'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'bot logout'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Follow-check worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Follow-check worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'PB-01 follow/hold/logout lifecycle passed; visual movement still requires player confirmation.'
        return
    }
    if ($CheckAdmissionMatrix) {
        $worldOutput = Join-Path $stage 'world.stdout.log'
        $baseline = ((Invoke-TestSql "SELECT account, class, online FROM characters.characters WHERE guid=$characterGuid;") -split [char]9) -join ','
        if ($baseline -ne "$accountId,1,0") { throw "Admission fixture changed: $baseline" }
        $banDate = [uint32]2147483647
        if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account_banned WHERE id=$accountId AND bandate=$banDate;") -ne '0') { throw 'Admission fixture already has the test ban row.' }
        if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account_banned WHERE id=$accountId AND active=1;") -ne '0') { throw 'Admission fixture account is already banned.' }
        $wrongAccountId = [uint32]($accountId + 1000000)
        foreach ($case in @('wrong-account','wrong-class','banned-account','already-online')) {
            try {
                switch ($case) {
                    'wrong-account' { [void](Invoke-TestSql "UPDATE characters.characters SET account=$wrongAccountId WHERE guid=$characterGuid;") }
                    'wrong-class' { [void](Invoke-TestSql "UPDATE characters.characters SET class=2 WHERE guid=$characterGuid;") }
                    'banned-account' { [void](Invoke-TestSql "INSERT INTO auth.account_banned (id, bandate, unbandate, bannedby, banreason, active) VALUES ($accountId, $banDate, 0, 'PB-00 isolated test', 'Admission rejection proof', 1);") }
                    'already-online' { [void](Invoke-TestSql "UPDATE characters.characters SET online=1 WHERE guid=$characterGuid;") }
                }
                $expected = switch ($case) {
                    'wrong-account' { "$wrongAccountId,1,0" }
                    'wrong-class' { "$accountId,2,0" }
                    'banned-account' { "$accountId,1,0" }
                    'already-online' { "$accountId,1,1" }
                }
                $observed = ((Invoke-TestSql "SELECT account, class, online FROM characters.characters WHERE guid=$characterGuid;") -split [char]9) -join ','
                if ($observed -ne $expected) { throw "$case fixture mutation did not take effect: $observed" }
                if ($case -eq 'banned-account' -and (Invoke-TestSql "SELECT COUNT(*) FROM auth.account_banned WHERE id=$accountId AND active=1;") -ne '1') { throw 'Test account ban did not take effect.' }
                $rejectBefore = @(Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 start rejected').Count
                $admitBefore = @(Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 session admitted').Count
                $statusBefore = @(Select-String -LiteralPath $worldOutput -SimpleMatch 'No PB-00 session is active.').Count
                Send-WorldCommand 'server playerbotdev start'
                Wait-For { @(Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 start rejected').Count -gt $rejectBefore } 15 "$case rejection"
                Send-WorldCommand 'server playerbotdev status'
                Wait-For { @(Select-String -LiteralPath $worldOutput -SimpleMatch 'No PB-00 session is active.').Count -gt $statusBefore } 15 "$case empty session status"
                if (@(Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 session admitted').Count -ne $admitBefore) { throw "$case unexpectedly admitted a session." }
                $observed = ((Invoke-TestSql "SELECT account, class, online FROM characters.characters WHERE guid=$characterGuid;") -split [char]9) -join ','
                if ($observed -ne $expected) { throw "$case changed the character fixture after rejection." }
                Write-Host "$case rejected; no PB-00 session admitted."
            } finally {
                switch ($case) {
                    'wrong-account' { [void](Invoke-TestSql "UPDATE characters.characters SET account=$accountId WHERE guid=$characterGuid;") }
                    'wrong-class' { [void](Invoke-TestSql "UPDATE characters.characters SET class=1 WHERE guid=$characterGuid;") }
                    'banned-account' { [void](Invoke-TestSql "DELETE FROM auth.account_banned WHERE id=$accountId AND bandate=$banDate AND bannedby='PB-00 isolated test';") }
                    'already-online' { [void](Invoke-TestSql "UPDATE characters.characters SET online=0 WHERE guid=$characterGuid;") }
                }
            }
            $observed = ((Invoke-TestSql "SELECT account, class, online FROM characters.characters WHERE guid=$characterGuid;") -split [char]9) -join ','
            if ($observed -ne $baseline) { throw "$case fixture did not restore to baseline." }
            if ($case -eq 'banned-account' -and (Invoke-TestSql "SELECT COUNT(*) FROM auth.account_banned WHERE id=$accountId AND active=1;") -ne '0') { throw 'Test ban did not restore to baseline.' }
        }
        Write-Host 'Four admission rejections passed; proceeding with the valid Warrior lifecycle control.'
    }
    if ($CheckPersistence) {
        $levelBefore = Invoke-TestSql "SELECT level FROM characters.characters WHERE guid=$characterGuid;"
        if ($levelBefore -ne '1') { throw "Expected disposable level-1 Warrior; found level $levelBefore." }
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'Warrior online before level change'
        Wait-For { (Select-String -LiteralPath $serverLog -Pattern 'Login Character:\[Testone\].*Level: 1' -Quiet) } 15 'initial level-1 login'
        Send-WorldCommand 'character level Testone 2'
        Send-WorldCommand 'server playerbotdev stop'
        Wait-For { (Invoke-TestSql "SELECT online, level FROM characters.characters WHERE guid=$characterGuid;") -eq "0$([char]9)2" } 60 'saved level-2 logout'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'First persistence worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "First persistence worldserver exited with $($worldWorker.Process.ExitCode)." }
        Move-Item -LiteralPath $serverLog -Destination (Join-Path $stage 'logs/Server-before-restart.log')
        Write-Host 'Warrior level 2 saved and first worldserver exited normally; restarting from the same cloned database.'
        $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'world-restart'
        Wait-For { (Test-Path $serverLog) -and (Select-String -LiteralPath $serverLog -Pattern 'worldserver.*ready\.\.\.' -Quiet) } 240 'restarted worldserver readiness'
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online, level FROM characters.characters WHERE guid=$characterGuid;") -eq "1$([char]9)2" } 90 'reloaded level-2 Warrior online'
        Wait-For { (Select-String -LiteralPath $serverLog -Pattern 'Login Character:\[Testone\].*Level: 2' -Quiet) } 15 'reloaded level-2 login'
        Send-WorldCommand 'server playerbotdev stop'
        Wait-For { (Invoke-TestSql "SELECT online, level FROM characters.characters WHERE guid=$characterGuid;") -eq "0$([char]9)2" } 60 'reloaded Warrior saved logout'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Restarted persistence worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Restarted persistence worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'Persistence replay passed: level 1 to 2 saved on logout, survived worldserver restart, and reloaded at level 2.'
        return
    }
    if ($CheckClientCollision) {
        $reservationMessage = 'reserved for the enabled PB-00 lifecycle session'
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'Warrior online before client collision'
        Send-WorldCommand 'server playerbotdev status'
        Write-Host 'CLIENT COLLISION READY: launch the 4.3.4.15595 client, select Cata isolated test, and attempt CATASMOKE login using the disposable test password.'
        Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch $reservationMessage -Quiet) } 600 'authenticated client rejection on the reserved PB-00 account'
        if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '1') { throw 'The client collision disturbed the active Warrior.' }
        Send-WorldCommand 'server playerbotdev status'
        $worldOutput = Join-Path $stage 'world.stdout.log'
        Wait-For { (Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 session: character in world.' -Quiet) } 15 'bot still in world after client rejection'
        Write-Host 'Reserved-account client rejection observed; the original PB-00 Warrior remained online.'
        Send-WorldCommand 'server playerbotdev stop'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'Warrior offline after collision check'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Client-collision worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Client-collision worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'Client-collision lifecycle passed: rejection, bot preservation, saved logout, and clean worldserver shutdown.'
        return
    }
    if ($CheckPendingLoad -or $CheckDrainTimeout) {
        $lockArgs = @('--no-defaults','--protocol=TCP','--host=127.0.0.1','--port=13306','--user=cata_smoke',
            '--database=characters','--batch','--skip-column-names','--unbuffered','--connect-timeout=3')
        $lockWorker = Start-Worker $mysqlExe $lockArgs 'mysql-lock' @{ MYSQL_PWD=$credential.password }
        $lockOutput = Join-Path $stage 'mysql-lock.stdout.log'
        $worldOutput = Join-Path $stage 'world.stdout.log'
        if ($CheckDrainTimeout) {
            $marker = 'PB_LOCKED_TIMEOUT'
            $lockWorker.Process.StandardInput.WriteLine("LOCK TABLES character_aura WRITE; SELECT '$marker';")
            $lockWorker.Process.StandardInput.Flush()
            Wait-For { (Test-Path $lockOutput) -and (Select-String -LiteralPath $lockOutput -SimpleMatch $marker -Quiet) } 15 'timeout phase character-query lock'
            Send-WorldCommand 'server playerbotdev start'
            Wait-For { Send-WorldCommand 'server playerbotdev status'; Start-Sleep -Milliseconds 250; (Select-String -LiteralPath $worldOutput -SimpleMatch 'PB-00 session: character loading (login query pending).' -Quiet) } 15 'pending character query before shutdown'
            if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw 'Warrior became online while the character query was held.' }
            Send-WorldCommand 'server shutdown 0'
            $timeoutMessage = 'PB-00 session did not drain within 30 seconds'
            $deadline = (Get-Date).AddSeconds(45)
            do {
                if (Select-String -LiteralPath $serverLog -SimpleMatch $timeoutMessage -Quiet) { break }
                if ($worldWorker.Process.HasExited) { throw 'Worldserver exited without logging the PB-00 drain timeout.' }
                Start-Sleep -Milliseconds 500
            } while ((Get-Date) -lt $deadline)
            if (-not (Select-String -LiteralPath $serverLog -SimpleMatch $timeoutMessage -Quiet)) { throw 'PB-00 drain timeout was not logged within 45 seconds.' }
            Write-Host 'PB-00 30-second drain timeout logged while the character query remained locked.'
            Start-Sleep -Seconds 3
            $exitedBeforeUnlock = $worldWorker.Process.HasExited
            $lockWorker.Process.StandardInput.WriteLine('UNLOCK TABLES;')
            $lockWorker.Process.StandardInput.Flush()
            if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Worldserver did not finish within 60 seconds after unlocking the held query.' }
            if ($worldWorker.Process.ExitCode -ne 0) { throw "Drain-timeout worldserver exited with $($worldWorker.Process.ExitCode)." }
            if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw 'Drain-timeout shutdown left the Warrior online.' }
            Write-Host "Drain-timeout shutdown passed: exit code 0, Warrior offline, exited before unlock: $exitedBeforeUnlock."
            return
        }
        foreach ($phase in @('stop','shutdown')) {
            $marker = "PB_LOCKED_$phase"
            $lockWorker.Process.StandardInput.WriteLine("LOCK TABLES $PendingTable WRITE; SELECT '$marker';")
            $lockWorker.Process.StandardInput.Flush()
            Wait-For { (Test-Path $lockOutput) -and (Select-String -LiteralPath $lockOutput -SimpleMatch $marker -Quiet) } 15 "$phase phase tutorial-table lock"
            $loadingPattern = if ($PendingTable -eq 'account_tutorial') { 'PB-00 session: account loading' } else { 'PB-00 session: character loading (login query pending)' }
            $loadingBefore = @(Select-String -LiteralPath $worldOutput -SimpleMatch $loadingPattern).Count
            Send-WorldCommand 'server playerbotdev start'
            Wait-For { Send-WorldCommand 'server playerbotdev status'; Start-Sleep -Milliseconds 250; @(Select-String -LiteralPath $worldOutput -SimpleMatch $loadingPattern).Count -gt $loadingBefore } 15 "$phase phase pending $PendingTable load"
            if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw "$phase phase Warrior became online while the account query was held." }
            if ($phase -eq 'stop') {
                Send-WorldCommand 'server playerbotdev stop'
                Start-Sleep -Seconds 2
                if ($worldWorker.Process.HasExited) { throw 'Worldserver exited during pending-load stop.' }
                $lockWorker.Process.StandardInput.WriteLine('UNLOCK TABLES;')
                $lockWorker.Process.StandardInput.Flush()
                Wait-For { Send-WorldCommand 'server playerbotdev status'; Start-Sleep -Milliseconds 250; (Select-String -LiteralPath $worldOutput -SimpleMatch 'No PB-00 session is active.' -Quiet) } 15 'pending-load stop session removal'
                if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw 'Pending-load stop changed the Warrior online state.' }
                Write-Host "Pending $PendingTable stop passed: session removed, Warrior offline, worldserver alive."
            } else {
                Send-WorldCommand 'server shutdown 0'
                Start-Sleep -Seconds 2
                if ($worldWorker.Process.HasExited) { throw 'Worldserver exited before the held account query was released.' }
                $lockWorker.Process.StandardInput.WriteLine('UNLOCK TABLES;')
                $lockWorker.Process.StandardInput.Flush()
                if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Pending-load shutdown did not finish within 60 seconds.' }
                if ($worldWorker.Process.ExitCode -ne 0) { throw "Pending-load shutdown exited with $($worldWorker.Process.ExitCode)." }
                if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '0') { throw 'Pending-load shutdown changed the Warrior online state.' }
                Write-Host "Pending $PendingTable shutdown passed: Warrior offline, worldserver exit code 0."
            }
        }
        return
    }
    if ($SkipBot) {
        Write-Host 'No-bot control: testing normal shutdown without admitting a PB-00 session.'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Control worldserver did not shut down within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Control worldserver exited with $($worldWorker.Process.ExitCode)." }
        Write-Host 'No-bot control shutdown passed.'
        return
    }
    if ($CheckFullParty) {
        foreach ($bot in $fullPartyBots) {
            Send-WorldCommand "server playerbotdev slot $($bot.Slot) start"
            $botGuid = $bot.Guid
            Wait-For { (Invoke-TestSql "SELECT online, map FROM characters.characters WHERE guid=$botGuid;") -eq "1$([char]9)530" } 90 "bot slot $($bot.Slot) online on outdoor map"
            $worldOutput = Join-Path $stage 'world.stdout.log'
            $slotPattern = "Playerbot slot $($bot.Slot): ready; character in world;"
            Wait-For {
                $before = @(Select-String -LiteralPath $worldOutput -SimpleMatch $slotPattern).Count
                Send-WorldCommand "server playerbotdev slot $($bot.Slot) status"
                Start-Sleep -Milliseconds 250
                @(Select-String -LiteralPath $worldOutput -SimpleMatch $slotPattern).Count -gt $before
            } 30 "bot slot $($bot.Slot) session ready"
        }
        if ($CheckRosterOnly) {
            foreach ($bot in $fullPartyBots) { Send-WorldCommand "server playerbotdev slot $($bot.Slot) stop" }
            foreach ($bot in $fullPartyBots) {
                $botGuid = $bot.Guid
                Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$botGuid;") -eq '0' } 60 "bot slot $($bot.Slot) logout"
            }
            Send-WorldCommand 'server shutdown 0'
            if (-not $worldWorker.Process.WaitForExit(60 * 1000) -or $worldWorker.Process.ExitCode -ne 0) {
                throw 'Roster-only worldserver did not shut down cleanly.'
            }
            Write-Host 'Four-bot roster readiness, outdoor fixture normalization, save/logout and shutdown passed. No client gameplay was tested.'
            return
        }
        Write-Host 'FULL PARTY READY: log into Test on the disposable Test realm using its fixture account credentials.'
        if ($Interactive) { Write-Host "INTERACTIVE: human steps have no deadline. Log out when finished; to stop at any step create $stage/stop.request." }
        Wait-ForHuman { (Invoke-TestSql "SELECT online, map FROM characters.characters WHERE guid=$humanGuid;") -eq "1$([char]9)530" } 600 'human Test on outdoor map 530'
        if (-not $MixedParty) {
            foreach ($bot in $fullPartyBots) {
                Send-WorldCommand "server playerbotdev slot $($bot.Slot) follow $humanGuid"
                $followLine = "PB-01: $($bot.Name) following Test"
                Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch $followLine -Quiet) } 20 "bot slot $($bot.Slot) following Test"
            }
        }
        Write-Host "Invite $($fullPartyBots.Name -join ', ') to your party. Then use .tele RagefireChasm and walk through the portal."
        foreach ($bot in $fullPartyBots) {
            $joinLine = "PB-PARTY: $($bot.Name) joined followed leader"
            Wait-ForHuman { (Select-String -LiteralPath $serverLog -SimpleMatch $joinLine -Quiet) } 240 "bot slot $($bot.Slot) party join"
        }
        Wait-ForHuman { (Invoke-TestSql 'SELECT COUNT(*) FROM characters.group_instance gi JOIN characters.instance i ON i.id=gi.instance WHERE i.map=389;') -ne '0' } 300 'full party bound to Ragefire Chasm'
        Start-Sleep -Seconds 3
        foreach ($bot in $fullPartyBots) { Send-WorldCommand "server playerbotdev slot $($bot.Slot) joininstance 389" }
        foreach ($bot in $fullPartyBots) {
            $enteredLine = "PB-PARTY: $($bot.Name) entered dungeon map 389 instance"
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch $enteredLine -Quiet) } 90 "bot slot $($bot.Slot) dungeon entry"
        }
        if ($MixedParty) {
            Write-Host 'MIXED PARTY IN DUNGEON: make a few normal pulls; observe Warrior threat, Mage damage and Priest healing.'
            Write-Host 'If convenient, observe one party-member death/resurrection and one party removal/re-invite. No forced wipe is required. Log out when finished.'
        }
        else { Write-Host 'FULL PARTY IN DUNGEON: make several normal pulls, then deliberately push into a wipe or death. Observe follow, assist, and what each bot does after death.' }
        if ($Interactive) {
            Write-Host 'Free play: observe the party, then log out. Combat/death evidence is optional in this mode.'
            Wait-ForHuman { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 600 'human logout after interactive playtest'
        }
        else {
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-02: Testone auto-assisting' -Quiet) } 240 'full-party combat engagement'
        }
        if ($MixedParty) {
            if (-not $Interactive) {
                Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 600 'human logout after mixed-party playtest'
            }
            foreach ($pattern in @('PB-02: Botmage began (Frostbolt|Fireball|Fire Blast|Frost Nova)', 'PB-02: Botpriest began (Flash Heal|Heal|Renew|Power Word: Shield)', 'PB-02: Botpriest began Power Word: Fortitude')) {
                Write-Host "Class evidence [$pattern]: $(@(Select-String -LiteralPath $serverLog -Pattern $pattern).Count) accepted casts"
            }
            foreach ($pattern in @('PB-ENGINE: Testone Warrior combat routed', 'PB-ENGINE: Botmage Mage combat routed', 'PB-ENGINE: Botpriest Priest healing routed', 'PB-02: Testone began (Taunt|Shield Slam|Victory Rush|Rend|Strike)', 'PB-02: Botpriest began Resurrection', 'PB-RECOVERY: .* accepted resurrection')) {
                Write-Host "Engine/recovery evidence [$pattern]: $(@(Select-String -LiteralPath $serverLog -Pattern $pattern).Count) log matches"
            }
        }
        elseif (-not $Interactive) {
            Wait-For { (Select-String -LiteralPath $serverLog -SimpleMatch 'PB-DEATH:' -Quiet) } 300 'human or bot death in Ragefire Chasm'
            Write-Host 'DEATH RECORDED: note what happened in game, then log out of Test to finish.'
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$humanGuid;") -eq '0' } 180 'human logout after death observation'
        }
        foreach ($bot in $fullPartyBots) { Send-WorldCommand "server playerbotdev slot $($bot.Slot) stop" }
        foreach ($bot in $fullPartyBots) {
            $botGuid = $bot.Guid
            Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$botGuid;") -eq '0' } 60 "bot slot $($bot.Slot) logout"
        }
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000) -or $worldWorker.Process.ExitCode -ne 0) { throw 'Full-party worldserver did not shut down cleanly.' }
        if ($Interactive) { Write-Host 'Interactive party session shut down cleanly; inspect evidence and player report, no mandatory combat/death assertion was made.' }
        else { Write-Host 'Full-party entry, combat, death observation, and clean shutdown completed; inspect logs and player report for behavior.' }
        return
    }
    if ($CheckTwoBots) {
        Send-WorldCommand 'server playerbotdev start'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'first Warrior online'
        Send-WorldCommand 'server playerbotdev start2'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$secondGuid;") -eq '1' } 90 'second Warrior online'
        Send-WorldCommand 'server playerbotdev status2'
        Send-WorldCommand 'server playerbotdev stop2'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$secondGuid;") -eq '0' } 60 'second Warrior independently offline'
        if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '1') { throw 'Stopping second Warrior disturbed first Warrior.' }
        Send-WorldCommand 'server playerbotdev start2'
        Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$secondGuid;") -eq '1' } 90 'second Warrior restarted'
        Send-WorldCommand 'server shutdown 0'
        if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Two-bot shutdown did not finish within 60 seconds.' }
        if ($worldWorker.Process.ExitCode -ne 0) { throw "Two-bot worldserver exited with $($worldWorker.Process.ExitCode)." }
        if ((Invoke-TestSql "SELECT COUNT(*) FROM characters.characters WHERE guid IN ($characterGuid,$secondGuid) AND online<>0;") -ne '0') { throw 'One or both Warriors remained online after shutdown.' }
        Write-Host 'Two-bot lifecycle passed: concurrent admission, independent stop/restart, and shutdown drain.'
        return
    }
    Send-WorldCommand 'server playerbotdev start'
    Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '1' } 90 'Warrior online state'
    Send-WorldCommand 'server playerbotdev status'
    if ($CheckDuplicateStart) {
        Send-WorldCommand 'server playerbotdev start'
        $worldOutput = Join-Path $stage 'world.stdout.log'
        Wait-For { (Select-String -LiteralPath $worldOutput -Pattern 'PB-00 start rejected' -Quiet) } 15 'duplicate admission rejection'
        if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '1') { throw 'Duplicate start disturbed the original Warrior session.' }
        Write-Host 'Duplicate admission rejected while the original Warrior remained online.'
    }
    Write-Host "Warrior is online. Holding idle for $IdleSeconds seconds."
    if ($IdleSeconds -gt 0) { Start-Sleep -Seconds $IdleSeconds }
    if ($worldWorker.Process.HasExited) { throw 'Worldserver exited during idle hold.' }
    if ((Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -ne '1') { throw 'Warrior did not stay online for the idle hold.' }
    Send-WorldCommand 'server playerbotdev stop'
    Wait-For { (Invoke-TestSql "SELECT online FROM characters.characters WHERE guid=$characterGuid;") -eq '0' } 60 'Warrior offline state'
    Send-WorldCommand 'server playerbotdev status'
    Write-Host "PB-00 lifecycle database checks passed: login, $IdleSeconds-second online hold, logout."
    if ($PostStopSeconds -gt 0) {
        Write-Host "Observing post-logout worldserver for $PostStopSeconds seconds."
        Start-Sleep -Seconds $PostStopSeconds
        if ($worldWorker.Process.HasExited) { throw 'Worldserver exited during post-logout observation.' }
    }
    Send-WorldCommand 'server shutdown 0'
    if (-not $worldWorker.Process.WaitForExit(60 * 1000)) { throw 'Worldserver did not shut down within 60 seconds.' }
    if ($worldWorker.Process.ExitCode -ne 0) { throw "Worldserver exited with $($worldWorker.Process.ExitCode)." }
    Write-Host 'Normal worldserver shutdown passed.'
} finally {
    if ($null -ne $lockWorker -and -not $lockWorker.Process.HasExited) {
        try { $lockWorker.Process.StandardInput.WriteLine('UNLOCK TABLES;'); $lockWorker.Process.StandardInput.Flush() } catch { }
    }
    if ($null -ne $worldWorker -and -not $worldWorker.Process.HasExited) {
        try { Send-WorldCommand 'server shutdown 0'; [void]$worldWorker.Process.WaitForExit(45000) } catch { }
    }
    if ($null -ne $authWorker -and -not $authWorker.Process.HasExited) {
        try { $authWorker.Process.Kill(); $authWorker.Process.WaitForExit() } catch { }
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
