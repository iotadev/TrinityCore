# PB-00 isolated lifecycle validation - 2026-09-23

## Result

The default-off Cata 4.3.4 one-Warrior Playerbots prototype passed a
positive-path runtime test, seven targeted admission rejections, and held-query
stop/shutdown checks. This proves a server-origin session can use the canonical
character login, remain in-world without a client socket for more than two
minutes, save/logout, and allow a normal clean shutdown. It does not prove
combat, follow, group play, population management, or human-client collision.

The Win64 `RelWithDebInfo` worldserver build/link and `git diff --check`
passed. The successful run used `contrib/local/playerbot-lifecycle-smoke.ps1`
and Git-ignored evidence directory `build/playerbot-smoke-20260923-113326`.
The script copied the prior cleanly stopped, disposable MySQL data directory
into a new directory. The lifecycle checks used only the staged server and
database processes; no game client was required for this phase.
The older diagnostic database/binary clones were removed after their small
logs were hash-verified into Git-ignored
`build/playerbot-diagnostic-logs-20260923`; the successful full-lifecycle
clone and original baseline smoke-test database remain.

## Observed sequence

1. The cloned database had offline account `CATASMOKE` (ID 1) and its
   level-1 Warrior `Testone` (GUID 2). Test config bound the database to
   `127.0.0.1:13306` and worldserver to `127.0.0.1:18085`, with the PB-00
   feature enabled only in that clone. No authserver or game client ran.
2. Console command `server playerbotdev start` admitted the one server-origin
   session. `world.stdout.log` records `Login Character:[Testone]` and
   `PB-00 session: character in world`; the character's database `online`
   state became 1.
3. After a 125-second idle hold, the worldserver was still alive and `online`
   remained 1. `server playerbotdev stop` produced
   `Logout Character:[Testone]`; `online` returned to 0 and status reported
   no PB-00 session.
4. `server shutdown 0` completed with worldserver exit code 0. Its four
   database pools closed. The cloned MySQL log records `Normal shutdown` and
   `Shutdown complete`; no test-owned process or listener remained.

## Shutdown defect discovered and corrected

Before the content fix, two bot runs reproduced Windows exit status
`0xC0000374` after normal logout and during worldserver shutdown. A no-bot
control with the same binary/database exited cleanly. Temporary checkpoints
localized the failure to `OutdoorPvPMgr::Die()`, specifically deletion of
the map-530 Zangarmarsh OutdoorPvP object. Source inspection showed its
graveyard capture point was owned by both a derived-script `unique_ptr` and
the base `OutdoorPvP::m_capturePoints` `unique_ptr` map. Nagrand used the same
double-ownership pattern for its Halaa point. Both ownership transfers were
corrected; the full 125-second replay then passed clean shutdown. Temporary
instrumentation was removed from the final source.

The first trial also exposed a test-harness packaging issue: the current
worldserver directly needs OpenSSL 4, but the installed MySQL `libmysql.dll`
imports OpenSSL 3. The harness now stages both matching library pairs.

## Additional admission check

A later replay (`-IdleSeconds 0 -CheckDuplicateStart`) admitted the Warrior,
issued a second `server playerbotdev start`, observed `PB-00 start rejected`,
and confirmed the original Warrior remained online. Stop/logout and normal
shutdown still passed. Its database/binary clone was removed after its four
logs were hash-verified into
`build/playerbot-diagnostic-logs-20260923/playerbot-smoke-20260923-114633`.

A further isolated replay (`-CheckAdmissionRejects -IdleSeconds 0`) booted
three worldservers sequentially against one cloned database. With
`Playerbots.Dev.Enabled = 0`, start was rejected and the Warrior remained
offline. With the feature enabled but a verified nonexistent character GUID,
start was again rejected and the Warrior remained offline. Each rejected
server exited normally. A final valid-GUID boot admitted the Warrior, observed
online state 1, stopped it, observed offline state 0, and exited normally.
The test harness now preserves a separate `Server.log` per boot so readiness
cannot be inherited from an earlier boot. Logs from this run and an earlier
readiness-check harness timeout were hash-verified into
`build/playerbot-diagnostic-logs-20260923`; both disposable clones were
removed. The timeout was a harness mistake: readiness appears in `Server.log`
before it appears in console output; the worldserver itself initialized.

