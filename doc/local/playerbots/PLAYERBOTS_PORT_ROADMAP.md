# Cataclysm Playerbots roadmap

Updated 2026-10-21. The goal is AzerothCore Playerbots and MultiBot functionality
on native TrinityCore Cataclysm 4.3.4. Reuse upstream behavior and preserve Cata's
session, map, inventory, loot and database ownership.

Publication cleanup carried the known no-PCH include fix into canonical source,
removed fixed helper login credentials and refreshed release-facing docs. The
476/476 native results below remain dated build evidence, not a new post-cleanup
compile. No gameplay scope was added; the combined outdoor replay is still next.

The near-term gameplay milestone is a useful human-led Warrior/Mage/Priest
dungeon party. Full class coverage, pets, autonomous populations, quests, travel
and automatic group formation follow on separate tracks.

## Current capabilities

Local Hunter baseline adds native admission, focus-based ranged combat/Auto Shot,
starter spec priorities and control/summon/revive/mend of an existing owned pet.
The independent gate defaults off. Native core owns pet lifecycle and spell
effects; no pet creation/taming, Wrath ammo/mana/happiness, advanced traps/kiting
or Hunter gear scoring. Windows/Linux worldserver/tests-common passed 474/474
each; no live Hunter/pet replay. A default-off six-role fixture extension adds
native managed-GUID Rogue/Hunter preparation without replacing the four-slot
recipe or creating pets. Final-source Windows/Linux builds passed 476/476 each;
compilers and test-owned realms are stopped. Native provisioning and role
preparation completed in a stopped disposable copy: level-20 Combat Rogue and
Marksmanship Hunter, with saved equipment and an active living native Hunter
pet. The reuse-only outdoor raid helper now includes all seven actors in capture;
service-free checks passed. Expanded raid gameplay/pet combat remain unobserved.

Local Rogue baseline now wires native class admission, generic/Combat/
Assassination strategies, target-qualified energy/combo builders and finishers,
Slice and Dice, Kick and shared melee movement/party targeting. Its independent
combat gate defaults off. Subtlety uses a generic fallback; poison/Envenom,
stealth/openers, broader spec abilities and Rogue equipment scoring remain later
dependencies. Windows/Linux full builds and 469/469 tests passed; Rogue has no
live replay yet.

The earlier published core `eee1755104` / module `9f99b27` provided optional modules, native
bot lifecycle, managed rosters, bounded character creation, MultiBot lifecycle/
control and shared combat/noncombat/dead engines for Warrior/Mage/Priest.

The October 9 checkpoint includes the earlier gear/loot milestone (historically
core `bb8c37e2b4` / module `40f5f7d`). It adds main-tank selection, no-steal protection,
active DPS reassessment, copied item/stat readers, eight-spec starter scoring at
levels 10–39, `gear?`, one-slot `gear apply` and guarded native need/greed/pass.
The same checkpoint adds qualified actual-loot affix comparison, read-only
context integration and explicit human-led quest controls.

Quest controls now include native incoming shares/party confirmations, selected-
giver `accept <quest>` / bounded `accept *`, `quests` inspection, explicit
`reward <quest> <item>`, one-bot outgoing `share <quest>` and separately opted-in
active `drop <quest>`. Native quest/item links and numeric operands are supported.
Explicit `reward *` batches ordinary completed zero/single-choice quests at the
selected giver, using at most 25 active IDs with fresh checks per quest. Multiple
choices remain manual; native handlers own reward admission and grant.
Read-only `quests` also supports donor completed/co and incompleted/in filters,
all details and summary-only output; travel-manager details remain unported.
All gates default off. Native admission, inventory and script ownership remain;
there is no forced completion, direct AddQuest/RewardQuest fallback or removal of
rewarded history. The confirmation handler's empty-sharer lookup was repaired
without removing its native checks, including when modules are disabled.

The map-owned reward-choice policy preserves donor usage precedence and native
slot identities; unknown inputs stay unresolved. It does not authorize a grant.
Accept-all uses at most 25 copied native offers with per-candidate revalidation
and partial outcomes, not rollback or automatic retries.

An independent default-off master-loot priority defers only quest-class corpse
items while the human controller's native quest need remains. It skips bot pickup,
not native ownership or recipient eligibility; broader donor item classification,
bag/container behavior and master-progress copying are not ported by this slice.

