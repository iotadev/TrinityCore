# Playerbots reference and porting decisions

Reference snapshot reviewed 2026-09-29; status wording reconciled 2026-10-01.
The shared-state audit refreshed primary upstream master on 2026-10-02 to
`037c01418b5d01506917a3db9b44fd56ac5f965c`, comparing the changed AI file against
`7bae1b5c58c76a0aa20381155edc08096d1485b2`. Its separate-engine pattern remains
unchanged. Historical comparison rows below retain their original review pins;
this refresh does not relabel earlier imports as current-master ports.
Use with the [roadmap](PLAYERBOTS_PORT_ROADMAP.md)
and [implementation packets](PLAYERBOTS_WORK_PACKETS.md). This guide records
reference policy, not another implementation plan or evidence of feature parity.

## Authority and source selection

The implementation is the matching `iotadev/TrinityCore` and
`iotadev/cata-playerbots` pair. Inspect the actual checkout revisions and pending
diffs before proposing work: published branches can lag local development.
Existing implementation is the starting point, not proof that every behavior
is correct. Resolve discrepancies against native contracts and concrete evidence.

Use this order when choosing an adaptation:

1. Native Cata APIs, data and lifecycle rules decide platform correctness.
2. Current `mod-playerbots/mod-playerbots` supplies the primary Player-based
   architecture and behavior relationships. Check master, pin an immutable
   revision, and review relevant changes since the previous import.
3. Inspectable independent Cata implementations can supply behavior comparisons
   and missing scenarios. They do not replace the primary architecture.
4. Historical discussions, private/repack claims and binary behavior are leads,
   not source evidence. Do not infer implemented features from marketing text.

The local WotLK fork remains useful for its separately identified custom fixes.
Do not silently substitute it for current upstream or update its runtime as part
of a Cata port. Preserve source notices and record actual copied/adapted code in
the module's `PORTING.md`; inspecting a reference is not importing it.

## Revision snapshot

These are observations on the review date, not floating compatibility promises.
Refresh affected references at the next substantial import, not for every edit.

| Source | Observed revision and scope |
|---|---|
| Published Cata pair | Core `c3b559e873e1056d827bfcf12d3c862bfde97be6`; module `b9ebc6c7dfc3510d21a40b32a61c659df16e24d7` |
| Local checkpoint parents | Core `098591f09597a5f5d83536357245efc62b637635`; module `4101a7fb8ff7f36b6caa772eee99a314e9ceafe2`; these commits do not include subsequent uncommitted factory, addon and party-buff work. See the infrastructure acceptance checklist for that work's evidence. |
| Primary donor | `mod-playerbots/mod-playerbots` master `7bae1b5c58c76a0aa20381155edc08096d1485b2` |
| Secondary Cata reference | `Arkania/ArkCORE-NG` master `a7304c3075bf8ee7eb5bdf45f31cda01c8626b52` |
| Peer port comparison | `g0015590/TrinityCore_playerbots-cataclysm`, branch `playerbots-cataclysm`, `7037ad981b42e558b2928935f34ce4a428c11771` |

The 2026-10-01 accepted infrastructure module is
`70014ce88cb2d99a370894baef7a32876ff94a50`, paired with the core milestone
containing this update. The snapshot table above retains the earlier reference
review, not the new publication state. The core README is the current matching
module pin; the infrastructure checklist records acceptance boundaries.

## ArkCORE: behavior reference, not an architecture donor

At the pinned revision, `bot_ai` derives from `ScriptedAI` and class bot scripts
use `CreatureScript`. Our bots are Players owned by native WorldSessions.
Do not import NPC ownership, spawned-creature lifecycle, direct revival helpers,
or a second AI update loop to make a class action work.

The inspected files are under
[`src/server/game/AI/NpcBots`](https://github.com/Arkania/ArkCORE-NG/tree/a7304c3075bf8ee7eb5bdf45f31cda01c8626b52/src/server/game/AI/NpcBots):

| Reference | Useful comparison questions | Owning Cata seam |
|---|---|---|
| `bot_warrior_ai.cpp`: stance and TAUNT branches | Is this bot the assigned tank? Who is being attacked? Is the target controlled? Is the action legal at this distance? | Warrior strategies, role/target values, triggers and native cast adapter |
| `bot_priest_ai.cpp`: Flash Heal, Fortitude and `RezGroup` caller | Which living group member needs healing? Is a buff absent? Is resurrection appropriate rather than healing? | Priest actions/triggers and shared party values |
| `bot_ai.cpp`: `BuffAndHealGroup`, `RezGroup`, `IsInBotParty`, instance/map checks | How are candidates filtered? Are outstanding resurrection requests skipped? What happens when controller, party or map state changes? | Shared eligibility values plus session/manager recovery coordination |

These are review scenarios, not endorsed thresholds or copied policies.
Recheck Cata spell IDs, learned spells, resources, cooldowns, range, line of sight,
roles and group semantics. Do not copy hardcoded cooldowns, random gates,
triggered casts or class-based tank heuristics without justification. In
particular, this reference's implicit NPC-party relationships are not native
Player group membership. Its group-main-tank database lookup is not permission
to add synchronous database queries to map-thread AI.

### Recovery ownership

Keep recovery coordinated rather than duplicating it in every class:

- Core retains native death/corpse, resurrection-response, map-transfer and
  session/save/logout rules.
- The module's session/manager layer coordinates shared recovery state,
  controller/group validity, pending operations and resumption/cancellation.
- Class strategies choose and attempt learned recovery spells through the native
  cast path; shared values determine eligible targets.

The inspected ArkCORE `RezGroup` is a shared class-spell resurrection helper.
It does **not** establish that all death/revive behavior belongs to a manager,
nor that NPC revival can be transplanted into Player lifecycle handling.
Our boundary follows the primary donor and Cata ownership contracts. Keep one
decision owner per migrated behavior; retire or gate its old fallback when the
new route becomes active. Extend existing seams before adding a new manager.

## Peer-port comparison

At the pinned peer revision, the latest commit is dated 2026-08-20 and adds the
Playerbots database pool. Source includes PlayerbotScript/session hooks and
`src/server/scripts/Playerbots/playerbots_script_loader.cpp`; the latter's
`AddPlayerbotsScripts()` is explicitly an empty skeleton. This is a concrete
snapshot, not evidence that the author lost interest or a permanent ranking of
projects. Check new source before making future comparisons. Hooks may still
be useful to compare even when gameplay is absent from the inspected slice.

## Review and implementation handoff

Do a focused design/reference review before a substantial dependency import,
ownership change, or when evidence conflicts. A stronger reasoning pass can
help at those boundaries; model choice is not a required test or a reason to
pause routine implementation. Use the execution packet in the work-packet file
to hand decisions to the implementer without requiring them to rediscover scope.

This review does not reorder the next batch: finish managed lifecycle outcomes
and authorization, then the first MultiBot mapping over shared services. Use
ArkCORE comparisons when class, recovery or dungeon work reaches those seams.
Batch operational checks; do not add a client session for every reference case.