One further CheckAdmissionMatrix replay tested four rejections in a single
isolated worldserver boot. It temporarily changed the cloned Warrior's
account ID, then class, inserted a test ban for the configured account, and
set the Warrior's online flag. Each case produced a fresh rejection response,
no active PB-00 session, and no unexpected character-state change. The
harness restored and checked the baseline after each case. It then admitted
the original Warrior and completed normal login/logout and shutdown. The
console log contains four rejections, one admission, one character login,
and one logout; cloned MySQL shut down cleanly. Its seven logs were
hash-verified into the diagnostic archive, then the disposable clone was
removed. The successful full-lifecycle clone and original seed remain.

## Pending-load stop and shutdown

Two more isolated replays used a second MySQL connection to hold a table
needed by an asynchronous login query. With `-CheckPendingLoad` and the
`account_tutorial` table held, console status confirmed `account loading`.
Stop removed the session without a character login; a second admission held
at the same point survived a shutdown request until the lock was released,
then worldserver exited with code 0. The Warrior remained offline.

With `-CheckPendingLoad -PendingTable character_aura`, status confirmed
`character loading (login query pending)` while the table was held and the
Warrior remained offline. A stop request did not tear down the pending
session: after the lock was released, the canonical character login completed,
immediately followed by logout, and the session disappeared. Repeating this
with `server shutdown 0` likewise completed login/logout after lock release,
then exited with code 0. Both final Warrior online states were 0. These
checks prove deferred cleanup under the held queries, not cancellation of
an in-flight character login. The lock was held for two seconds after each
exit request; the 30-second shutdown timeout was not exercised.

The first character-query attempt timed out in the harness because it only
issued one status command while account loading was still finishing. The
corrected harness polls status until it observes the target state. The
worldserver from that attempt initialized and was cleaned up, but it is not
counted as a passed pending-character test.
Logs from all three pending-load runs were hash-verified into
`build/playerbot-diagnostic-logs-20260923`; their disposable database/binary
clones were then removed. The successful full-lifecycle clone and original
baseline smoke-test database remain.

## Thirty-second drain deadline

An isolated `-CheckDrainTimeout -PendingTable character_aura` run held the
character query through shutdown. The console confirmed `character loading
(login query pending)` before `server shutdown 0`. With the lock still held,
`Server.log` recorded `PB-00 session did not drain within 30 seconds;
continuing normal world shutdown cleanup`. No character login was logged,
and the Warrior remained offline. The server was still alive three seconds
after that message; its log had reached `Closing down DatabasePool
'characters'`. After the test released the table lock, worldserver exited
with code 0 and cloned MySQL shut down cleanly.

This validates that the PB-00 drain deadline advances world shutdown. It
does **not** prove a hard 30-second process-exit bound when a database query
remains blocked: database-pool closure itself waited for the held query in
this test. The harness releases its test lock in cleanup even on failure.
The timeout run's nine logs were hash-verified into
`build/playerbot-diagnostic-logs-20260923`, then its disposable clone was
removed; the earlier successful clone and original seed remain.

## Saved-field persistence after restart

A disposable CheckPersistence replay admitted the level-1 Warrior, used the
console character-level command against the online player to raise it to
level 2, then stopped the bot. The first server log records login at level 1
and logout at level 2; the cloned character database recorded online 0 and
level 2 after logout. Worldserver exited normally and was restarted against
the same cloned database. A fresh PB-00 login recorded level 2, followed by
normal logout, online 0, and another clean worldserver shutdown. Cloned MySQL
also shut down cleanly. This proves a specific in-memory character change
survived canonical logout and a worldserver restart, without a game client.

