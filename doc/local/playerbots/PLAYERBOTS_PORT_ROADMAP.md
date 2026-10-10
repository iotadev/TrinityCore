# Cataclysm Playerbots roadmap

Updated 2026-10-09. The goal is AzerothCore Playerbots and MultiBot functionality
on native TrinityCore Cataclysm 4.3.4. Reuse upstream behavior and preserve Cata's
session, map, inventory, loot and database ownership.

The near-term gameplay milestone is a useful human-led Warrior/Mage/Priest
dungeon party. Full class coverage, pets, autonomous populations, quests, travel
and automatic group formation follow on separate tracks.

## Current capabilities

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
synchronization, professions/vendor/token/disenchant classification, autonomous
populations and broader class/spec/pet coverage remain separate.

## Current validation

| Scope | Verified result | Remaining limit |
| --- | --- | --- |
| Current local Windows source | Full-script worldserver/tests-common passed 431/431; includes per-player quest-loot exemption and current observer additions | New exemption, reward batches and broader quest flows remain unobserved |
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

1. Improve the next same-map outdoor setup using native `.group summon Test`,
   which already exists; verify arrival without adding another summon command.
   Dedicated dungeon entry remains the cross-map/instance path. Continue donor
   behavior porting and a useful human-led dungeon toward a clear. Add optional
   deferred coverage only when convenient, with no forced completions, starting-zone
   combat, mandatory wipes or tiny per-command tests.
2. Port connected donor NPC/quest interaction or observed party/inventory needs.
   The bundled real-quest check is complete; retain unobserved batch/link/party-push/
   relogin/affix limits rather than reopening lifecycle infrastructure. Broader
   professions/economy, class coverage and autonomy remain separate tracks.

Development can continue offline while the replay is pending. Missing suitable
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
freshness reporter in a useful party replay. Add native phase, attack-victim/
facing facts or bounded rejection history only for a concrete preflight or
diagnostic need, through the companion's versioned copied-data contract.

Use fresh, qualified focused queries for fixture preflight and failure diagnosis:
identity/generation, health/resources, combat, map/instance, controller/follow,
strategies, selected target, last executed action and queue count. Check boot ID,
per-entity freshness and sample skew before using a snapshot. Configured scope is
not guaranteed complete party membership; selected target is not necessarily the
attack victim; last action and queue count do not prove a currently executing
action or landed spell. Missing/stale/unsupported context remains explicit.

Later history should correlate copied bot intent/admission/submission with native
outcomes using entity/session identities and timestamps. Independent client
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