Read inspection is not an external API/MultiBot quest UI port. NPC discovery,
quest travel, chain rescanning, automatic sharing/multiple-choice reward selection, master-progress
synchronization, full profession/vendor/token/disenchant classification, autonomous
populations and broader class/spec/pet coverage remain separate.

## Current validation

Hunter plus fixture source passed Windows/Linux full-script worldserver/
tests-common 476/476 each. Compilers and test-owned realms are stopped.
The following bag/Rogue checkpoints are completed predecessor snapshots, not
validation of the new Hunter source.

The native populated-bag blocker now has a swap-specific Cata adaptation based
on current AzerothCore master f5f668e: generic storage remains guarded and only
owned carried-bag/empty-backpack-bag native exchanges can pass. Current full
Windows/Linux worldserver/tests-common builds passed 469/469 each, including the
connected Rogue baseline. Builds,
compiler and realms are stopped. A new core predicate test enumerates all required
fact combinations. Fresh Windows modules-off worldserver/tests-common passed
20/20 including the new predicate. Native bot migration/persistence and Linux
runtime remain unobserved. The October 13 human-reported manual swap and normal
party replay have separate runtime scope in PORTING.md.

The following checkpoints describe earlier source snapshots, not current build
jobs or blockers; the current results above supersede them.

Local explicit bag upgrade now uses native replacement for empty ordinary
carried bags, with copied GUID/count/affix confirmation and
one-change bounds. Unsupported/busy/specialized layouts stay excluded.
Linux passed 463/463; Windows full build passed 463/463 and its final-source
incremental check is running. Linux compiler and realms are stopped.
Populated replacement is blocked by Cata's earlier nonempty-bag storage check,
before its transfer branch. A donor-informed swap-specific core adaptation is
needed; weakening generic storage or module-side migration is not the plan.
Older counts below describe predecessor snapshots.

Local explicit `gear apply` now falls back to one native empty-bag-slot fill
after gear candidates, with owned empty ordinary backpack bags only. Replacement,
bank/nested bags and content migration stay unported. Linux built and passed
461/461; Windows also completed 461/461, inspected before this extension.
Native fill/persistence is not yet observed.

Local bag-capacity retention now qualifies ordinary bag upgrades from all four
carried slots and feeds reward inspection. Unknown/specialized cases stay
unresolved; no bag equip, sale or loot-vote scope is widened. Linux built and
passed 460/460; Windows also completed 460/460, collected October 13.
These counts precede the empty-slot mutation extension; older counts below
describe their own snapshots.

Current recovery resupply extends selected-vendor buying to five independent
categories: food, drink, healing/mana potions and bandages. Potions reuse the
combat usability classifier; bandage stocking is not an automated use action.
Windows/Linux worldserver/tests-common passed 457/457 each. Native resupply/
persistence and Linux realm runtime remain unobserved. Older counts below
describe their own source snapshots.

The local trainer extension adds native catalogue inspection and a bounded
explicit learn-all batch: 128 scanned rows, 12 displayed offers, 16 purchases.
Native policy and list/buy handlers remain authoritative. Windows/Linux
full-script worldserver/tests-common passed 456/456 each for current source;
compiler and realms are stopped. No client learning/persistence or Linux realm
runtime claim. The later bundled trainer replay uses the separate opt-in;
ordinary fixtures keep Train disabled. Travel, professions and autonomous
training remain separate tracks. Older single-spell 455/455 evidence is in PORTING.md.

Latest recipe-material fallback uses a bounded immutable copied skill/item index
under world startup/config-reload/shutdown ownership. Windows/Linux full-script
worldserver/tests-common passed 454/454 each. Native catalog startup/reload and
client publication remain unobserved; older results below are their snapshots.

Local `sell vendor` now supports only qualified plain gray junk at a selected
nearby vendor, with a separate default-off gate and complete fresh no-need facts.
General Vendor/Auction and quality sweeps remain blocked by missing retention
coverage. Current qualification is in PORTING.md; native sale/persistence has not
been observed in a client fixture.
Windows and Linux worldserver/tests-common passed 452/452 for the final native
adapter and quest guard. Service-free copied-fixture checks passed; compiler stopped.

