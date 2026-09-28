param([switch]$KeepRunning, [string]$HostUser,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$MySqlHome, [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$OpenSslBin,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$ServerDirectory,
    [string]$BuildDirectory = 'build/bin/RelWithDebInfo', [string]$DataDirectory)

# Disposable localhost validation. Never starts/stops services or uses an existing DB.
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'test-environment.ps1')
$server = Resolve-TestDirectory $ServerDirectory $repo 'ServerDirectory'
$built = Resolve-TestDirectory $BuildDirectory $repo 'BuildDirectory'
$mysqlHome = Resolve-TestDirectory $MySqlHome $repo 'MySqlHome'
$opensslHome = Resolve-TestDirectory $OpenSslBin $repo 'OpenSslBin'
if (-not $DataDirectory) { $DataDirectory = Join-Path $server 'Data' }
$gameData = Resolve-TestDirectory $DataDirectory $repo 'DataDirectory'
Assert-TestFiles $built @('authserver.exe','worldserver.exe') 'BuildDirectory'
Assert-TestFiles $mysqlHome @('bin/mysql.exe','bin/mysqld.exe','lib/libmysql.dll') 'MySqlHome'
Assert-TestFiles $mysqlHome @('bin/libcrypto-3-x64.dll','bin/libssl-3-x64.dll') 'MySqlHome'
Assert-TestFiles $opensslHome @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll') 'OpenSslBin'
Assert-TestFiles $server @('worldserver.conf','authserver.conf','TDB_full_world_434.22011_2022_01_09.sql','TDB_full_hotfixes_434.22011_2022_01_09.sql') 'ServerDirectory'
$stage = Join-Path $repo ('build/runtime-smoke-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$dbPort = 13306
$authPort = 13724
$worldPort = 18085
$workers = [Collections.Generic.List[object]]::new()
$dbReady = $false
$worldWorker = $null
$authWorker = $null
$utf8 = [Text.UTF8Encoding]::new($false)

function New-Secret { [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(24)) }

function Start-Worker([string]$Exe, [string[]]$Arguments, [string]$Label, [hashtable]$Environment = @{}) {
    $psi = [Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Exe
    $psi.WorkingDirectory = $stage
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $psi.ArgumentList.Add($argument) }
    # Older MSBuild/.NET rejects inherited Path/PATH duplicates; normalize children.
    [void]$psi.Environment.Remove('PATH')
    $psi.Environment['Path'] = $env:PATH
    foreach ($key in $Environment.Keys) { $psi.Environment[$key] = $Environment[$key] }
    $outFile = [IO.FileStream]::new((Join-Path $stage "$Label.stdout.log"), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, [IO.FileOptions]::Asynchronous)
    $errFile = [IO.FileStream]::new((Join-Path $stage "$Label.stderr.log"), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, [IO.FileOptions]::Asynchronous)
    $process = [Diagnostics.Process]::Start($psi)
    $worker = [pscustomobject]@{ Process=$process; Label=$Label; OutFile=$outFile; ErrFile=$errFile; OutTask=$process.StandardOutput.BaseStream.CopyToAsync($outFile); ErrTask=$process.StandardError.BaseStream.CopyToAsync($errFile) }
    $workers.Add($worker)
    $state = @($workers | ForEach-Object { @{Label=$_.Label;Pid=$_.Process.Id;Executable=$_.Process.StartInfo.FileName} })
    [IO.File]::WriteAllText((Join-Path $stage 'processes.json'), ($state | ConvertTo-Json), $utf8)
    Write-Host "Started $Label (PID $($process.Id))"
    return $worker
}

function Wait-Worker($Worker, [int]$Seconds = 300) {
    if (-not $Worker.Process.WaitForExit($Seconds * 1000)) { throw "$($Worker.Label) timed out; inspect its local logs." }
    # On failure, let finally stop the DB before draining inherited migration pipes.
    if ($Worker.Process.ExitCode -ne 0) { throw "$($Worker.Label) failed with exit $($Worker.Process.ExitCode); inspect its local logs." }
    [void]$Worker.OutTask.GetAwaiter().GetResult()
    [void]$Worker.ErrTask.GetAwaiter().GetResult()
    $Worker.OutFile.Flush()
    $Worker.ErrFile.Flush()
}

function Invoke-TestSql([string]$Sql) {
    $psi = [Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = Join-Path $mysqlHome 'bin/mysql.exe'
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    foreach ($arg in @('--no-defaults','--protocol=TCP','--host=127.0.0.1',"--port=$dbPort",'--user=cata_smoke','--batch','--skip-column-names','--connect-timeout=3')) { $psi.ArgumentList.Add($arg) }
    [void]$psi.Environment.Remove('PATH')
    $psi.Environment['Path'] = $env:PATH
    $psi.Environment['MYSQL_PWD'] = $dbPassword
    $p = [Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEndAsync()
    $err = $p.StandardError.ReadToEndAsync()
    $p.StandardInput.WriteLine($Sql)
    $p.StandardInput.Close()
    if (-not $p.WaitForExit(30000)) { $p.Kill(); throw 'Test MySQL query timed out.' }
    if ($p.ExitCode -ne 0) { throw ('Test MySQL query failed: ' + $err.Result) }
    return $out.Result.Trim()
}

function Write-TestConfig([string]$InputPath, [string]$OutputPath, [hashtable]$Overrides) {
    $text = [IO.File]::ReadAllText($InputPath)
    foreach ($key in $Overrides.Keys) {
        $pattern = '(?m)^\s*' + [regex]::Escape($key) + '\s*=.*$'
        if (-not [regex]::IsMatch($text, $pattern)) { throw "Missing configuration key $key" }
        $replacement = $key + ' = ' + $Overrides[$key]
        $text = [regex]::Replace($text, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement })
    }
    [IO.File]::WriteAllText($OutputPath, $text, $utf8)
}

function Wait-WorldReady($Worker, [string]$LogRelative = 'logs/Server.log', [int]$Seconds = 180) {
    $deadline = (Get-Date).AddSeconds($Seconds)
    $log = Join-Path $stage $LogRelative
    do {
        if ($Worker.Process.HasExited) { throw 'Worldserver exited before ready; inspect test logs.' }
        if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern 'worldserver.*ready\.\.\.' -Quiet)) { return }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $deadline)
    throw "Worldserver did not report ready within $Seconds seconds."
}

