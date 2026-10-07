# Playerbots development handoff

Updated 2026-10-07. Start here. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns
priorities; module [PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns
donor pins, adaptations and dated implementation/build evidence. The
[party fixture](PLAYERBOTS_PARTY_FIXTURE.md) owns the test recipe.

## Resume state

- Active core checkout: `TrinityCore-publication-candidate`; the independent
  module repository is `modules/mod-playerbots`. Both use `work/managed-roster`.
- Published baseline: core `eee1755104`, module `9f99b27`. The local gear/loot
  milestone module is committed as `40f5f7d`; the matching core milestone records
  that exact module revision in its README. Neither new milestone has been pushed.
- Current Windows source: worldserver/tests-common, **384/384 tests**, including
  controlled-fixture preparation and deferred evaluation during combat/casting.
  No build remains pending. Four mocked controlled SQL checks also passed.
- Current Linux source also built and passed **384/384 tests**, including the
  shared usage/template/roll and controlled-fixture changes. Its compiler container
  is stopped. Current Windows core-only worldserver/tests-common passed **19/19**
  with both optional modules disabled. Linux runtime remains untested.
- The copied replay `build/playerbot-smoke-20261006-224959/` completed and exited
  zero and its Cata services stopped. Logs show
  four-bot dungeon entry, normal role actions and 12 native pass submissions
  across three rolls, with no duplicate bot/roll submission. Need/greed and native
  winning-item award were not observed in that natural-drop replay. The later
  controlled replay `build/playerbot-smoke-20261006-233354/` passed: Testone need,
  Testtwo greed, caster pass on one roll, and saved stock increased by one.
  Player feedback confirms expected behavior. All Cata services and the Linux
  compiler are stopped; no build is running.
  Recheck service state before another realm;
  unrelated Docker/AI workloads are outside this task.
- Outgoing review included tracked/new files in both repositories, core/module
  boundaries, native vote fencing, source provenance and a targeted credential/
  host scan. No new blocker was identified. Local milestone commits are prepared
  with the iotadev identity; no remote publication was performed.

## What is already implemented

The published infrastructure and shared combat/noncombat/dead engines remain the
base. Local coordination adds explicit/fallback main-tank selection, target
retention, no-steal guards and active auto-assisted DPS reassessment. Explicit
commands, active casts and native admission retain their existing authority.

The local inventory dependency chain is:

- Consumable stock and native base/flat-effect/enchantment readers, with affix,
  socket and set context. Unsupported/conditional/proc inputs remain explicit.
- Default-off starter scoring and carried-equipment comparison for the eight
  implemented specs at levels 10–39. These are donor heuristics with documented
  Cata adaptations, not endgame tuning.
- Authorized `gear?` reads an immutable map-published survey. Explicit
  `gear apply` queues copied requester intent, rechecks authority/state and
  inventory on the map, and confirms at most one native slot change.
- Shared `item usage` composes consumable/carried facts. Separate
  `template equipment comparisons` and `template item usage` handle non-affixed
  unowned templates. Native CanEquipNewItem creates/deletes a transient Item for
  admission, without storing or saving it; it can consume a native item GUID.
- Optional native voting now connects donor policy through copied pending-roll
  requests, map evaluation and guarded world/group submission. It remains
  default-off; the controlled supported need/greed/pass/award check passed.
  Broader runtime coverage remains pending; Linux source validation passed.
  Template scope and a usage
  category alone do not establish actual loot identity.

StarterScore and StarterEquip remain default-off. Coupled hand changes, incomplete
instance inputs and unproven affixes stay Unknown. Profession, quest/master sync,
token, vendor/AH and disenchant classification remain unported.

## Next implementation batch

The connected optional loot path for supported non-affixed items is implemented;
its final Windows/Linux builds passed 384 checks and Windows core-only passed 19.
The controlled replay has established
the supported decisions and saved award, following the earlier natural pass-only
replay. The outgoing review and local milestone are complete; no repeat
of the same controlled test is needed. Preserve this scope before
expanding scoring or individual class spells. The controlled recipe is now
implemented: add `-ControlledLootRoll` to the reused recovery/dungeon/roll replay.
It prepares the native role fixture, preserves Testone's chest in a bag and makes
Oggleflint drop one chest 2866. Testone should need, Testtwo should greed, and the
human should pass; verify the saved award. Only the copied creature loot source
changes, with preconditions and a recorded original ID. Windows and the controlled
replay passed, using the clean pre-farming seed
`build/playerbot-smoke-20261006-113536/`. The adapter queues through temporary combat/cast
locks so native armor admission can run once idle. The implemented sequence is:

1. Resolve an actual native pending roll and copy the item/roll identity needed for map
   evaluation. Retain explicit scope and freshness; carried or hypothetical
   template results must not silently become proof of a dropped instance.
2. Evaluate supported usage through the existing readers. Define a conservative
   explicit fallback for unsupported items; broader classification can follow.
3. Submit through the native world/group owner after fresh membership, roll
   lifetime, pending-vote and allowed-choice checks. Ensure at-most-once submission.
4. Five mailbox/admission regressions cover expiry, changed identities, duplicate/
   late completion, refreshed native choice masks and cancellation. The native
   gameplay outcome remains to be observed.

Gate `Playerbots.Loot.Rolls.Enabled` requires StarterScore and is suppressed by
PassOnGroupLoot. The fixture switch `-LootRolls` requires `-RecoveryLoot
-DungeonFixture -ModuleConfig`; use normal Group Loot and a qualifying drop.
Unsupported/random-affix items pass. World polling is one second, with one
outstanding request and a five-second expiry. `PB-ROLL` is submission evidence;
observe the actual native vote/outcome before claiming runtime acceptance.

Cata CMSG_LOOT_ROLL is PROCESS_THREADUNSAFE. Group::CountRollVote increments totals
without checking NOT_EMITED_YET or the vote mask at that call boundary. Dispatching
a native packet alone does not supply those guarantees. Do not reuse the map-owned
equip seam, iterate live Group/Roll state from a map update, or carry native
pointers across updates/threads. Keep new core integration narrow.

Donor behavior for the current item batch is pinned at
`037c01418b5d01506917a3db9b44fd56ac5f965c`. Consult current upstream master for
new porting work, then record the exact revision and Cata adaptations.

## Validation and milestone

Build once for the complete bounded batch. New source/test files require explicit
CMake regeneration: use `contrib/local/build-local.ps1 -Configure` with the
existing `build-both` directory. Existing-file changes can omit Configure.
Do not infer new-file discovery from “Checking File Globs.” Refresh the existing
Linux source/build snapshot before its next build and stop its compiler container
afterward. Schedule that pass with available resources; preserve unrelated services.

Use one bundled copied-realm party/loot check when the feature is connected.
Observe a supported native vote outcome and ordinary party operation. If useful,
combine occupied-slot equip/relogin and strategy ACK/STATE/restore. No forced wipe,
isolated spell checks or broader item-model qualification is required for this batch.
Then review docs and outgoing core/module changes and take the milestone commit.

Continue the human-led dungeon toward a clear after that batch. Multi-tank behavior,
detailed facing, quantitative healer savings and broad class/spec coverage remain
open; infrastructure should not be reopened merely to continue feature porting.

## Useful local evidence

Paths below are ignored build evidence, not distributed runtime requirements.

| Evidence directory | What it establishes |
| --- | --- |
| `build/playerbot-smoke-20261005-113123/` | Party recovery, native drink starts, repeated heals/tank recovery and owner-death hold/resume; clean shutdown |
| `build/playerbot-smoke-20261005-163042/` | Arms/Mage reassessment, tank rescue and healing in one Ragefire instance; successful player report |
| `build/playerbot-smoke-20261006-092902/` | Testone's four-row read-only gear report; clean shutdown |
| `build/playerbot-smoke-20261006-113536/` | One empty-waist move, native completion and saved item preservation; harness exited zero |
| `build/playerbot-smoke-20261006-224959/` | Normal party combat and 12 native pass submissions over three rolls; clean shutdown; need/greed/award deferred |
| `build/playerbot-smoke-20261006-233354/` | Controlled native need/greed/pass on one roll; saved award to Testone; clean service shutdown |
| `build/linux-native-loot-20261007/LastTest.log` | Current Linux worldserver/tests-common pass, 384 tests; compiler stopped |
| `build-core-only/Testing/Temporary/LastTest.log` | Current Windows build with both optional modules disabled, 19 tests |
| `build-both/Testing/Temporary/LastTest.log` | Latest local Windows test run; currently 384 tests, overwritten by later runs |

The native equip check does not establish relogin or occupied-slot displacement.
The earlier dungeon-entry failure was a harness/transfer-path mismatch, not proven
phasing. Use `-RecoveryLoot -DungeonFixture` for the dungeon recipe; confirm all
four arrivals through dedicated `joininstance`. Ordinary cross-map `.summon`
does not supply the bot transfer acknowledgement path.
