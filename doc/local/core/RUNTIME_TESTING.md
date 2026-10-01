# Local Cata runtime smoke test

`runtime-smoke.ps1` tests the freshly built binaries without deploying them over
the existing `Server` directory. It uses the installed MySQL executable but does
not install, start, stop, or change any Windows service or Docker container.

Run from a PowerShell 7 terminal:

```powershell
$runtimeInputs = @{
    MySqlHome = '<MySQL installation directory>'
    OpenSslBin = '<compatible OpenSSL binary directory>'
    ServerDirectory = '<test config and TDB dump directory>'
    DataDirectory = '<extracted Cata data directory>'
    BuildDirectory = 'build/bin/RelWithDebInfo'
}
.\contrib\local\runtime-smoke.ps1 @runtimeInputs
# Keep the successful test running for a manual client test:
.\contrib\local\runtime-smoke.ps1 @runtimeInputs -KeepRunning
```

The script creates a new, Git-ignored `build/runtime-smoke-<timestamp>` directory
on every run. It copies the build's auth/world binaries and symbols, the
installed matching OpenSSL/MySQL DLLs, and the existing TDB world/hotfix dumps.
Extracted client data is selected by `-DataDirectory`, defaulting to `Data`
inside the explicitly supplied `-ServerDirectory`.

The test uses a **fresh database**, not existing Cata accounts or characters:

| Component | Bind endpoint |
| --- | --- |
| Disposable MySQL | `127.0.0.1:13306` |
| Authserver | `127.0.0.1:13724` |
| Worldserver | `127.0.0.1:18085` |

Database bootstrap/migrations are confined to that new instance. Normal runtime
configs disable automatic database updates, SOAP, and remote administration.
Bootstrap uses normal worldserver startup and shutdown. The disposable MySQL
instance uses a 1 GiB redo log and `innodb_flush_log_at_trx_commit=2` to make large
upstream migrations practical; its test data is expendable on a host crash.
These settings are not applied to any existing database.
The harness creates its own server configuration and database files. It does not
manage unrelated server installations or change the client configuration.
Credentials and database files are restricted to the executing user,
an optional additional account supplied with `-HostUser`, system administrators,
and the conditional sandbox helper group implemented in the script's ACL setup.
`-HostUser` has no default account name. Normally the executing Windows account
already has access. When running under a separate sandbox or service account,
pass the intended additional account explicitly (local name or DOMAIN\User).

The controller checks auth TCP acceptance, then performs three Cata world
greeting/authentication-challenge exchanges. These exercise the connection-time
ARC4 construction path. **They do not prove account authentication, character
selection, or entering the world.** Those require a real client login.

With `-KeepRunning`, controller commands are:

- `status`: show whether its three processes are alive.
- `probe`: repeat the world-connection probes.
- `account`: create a disposable `CATASMOKE` account and save its credentials
  to the private `test-login.txt` inside the test directory.
- `stop`: shut down the test; retain files and logs for inspection.

The helper normalizes inherited `Path`/`PATH` environment keys for child
processes. It passes simple config filenames from the staged working directory
because this checkout's Boost command-line path parser rejects absolute `-c`
values containing spaces. Test logging is raised from the saved error-only
setting to informational level so startup can be verified.

## Environment requirements

These PowerShell helpers currently target Windows. Dependency paths can be
absolute or repository-relative. Runtime bootstrap requires `-MySqlHome`,
`-OpenSslBin` and `-ServerDirectory`; `-BuildDirectory` defaults to the normal
RelWithDebInfo output but can be overridden. Symbols are copied when present.
ServerDirectory must contain worldserver.conf, authserver.conf and the documented
TDB 434.22011 SQL dumps. Current DLL checks require the tested OpenSSL 4 server
ABI and OpenSSL 3 MySQL client ABI; configurable paths do not imply other ABI
versions were tested.