The first attempt's console-log assertion timed out because that output split
the login entry across lines. The server file log held the complete entry;
the corrected replay passed. The first attempt is not counted as a
persistence pass. All 17 logs from these two runs were hash-verified into
the diagnostic archive, then both disposable database/binary clones were
removed; the successful full-lifecycle clone and original seed remain.

## Still unproven

- Feature-off, nonexistent-character, wrong-account, wrong-class,
  banned-account, already-online, and duplicate-bot admission passed targeted
  runtime rejection checks. The enabled PB-00 account is structurally rejected
  during authenticated client admission before client-session allocation, and
  a real-client collision replay passed on 2026-09-24.
- Stop and normal shutdown with held account and character queries passed.
  The 30-second PB-00 drain deadline fired as designed, but process exit
  while a database query remains blocked is not bounded by this proof.
- Nagrand's Halaa spawn/delete path was fixed from the same ownership analysis
  but not exercised by this map-530 character.
- Level persistence passed across restart. Position and inventory persistence
  have not been specifically mutated and checked in PB-00.

Those checks are the next PB-00 gate before movement or combat work.

## Typed configuration and reserved-account regression

The three PB-00 settings were moved into the typed world configuration and
documented in `worldserver.conf.dist`. The enabled dedicated account is now
rejected in `WorldSocket::HandleAuthSessionCallback` after credential and ban
checks but before successful-login hooks or client `WorldSession` allocation.
The existing world-thread collision branch remains a defense-in-depth guard.

The Win64 `RelWithDebInfo` worldserver rebuilt and linked successfully after
this change. A fresh isolated replay in
`build/playerbot-smoke-20260923-204157` admitted the configured Warrior,
rejected a duplicate start while it remained online, completed saved logout,
reported no active PB-00 session, and shut down worldserver and cloned MySQL
normally. This replay validates the typed enabled path; it does not replace the
real-client collision test described below.

## Real-client account collision

An isolated `-CheckClientCollision` replay started cloned MySQL, authserver,
and worldserver on `127.0.0.1:13306`, `127.0.0.1:13724`, and
`127.0.0.1:18085`. PB-00 admitted `Testone` and reported `character in world`.
The existing 4.3.4.15595 client then authenticated as `CATASMOKE` against the
isolated realm while that bot session owned the same account.

`Server.log` records the authenticated attempt being rejected because account
1 was reserved for the enabled PB-00 lifecycle session. A status command after
the rejection still reported the original bot `character in world`. The
harness then requested normal bot exit, recorded `Logout Character:[Testone]`,
shut worldserver down with exit code 0, and observed normal cloned-MySQL
shutdown. Evidence is retained in Git-ignored
`build/playerbot-smoke-20260924-015319`.

This closes the human-client collision gate for the dedicated PB-00 account.
It does not make shared human/bot accounts supported; the account is explicitly
reserved while the feature is enabled.

## PB-01 local follow/hold check

On 2026-09-24, `-CheckFollow` cloned the disposable database and ran MySQL,
authserver, and worldserver on loopback ports 13306, 3724, and 8085. The
existing client config remained at `127.0.0.1`. The harness created a
disposable second account; the human client created and entered a Blood Elf
character `Test` (GUID 3) on map 530 while the server-origin Warrior
`Testone` (GUID 2) was online. Evidence is in Git-ignored
`build/playerbot-smoke-20260924-022615`.

`Server.log` records both character logins, two accepted `PB-01: Testone
following Test` transitions (initial and resumed), the human logout, the
automatic `follow target left bot map or died; holding` transition, and the
bot's saved logout. The harness issued `hold` between the two follow requests;
the command was acknowledged. Its immediately following `status` still read
`following` because map-thread command delivery is asynchronous, so that
particular status line is not proof of hold application. The user reported
that the visible in-client behavior looked good. The worldserver exited 0,
and the cloned MySQL stopped cleanly. No test-owned service remains running.