function Read-Exact($Stream, [int]$Count) {
    $buffer = [byte[]]::new($Count)
    $offset = 0
    while ($offset -lt $Count) {
        $read = $Stream.Read($buffer, $offset, $Count - $offset)
        if ($read -eq 0) { throw 'Peer closed connection early.' }
        $offset += $read
    }
    return ,$buffer
}

function Test-WorldGreeting {
    for ($attempt=1; $attempt -le 3; $attempt++) {
        $tcp = [Net.Sockets.TcpClient]::new()
        try {
            $tcp.Connect('127.0.0.1', $worldPort)
            $stream = $tcp.GetStream()
            $stream.ReadTimeout = 5000
            $stream.WriteTimeout = 5000
            $header = Read-Exact $stream 2
            $length = ([int]$header[0] -shl 8) -bor [int]$header[1]
            if ($length -gt 128) { throw 'Unexpected server greeting size.' }
            $greeting = [Text.Encoding]::ASCII.GetString((Read-Exact $stream $length))
            if ($greeting -ne 'WORLD OF WARCRAFT CONNECTION - SERVER TO CLIENT') { throw 'Unexpected server greeting.' }
            $reply = [Text.Encoding]::ASCII.GetBytes('WORLD OF WARCRAFT CONNECTION - CLIENT TO SERVER')
            $packet = [byte[]]::new($reply.Length + 2)
            $packet[0] = [byte]($reply.Length -shr 8)
            $packet[1] = [byte]($reply.Length -band 255)
            [Array]::Copy($reply, 0, $packet, 2, $reply.Length)
            $stream.Write($packet, 0, $packet.Length)
            $challengeHeader = Read-Exact $stream 4
            $size = ([int]$challengeHeader[0] -shl 8) -bor [int]$challengeHeader[1]
            if ($size -lt 2 -or $size -gt 512) { throw 'Unexpected auth challenge size.' }
            $challenge = Read-Exact $stream ($size - 2)
            $opcode = [int]$challengeHeader[2] -bor ([int]$challengeHeader[3] -shl 8)
            if ($opcode -ne 0x4542) { throw ('Unexpected world opcode: 0x{0:X4}' -f $opcode) }
            Write-Host ("World handshake {0}/3: greeting and auth challenge received (opcode 0x{1:X4}, {2} payload bytes)." -f $attempt,$opcode,$challenge.Length)
        } finally { $tcp.Dispose() }
    }
    if ($worldWorker.Process.HasExited) { throw 'Worldserver exited after connection probes.' }
}