Local carried disenchant-retention facts now combine exact owned identity with
qualified non-upgrade, native skill/rarity and donor binding policy. They do not
authorize casts or sales. Current source qualification is in PORTING.md; other
retention branches and complete vendor fallback remain separate dependencies.
Windows/Linux worldserver/tests-common passed 448/448 each. Client retention and
Linux realm runtime remain untested; earlier counts below describe their snapshots.

Local profession-retention work adds positive tool/recipe facts to human-led
item usage; the material extension also adds bounded native skill-line reagent/
output facts with donor gathering aliases. Recipe-template fallback now uses a
bounded immutable skill/item index under world startup/reload/shutdown ownership.
Native skills and learning routes are read without mutation. Current
follow-up qualification is in PORTING.md. Material catalogs and other retention
branches remain dependencies before general selling; the qualified-junk subset
uses the separate world-owned classifier described above.
Windows and Linux worldserver/tests-common passed 446/446 each. Client profession
behavior and Linux realm runtime remain untested; prior results below are dated snapshots.

Latest local maintenance adds one-bundle `buy <numeric item ID>` and bounded
`buy vendor` food/drink restock to published repair core `80d1fc7491` / module
`1e108ca`. Native operations use personal bot funds; vendor mode uses fresh
donor stock policy. Windows and Linux worldserver/tests-common passed 439/439
each. Client maintenance and Linux realm runtime remain untested. Autonomous reserves, discovery
and scheduling remain later work. Module PORTING.md records dated results.
The table below describes the October 9 published milestone.

| Scope | Verified result | Remaining limit |
| --- | --- | --- |
| Published October 9 Windows source | Full-script worldserver/tests-common passed 431/431; includes per-player quest-loot exemption and observer additions | New exemption, reward batches and broader quest flows remain unobserved |
| Complete current Linux source | Full-script worldserver/tests-common passed 431/431 after refreshing core, Playerbots and canonical observer sources | Linux realm runtime remains untested |
| Optional modules disabled | Fresh Windows worldserver/tests-common passed 19/19 with all three installed modules off after current core corrections | No Linux module-off runtime claim |
| Existing party operation | Outdoor/Ragefire engagement, support, recovery, owner-death hold/resume and dedicated instance entry observed | No full clear, broad parity or quantitative role/positioning guarantee |
| Native equip | One empty-slot change saved; owned item identities/properties preserved | Occupied-slot displacement and relogin remain open |
| Native loot | Controlled need/greed/pass and saved award observed | Natural-affix decisions/awards and broader item coverage remain open |
| Context tooling | Five-identity Ragefire capture; optional phase diagnostics used in quest replay; companion history publication/archive check and 43 reader tests passed | Earlier capture had 434 stale online polls; freshness cause, native sampling cost and asynchronous outcomes remain unqualified |

After the initial inverted native sharing guard was repaired, the corrected
October 8 replay confirmed four native accepts, objective progression and
Testone's explicit reward 22979. Saved rewarded history and mapped inventory
confirm that one turn-in; other bots remain complete/unrewarded. Relogin and
batch/link/party-push behavior remain open. Builds are finished, and the realm and
Linux compiler stopped. The shared-loot exemption has not been live-deployed.
Recheck listeners before another
realm and preserve unrelated workloads. The current builds are source evidence,
not a replacement for gameplay. Dated donor pins, intermediate build counts and
runtime provenance remain in module [PORTING.md](../../../modules/mod-playerbots/PORTING.md),
[milestone evidence](PLAYERBOTS_STATE_MILESTONE.md) and the existing history.

## Next two batches

1. Continue donor combat/class coverage in connected batches. The Rogue baseline
   passed Windows/Linux validation and review; Hunter's ranged/pet slice is
   Windows/Linux-qualified at 476/476 including the fixture extension.
   Include normally created/equipped Rogue and Hunter
   characters in one outdoor raid replay rather than testing abilities in
   isolation. Hunter needs an existing native active pet; automatic pet creation
   is not part of this batch.
   Context/strategy/executor/admission are wired; runtime behavior is unverified.
   Pets, poison inventory, advanced stealth and all-spec parity remain explicit
   later dependencies. Do not
   default to another isolated spell or maintenance side track.