An initial live attempt in `build/playerbot-smoke-20260924-021956` reached
human login but the harness passed GUID 0 due to a PowerShell scriptblock
variable-scope error. It shut down normally without testing movement; the
scope was fixed before the successful replay. No client configuration or
installed server files were changed by either attempt.

## PB-02 Warrior auto-attack and cease-fire check

On 2026-09-24, `-CheckCombat` cloned the cleanly stopped PB-01 fixture with
the saved human character `Test`. The local client logged into that character;
the bot followed it, then the owner selected a nearby Mana Wyrm. The console
requested `attack` and later `cease`. `Server.log` records `PB-02: Testone
attacking Mana Wyrm`, `PB-02: Testone ceased attack`, the human logout,
automatic owner-loss hold, and the bot's saved logout. The user confirmed
visually that engagement succeeded and the bot stopped. The worldserver exited
0, the cloned MySQL shut down normally, and no test-owned service remains.
Evidence is in Git-ignored `build/playerbot-smoke-20260924-024208`.

As with PB-01, `status` immediately after a queued console request can show
the previous map-thread state; the later transition log and user observation
are the evidence for cease-fire. This first check did not exercise target death,
leash escape, invalid target, PvP rejection, spells, loot, or threat behavior.
An earlier combat attempt in `build/playerbot-smoke-20260924-024019` stopped
at worldserver startup because copying the PB-01 config duplicated generated
Playerbots keys; the harness now removes those duplicates in the staged copy.

## PB-02 first Warrior ability check

The pinned 4.3.4.15595 DBC marks Strike (88161) as an automatically learned
level-1 Warrior ability with a 20-rage cost. The prototype checks it once per
second during the controlled melee engagement, requiring a known spell,
melee range, line of sight, facing, no cooldown, and the core's ordinary cast
and power checks. It does not cast when those requirements fail.

On 2026-09-24, `-CheckCombat -WaitForStrike` cloned the stopped fixture in
`build/playerbot-smoke-20260924-024208`. With the human `Test` logged in and a
Mana Wyrm selected, `Server.log` recorded `Testone attacking Mana Wyrm`,
`Strike known for Testone`, `Testone began Strike on Mana Wyrm`, and then
`Testone ceased attack`. The human and bot logged out, the worldserver exited
0, MySQL shut down normally, and no test-owned service remained. Evidence is
in Git-ignored `build/playerbot-smoke-20260924-030017`. The cast-start log
confirms core acceptance, not independently measured hit or damage; clicking
off the target after the attack request did not invalidate the recorded cast.

## PB-02 automatic target-death stop

On 2026-09-24, `-CheckCombat -WaitForTargetDeath` cloned the same cleanly
stopped fixture. The user logged into `Test` and selected a Mana Wyrm. The
server recorded `Testone attacking Mana Wyrm`, `Testone began Strike on Mana
Wyrm`, `Testone target died; returning to follow`, and `Testone ceased attack`.
This confirms the stored combat target died and the bot automatically ceased
without an explicit `cease` command. Both characters then logged out; the
worldserver exited 0 and cloned MySQL shut down normally. The Git-ignored
evidence directory is `build/playerbot-smoke-20260924-124509`. The log does
not independently attribute the killing blow to Strike or verify the follow
movement visually.

## PB-02 combat leash pending live check

The existing 35-yard combat leash now emits a distinct reason when the owner
or target gets too far from the bot, before clearing chase and resuming the
retained follow order. The worldserver build passed. A first `-CheckCombat
-WaitForLeash` run on 2026-09-24 did not reach login: the worldserver failed
to bind its instance port during startup, while another local test was active.
Its disposable processes shut down normally; evidence is in Git-ignored
`build/playerbot-smoke-20260924-125604`. The harness now checks instance port
8086 before cloning. No leash gameplay result is claimed yet.