foreach ($port in @($dbPort,$authPort,$worldPort)) {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port)
    try { $listener.Start() } finally { $listener.Stop() }
}
New-Item -ItemType Directory -Path $stage | Out-Null
# The generated database/configs are private and ignored by Git.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
$acl = Get-Acl -LiteralPath $stage
$acl.SetAccessRuleProtection($true,$false)
$allowedSids = @($identity,[Security.Principal.SecurityIdentifier]::new('S-1-5-18'),[Security.Principal.SecurityIdentifier]::new('S-1-5-32-544'))
# Optional extra account for a sandbox/service caller; no workstation identity is embedded.
if (-not [string]::IsNullOrWhiteSpace($HostUser)) {
    $hostAccount = if ($HostUser.Contains('\')) {
        [Security.Principal.NTAccount]::new($HostUser)
    } else {
        [Security.Principal.NTAccount]::new($env:COMPUTERNAME, $HostUser)
    }
    $allowedSids += $hostAccount.Translate([Security.Principal.SecurityIdentifier])
}
foreach ($sid in $allowedSids) {
    $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($sid,'FullControl','ContainerInherit,ObjectInherit','None','Allow'))
}
Set-Acl -LiteralPath $stage -AclObject $acl
if ($env:USERNAME -like 'CodexSandbox*') {
    & icacls $stage /grant ($env:COMPUTERNAME+'\CodexSandboxUsers:(OI)(CI)M') | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not grant the paired Codex tool processes access to test artifacts.' }
}
Write-Host "TEST DIRECTORY: $stage"
$dataDir = Join-Path $stage 'mysql-data'
foreach ($folder in @('mysql-data','logs','migration-logs')) { New-Item -ItemType Directory -Path (Join-Path $stage $folder) | Out-Null }
foreach ($name in @('authserver.exe','worldserver.exe')) { Copy-Item -LiteralPath (Join-Path $built $name) -Destination $stage }
foreach ($name in @('authserver.pdb','worldserver.pdb')) { if (Test-Path -LiteralPath (Join-Path $built $name)) { Copy-Item -LiteralPath (Join-Path $built $name) -Destination $stage } }
foreach ($name in @('libcrypto-4-x64.dll','libssl-4-x64.dll','legacy.dll')) { Copy-Item -LiteralPath (Join-Path $opensslHome $name) -Destination $stage }
Copy-Item -LiteralPath (Join-Path $mysqlHome 'lib/libmysql.dll') -Destination $stage
foreach ($name in @('libcrypto-3-x64.dll','libssl-3-x64.dll')) { Copy-Item -LiteralPath (Join-Path $mysqlHome "bin/$name") -Destination $stage }
foreach ($name in @('TDB_full_world_434.22011_2022_01_09.sql','TDB_full_hotfixes_434.22011_2022_01_09.sql')) { Copy-Item -LiteralPath (Join-Path $server $name) -Destination $stage }
$dbPassword = New-Secret
$rootPassword = New-Secret
[IO.File]::WriteAllText((Join-Path $stage 'test-db-credentials.json'), (@{host='127.0.0.1';port=$dbPort;user='cata_smoke';password=$dbPassword} | ConvertTo-Json), $utf8)
$overrides = @{
    'BindIP'='"127.0.0.1"'; 'WorldServerPort'=$worldPort; 'DataDir'=('"'+$gameData.Replace('\','/')+'"');
    'LogsDir'=('"'+(Join-Path $stage 'logs').Replace('\','/')+'"'); 'SourceDirectory'=('"'+$repo.Replace('\','/')+'"');
    'MySQLExecutable'=('"'+(Join-Path $mysqlHome 'bin/mysql.exe').Replace('\','/')+'"');
    'Updates.EnableDatabases'=0; 'Updates.AutoSetup'=0; 'Console.Enable'=1; 'Ra.Enable'=0; 'SOAP.Enabled'=0;
    'Logger.root'='3,Console Server'
}
foreach ($entry in @{LoginDatabaseInfo='auth';WorldDatabaseInfo='world';CharacterDatabaseInfo='characters';HotfixDatabaseInfo='hotfixes'}.GetEnumerator()) {
    $overrides[$entry.Key] = '"127.0.0.1;'+$dbPort+';cata_smoke;'+$dbPassword+';'+$entry.Value+'"'
}
Write-TestConfig (Join-Path $server 'worldserver.conf') (Join-Path $stage 'worldserver.conf') $overrides
$overrides['Updates.EnableDatabases']=15
$overrides['LogsDir']='"'+(Join-Path $stage 'migration-logs').Replace('\','/')+'"'
Write-TestConfig (Join-Path $server 'worldserver.conf') (Join-Path $stage 'worldserver.migrate.conf') $overrides
$authOverrides = @{'BindIP'='"127.0.0.1"';'RealmServerPort'=$authPort;'LogsDir'=('"'+(Join-Path $stage 'logs').Replace('\','/')+'"');'Updates.EnableDatabases'=0;'Updates.AutoSetup'=0;'LoginDatabaseInfo'=$overrides.LoginDatabaseInfo}
Write-TestConfig (Join-Path $server 'authserver.conf') (Join-Path $stage 'authserver.conf') $authOverrides

try {
    $init = Start-Worker (Join-Path $mysqlHome 'bin/mysqld.exe') @('--no-defaults','--initialize-insecure',"--basedir=$mysqlHome","--datadir=$dataDir",'--lower-case-table-names=1') 'mysql-initialize'
    Wait-Worker $init
    $bootstrap = Join-Path $stage 'bootstrap.sql'
    $sql = "ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootPassword';`nCREATE USER 'cata_smoke'@'127.0.0.1' IDENTIFIED BY '$dbPassword';`n"
    foreach ($db in @('auth','characters','world','hotfixes')) { $sql += "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`nGRANT ALL PRIVILEGES ON $db.* TO 'cata_smoke'@'127.0.0.1';`n" }
    $sql += "GRANT SHUTDOWN ON *.* TO 'cata_smoke'@'127.0.0.1';`n"
    [IO.File]::WriteAllText($bootstrap,$sql,$utf8)
    # Test data is disposable: avoid a disk flush per statement in large upstream migrations.
    $mysqlWorker = Start-Worker (Join-Path $mysqlHome 'bin/mysqld.exe') @('--no-defaults',"--basedir=$mysqlHome","--datadir=$dataDir",'--bind-address=127.0.0.1',"--port=$dbPort",'--mysqlx=OFF','--skip-name-resolve','--skip-log-bin','--lower-case-table-names=1','--innodb-buffer-pool-size=512M','--innodb-redo-log-capacity=1G','--innodb-flush-log-at-trx-commit=2','--max-allowed-packet=256M',"--init-file=$bootstrap",('--log-error='+(Join-Path $stage 'mysql-error.log'))) 'mysql'
    $deadline=(Get-Date).AddSeconds(60)
    do {
        if ($mysqlWorker.Process.HasExited) { throw 'Disposable MySQL failed to start.' }
        try { $dbReady = (Invoke-TestSql 'SELECT 1;') -eq '1' } catch { $dbReady=$false }
        if (-not $dbReady) { Start-Sleep -Milliseconds 500 }
    } while (-not $dbReady -and (Get-Date) -lt $deadline)
    if (-not $dbReady) { throw 'Disposable MySQL readiness check timed out.' }
    # This single generated secret bootstrap file is no longer needed.
    Remove-Item -LiteralPath $bootstrap
    Write-Host 'Disposable MySQL ready. Populating/updating only its four empty Cata schemas.'
    # This core's Boost path option rejects whitespace-containing absolute -c values.
    # Child cwd is the test directory, so simple relative filenames avoid that parser bug.
    # Bootstrap through normal startup/shutdown; update-only returns before ioContext.stop().
    $migrate = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.migrate.conf') 'migrate'
    $worldWorker = $migrate
    Wait-WorldReady $migrate 'migration-logs/Server.log' 2700
    $migrate.Process.StandardInput.WriteLine('server shutdown 0')
    $migrate.Process.StandardInput.Close()
    Wait-Worker $migrate 60
    [void](Invoke-TestSql "UPDATE auth.realmlist SET name='Cata isolated test',address='127.0.0.1',localAddress='127.0.0.1',port=$worldPort WHERE id=1;")
    Write-Host 'Disposable database migrations completed. Runtime automatic updates are disabled.'
    $worldWorker = Start-Worker (Join-Path $stage 'worldserver.exe') @('-c','worldserver.conf') 'world'
    Wait-WorldReady $worldWorker
    $authWorker = Start-Worker (Join-Path $stage 'authserver.exe') @('-c','authserver.conf') 'auth'
    Start-Sleep -Seconds 2
    if ($authWorker.Process.HasExited) { throw 'Authserver exited before connection check.' }
    $authSocket=[Net.Sockets.TcpClient]::new()
    try { $authSocket.Connect('127.0.0.1',$authPort); Write-Host "Authserver accepts localhost TCP on $authPort." } finally { $authSocket.Dispose() }
    Test-WorldGreeting
    Write-Host 'SMOKE TEST PASSED: three connection-time crypto/greeting/challenge cycles; worldserver remains alive.'
    if ($KeepRunning) {
        Write-Host 'Controller ready. Commands: status, probe, account, stop. No existing client configuration has changed.'
        do {
            $command=Read-Host 'cata-smoke'
            switch ($command) {
                'status' { Write-Host "World alive: $(-not $worldWorker.Process.HasExited); Auth alive: $(-not $authWorker.Process.HasExited); MySQL alive: $(-not $mysqlWorker.Process.HasExited)" }
                'probe' { Test-WorldGreeting }
                'account' {
                    if ((Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='CATASMOKE';") -ne '0') {
                        Write-Host 'CATASMOKE already exists; existing test-login.txt has not been changed.'
                        break
                    }
                    $loginPassword=[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(6))
                    [IO.File]::WriteAllText((Join-Path $stage 'test-login.txt'),"Disposable realm only`nAccount: CATASMOKE`nPassword: $loginPassword`nAuth: 127.0.0.1:$authPort`nWorld: 127.0.0.1:$worldPort`n",$utf8)
                    $worldWorker.Process.StandardInput.WriteLine("account create CATASMOKE $loginPassword")
                    $worldWorker.Process.StandardInput.Flush()
                    $accountDeadline=(Get-Date).AddSeconds(10)
                    do {
                        $accountCreated=(Invoke-TestSql "SELECT COUNT(*) FROM auth.account WHERE username='CATASMOKE' AND expansion=3;") -eq '1'
                        if (-not $accountCreated) { Start-Sleep -Milliseconds 200 }
                    } while (-not $accountCreated -and (Get-Date) -lt $accountDeadline)
                    if (-not $accountCreated) { throw 'Test account creation was not confirmed; inspect world logs.' }
                    Write-Host 'Test-only Cata account creation confirmed; login credentials saved privately to test-login.txt.'
                }
            }
        } while ($command -ne 'stop')
    }
} finally {
    if ($null -ne $worldWorker -and -not $worldWorker.Process.HasExited) {
        try { $worldWorker.Process.StandardInput.WriteLine('server shutdown 0'); $worldWorker.Process.StandardInput.Close(); [void]$worldWorker.Process.WaitForExit(20000) } catch { }
    }
    if ($null -ne $authWorker -and -not $authWorker.Process.HasExited) { $authWorker.Process.Kill(); $authWorker.Process.WaitForExit() }
    if ($dbReady) { try { [void](Invoke-TestSql 'SHUTDOWN;') } catch { } }
    foreach ($worker in $workers) {
        if (-not $worker.Process.HasExited -and -not $worker.Process.WaitForExit(15000)) { $worker.Process.Kill(); $worker.Process.WaitForExit() }
        try { [void]$worker.OutTask.GetAwaiter().GetResult(); [void]$worker.ErrTask.GetAwaiter().GetResult() } catch { }
        $worker.OutFile.Dispose()
        $worker.ErrFile.Dispose()
    }
    Write-Host "All processes owned by this test are stopped. Evidence retained in $stage"
}