Continuation tests require `-MySqlHome` and `-Seed`. A seed must be a cleanly
stopped runtime-smoke directory under this checkout's build directory (Playerbots
scenarios also accept their own stopped playerbot-smoke fixtures). Each seed must
contain its own test-db-credentials.json. New clones retain that file; no fallback
to another fixture is allowed. Optional `-DataDirectory` updates the cloned server
configuration when extracted data has moved. Seed database directories must not
be links. These helpers have not been validated on other operating systems.

Playerbot lifecycle scenarios may explicitly set `-SeedRepository` to another
source checkout containing the stopped fixture. Its checkout files are checked,
and the seed must still be a direct, non-linked smoke directory under that
checkout's build directory with credentials and clean-shutdown evidence. Only
the new clone under the current checkout is started or modified.

`playerbot-lifecycle-smoke.ps1 -CheckFactory -ModuleConfig` runs a server-only
factory batch with the shared seed/MySQL/build inputs. It covers disabled and
missing-evidence/schema gates, ineligible accounts, explicit enrollment, native
creation, exact reuse with stale realm-count repair, conflicting intent rejection
and explicit managed admission/save/logout. Temporary account credentials are
random and omitted from command narration. Fixture config reloads replace keys
rather than introducing duplicate INI keys; readiness polls the native receipt.
This is an optional Windows test helper, not a server runtime dependency. It
does not test client character creation, addon UI or gameplay, and does not change
production databases/configuration or existing native service installations.

`playerbot-lifecycle-smoke.ps1 -CheckManagedClient -ModuleConfig` uses the same
validated stopped seed and current binaries for a bundled client check. It starts
only cloned localhost services, creates a fresh ordinary player account with a
random client-compatible password, and writes private instructions to the ignored
`test-login.txt`. Create the requested Blood Elf Warrior through the real client,
then use MultiBot Units to connect, disconnect and reconnect the configured bot.
The helper checks native character/realm accounting and each online transition;
no GM override or console connect stands in for addon completion. Log out to
finish cleanup. This scenario has a ten-minute deadline for each human step.
Use the valid character name `Lifecycletst`. An optional `-ManagedClientPassword`
accepts a disposable 3-16-character alphanumeric password; never pass a real
account credential. `-ReuseManagedClientFixture` explicitly permits the existing
ordinary test account in a cleanly stopped fixture so a saved test character can
be reused. This does not repeat its original character-creation interaction.
In MultiBot, select My Bots under Roster Filters; left-click an offline bot to
connect and right-click an online bot to disconnect. The 2026-10-01 bundled
check passed native accounting, addon lifecycle and clean shutdown.

For the AHBot and Playerbots examples below, define the shared inputs first:

```powershell
$continuationInputs = @{
    Seed = 'build/runtime-smoke-<your-stopped-run>'
    MySqlHome = '<MySQL installation directory>'
    BuildDirectory = 'build/bin/RelWithDebInfo'
}
```

DBC checks require `-DbcDir <matching-extracted-DBC-directory>` explicitly.

## Common regression tests

From the repository root, enable and build the existing test target:

```powershell
$env:PATH = 'C:\Program Files\OpenSSL-Win64\bin;' + $env:PATH
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build --config RelWithDebInfo --target tests-common --parallel 8
ctest --test-dir build -C RelWithDebInfo --output-on-failure
```

The OpenSSL path must be visible during test discovery at build time as well;
set it before the build if it is not already in your environment. Catch2 v2.13.9
is fetched by the existing CMake setup on first enablement. In a child process
environment with duplicate `Path`/`PATH` keys, normalize the child environment
as the runtime helper does before invoking CMake/MSBuild.

The navigation tests create synthetic temporary files; no database/server or
client assets are required. The full suite retains an existing EventMap
`[!mayfail]` case, documented in CLEANUP.md.

See CLEANUP.md for warning triage and `../playerbots/PLAYERBOTS_DEV.md` for the proposed
single-bot lifecycle milestone.

