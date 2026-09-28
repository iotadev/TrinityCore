# Cata Playerbots development starting point

Status (2026-09-26): baseline, PB-00 lifecycle, PB-01 follow/hold, and a
four-action PB-02 Warrior assist slice validated locally. Mage ranged damage
and buffs now have client confirmation. Priest healing casts are logged, but
sustained combat healing remains unverified. The latest mixed-party run ended
on a Testtwo invitation timeout and clean shutdown. Playerbots remains default-off.

Current sequencing and implementation task allocation are in
[`PLAYERBOTS_PORT_ROADMAP.md`](PLAYERBOTS_PORT_ROADMAP.md), with concrete handoff
contracts in [`PLAYERBOTS_WORK_PACKETS.md`](PLAYERBOTS_WORK_PACKETS.md).
That roadmap supersedes older next-step ordering below. Earlier sections retain
historical design and validation states; they are not all descriptions of the
current implementation.

The optional module foundation has now extracted companion behavior/state,
class helpers and development commands into `modules/mod-playerbots`, with
module-owned configuration and tests. Native session ownership, admission and
shutdown hooks remain in core. The upstream Engine/context port is the next
step; packaging does not itself establish that parity. See
`modules/mod-playerbots/README.md` for build/config controls and
`PLAYERBOTS_MODULE_VALIDATION.md` for verification evidence.

## What is established

- Client/core target: Cataclysm 4.3.4.15595, upstream baseline `9da95e6cc9c2`.
- A clean native build and isolated real-client login, character creation,
  movement persistence, and logout succeeded. See `../core/VALIDATION.md`.
- The common-test target now builds and includes navigation-loader regression
  coverage. Remaining baseline warnings are triaged in `../core/CLEANUP.md`.
- Development tests use disposable fixtures; deployed databases and source
  donor checkouts are separate inputs.

## First engineering hurdle: a player without a game-client socket

The current source is not already a server-side Playerbots host:

- `WorldSession` can be constructed with a null socket, but its world-session
  update path returns false when the realm socket is absent. That removes the
  session. Merely constructing a Player and attaching AI will not solve this.
- The normal login path checks account/character ownership, loads characters
  through an asynchronous `LoginQueryHolder`, initializes session/player state,
  and routes client packets. A bot needs an explicit lifecycle integration that
  preserves those checks, not a shortcut around them.
- `PlayerAI` and `SimpleCharmedPlayerAI` contain useful Cata-specific helpers,
  but charm AI is not a bot-account/login/group/command system.
- `src/server/scripts/Custom/custom_script_loader.cpp` is currently empty. It
  can host dev commands later, but script registration alone does not address
  session removal and packet routing.

Relevant entry points:

| Concern | Current source |
| --- | --- |
| Session lifetime and socket removal | `src/server/game/Server/WorldSession.cpp` |
| Account-bound character loading | `src/server/game/Handlers/CharacterHandler.cpp` |
| Session insertion/update ownership | `src/server/game/World/World.cpp` |
| Cata player AI and spell validation helpers | `src/server/game/AI/PlayerAI/PlayerAI.h` |
| AI update/ownership | `src/server/game/Entities/Unit/Unit.cpp` |
| Navigation and following foundation | `src/common/Collision/Management/MMapManager.cpp` and movement code |

The local WOTLK `mod-playerbots` checkout (inspected at `89f7da90`, origin
`https://github.com/mod-playerbots/mod-playerbots.git`) is a reference for bot
holders, asynchronous login, packet handling, and logout. Its current local
files are not assumed pristine, and its AzerothCore interfaces must not be
copied into Cata unchanged. No WOTLK files were modified.

## Proposed milestone PB-00: one idle bot with a complete lifecycle

Keep this smaller than a combat or leveling bot.

