# Archived Playerbots handoff — 2026-10-08

This preserves the pre-consolidation notes as historical evidence. Build/process
states and next-step instructions below may be stale; use PLAYERBOTS_WORK_PACKETS.md
for the current resume sequence and PORTING.md for dated provenance.

# Playerbots development handoff

Updated 2026-10-08. Start here. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns
priorities; module [PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns
donor pins, adaptations and dated implementation/build evidence. The
[party fixture](PLAYERBOTS_PARTY_FIXTURE.md) owns the test recipe.

## Resume state

- Explicit `accept *` is now in source under existing AcceptNpc, snapshotting at
  most 25 native offered-menu IDs from the selected nearby giver. It rechecks
  authority/state/interaction/location/request age per candidate and calls typed
  native acceptance; callback menu/transfer changes cannot reuse old iteration
  pointers. Partial counts are reported without rollback/retry. Two tests added.
  Linux passed 417/417 and its compiler stopped; Windows 78334 is running.
  No core/API change or realm started. Live batch acceptance remains unqualified.
- Quest command link compatibility is in source: accept/share/drop take numeric
  quest IDs or native quest links; reward takes numeric or typed quest/item links.
  It uses native hyperlink framing with strict bounded ID extraction and preserved
  |H markup, rejecting wrong types/trailing text. Existing permissions/handlers
  and whisper-only share/drop scope are unchanged. Linux passed 415/415 and its
  compiler stopped; Windows also passed 415/415. No compiler is running. No core/API changes or client
  replay. Numeric commands remain supported; links are intent, not instance proof.
- Explicit active `drop <quest ID>` is in source under default-off independent
  Playerbots.Quest.Abandon.Enabled. Whisper-only; current log slot is resolved
  after authority/state/map checks and native abandonment owns all item/PvP/
  timed/script effects. No bulk cleanup or rewarded-history reset; no quest was
  abandoned. Two tests added. Linux passed 413/413 and its compiler stopped;
  Windows also passed 413/413. No compiler/realm is running. Normal QuestFixture keeps this gate off;
  separate -QuestAbandon is required for any later copied-realm check.
- Outgoing `share <quest ID>` whisper is in source under default-off
  Playerbots.Quest.Share.Enabled. One controlled bot submits through native Cata
  party sharing after ownership/control/CanShareQuest checks. Submission is not
  acceptance; no auto-share, bot-to-bot consent or core bridge change. Linux passed
  411/411 and its compiler stopped; Windows also passed 411/411. No compiler or realm
  is running. The prior core-off 19-test pass applies to unchanged core files.
- Party-pushed confirmation support is now in source under AcceptShared.
  Native pending state selects ordinary vs typed confirmation; human control,
  group/active quest and native admission checks remain. A narrow QuestHandler
  repair preserves the sharer before clearing native sharing state, fixing an
  existing empty lookup. Human confirmations are affected too. Two routing tests
  and a source-order/guard regression were added; the environment suite passed.
  Windows/Linux built with 409/409; Linux compiler stopped. Fresh Windows
  all-modules-off validation also passed 19/19. No compiler or realm is running. Confirmation
  gameplay/persistence remains unqualified.
- `quests` read inspection is now implemented behind an independent default-off
  Playerbots.Quest.Inspection.Enabled gate, using donor ListQuestsAction semantics
  and native status/counters/carried counts/reward IDs. No quest mutation or new
  core header/hook. Inspection shares the bounded request channel but allows
  combat/dead/share-dialog reads while preserving authority and transfer guards.
  Windows/Linux full-script worldserver/tests-common passed 407/407; Linux compiler
  is stopped, with evidence in build/linux-quest-inspection-20261008/LastTest.log.
  Fresh Windows all-modules-off validation passed 19/19 for the forwarding
  implementation change. No compiler or realm is running. Live read/gameplay
  remain unqualified; the source-qualified report can join the bundled replay.
- Explicit reward execution is now in source behind Playerbots.Quest.Reward.Enabled.
  Command: reward <quest ID> <item ID>, with item zero only for no-choice quests.
  Native slot resolution, completed ordinary quest state and native reward checks
  are revalidated at execution; no cached ranking or direct RewardQuest grants.
  The unpublished bridge is now RequestPlayerbotQuestCommand for both operations.
  Windows/Linux full-script worldserver/tests-common passed 406/406. Linux compiler
  is stopped; evidence is build/linux-quest-reward-execution-20261008/LastTest.log.
  Fresh Windows all-three-modules-off validation passed 19/19 after the bridge
  change. No compiler or realm is running. The acquisition/reward source batch
  is qualified; native gameplay, exact item grant, persistence and relogin remain
  unobserved. One bundled real-quest replay is the next useful live check.
  QuestFixture now captures before/after rewarded history, inventory-mapped totals
  (including bank), level/XP/money in quest-reward-state-result.json, after clean
  world shutdown. Bounded reader/ownership/numeric-range tests passed. It has not
  observed native rewards yet; ordinary gameplay can also cause inventory/XP/money
  deltas. Do not treat disappearance from the active quest log as saved reward proof.
- New reward-choice dependency is implemented as map-owned `quest reward choices`.
  It reuses donor usage/category selection and existing Cata item readers, retains
  native choice slots and leaves unknown/unscored alternatives unresolved. There
  is no reward grant/turn-in or new core bridge. Four regressions are added;
  Windows/Linux passed 402/402 and the Linux compiler stopped. No build or realm
  was running for that completed dependency. Runtime reward evaluation/turn-in is
  unobserved; the newer explicit granting path above is still being validated.
  The preceding acquisition batch
  passed 398 on both platforms and Windows all-modules-off 19.
- Completed acquisition baseline: the default-off selected-giver NPC quest-accept command is in
  source. Windows full-script worldserver/tests-common passed 398/398 tests.
  Linux full-script worldserver/tests-common also passed 398/398; its compiler
  container is stopped. Evidence is build/linux-quest-npc-20261007/LastTest.log.
  Windows all-modules-off validation passed 19/19; all three optional-module
  cache flags were verified OFF. Those compilers and realm stopped. The quest
  source batch is qualified; native quest gameplay and relogin are not observed.
  This describes the completed acquisition builds, not the newer reward build above.
  The replay harness has opt-in -QuestFixture for the quest gates, requires
  the reused interactive recovery/mixed-party module fixture, and explicitly
  disables them for ordinary runs (now including the separate reward gate). Gate replacement (including duplicate/
  indented seed keys), syntax, environment and the existing 11 wait/controlled
  fixture checks passed without starting services. Fresh module-off validation
  of the new session bridge passed as recorded above.
  QuestFixture also records bounded saved active quest states before admission
  and after clean native world shutdown in quest-state-result.json. Empty,
  complete/incomplete/failed, malformed and over-limit rows plus malformed GUID
  scope passed mocked reader checks. This reporter has not yet run against a
  native quest replay; it is not relogin or automatic acceptance proof.
- Active core checkout: `TrinityCore-publication-candidate`; the independent
  module repository is `modules/mod-playerbots`. Both use `work/managed-roster`.
- Published baseline: core `eee1755104`, module `9f99b27`. The local gear/loot
  milestone module is committed as `40f5f7d`; the matching core milestone records
  that exact module revision in its README. Neither new milestone has been pushed.
- The uncommitted natural-affix extension passed Windows and Linux
  worldserver/tests-common with **388/388 tests** each. The preceding local
  milestone passed 384; its commits remain unchanged. These affix checks completed
  before the completed context builds below.
  Four mocked controlled SQL checks passed for the milestone fixture.
- Context integration is now applied on top of that source, with canonical
  mod-context-api linked at modules/mod-context-api. Full Windows/Linux builds
  passed 390/390; Windows with all three modules off passed 19/19, and the 17
  reader/interface tests passed. Those builds completed. Copied party replay
  build/playerbot-smoke-20261007-164901/ completed with ContextCapture; all four
  bots and the human have fresh records in one native group in Ragefire,
  map 389/instance 1; all four dedicated bot transfers completed. After the weak
  starting-zone pulls, native dungeon logs show both Warriors and Mage acting,
  Priest Renew on Testone, target-death return to noncombat, corpse opening and
  Mage drinking. Player ended the check as sufficient. This is a bundled
  operational observation, not landed-spell, natural-affix, stress or full-clear
  qualification. The harness exited zero and stopped its owned processes. All
  five had combat/offline observations and explicit stopped publication. The
  report counted 434 stale online entity polling observations, maximum sample
  skew 4034 ms and maximum query time 34.128 ms. Freshness is not fully qualified
  and native sampling cost is unmeasured. The original report has no gap timeline;
  do not infer a cause from these totals. The external monitor now records bounded
  anomaly timestamps/ages and query statuses; all 23 Python tests passed,
  including six accumulator regressions. No new native build was needed.
  Future recovery/role/gear/context checks stage at Tranquillien rather than the
  level-one homebind; the current session was not repositioned.
- The preceding Windows core-only build passed **19/19** with both gameplay
  modules disabled. The new 19-test pass also disables context-api. Linux compiler
  stopped after those checks; it is now running the newer NPC batch above.
  Linux server runtime is untested.
- The copied replay `build/playerbot-smoke-20261006-224959/` completed and exited
  zero and its Cata services stopped. Logs show
  four-bot dungeon entry, normal role actions and 12 native pass submissions
  across three rolls, with no duplicate bot/roll submission. Need/greed and native
  winning-item award were not observed in that natural-drop replay. The later
  controlled replay `build/playerbot-smoke-20261006-233354/` passed: Testone need,
  Testtwo greed, caster pass on one roll, and saved stock increased by one.
  Player feedback confirms expected behavior. Those replay services stopped;
  the later context replay also completed as recorded above.
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
instance inputs and unproven affixes stay Unknown. The new native loot comparison
uses validated property/suffix/factor facts locally; hypothetical queries still
cannot claim that proof. Same-entry different affix variants can now upgrade.
The existing owned collector is reused, without cache mutation or a core API change.
Natural-affix gameplay remains to be observed in the next dungeon session.
Profession, quest/master sync,
token, vendor/AH and disenchant classification remain unported.

## Next implementation batch

Complete bounded accept-all validation; the core-off baseline is unchanged.
Hyperlink transport validation is complete.
Abandonment platform validation is complete.
This closes the bounded explicit human-led quest-control set in source, not
autonomous questing. All live acquisition/confirmation/reward/inspection/share/
abandonment observations may join one useful replay; abandonment is optional and
not required to accept the normal workflow. Outgoing-share platform validation
is complete. Confirmation platform/module-off checks are
complete. Read inspection also passed
platform and module-off checks. The next
bundled acquisition/reward replay can use `quests` to see IDs,
progress and reward items without guesswork. No separate tiny read test is needed.

Reward-choice source validation is complete; explicit human-directed reward
execution is now implemented. Finish platform/module-off qualification, then
prepare a bundled acquisition/reward check with a suitable real quest. Do not
use a cached recommendation as mutation authority or copy the donor's direct
RewardQuest call. The existing acquisition and new reward
observations can join one later useful party check; no repeat of infrastructure
or forced quest completion is required. Detailed ranking limits are in PORTING.md.

The next shared dependency is now implemented in source: own-quest item
usefulness, adapted from current upstream master (unchanged donor revision).
It handles native quest source requirements, direct objectives and item-created
objectives, using Cata's six objective slots. It is a map-owner read fact only;
no quest acceptance/master synchronization or active loot policy was enabled.
Useful consumable stock retains precedence, but exhausted/unsupported consumables
now reach the quest fallback. Three regressions cover counts, roll scope and that
precedence. Initial Windows validation passed 392 tests; the completed fallback
batch passed Linux worldserver/tests-common with 393/393 and its compiler stopped.
The corresponding Windows run also passed 393/393. Native quest gameplay is pending.
The first connected share feature is now implemented: default-off
Playerbots.Quest.AcceptShared.Enabled responds only to an existing ordinary native
share from the attached, authorized human in the same party/map while the bot is
idle. It calls the typed native accept handler, not AddQuest or a copied WotLK wire
packet. Receipt tests are added; Linux built with 395/395 tests passed and its
compiler stopped after that batch. The corrected Windows build also passed
395/395. No new core hook was required for shared acceptance. See module
PORTING.md for exact exclusions and remaining
admission/persistence observations. Do not enable or test separate NPC/reward/
party-confirmation flows as if they were covered by this gate.

The following NPC slice is now implemented separately behind default-off
Playerbots.Quest.AcceptNpc.Enabled: whisper/party `accept <numeric quest ID>`
targets the human's selected nearby creature/gameobject. A thin session bridge
posts a single copied, five-second intent with giver/map/instance binding, then
world execution rechecks control and native interaction before the typed accept
handler. Three tests are added; Windows/Linux passed 398/398 and Windows
all-modules-off passed 19/19. These were wider builds
because the session header changed. No client realm was started. Native quest admission/persistence remains
pending; do not claim those from receipt tests. Donor's direct AddQuest fallback
after native rejection is intentionally omitted. All builds are complete and
the test-owned Linux compiler is stopped. The next useful party replay may add
-QuestFixture; no separate tiny quest test or forced grant is required.

Next continue the human-led dungeon using the normal prepared roster and optional
roll gate, without ControlledLootRoll. Observe natural-affix loot when it appears;
do not force a separate check or repeat the accepted need/greed fixture. Fix actual
party problems through their donor owners and choose the next cohesive feature
batch from those observations. The affix extension is already implemented and
source-qualified; its details are in module PORTING.md.

The context replay and cleanup are complete. Keep its freshness limitation open
and use the strengthened monitor alongside the next useful party session; do not
force a repeat merely to obtain a zero-gap report. Choose the next gameplay port
from shared party dependencies, not speculative fixes to healthy behavior.

The following records the completed milestone recipe and its regression fixture:

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

## Companion context tooling checkpoint

Read the related chat "Design agent-wow Cata observer" and the canonical companion
documents in workspace-relative `CATA/cata-context-api/` (ROADMAP.md, VALIDATION.md,
contracts/SNAPSHOT_V1.md) before integration work. Its optional mod-context-api
and Python CLI/HTTP queries exist in separate experimental checkouts; MCP itself
and write controls are not shipped. The current prototype passed its own older
baseline Windows/single-bot checks, not current gameplay/platform qualification.

The packaged hooks are now applied and mod-context-api is linked to its canonical
source. Full-script Windows/Linux passed 390 tests each; all-modules-off passed 19. Next
compare fresh five-member data with a normal client session; sampling cost remains
to be measured separately. The copied party harness uses -ContextCapture and
enables only read capture for all five configured identities. The companion
scripts/check-party-capture.py records freshness/group/instance/combat observations
through shutdown; human comparison and native overhead are separate evidence.
Avoid overwriting current gameplay files
with older experimental copies. Keep canonical telemetry code in the companion
module, Playerbots-specific diagnostics in Playerbots and generic hooks in core.

Once qualified, prefer focused party/bot queries during preflight and diagnosis.
Check server boot, lifecycle generation, per-entity age and sample skew; target
means selection, last executed action is historical, and queue count is not queue
enumeration. Current fields cannot prove aura/spell outcomes, threat or complete
party discovery. Use the existing native/client evidence for those questions;
add bounded history/fields only for a demonstrated diagnostic need. Telemetry
must have independent read gates and preserve deterministic gameplay ownership.

Current Playerbots development continues while this optional checkpoint is pending.
Shared realm tests must coordinate database/realm/instance ports and cleanup:
the companion experimental harness has its own port parameters. Do not start a
second realm on another task's listeners or stop its services to make room.

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
| `build/linux-native-loot-20261007/LastTest.log` | Committed gear/loot baseline, 384 Linux tests |
| `build/linux-context-integration-20261007/LastTest.log` | Current full-script Linux integration, 390 tests; compiler stopped |
| `build/linux-quest-items-20261007/LastTest.log` | Quest-item and consumable-fallback batch, 393 Linux tests; compiler stopped |
| `build/linux-quest-share-20261007/LastTest.log` | Ordinary native quest-share adapter, 395 Linux tests; compiler stopped |
| `build/linux-quest-npc-20261007/LastTest.log` | Explicit NPC acceptance/session bridge, 398 Linux tests; compiler stopped |
| `build/linux-quest-reward-choices-20261007/LastTest.log` | Read-only reward-choice dependency, 402 Linux tests; compiler stopped |
| `build/linux-quest-reward-execution-20261008/LastTest.log` | Explicit native reward command/generalized bridge, 406 Linux tests; compiler stopped |
| `build/linux-quest-inspection-20261008/LastTest.log` | Native read-only quest inspection, 407 Linux tests; compiler stopped |
| `build/linux-quest-confirmation-20261008/LastTest.log` | Party-pushed confirmations/native sharer-identity repair, 409 Linux tests; compiler stopped |
| `build/linux-quest-outgoing-share-20261008/LastTest.log` | Outgoing native party quest share, 411 Linux tests; compiler stopped |
| `build/linux-quest-abandon-20261008/LastTest.log` | Default-off native active-quest abandonment, 413 Linux tests; no abandonment executed; compiler stopped |
| `build/linux-quest-links-20261008/LastTest.log` | Native-framed quest/item command links, 415 Linux tests; compiler stopped |
| `build/linux-quest-accept-all-20261008/LastTest.log` | Bounded selected-giver accept-all, 417 Linux tests; compiler stopped |
| `build-core-only/Testing/Temporary/LastTest.log` | Current Windows build with all three optional modules disabled, 19 tests |
| `build-both/Testing/Temporary/LastTest.log` | Latest local Windows integration, 390 tests; overwritten by later runs |
| `build/playerbot-smoke-20261007-164901/` | Ragefire group/instance, role actions, corpse opening/drink start, clean shutdown and stopped capture; freshness gaps in context-party-report.json |

The native equip check does not establish relogin or occupied-slot displacement.
The earlier dungeon-entry failure was a harness/transfer-path mismatch, not proven
phasing. Use `-RecoveryLoot -DungeonFixture` for the dungeon recipe; confirm all
four arrivals through dedicated `joininstance`. Ordinary cross-map `.summon`
does not supply the bot transfer acknowledgement path.