Full-party playtests now support `-Interactive` with `-CheckFullParty`.
Human login, party formation, dungeon entry and logout steps have no deadline;
native startup, bot readiness, transfer and shutdown remain bounded. Create
`stop.request` in the printed test directory to cancel at any wait and run
normal test-owned cleanup. Do not combine this with `-CheckRosterOnly`.
The automatic mode retains combat/death expectations; interactive mode records
observations without claiming those assertions passed.

`-CheckFullParty -CheckRosterOnly` runs four-bot admission/readiness/logout
without waiting for a client. Add `-MixedParty` for the Mage/Priest roster and
`-ReuseFullPartyFixture` only for a stopped, pre-party prepared roster.
All four offline bot positions are normalized in the disposable copy to the
same outdoor start point before login, including reused Testtwo. Existing group
membership is rejected, not deleted. Run
`./contrib/local/test-playerbot-harness-waits.ps1` for service-free wait-policy
regressions. These checks do not prove invitation/combat behavior.

## Native Auction House Bot seller replay

`ahbot-smoke.ps1` clones the same cleanly stopped disposable database used by
the runtime tests, assigns the disposable `CATASMOKE`/`Testone` identity to the
built-in Cata Auction House Bot, and enables only a twelve-listing neutral-house
seller profile. It verifies auction and item-instance rows, prints a compact
price/item summary, and requires a clean worldserver shutdown. The installed
server config and real auction tables are not changed. Existing auctions in
the disposable seed are removed only from the new clone so seller population
starts from a deterministic empty-market baseline.

Run from the repository root after building `RelWithDebInfo`:

```powershell
.\contrib\local\ahbot-smoke.ps1 @continuationInputs
# Also prove one deterministic player-auction bid or buyout:
.\contrib\local\ahbot-smoke.ps1 @continuationInputs -CheckBuyer
# Request 120 listings with a one-listing-per-item segment ceiling:
.\contrib\local\ahbot-smoke.ps1 @continuationInputs -CheckSupplyProfile -CheckBuyer
# Also stagger expiry, remove 24 stopped-server listings, and prove exact refill:
.\contrib\local\ahbot-smoke.ps1 @continuationInputs -CheckTurnover -CheckBuyer
```

The retained `build/ahbot-smoke-<timestamp>` directory is disposable evidence
for comparing the native seller with later pricing or selection changes. The
base mode requires the exact twelve-listing target and a configured six-hour
auction lifetime. Every mode exercises both live ratio-command forms to prove
that setting 100% neither underfills nor expands the target. The script also
enables the opt-in crafted source and writes `ahbot-market-catalog.csv` plus a
grouped summary.
Filter the raw CSV on `seller_eligible=1` for the exact posting pool; rows with
`seller_eligible=0` are additional profession outputs retained for review and
are not posted. See `../ahbot/AHBOT_MARKET_CATALOG_ANALYSIS.md` for the measured baseline
and `../ahbot/AHBOT_DEV.md` for the supply/demand roadmap.

`-CheckSupplyProfile` enables the default-off segment policy only in the cloned
test configuration, requests 120 listings, sets commodity, equipment, and
other weights to 45/40/15, and sets all per-item ceilings to one. It requires
the exact 54/48/18 segment targets and all 120 listings to use distinct item
entries. It also validates that every commodity uses a configured single,
quarter, half, or full-stack shape derived from the item's actual maximum, and
that equipment remains single-item. This proves allocation, ceiling, and stack
behavior without selecting a production profile or changing pricing.

`-CheckTurnover` implies `-CheckSupplyProfile`, configures randomized 6-18 hour
lifetimes, and requires more than one expiration timestamp. After the initial
seller phase shuts down cleanly, it removes 24 AHBot listings and their item
instances from the disposable clone only. It restarts the staged worldserver
and requires a refill to 120 distinct item entries, fresh auction IDs, and the
same exact 54/48/18 segment allocation before shutting down again. This proves
staggered turnover and refill mechanics without waiting in real time or editing
an installed database.