Current local prototype: after explicitly setting `Playerbots.Dev.Enabled = 1`,
`Playerbots.Dev.AccountId`, and `Playerbots.Dev.CharacterGuid` for an isolated
ordinary-player account with an offline Warrior, an authorized console
operator can use `.server playerbotdev start`, `status`, and `stop`. These are
manual development controls, not an automatic population system. An isolated
one-Warrior positive-path test passed login, a 125-second idle hold,
save/logout to offline state, and normal worldserver shutdown on 2026-09-23.
Feature-off, unknown-character, wrong-account, wrong-class, banned-account,
already-online, duplicate-bot, interrupted-loading, drain-timeout, and saved
level persistence checks also passed. While the feature is enabled, the
dedicated account is now rejected during authenticated client admission before
a client `WorldSession` is allocated. A real 4.3.4.15595 client collision
replay confirmed that rejection while the bot remained in-world. Normal
shutdown allows up to 30 seconds to drain the bot;
force/exit/process termination does not.

1. Add an explicit, default-off development feature and bot-session identity.
   Do not globally keep every disconnected/null-socket human session alive.
2. Allow a GM/console command to load one pre-created, allowlisted test character
   owned by a dedicated test account. Reject foreign characters and duplicate
   human/bot login attempts. Do not expose raw SQL or shell commands.
3. Reuse the character-loading checks and asynchronous database flow. Give
   bot-only outbound packets an explicit destination/handling policy without
   suppressing errors for normal client sessions.
4. Keep the character alive across normal world updates for at least two
   minutes, with no game client connected for that character.
5. Save and log out cleanly; cover server shutdown and interrupted loading too.
   Prove the session, Player, AI, and pending callbacks have clear owners.

Acceptance checks: feature-off behavior unchanged; one bot limit enforced;
wrong-account GUID rejected; duplicate login rejected; idle bot survives; save
and logout complete; no crash or dangling callback on teardown. Use only the
isolated Cata database/ports for runtime verification.

See `PLAYERBOTS_LIFECYCLE_VALIDATION.md` for the test sequence,
evidence directory, map-530 shutdown fix, and remaining decision gates.

## Subsequent milestones

- **PB-01 Follow/stop:** follow an authorized owner on one known-good starting
  map, then stop immediately on command or owner logout. Log path failures;
  do not compensate by teleporting or disabling collision checks.
- **PB-02 Single-class combat:** one class, auto-attack, and a small reviewed
  spell set. Respect known spells, target legality, range, line of sight, power,
  cooldowns, death, and crowd control. No raids or all-class rotations yet.
- **PB-03 Capability catalog:** pin Cata spell/talent data, generate reviewed
  action proposals offline, and add deterministic tests/replays before enabling
  additional capabilities.
- **PB-04 Addon control contract:** replace the development console-only surface
  with an authenticated, versioned, capability-negotiated addon-message bridge.
  Begin with bot discovery/status plus the already proven start/stop,
  follow/hold, and attack/cease controls. Keep authorization and action
  validation server-side; do not expose an arbitrary command executor.
- **PB-05 Cata control addon:** port the WOTLK MultiBot control experience to a
  separate Cataclysm 4.3.4 addon only after PB-04 is stable. Treat the existing
  WOTLK addon and its `MBOT` bridge as behavioral/protocol references, not as a
  drop-in client. Selectively adapt useful PlayerBotManager roster, gear, spec,
  strategy, and raid-planning views after their corresponding server
  capabilities exist.

LLMs can help author code, data proposals, tests, dialogue, and plans. Runtime
combat actions remain deterministic and validated by the core. Player chat,
model text, and arbitrary spell IDs must not become unrestricted commands.

### PB-04/PB-05 addon-control boundary

Two WotLK addon designs were evaluated as control-interface references:

- `MultiBot` is the broad live-control UI. Its current fork targets interface
  30300 and prefers structured addon messages through a companion bridge with
  explicit capabilities such as `BOT_LIFECYCLE_V1`, while retaining a limited
  set of legacy chat-command paths.
- `PlayerBotManager` is the roster/gear/spec/strategy/raid-management UI. It
  also targets interface 30300, and its current command layer sends party,
  raid, whisper, and admin commands through chat.

The Cata work should therefore port the user workflows, not copy either addon
wholesale. Build the server-side PB-04 contract first, then create a separate
interface-40300 client addon that negotiates only implemented capabilities and
disables unsupported controls. Audit Cataclysm API changes, talents/specs,
classes, spell and item data, roster discovery, equipment slots, saved-variable
migrations, and licensing/provenance before adapting each feature family.