Two subsequent `-WaitForLeash` attempts did reach the live client, but the
attack request was rejected before the leash phase. The user clarified that
Testone was not stuck at a boundary: it appeared to move to the same unexpected
waypoint-like spot in both runs, then remained a long distance from `Test`.
Evidence is in Git-ignored
`build/playerbot-smoke-20260924-131257` and
`build/playerbot-smoke-20260924-131726`; each harness shut down its own realm
cleanly. The original rejection log did not identify which target condition
failed. A rebuilt diagnostic now records owner/bot and target distances,
target validity, and line of sight at rejection, but has not been live-run.

Source inspection shows `FollowMovementGenerator::LaunchMovement` chooses a
destination near the owner, collision-checks that destination, then launches a
straight spline from the bot. It updates while owner movement is detected;
when the owner stops, an alignment event sends the bot toward a destination
near the owner's then-current position.

A follow-only replay in `build/playerbot-smoke-20260924-133210` recorded the
owner and bot positions once per second during the recorded test route past the
pillar and stairs. The bot generally stayed near the owner. At second 42 the
center-to-center gap was about 9 yards on the stairs, narrowing over the next
seconds. When the owner stopped at second 46, the bot moved to a point about
3 yards in front of the owner's facing by second 49 and stayed there. That
is consistent with the prior `MoveFollow(owner, 3.0f, 0.0f)` forward offset
and the repeatable waypoint-like destination without implicating map data. The local
prototype now requests 2 yards behind the owner; this new offset is built but
has not had a separate visual acceptance check.

A later short attack-entry replay in `build/playerbot-smoke-20260924-133718`
used the expanded rejection log. The selected Mana Wyrm was alive, legal, and
in line of sight, but it was 34.9 yards from the owner and 36.0 yards from
the bot. Both exceed the prototype's 25-yard attack-entry limit. The bot was
close to the owner at that instant, so this rejection does not support the
theory that a follow gap broke the attack test. The leash behavior itself
remains untested. Both disposable replays shut down cleanly.

## PB-02 owner-engagement auto-assist

On 2026-09-24, `-CheckCombat -PlayAssist` cloned the stopped fixture into
Git-ignored `build/playerbot-smoke-20260924-135235`. The human `Test` fought a
Mana Wyrm normally with Testone following; no console attack was requested.
`Server.log` records `Testone auto-assisting Mana Wyrm`, `Testone began Strike
on Mana Wyrm`, `Testone target died; returning to follow`, and `Testone ceased
attack`. The user confirmed the behavior in game. Both characters logged out,
the harness exited 0, and test-owned processes stopped. This verifies the
first playable owner-selected assist loop, not independent target selection,
the killing blow, or a broader Warrior rotation.

## PB-02 Warrior priority slice and chase crash

The Cata 4.3.4.15595 `SpellLevels.dbc` assigns Strike (88161) to level 1,
Victory Rush (34428) to level 5, and Rend (772) to level 7. `SpellEffect.dbc`
shows that Rend applies its periodic debuff through spell 94009, so the
Rend-missing trigger checks that aura rather than the casting spell ID. A
small priority list adapted from WotLK Playerbots proposes Victory Rush when
its proc is active, then missing Rend, then Strike. Normal core cast checks
remain authoritative. The `RelWithDebInfo` worldserver build passed.

The first 2026-09-24 live replay in Git-ignored
`build/playerbot-smoke-20260924-160542` crashed shortly after auto-assist
began. The retained crash report and dump identify an access violation at
`ChaseMovementGenerator::Update`, line 123, in `DoMovementInform`. That callback
returned for creatures but dereferenced `owner->ToCreature()` for the
player-bot chaser. The callback now accesses Creature AI only when the owner
actually is a Creature. The rebuilt worldserver passed.