`-CheckBuyer` restarts the staged worldserver with selling disabled, converts
two generated listings into one-copper auctions owned by a non-bot character
in the disposable clone, and requires the native buyer to buy exactly one in
its first cycle under an action cap of one. It also requires the aggregate
cycle diagnostic and verifies that the other auction remains for a later
cycle. If the seed has no second character, the test clones its disposable
character row under a synthetic non-bot account identity. This validates buyer
cadence and mechanics, not the economic quality of the current placeholder
valuation formula.

## PB-00 one-Warrior lifecycle replay

`playerbot-lifecycle-smoke.ps1` clones the cleanly stopped disposable database
specified by `-Seed`, stages the freshly built worldserver and its required
OpenSSL/MySQL DLLs, then runs the console-only PB-00 start/status/stop sequence
and normal shutdown. Supply the repository-relative path of a cleanly stopped
fixture created on the current host. The successful lifecycle,
negative-path, persistence, and manual-client collision runs are documented in
`../playerbots/PLAYERBOTS_LIFECYCLE_VALIDATION.md`.
Use `-CheckDuplicateStart -IdleSeconds 0` for a shorter duplicate-admission
replay. Diagnostic logs are retained separately from the disposable database
clones.

For the manual client-collision gate, use:

```powershell
.\contrib\local\playerbot-lifecycle-smoke.ps1 @continuationInputs -CheckClientCollision -IdleSeconds 0
```

That mode stages authserver as well, admits the configured bot, and waits for
an authenticated client attempt on the reserved test account.

For the PB-01 follow check, use `-CheckFollow` with the continuation inputs defined above.
It creates a disposable second client account on a cloned database and uses
loopback's standard client ports, without editing `Config.wtf`. The PB-02
`-CheckCombat` mode accepts a cleanly stopped PB-01 test directory as `-Seed`
so the existing human test character can be reused. Its console-only commands
are `server playerbotdev attack` (the following human's selected nearby hostile
creature) and `server playerbotdev cease`. Use `-WaitForStrike` with
`-CheckCombat` to wait up to 60 seconds for a legal Warrior Strike cast. See
`../playerbots/PLAYERBOTS_LIFECYCLE_VALIDATION.md` for the completed local runs and limits.
While the client is unavailable, run
`.\contrib\local\playerbot-warrior-capabilities.ps1 -DbcDir <DBC-directory>` from the checkout to
verify the early Warrior ability mapping against the installed Cata DBCs.
This read-only check does not start a realm or validate combat behavior.
`playerbot-caster-buffs.ps1 -DbcDir <DBC-directory>` similarly verifies Mage/Priest buff levels and
single/party aura mappings against the local Cata DBCs. It does not validate
the runtime database's spell-script bindings or actual buff application.
For the next mixed-class playtest, `-PrepareClassFixture -Seed <stopped
playerbot-smoke directory>` starts a disposable feature-off realm and waits
for real Blood Elf Mage `Testmage` and Priest `Testpriest` characters to be
created on the disposable `PB01HUMAN` account. It saves a stopped clone for
later bot-account imports; this preparation mode has not yet been run.
Use `-WaitForTargetDeath` instead to let the selected creature die and check
that combat ends automatically.
Use `-WaitForLeash` instead to wait for an engaged bot to exceed its 35-yard
combat leash; select a sturdier hostile and move away when attack begins. This
mode is built but has not completed a live check.
Use `-ObserveFollow` with `-CheckCombat` for a follow-only, first-minute
position trace; no attack is requested, and logging out ends the replay.
Use `-PlayAssist` with `-CheckCombat` to fight normally with the following bot:
it joins your selected nearby hostile after you enter combat, and logging out
ends the run (up to five minutes).
Add `-BotLevel 7` only to that mode to level the bot and seed its trainer-learned
Victory Rush and Rend in the cloned test database. The saved seed is unchanged.
Add `-BotLevel 20` to the same mode to seed Battle Shout as well. That run
requires a Battle Shout cast-start log before reporting success; confirm the
buff itself in the client. Both leveled fixtures require a clean, offline
level-1 Warrior seed and change only the new database clone.