Initial PB-05 acceptance is intentionally small: the addon loads without Lua
errors on the 4.3.4.15595 client, discovers only authorized bots, shows
authoritative online/control state, and can invoke start/stop, follow/hold, and
attack/cease through PB-04 without automated SAY/WHISPER command traffic. It
must time out cleanly when the bridge or a capability is unavailable. Advanced
inventory, talents, professions, quests, formations, raid tools, and bulk bot
population controls remain deferred until their server behavior exists and has
its own deterministic tests.

Use a separate Cata addon project and explicit server capability discovery.
Do not assume that friends-list roster scanning provides an authoritative bot
roster; validate discovery and authorization through the server API.

### PB-01 local follow prototype

With the PB-00 bot in-world and a human character on the same map, enter
`server playerbotdev follow <human character GUID>` in the worldserver console.
`server playerbotdev hold` stops the movement; `status` reports the active
follow GUID or holding state. Commands are console-only. The map update rejects
an absent, dead, or bot target, and holds if the owner logs out, changes map,
or dies. No teleport or combat behavior is added. The command acknowledges a
request; the map-thread log reports acceptance or rejection on the next tick.
The 2026-09-24 local live-client check covered follow/hold/resume commands,
human logout, and automatic hold. The user reported that the in-client behavior
looked good; see
`PLAYERBOTS_LIFECYCLE_VALIDATION.md`.
This uses the core's existing follow generator; route/path-failure diagnostics
are not implemented yet, and the first live check used clear terrain. A later
follow-only replay sampled both characters once per second around the test player's
pillar/stairs route: the largest sampled center-to-center gap was about 9 yards
for one second on the stairs, then it closed. When the owner stopped, the bot
went to a point about 3 yards away, consistent with the configured forward
follow offset and the repeated waypoint-like destination; that offset is now
2 yards behind.
No corrupt map geometry or failed 35-yard combat leash was demonstrated.

### PB-02 controlled Warrior auto-attack prototype

While the bot is following an in-world human, the worldserver console accepts
`server playerbotdev attack`. On the map thread it checks that the human's
selected target is a nearby hostile, non-player-controlled creature with line
of sight. Only then does the Warrior enter the core's ordinary melee auto-swing
and chase. `server playerbotdev cease` stops its attack/chase and resumes
following. `hold` and a new `follow` request also cease combat. The bot ceases
if the target dies, becomes invalid, or exceeds a short leash from the owner.
While engaged, a Warrior evaluates a small priority list once per second:
Victory Rush when its proc is active (level 5), Rend when its applied debuff
is missing (level 7), then Strike (level 1). The core still checks known spells,
range, line of sight, facing, power, and cooldowns; auto-swings continue when
none is castable. This adapts the WotLK Playerbots trigger/action priority
pattern, not its full engine. While following,
the bot also assists the owner's selected hostile creature once the owner is
in combat with it, subject to the same entry checks and 25-yard range. A
manual `cease` disarms auto-assist until a new `follow` request. There is no
independent target search, PvP, a broader class rotation, loot,
or threat policy yet. This is a narrow local prototype, not a complete PB-02
milestone. The 2026-09-24 live-client checks confirmed engagement, cease-fire,
and core acceptance of a Strike cast against a Mana Wyrm. A landed Strike hit
or damage was not independently verified. The target-death stop was verified
in a second live-client run; leash and invalid-target paths remain untested
live, and follow movement after the kill was not independently confirmed. A
later attack-entry rejection was traced to the selected creature being about
35 yards from the owner and 36 yards from the bot, beyond the 25-yard entry
limit; it was not a target-legality or line-of-sight failure.

The 2026-09-24 live-client auto-assist run confirmed Testone joined the
owner's Mana Wyrm fight without a console attack request. The server recorded
Strike, target death, and cease/return-to-follow; the user confirmed the
behavior in game. The disposable realm shut down cleanly. See the validation
log for the retained evidence directory.

