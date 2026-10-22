# Playerbots development handoff

Updated 2026-10-22. Start here. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns
priorities; module [PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns
donor pins, adaptations and dated implementation/build evidence. The
[party fixture](PLAYERBOTS_PARTY_FIXTURE.md) owns the test recipe.
Older chronological handoff detail is preserved in
[handoff history](PLAYERBOTS_HANDOFF_HISTORY_2026-10-08.md), not the resume sequence.

## Current state

- Active core: `TrinityCore-publication-candidate`; independent module:
  `modules/mod-playerbots`. Both branches are `work/managed-roster`.
- Published October 21 core `2e03c2a31ee39bd2c39f958014fed9b5de607307`
  replaces the prior core `80d1fc7491` / module `1e108ca` checkpoint. Module `39e7000b6a361bbd455ac006efb6d0d386febe13` includes maintenance,
  retention, training, native bag-swap and Rogue/Hunter foundations; the core
  README pins that matching revision. Historical pins and intermediate build
  counts belong in PORTING.md, not the resume sequence.
- October 22 documentation refresh pins module
  `1661edaf711ef175cd96a80630bb7738b6a54f18` in the core README. Only docs and
  configuration comments changed; runtime settings and gameplay are unchanged.
- Final Hunter plus six-role fixture Windows/Linux full-script worldserver/
  tests-common passed **476/476** each with all three modules enabled.
  Prior Windows **worldserver and
  tests-common**, with all three modules disabled, passed **20/20**.
  Linux server runtime and Rogue/Hunter gameplay remain untested. Linux compiler
  container and Windows compiler are stopped; no test-owned realm is running.
- Publication cleanup applied the known explicit Creature include for no-PCH
  builds; its earlier isolated Linux qualification is documented in the context
  project. No new canonical native build was run for this include-only change.
  Fixed helper passwords were removed: copied-realm runs generate private login
  files and reset only the copied offline human account through native commands.
  Service-free checks pass. Module milestone identity and the core's matching pin
  were assigned after cleanup; the source checkpoint does not imply a live replay.
- Latest prepared copy is `build/playerbot-smoke-20261013-164429/`: native factory
  created Testrogue and Testhunter, native role preparation completed and both
  saved level-20 Combat/Marksmanship specs and equipment. Hunter has an active,
  living level-20 slot-0 native pet. All six bots and test-owned services stopped.
  The expanded roster is saved, not yet party/raid or gameplay-qualified.
  Private extra-dps-preparation.json records the extra identities. New
  `-ReuseExtraDps` replay validates that receipt against saved native identities/
  enrollment, starts the two managed bots and includes all seven actors in
  context capture. Service-free checks pass; this replay path is not live-tested.
- Previous copied realm `build/playerbot-smoke-20261013-120608/` shut down cleanly
  after human logout, all four bot stops/saves and MySQL shutdown. Preserve
  unrelated services; verify listener ownership before any database command.
- Donor module master was checked at `79bd428115c8f33b74b13de23b133d49c3f75c60`;
  bag-core comparison used AzerothCore master
  `f5f668e29a7548a566eff4a69cb7a30d216dc7a0`. Recheck remote master for the next
  port; the reference checkout's working files may be older than origin/master.

## Current capabilities and limits

- Optional-module boundary, native asynchronous bot sessions, managed rosters,
  bounded character creation, MultiBot lifecycle/control and shared combat/
  noncombat/dead engines are connected. Combat admission currently supports
  **Warrior, Mage, Priest and local Rogue/Hunter baselines**. Neither new class has a live replay
  yet; role predicates for other classes are not proof of their AI support.
- Rogue connects default-off native attack admission, generic/Combat/Assassination
  contexts, current-target combo/energy policy, builders/finishers, Slice and Dice,
  Kick, shared melee movement and party DPS reassessment. Subtlety uses the generic
  fallback. Poison/Envenom, stealth/openers, broader spec abilities and gear
  scoring remain deferred; unknown gear never becomes sale/equip authority.
- Hunter connects native Auto Shot, focus builders/dumps, starter native spec
  routes and shared ranged targeting/movement. Existing owned active pets can
  be called/revived/mended through spells and controlled by native map-owned
  PetAI. Gate-off/stop/target loss returns them to follow. No pet creation/taming,
  full rotations, advanced traps/kiting or Hunter scoring. Both full builds and
  474/474 tests passed; gameplay is unobserved.
- Default-off disposable fixture now supports six named roles, preserving the
  original four-slot commands and adding console-only managed fixture20 GUID/
  role requests. Native level-20 Combat Rogue / Marksmanship Hunter preparation
  preserves existing gear and uses native talent/equip/learn/save helpers; no pet
  is created by that fixture helper. Native extra character preparation has now
  completed in the latest stopped copy; gameplay remains unobserved.
- The October 13 level-20 party replay observed tank/Arms/Frost routing, accepted
  tank/DPS casts, Priest Renew/Heal starts, native corpse opening and return to
  noncombat with everyone alive/full health. This is useful party operation,
  not a full dungeon clear, quantified threat/healing or every spell landing.
  No sustained recovery pressure or new resurrection check was claimed.
- Shared inventory facts cover consumable stock, qualified gear/affixes,
  positive profession/material/disenchant retention and ordinary bag capacity.
  `gear?`, explicit one-change `gear apply` and guarded native loot votes are
  connected. Unknown facts never become sale authority.
- Native populated ordinary-bag replacement now uses a private swap-scoped
  core exception while public storage calls retain the nonempty-bag guard.
  One owned empty backpack candidate, four carried destinations and copied
  content identities/counts/affixes bound the module action. The human reported
  a manual populated swap working. Bot-initiated replacement, exact runtime
  content matching and saved/relogin persistence remain unobserved.
- Independent default-off maintenance supports native `repair`, recovery-supply
  `buy <ID>` / `buy vendor`, qualified plain-gray-junk `sell vendor`, and
  default-class-trainer `trainer` / `trainer learn` / `train <ID>`.
  These have source/build qualification, not newly observed native
  repair/resupply/sale/training or persistence. Broad vendor classification,
  automated bandage use and autonomous budgets/discovery remain later work.
- Recipe-material facts publish bounded immutable copied IDs under world
  startup/reload/shutdown. The latest realm booted with this source; explicit
  reload/material-retention behavior was not checked.
- Before/after bot saved snapshots both contain the same 58 item rows/mappings,
  byte-for-byte in the captured strings. The baseline precedes native role
  provisioning; this is not an isolated causal equip/purchase/loot assertion.
  The human bag test is outside those bot-only snapshots.
- Maintenance replay now accepts separate `-MaintenanceEquip`, requiring
  `-Maintenance` and rejecting the isolated waist-only `-GearApply` mode.
  Ordinary fixtures reset inherited equip gates; before/after saved captures
  are diagnostic evidence, not automatic acceptance of every inventory delta.
  Service-free guard/config-normalization checks passed.

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

1. Resume donor combat/class expansion as a connected vertical slice, not another
   isolated spell or inventory chore. The connected Rogue baseline has completed
   Windows/Linux validation and source review. Context/strategy/executor/
   selector/role/admission is now wired. Hunter's connected ranged/pet batch is
   Windows/Linux qualified at 476/476 including the six-role fixture extension.
   Reuse the saved Rogue/Hunter roster with `-ReuseExtraDps` in the next useful
   outdoor raid replay, not separate smoke tests for every ability. The prepared
   Hunter has a saved native active pet; confirm its actual arrival and behavior.
   Poison inventory, stealth/openers, all-spec parity and scoring remain explicit
   dependencies; unsupported gear facts remain Unknown.
2. Prepare one human-led Ragefire attempt/clear when the human is available.
   Keep normal party control, durable encounters, tank/healer support and recovery
   together. October 13 outdoor operation is accepted as a useful checkpoint,
   not a reason to repeat it for every spell. The fixture's new
   `-MaintenanceEquip` works alongside maintenance without the old waist-only
   test assumptions. Use dedicated instance entry; verify actual group, phase,
   map and arrival before diagnosing behavior. Maintenance/trainer/bag cases
   join convenient normal play; do not extend that side track with isolated tests.

Hunter plus fixture source passed enabled Windows/Linux 476/476 each.
Unchanged-core disabled Windows
worldserver/tests-common 20/20 describes its completed snapshot.
Publication is a separate milestone
decision; do not push automatically. Preserve default-off gates and document
unobserved maintenance/training/bot migration. Observer expansion remains tied
to a concrete diagnosis. Remote-independent class work can continue without
requiring another client session now.

## Fixture and build rules

- Add `-Maintenance` to the reused interactive full mixed-party module recipe
  for the next bundled check. It enables Repair/Buy in the copy; other fixtures
  reset inherited maintenance gates off. Service-free guard/reset checks passed.
- Selling requires separate `-MaintenanceSell` in that copied recipe; ordinary
  maintenance keeps its gate off. Add it only for the prepared native sale check.
- Class training requires separate `-MaintenanceTrain` with `-Maintenance`.
  Service-free guard/reset tests cover opt-in and inherited duplicates. Do not
  force an unlearned spell if the prepared bot has no eligible trainer offer.

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
The optional linked mod-context-api is integrated; gameplay integration is
read-only. The companion's own current documentation owns its query/MCP release
status; those interfaces are not shipped by the core/Playerbots repositories.

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

Observer development is not a gameplay dependency. Use existing freshness,
phase, attack-victim/facing and bounded action-history queries when needed.
The October 8 companion reader snapshot passed 43 checks. The October 8 fixture exported optional
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
| `build-both/Testing/Temporary/LastTest.log` | Latest Windows result; current batch/count recorded in module PORTING.md |
| `build/linux-release-20261009/LastTest.log` | Published October 9 Linux 431-test snapshot |
| `build/linux-maintenance-20261011-439/LastTest.log` | Earlier complete Linux 439-test maintenance snapshot |
| `build/linux-profession-20261011-443/LastTest.log` | Earlier Linux 443-test tool/recipe snapshot |
| `build/linux-material-20261011-446/LastTest.log` | Earlier Linux 446-test material-retention snapshot |
| `build/linux-disenchant-20261011-448/LastTest.log` | Earlier Linux 448-test owned-retention snapshot |
| `build/linux-vendor-20261011-452/LastTest.log` | Earlier Linux 452-test qualified-junk sale snapshot |
| `build/linux-recipes-20261011-454/LastTest.log` | Earlier Linux 454-test recipe-catalog snapshot |
| `build/linux-trainer-catalog-20261011-456/LastTest.log` | Earlier Linux 456-test trainer snapshot |
| `build/linux-recovery-stock-20261011-457/LastTest.log` | Earlier Linux 457-test recovery-resupply pass; compiler stopped |
| `build/linux-bag-capacity-20261012-460/LastTest.log` | Earlier Linux 460-test bag-capacity pass; Windows counterpart also passed |
| `build/linux-empty-bag-fill-20261013-461/LastTest.log` | Earlier empty-bag-fill 461-test pass; Windows counterpart also passed |
| `build/linux-bag-replacement-20261013-463/LastTest.log` | Earlier restricted empty-bag replacement Linux 463-test pass; compiler stopped |
| `build/linux-native-bag-swap-20261013-464/LastTest.log` | Earlier native populated-bag admission Linux 464-test pass; compiler stopped |
| `build-core-only/Testing/Temporary/LastTest.log` | Windows all-modules-off worldserver/tests-common build and 20-test pass |
| `build/playerbot-smoke-20261008-212331/` | Human quest acquisition and four inspections; failed share; clean shutdown |
| `build/playerbot-smoke-20261008-215311/` | Four bot shares/progression, Testone turn-in and saved 22979; clean shutdown |
| `build/playerbot-smoke-20261006-113536/` | One native equip change and saved item preservation |
| `build/playerbot-smoke-20261006-233354/` | Controlled need/greed/pass and saved award; modified seed |
| `build/playerbot-smoke-20261007-164901/` | Ordinary Ragefire operation, stopped capture and freshness gaps |

Older dates, intermediate counts and detailed adaptations belong in PORTING.md,
the existing development/milestone history and the archived handoff.