The fresh replay in `build/playerbot-smoke-20260924-161324` completed with
three auto-assist engagements, two logged Strike cast starts, three
target-death/cease transitions, and follow movement afterward. Both characters
logged out, the worldserver exited normally, and cloned MySQL logged normal
shutdown. This verifies the level-1 fallback and the chase crash fix in that
play session. It does not yet verify Victory Rush or Rend casts at levels 5/7
or independently measure spell damage.

## PB-02 level-7 Warrior priority play

`SkillLineAbility.dbc` marks Victory Rush (34428) and Rend (772) as
trainer-learned, unlike automatically learned Strike (88161). The
`-CheckCombat -PlayAssist -BotLevel 7` fixture therefore changed only its
cloned, offline Testone row to level 7 and seeded those two trained spells
before starting the worldserver. The clean level-1 seed was untouched.

In the 2026-09-24 live session at Git-ignored
`build/playerbot-smoke-20260924-162202`, the server loaded Testone at level 7
and reported Victory Rush and Rend known. It recorded Rend and Strike against
Springpaw Lynx and Feral Tender, then Victory Rush, Rend, and Strike in that
order against a Tender and later an Arcane Wraith. The bot ceased combat on
target death and returned to follow. Both characters logged out; the harness
exited 0, the worldserver and cloned MySQL shut down normally, and no
test-owned processes remained. Cast-start logs prove core acceptance, not
independently measured hits or damage. This is a validated three-action
priority slice, not the full WotLK Playerbots decision engine.

## PB-02 decision-layer extraction

After the level-7 play session, the same three ordered Warrior actions and
their constant-time triggers were moved out of `WorldSession` into a Warrior
strategy file. A reusable decision evaluator now applies the existing known
spell, cooldown, cast-request, and `Spell::CanAutoCast` checks and begins the
first available action. `WorldSession` retains assist, target, leash, and tick
ownership. Existing CMake build files were regenerated to include the new
sources; the Win64 `RelWithDebInfo` worldserver build passed. The later
level-20 play sessions below exercised the extracted evaluator in game.

## PB-02 level-20 Battle Shout play

The disposable `-CheckCombat -PlayAssist -BotLevel 20` mode now raises only
the cloned offline Warrior to level 20 and seeds Victory Rush, Rend, and
Battle Shout from the pinned trainer-learned spell IDs. The run requires an
auto-assist engagement and a `PB-02: Testone began Battle Shout on Testone`
cast-start log before reporting success; the player must still confirm the
buff effect in the client. The clean level-1 seed is not modified. Both
2026-09-25 runs cloned the cleanly stopped
`build/playerbot-smoke-20260924-161324` level-1 combat seed.

The first live run, `build/playerbot-smoke-20260925-001553`, recorded two
auto-assist engagements, Battle Shout and Rend cast starts in the second,
two target-death returns to follow, and clean worldserver/MySQL shutdown.
The player saw the Battle Shout buff. In the first engagement Testone was
reported stationary while a Mana Wyrm attacked him; the available position
trace shows chase motion with no bot position change for roughly 40 seconds,
but did not record target range or facing. That encounter remains an
intermittent, undiagnosed behavior, not a passed movement check.

The second live run, `build/playerbot-smoke-20260925-002440`, used temporary
one-second combat diagnostics. It recorded nine auto-assist engagements,
one Battle Shout, nine Rends, five Strikes, nine target-death returns to
follow, and clean worldserver/MySQL shutdown. The player reported solid
in-game behavior and did not see the stationary issue recur. Its sampled
combat ticks showed valid facing and line of sight; they cannot establish
the missing state of the first run. The temporary diagnostics and an
unproven turn-to-target change were removed afterward, so neither is being
claimed as a fix. Cast-start logs show core acceptance, not independently
measured spell effects or damage beyond the player-observed buff.