The first live-client run with the priority list exposed a pre-existing
`ChaseMovementGenerator::DoMovementInform` null dereference when player-bot
chase arrived: its creature guard was inverted. The callback now safely runs
only for creatures. After rebuilding, a fresh play replay recorded three
auto-assist engagements, two Strike casts, target-death stops, and return to
follow, with clean worldserver/MySQL shutdown. Victory Rush and Rend were
checked against pinned Cata data. A later level-7 play session on a cloned
fixture confirmed both were known and logged successful cast starts: Rend and
Strike in several fights, and Victory Rush before Rend and Strike in two
later fights. The original level-1 fixture was not changed; the level-7
character and trained spells existed only in that disposable clone.

The next code-only pass moved the ordered trigger/action evaluator and common
spell-cast checks into `PlayerbotCombatDecision`, and the Cata Warrior
conditions and priority list into `PlayerbotWarriorStrategy`. `WorldSession`
still owns admission, follow/assist target and leash, and the one-second
decision tick; it no longer contains Warrior spell IDs or cast construction.
The `RelWithDebInfo` worldserver build passed after regenerating CMake. The
2026-09-25 level-20 play sessions replayed this extracted decision layer;
the level-7 evidence above predates it.

The read-only `contrib/local/playerbot-warrior-capabilities.ps1` check now
pins the early Warrior spell IDs, levels, class masks, and acquisition data
against the installed 4.3.4 DBCs. It verifies Strike (1), Charge (3),
Victory Rush (5), Rend (7), Thunder Clap (9), Heroic Strike (14), and Battle
Shout (20), including Rend's cast-spell-to-periodic-aura link (772 to 94009).
Strike, Victory Rush, and Rend are live-tested in the prototype. A later
source-only pass added an explicit self-target action mode and Battle Shout
when the engaged Warrior lacks its own 6673 aura. The pinned data shows the
6673 cast has a self trigger (92049) and two party aura effects. This action
is evaluated only on the existing engaged-melee tick; it does not add
out-of-combat buffing. The 2026-09-25 level-20 live-client replay recorded
Battle Shout cast starts, and the player confirmed the buff appeared. A
second diagnostic replay recorded Battle Shout, Rend, Strike, and repeated
target-death returns to follow with good reported behavior. The first replay
also had one stationary combat engagement before a working second fight; its
cause was not established, and it did not recur in the second replay. Charge,
Thunder Clap, and Heroic Strike remain port candidates requiring movement/entry, area-effect,
and resource/attack-semantics review respectively. The DBC check is
source-side evidence only; it does not replay combat or confirm actions in
game.

The priority/fallback loop is now isolated from spell execution and covered
by three `tests-common` cases: inactive actions are skipped, a failed attempt
falls through in order, and evaluation stops after the first success. All
three passed (five assertions), and the `RelWithDebInfo` worldserver build
linked afterward. These are deterministic selection tests, not spell-cast or
client-behavior tests.

The next PB-02 slice reuses the core-checked spell attempt for a 2-second
out-of-combat Battle Shout check while the Warrior is following. It casts only
when the bot knows 6673 and lacks its aura; the existing combat priority is
unchanged. The `RelWithDebInfo` worldserver build and 20/20 CTest cases passed;
the 2026-09-25 level-20 disposable replay then recorded Battle Shout immediately
after follow and before the first auto-assist engagement. The player confirmed
the buff in the client; one engagement and clean worldserver/MySQL shutdown
followed. Evidence is in `build/playerbot-smoke-20260925-011614`.

The original dungeon-facing prototype accepted an ordinary party invitation only
when its leader is the human player the bot is already following on the same
map. It reuses the core's normal invite-accept handler and does not enable
unrelated invitations, additional bots, or dungeon navigation. The
`RelWithDebInfo` worldserver build and 20/20 CTest cases passed. A 2026-09-25 disposable replay in
`build/playerbot-smoke-20260925-012416` recorded `Testone joined Test's party`,
then an auto-assist engagement and clean shutdown. The server-side invitation
path passed, and the player confirmed the party frame and behavior in the client.

The 2026-09-26 invitation revision removes that preassigned-owner restriction.
Following mod-playerbots' `AcceptInvitationAction`, an ungrouped development bot
accepts a valid human-led invitation through the core handler, adopts that
human as controller, and requests follow when both are alive on the same map.
Invalid invitations are declined through the core handler rather than left
pending. Core party restrictions remain; full PlayerbotSecurity is not ported.
The mixed-party harness does not prebind follow before invitations, and revives
the saved roster through the native command before starting the test. Runtime
confirmation of this revision is pending.