2. Aim for one human-led Ragefire clear covering combat, recovery, loot and
   available maintenance together. Existing group summon improves same-map staging;
   dedicated instance entry remains required. Fix demonstrated blockers in batches.
   Use the [MultiBot feature map](PLAYERBOTS_MULTIBOT_FEATURE_MAP.md) for UI dependencies.
   The October 13 outdoor replay is a useful accepted checkpoint, not a full
   clear or a mandatory per-feature repeat. Maintenance cases join convenient
   party play; remote class work does not require another client session now.

The October 9 milestone is published as core `1e17cbdc96` / module `4f7f79d`.
Maintenance is a follow-up. Broader economy, classes and autonomy stay separate.

Development can continue offline until the next useful replay. Missing suitable
quests/drops is deferred coverage, not a forced fixture. Test counts are validation
evidence; connected behavior and preserved native ownership define milestones.

## Companion track: realm context API and future MCP

The separate `cata-context-api` project provides structured development context
while Playerbots remains deterministic and server-owned. Its canonical roadmap,
qualification record and snapshot contract live in the workspace-relative
`CATA/cata-context-api/` directory. The related chat is
"Design agent-wow Cata observer". Keep implementation and detailed API planning
there; this roadmap owns the gameplay integration checkpoint.

The experimental read-only slice is integrated: optional C++ `mod-context-api`,
map-session sampling into copied JSON snapshots and a Python query application
with CLI/loopback access. It implements `context.get_capabilities`, `game.get_party`
and `playerbots.get_bot_state`. The canonical module is linked rather than forked;
core/Playerbots hooks retain optional module gates. Current full gameplay build
qualification is listed above, not inferred from the companion's older build.

A joint five-identity Ragefire replay observed combat/offline/stopped snapshots.
The bounded reader/party monitor passed 23 checks. Freshness gaps remain explicit:
the original capture lacks a gap timeline and does not measure native sampling
cost. Further useful replays may compare client/log evidence and the improved
monitor together; no isolated telemetry test is required to continue gameplay.
MCP registration, controls and independent client observation remain later stages.

No observer expansion blocks the next gameplay port. First use the prepared
freshness reporter in a useful party replay. Optional phase, attack-victim/facing
facts and bounded action history already exist. Use those for concrete diagnoses;
extend the versioned copied-data contract when an observed gap warrants it.

Use fresh, qualified focused queries for fixture preflight and failure diagnosis:
identity/generation, health/resources, combat, map/instance, controller/follow,
strategies, selected target, last executed action and queue count. Check boot ID,
per-entity freshness and sample skew before using a snapshot. Configured scope is
not guaranteed complete party membership; selected target is not necessarily the
attack victim; last action and queue count do not prove a currently executing
action or landed spell. Missing/stale/unsupported context remains explicit.

Existing history records engine admission and action returns. Correlation with
native asynchronous outcomes remains future work, using session identities and
timestamps. Independent client
observation can follow when it answers a specific unresolved question. MCP stays
a thin interface to the same semantic queries; bounded controls and repeatable
scenarios follow their own completion/cleanup qualification. Query availability
does not authorize writes. External readers never access live game pointers.

## Working rules

- Prefer cohesive donor feature batches and one build per meaningful batch.
  Judge progress by connected gameplay capabilities; test counts are evidence.
- Keep incomplete input distinct from a negative decision. Template comparison
  does not establish the identity or eligibility of a particular loot roll.
- Cata loot votes use the native world/group path. Do not reuse map-owned equip
  execution or retain Group/Roll pointers across threads.
- Use the [prepared fixture](PLAYERBOTS_PARTY_FIXTURE.md), with durable enemies
  and current roles, gear and consumables. Dedicated dungeon entry must confirm
  all bots in the party's instance; ordinary cross-map summons are not a substitute.
- Preserve the native core and optional-module boundaries. General far-transfer
  support is separate work; the earlier entry failure was not proven phasing.
- Keep public documentation portable and keep local runtime evidence ignored.
  No Linux client compatibility work is required.

The [handoff](PLAYERBOTS_WORK_PACKETS.md) contains the concrete resume sequence.
The [dated roadmap](PLAYERBOTS_PORT_ROADMAP_HISTORY_2026-10-04.md),
[development history](PLAYERBOTS_DEV.md) and module provenance retain older detail.
