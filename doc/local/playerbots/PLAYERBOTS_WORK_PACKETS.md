# Playerbots development handoff

Updated 2026-10-09. Start here. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns
priorities; module [PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns
donor pins, adaptations and dated implementation/build evidence. The
[party fixture](PLAYERBOTS_PARTY_FIXTURE.md) owns the test recipe.
Older chronological handoff detail is preserved in
[handoff history](PLAYERBOTS_HANDOFF_HISTORY_2026-10-08.md), not the resume sequence.

## Current state

- Core checkout: `TrinityCore-publication-candidate`; independent module:
  `modules/mod-playerbots`. Both use `work/managed-roster`.
- The October 9 release packages the earlier gear/loot work, quest controls and
  optional observer hooks. The core README owns the matching module pin.
  Previous publication was core `eee1755104` / module `9f99b27`; historical local
  gear/loot commits were `bb8c37e2b4` / `40f5f7d`.
- Complete current Windows/Linux full-script worldserver/tests-common builds
  passed **431/431** each, including per-player quest loot and observer additions.
  Fresh Windows all-three-modules-off passed **19/19** after current core repairs.
  The companion's reader suite passed **43/43**. Dated intermediate qualification
  and build-collision recovery remain in PORTING.md.
- Builds and test realms are stopped; the Linux compiler container is stopped.
  Corrected quest realm `build/playerbot-smoke-20261008-215311/`
  completed four bot accepts, objective progression and Testone's explicit
  turn-in, with native saved reward presence. Earlier attempt `214726` aborted
  on port contention and stopped. The companion selected separate runtime ports.
  Preserve companion services; never issue SQL to an unknown listener.
  Linux server runtime remains
  untested. Recheck processes/listeners before starting a copied realm; unrelated
  Docker, model and other-project workloads are outside this task.
- Current donor item/quest source is pinned at
  `037c01418b5d01506917a3db9b44fd56ac5f965c`. It was rechecked against remote master
  for these batches. Check current upstream for the next port and record the
  exact revision; do not use a stale local WotLK checkout as the default reference.

## Connected capabilities

Published infrastructure includes optional modules, native asynchronous bot
sessions, managed rosters, bounded character creation, MultiBot lifecycle/control
and shared combat/noncombat/dead engines for Warrior/Mage/Priest.

Local source adds party tank/DPS/healer coordination, targeting and movement,
recovery, buffs, interrupts and native corpse opening. The inventory chain has
consumable stock, copied stat facts, starter scoring for eight specs at levels
10–39, `gear?`, explicit one-slot `gear apply`, shared item usage and guarded
native party votes. Actual native loot affixes can be compared when their
property/suffix/factor and effects are qualified. Unknown is not a negative fact.
Automatic equipment management, vendor/profession/token/disenchant classification
and broader class/spec coverage remain separate.

### Human-led quest controls

All quest gates default off. Commands use copied bounded intent and fresh native
authority/state/location checks, not direct database edits. Quest/item links are
accepted where an ID operand is shown; links supply IDs, not eligibility or
actual item-affix proof.

| Command/flow | Gate suffix under Playerbots.Quest | Scope |
| --- | --- | --- |
| Native incoming share / party-pushed confirmation | AcceptShared.Enabled | Current controlled human, native pending state and admission |
| `accept <quest>` / `accept *` | AcceptNpc.Enabled | Selected nearby giver; batch snapshots at most 25 native offers and revalidates each |
| `quests [all\|completed\|incompleted\|summary]` | Inspection.Enabled | Native active status and objectives; completed/co and incompleted/in filter details, summary omits details |
| `reward <quest> <item>` | Reward.Enabled | Ordinary completed non-repeatable quest; explicit item, native grant checks; numeric item 0 only for no choices |
| `reward *` | Reward.Enabled | Up to 25 active IDs at selected giver; reward completed zero/single-choice quests, skip multiple choices, revalidate each |
| `share <quest>` | Share.Enabled | Whisper one bot; native party offer, not recipient acceptance |
| `drop <quest>` | Abandon.Enabled | Whisper one active quest; destructive native abandonment, not rewarded-history reset |
| Human quest-class corpse-loot priority | SyncLootWithPlayer.Enabled | Skip competitive bot pickup while human need remains; native per-player drops exempt, no reservation |

The native confirmation repair captures the sharer GUID before clearing sharing
state. It affects human clients too and retains all native party/active-quest/
admission checks. Its source-order guard is not gameplay proof.
The native sharing availability rejection is also corrected: active and ordinary
non-pooled quests must not be rejected as unavailable. This retains native share
eligibility; the corrected ordinary-share path now has a four-bot client replay.
Inactive pooled-quest rejection and party-pushed confirmation remain unobserved.

Reward-choice ranking is a map-owned read dependency. Cached recommendations
are not mutation authority. Template admission can create/delete a transient
native Item and consume a GUID without storing/saving an inventory item.

There is no automatic quest travel, forced completion, NPC discovery, chain
rescanning, automatic multiple-choice reward selection, master-progress synchronization or
new bot-to-bot consent. Native auto-accept quest flags retain their core behavior.
Normal chat/link compatibility is not a LANG_ADDON/MultiBot quest UI port.

## What runtime evidence establishes

- Existing outdoor/Ragefire replays observed party engagement, support,
  target-death transitions, corpse opening, eating/drinking and owner-death
  hold/resume. This is useful party operation, not a full clear or broad parity.
- One empty-waist equip change saved with owned item identities/properties intact.
  Occupied-slot displacement and relogin remain unobserved.
- Controlled native loot replay observed Testone need, Testtwo greed, caster pass
  and one saved award. Do not repeat that isolated fixture merely to continue.
  Natural-affix decisions/awards remain unobserved.
- The corrected October 8 quest replay observed all four ordinary native accepts
  of 9156, inspections and objective progression. Testone's explicit turn-in was
  confirmed, with saved rewarded history and one owned 22979 after shutdown.
  The other bots remain complete/unrewarded. Party-pushed confirmation, outgoing
  offers, links, reward batches and abandonment remain source-qualified only.
  No quest was dropped.
  Exact reward contents, persistence and relogin require native evidence.
  Human-needed head deferral was logged; the new per-player exemption is not
  yet live-qualified. Native loot eligibility remains independent.

## Next two batches

1. Use the native `.group summon Test` path for the next same-map outdoor fixture
   instead of four manual summons, checking actual arrival. It exists already and
   has not been live-qualified with this bot party; do not invent another command.
   Keep dedicated dungeon entry for cross-map/instance transfer. Continue donor
   behavior ports and a useful human-led dungeon replay rather than tiny per-command
   tests; observer/MCP expansion remains need-driven.
2. Target connected donor NPC/quest interaction or observed tank/healer/inventory
   needs. The bundled real-quest check is complete; unobserved batch/link/party-push/
   relogin/affix cases are deferred coverage, not reasons to repeat it. Keep optional
   diagnostics truthful and native ownership intact. Milestone publication uses
   iotadev and the publication remotes, never the module's local-path origin.

Development can continue offline while the replay is pending. Do not invent
completed playtests, use queued replies as outcomes, or force additional telemetry
checks merely to obtain a clean report.

## Fixture and build rules

- Use a clean stopped copied seed. The controlled-drop seed is not a normal
  replay baseline; the accepted pre-farming seed is
  `build/playerbot-smoke-20261006-113536/`.
- QuestFixture requires the reused interactive recovery/mixed-party module
  recipe; it resets all quest gates. Abandonment stays off unless the separate
  `-QuestAbandon` opt-in is explicitly supplied. It is not a normal-test requirement.
- `quest-state-result.json` captures saved active states; the separate
  `quest-reward-state-result.json` captures rewarded history, inventory-mapped
  totals (including bank), level/XP/money after clean shutdown. Deltas may include
  ordinary gameplay. Neither report proves causation, item properties or relogin.
- Confirm group, identity, map/instance, native phase/eligibility and suitable
  level/gear/consumables before diagnosing behavior. Stage at Tranquillien with
  durable enemies. Dedicated `joininstance` completes bot entry into the party's
  Ragefire instance; ordinary cross-map summons are not equivalent.
- Build complete bounded batches. New source/test files require explicit CMake
  configuration; “Checking File Globs” is not proof of discovery. Use the existing
  build wrapper and process-local compiler options, not global PATH changes.
  The wrapper holds an exclusive per-output-directory lock through configure,
  build and tests; raw CMake and already-running older wrappers are not fenced.
  Never overlap writers to the same Windows output tree. After C1041 contention,
  serialize first and use process-local /FS if needed, not deleted PDBs or global
  compiler environment changes.
  Refresh the Linux snapshot before validation and stop its compiler afterward.
- Keep map-engine reads on their owner; world/group/native handlers retain
  mutation ownership. Never retain live Group/Roll/game pointers across threads.
  Native vote masks/lifetime/not-yet-voted fencing are required beyond merely
  calling CountRollVote.
- Keep public docs portable and ignored runtime evidence local. No Linux client
  compatibility work is required.

## Read-only context companion

Canonical code/docs live in workspace-relative `CATA/cata-context-api/`.
The optional linked mod-context-api is integrated; CLI/loopback queries are
read-only. MCP, write controls and independent client observation are not shipped.

The five-character Ragefire capture completed with combat/offline/stopped
observations, but counted 434 stale online entity polling observations. Maximum
sample skew was 4034 ms; query time is not native sampling overhead. The original
report lacks a gap timeline, so its totals do not establish a cause. The improved
bounded monitor passed all 23 Python checks and can join the next useful replay.

Before using telemetry, check boot/session identity, per-entity age and skew.
Configured scope is not guaranteed complete party discovery; selected target is
not necessarily attack victim; active-engine last action is historical; queue
count does not enumerate all native/control requests. Missing/stale data remains
explicit. Do not start a second realm on another task's listeners.

Observer development is not a gameplay dependency. Next use the improved
freshness reporter in an ordinary party replay; its 23 reader checks passed
again on October 8, without a realm. If a real diagnosis needs more context,
prioritize native phase and attack-victim/facing facts, then bounded action
admission/rejection history. The October 8 fixture already exported optional
phase/engagement diagnostics and observed mutual peer-phase visibility. The
companion qualified bounded action-history publication and logout/shutdown
archive behavior in its separate headless fixture, with 43 reader tests. That
does not prove asynchronous completion, live rejection coverage or landed spells.
Consult its current contract and validation instead of treating this handoff's
older query summary as complete. Exporter/query source is not part of this paired
core/Playerbots publication.
Do not infer
attack victim from selected target or add MCP/control infrastructure just to
continue porting. Keep any schema/ownership changes in the companion project.

## Evidence pointers

| Local ignored evidence | Scope |
| --- | --- |
| `build-both/Testing/Temporary/LastTest.log` | Latest Windows 431-test pass, including observer additions |
| `build/linux-release-20261009/LastTest.log` | Complete current Linux 431-test pass; compiler stopped |
| `build-core-only/Testing/Temporary/LastTest.log` | Fresh Windows all-three-modules-off 19-test pass after current core repairs |
| `build/playerbot-smoke-20261008-212331/` | Human quest acquisition and four inspections; failed share; clean shutdown |
| `build/playerbot-smoke-20261008-215311/` | Four bot shares/progression, Testone turn-in and saved 22979; clean shutdown |
| `build/playerbot-smoke-20261006-113536/` | One native equip change and saved item preservation |
| `build/playerbot-smoke-20261006-233354/` | Controlled need/greed/pass and saved award; modified seed |
| `build/playerbot-smoke-20261007-164901/` | Ordinary Ragefire operation, stopped capture and freshness gaps |

Older dates, intermediate counts and detailed adaptations belong in PORTING.md,
the existing development/milestone history and the archived handoff.