For a first dungeon-entry proof, `server playerbotdev joininstance <map ID>`
requests a console-only transfer after the human-led party has bound that
non-raid dungeon. The bot validates that it is alive, out of combat, and still
grouped under its previously followed leader. It uses the configured map
entrance and normal `Player::TeleportTo`/worldport-ack path, then requests
follow again in the destination map. A short-lived remembered leader GUID
allows the same owner's invitation to be accepted even if the owner changed
maps before inviting; explicit hold or a failed new follow clears that memory.

The first disposable test (`build/playerbot-smoke-20260925-013921`) did not
enter a dungeon: a long coordinate command placed the human high on the
outdoor map, and the bot correctly rejected an unbound instance request. A
second run (`build/playerbot-smoke-20260925-014742`) reached the named
teleport before the party invite; it exposed the order-sensitive invitation
check and shut down without a dungeon transfer. The harness now uses the
short `.tele RagefireChasm` command, waits for a real party instance bind,
and accepts a late invitation from the same followed leader.

The 2026-09-25 successful replay in
`build/playerbot-smoke-20260925-015556` recorded party join, target-map
transfer to Ragefire Chasm (map 389, instance 1), resumed follow, and clean
bot/worldserver/MySQL shutdown. The player confirmed Testone appeared in the
dungeon and followed. This verifies one-bot entry and regroup, not dungeon
combat, survival, route planning, or general multi-bot support.

A follow-up disposable replay in `build/playerbot-smoke-20260925-020423`
recorded Testone joining the party, entering the same Ragefire Chasm
instance, auto-assisting against a Molten Elemental, and starting Rend and
Strike casts there. The player reported that the in-game behavior worked;
both characters later died. The bot, worldserver, and cloned MySQL shut down
cleanly. This verifies dungeon entry plus a combat engagement, not dungeon
survival, death recovery, route planning, or repeatability across dungeons.

A second explicit bot slot is available through default-zero
`Playerbots.Dev.AccountId2` and `Playerbots.Dev.CharacterGuid2`, with matching
console-only `start2`, `stop2`, `status2`, `follow2`, `hold2`, `attack2`,
`cease2`, and `joininstance2` controls. Two more default-zero slots use the
same `AccountId3`/`CharacterGuid3` and `AccountId4`/`CharacterGuid4` pattern;
the console-only `server playerbotdev slot <1-4> <action> [argument]` command
controls all four. Every account and character GUID must be distinct; no slot
admits a GM, banned account, online character, or a class without a bot
strategy (currently anything except Warrior, Mage, and Priest). All configured
dedicated accounts are reserved against client login while the feature is
enabled. This is a fixed full-party development path, not a general bot
population manager.

The isolated `build/playerbot-smoke-20260925-021701` run logged both Warriors
in simultaneously, stopped and restarted the second without disturbing the
first, and drained both during normal shutdown. The `RelWithDebInfo`
worldserver build and 20/20 CTest cases passed. That early two-bot run did
not yet cover party invitations, simultaneous combat, or dungeon entry; the
four-bot replay below later covered those paths.

For the four-bot replay, the isolated harness uses the core's `pdump`
write/load commands to make three disposable Warrior imports with new
accounts/GUIDs, then starts all four sessions. That preparation exposed an
older PlayerDump null-field bug: its importer changed a quoted `nullptr`
placeholder into the bare token `nullptr`, which MySQL rejected and caused a
worldserver assertion. The narrow repair converts that placeholder to SQL
`NULL` after dump field rewriting. The fresh-clone replay
`build/playerbot-smoke-20260925-093255` completed three imports and admitted
all four Warriors. The client did not log in before that run's ten-minute
window elapsed; its test-owned processes shut down cleanly.

The follow-up client replay in `build/playerbot-smoke-20260925-094634` reused
the stopped fixture. Testone, Testtwo, Testthree, and Testfour all followed
the human Test, accepted party invitations, and entered the same Ragefire
Chasm instance (map 389, instance 1). All four auto-assisted a Molten
Elemental and an Earthborer, with Rend and Strike cast starts recorded.
Testone then died and ceased attack/held; the other three continued combat.
When Test died, all three surviving bots held. The player confirmed the logs
matched the visible behavior. Human and bot logouts, worldserver exit, and
cloned MySQL shutdown completed cleanly. This proves one full-party encounter
and death transitions, not resurrection/recovery, a dungeon clear, class-role
coverage, or reliable navigation across dungeons.

Playerbots architecture direction: the four explicit slots and console
commands are a lifecycle/test harness, not the desired gameplay design. Keep
the Cata core changes to socketless session, admission, and safe lifecycle
hooks; move follow formation, party interaction, and later class/role behavior
into bot strategies/actions modeled on the local WOTLK `mod-playerbots`.
Source examples: `Formations.cpp` computes per-bot angles from the group
roster, and `AcceptInvitationAction.cpp` accepts the invite, changes to follow
strategy, then optionally sends the master a configurable greeting. Adapt
those responsibilities to Cata APIs rather than copying WOTLK code blindly.
The client-visible polish observed in the full-party pass is therefore real
Playerbots work. The 2026-09-25 client replay confirmed four distinct follow
positions after party join and one hello whisper per bot. The player then
pointed out that spacing must begin on attachment, not party join. The
follow-up source change now derives formation slots from same-map bots
attached to the same owner, whether or not they have joined a party; this
specific pre-invite revision is built and unit-tested, not yet client-tested.

The same batch adapts two other local WOTLK Playerbots movement ideas to Cata:
long-gap follow switches at 18 yards to a path-generating point move and
returns to normal follow within 12 yards, while melee Warriors chase behind
a target unless they have aggro, when they take a front/tank position. Cata's
native `MoveFollow` and `MovePoint` use different movement generators, so
this is an adapter, not a copied WOTLK pathing implementation. The original
pillar/navmesh bounce and these new dynamic behaviors still need a later
in-game observation; a successful compile is not navigation proof.

The next mixed-role source batch broadens the allowlisted bot classes from
Warrior-only to Warrior, Mage, and Priest without weakening account, offline,
security, or duplicate-session admission checks. Mage uses the shared Cata
cast validator for a small Frostbolt/Fireball ranged priority with Fire Blast
and Frost Nova under close pressure. Priest scans the attached owner and its
shared same-map party in lowest-health-first order, excluding unreachable
members and duplicate candidates. It selects Shield, Flash Heal, Heal, or
Renew by severity, tries another injured member if no cast is accepted, and
stops after one accepted cast. Automated tests cover health ordering, failed
cast fallback, equal-health ties, empty candidates, and invalid health values.
The pinned 4.3.4 DBC confirms
these spell IDs, Mage/Priest class masks, and early trainer levels. These are
initial roles, not WOTLK-equivalent talent builds, threat control, kiting, or
complete healing. No mixed-role client behavior is claimed yet.

Remote follow-up adds out-of-combat Fortitude (21562) and Arcane Brilliance
(1459) upkeep for self, attached owner, and their shared reachable party.
The core's generic buff script converts these casts into single/party auras
79104/79105 and 79057/79058 respectively; upkeep checks both variants rather
than the dummy cast ID. `contrib/local/playerbot-caster-buffs.ps1` verifies
their Cata levels, class masks, and effect mappings without starting a realm.
These buffs and the mixed-role combat still need client validation.

Rotation development must use the bot's active talent tree, learned spells,
and current proc/resource state, not class alone. Cata exposes
`GetPrimaryTalentTree(GetActiveSpec())`; `PlayerAI::GetPlayerSpec` resolves its
TalentTab order but returns zero for an unset tree too. Preserve an explicit
unspecialized fallback instead of silently assigning the first spec. The next
profiles should separate Arcane/Fire/Frost Mage, Discipline/Holy/Shadow Priest,
and Arms/Fury/Protection Warrior priorities. Armor selection, role selection,
and signature/proc actions belong to those profiles; the current starter
lists are not complete spec rotations or automatic talent allocation.

## Next integrated Playerbots slice

### Long-term target: WotLK Playerbots feature parity

Playerbots should eventually have an identifiable optional module directory
and module-owned configuration, with only necessary integration hooks in the
core. Use TrinityCore's existing script/build facilities and suitable
AzerothCore module conventions rather than making a general plugin framework
a prerequisite. AHBot stays native to TrinityCore; extracting it into an
external module is not part of this plan. The mixed-role live test precedes
the Playerbots packaging refactor so its behavior can be checked afterward.

The target is a Cata adaptation of the local AzerothCore Playerbots feature
set, not merely socketless companions attached to a human. This includes
managed account/character creation, population login/logout scheduling,
independent world activity, progression/questing, and group/dungeon behavior.
Existing companion tests prove reusable foundations, not a limit on scope.

Prefer adapting identifiable upstream components and retaining their names,
responsibilities, and provenance over inventing parallel systems. Keep Cata
core/data/API differences in narrow adapters; similar architecture does not
mean rewriting TrinityCore to imitate AzerothCore's internals or importing
WotLK quest, item, spell, or navigation data.

The next enabling port should be a bounded account/character factory based
on `RandomPlayerbotFactory`, before adding more manual client fixture setup.
Both cores provide `AccountMgr` creation and `Player::Create`; Cata's native
creation path also owns transactional character saves, realm character
counts, character-cache registration, and creation hooks. Preserve those
invariants rather than synthesizing characters with SQL row copies. Begin
with explicit creation of a small managed roster, then reuse it for the
mixed-role playtest. Reruns must recognize existing managed characters,
avoid unrelated accounts, and never delete a population automatically.

Follow with adaptations of `PlayerbotFactory` for spells/talents/equipment
and `RandomPlayerbotMgr` for bounded independent login/logout scheduling.
Companion and autonomous modes should share the same AI context and class
actions; an owner command is an input to that AI, not a prerequisite for
every decision. Introduce autonomous behavior with a small default-off
population, then port questing/progression and dungeon layers in substantial
testable slices. The full feature-parity target is not claimed implemented.

The full-party replay is the structural gate for this phase: four socketless
sessions, distinct account ownership, ordinary invites, common dungeon
instance, shared Warrior combat, death hold, and clean teardown all ran in a
real client. More isolated proofs of those same hooks have diminishing value.
The remaining gaps are primarily absent bot behavior, not unexplained core
failures. In particular, the current death hold clears the active follow
target; it does not implement corpse release, resurrection, or regrouping.

Port one substantial vertical slice from the local GPLv2 WOTLK Playerbots
architecture, with Cata-specific adapters rather than a wholesale file copy:

1. A per-bot AI context with trigger/action/strategy/value boundaries, driven
   by the existing server-origin session tick. Keep the core-owned session,
   admission, and teleport hooks narrow and default-off.
2. Group behavior: invitation acceptance and configurable greeting, distinct
   roster-based follow positions, regroup/hold, and controlled dungeon join.
3. Death behavior: stop combat, recognize a living/ghost owner, accept a
   resurrection, and use a bounded corpse/graveyard recovery path with a
   human-controlled stop. Do not silently teleport a dead bot into combat.
4. Combat roles: the Cata-checked Warrior, Mage, and Priest starter actions
   now share the same spell validation path. Continue toward actual tank,
   caster, and healer class identity through role actions and triggers. Audit
   each imported WOTLK spell/action for Cata ID, talent, resource, range, and
   packet differences before enabling it.

Build and deterministic action-priority tests should run during the port, but
the next client acceptance pass should cover several newly ported behaviors
together: pre-invite spacing, path catch-up, melee stance, then mixed-role
pulls and recovery. Do not gate each source adaptation on another isolated
client run. A full clear and general dungeon planner remain later milestones.
This deliberately avoids treating all 1,000-plus WOTLK AI source files as a
drop-in Cata implementation.

## Lifecycle audit comparison

The public `playerbots-434` lifecycle audit has now been checked against this
exact checkout. Its world-owned, explicitly socketless `WorldSession` approach
is a good fit for the one-account/one-character PB-00 proof, with important
local constraints around asynchronous session initialization, same-account
session replacement, map-thread command delivery, and shutdown ordering.

See `PLAYERBOTS_LIFECYCLE_COMPARISON.md` for the source evidence,
open decisions and the PB-00 decision gate.
