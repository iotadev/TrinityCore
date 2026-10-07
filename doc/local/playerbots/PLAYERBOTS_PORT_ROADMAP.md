# Cataclysm Playerbots roadmap

Updated 2026-10-07. The goal is AzerothCore Playerbots and MultiBot functionality
on native TrinityCore Cataclysm 4.3.4. Reuse upstream behavior and preserve Cata's
session, map, inventory, loot and database ownership.

The near-term gameplay milestone is a useful human-led Warrior/Mage/Priest
dungeon party. Full class coverage, pets, autonomous populations, quests, travel
and automatic group formation follow on separate tracks.

## Current capabilities

The published coordination/recovery milestone is module `9f99b27`, paired with
core `eee1755104`. It includes the established module/session infrastructure,
bounded character creation, managed rosters and MultiBot lifecycle control.
Combat, noncombat and dead-state engines support starter Warrior/Mage/Priest
behavior, shared targeting and positioning, recovery, buffs, interrupts and
native corpse opening. Optional behavior requires its configuration gates.

Outdoor and Ragefire checks observed party engagement, damage/healing, tank
aggro recovery, eating/drinking, owner-death hold and following after recovery.
Dedicated instance entry works with the prepared fixture. Full dungeon clears,
broad class/spec parity and detailed positioning remain unqualified.

The local gear/loot milestone adds main-tank selection and no-steal protection, active
auto-assisted DPS reassessment, item/stat readers, starter gear scoring,
authorized `gear?` inspection and explicit `gear apply`. One empty-waist change
on Testone passed native completion and saved inventory preservation. Scoring
covers eight implemented specs at levels 10–39 and remains a limited heuristic.

Shared item-usage categories, pure roll-choice rules and non-affixed unowned
template comparison are implemented locally. They are dependencies for loot
voting. Optional native need/greed/pass is now connected in local source and
passed its Windows build and a controlled native need/greed/pass/award check.
Linux source validation passed; broader runtime qualification remains ahead.
Its gate defaults off. Automatic equipment management and
disenchant classification remain ahead. Unknown/unsupported items pass.

## Current validation

| Scope | Verified result | Remaining limit |
| --- | --- | --- |
| Current local Windows source | worldserver/tests-common built; 384/384 tests passed; controlled native decisions and saved award observed | Broader runtime coverage and full dungeon readiness remain pending |
| Current local Linux source | worldserver/tests-common built; 384/384 tests passed | Linux realm runtime remains untested |
| Published coordination/recovery milestone | Windows/Linux 324 tests; observed party recovery and combat | Earlier baseline, not the current local source |
| Optional modules disabled | Current Windows worldserver/tests-common built; 19 tests passed | No Linux module-off runtime claim |
| Native equip replay | One empty-slot move saved; owned item identities/counts/captured properties preserved | Relogin, occupied-slot displacement and broader gear coverage remain open |

Linux server runtime remains untested. The Cata test realm and Linux compiler
container were stopped after their completed checks. Intermediate build counts,
donor pins and dated evidence belong in module
[PORTING.md](../../../modules/mod-playerbots/PORTING.md) and the existing
[milestone evidence](PLAYERBOTS_STATE_MILESTONE.md).

## Next two batches

1. Continue the human-led dungeon toward a clear with the existing prepared party.
   The gear/loot milestone now has Windows/Linux 384-test builds, a current
   Windows module-off 19-test build, controlled need/greed/pass/saved-award evidence
   and outgoing review. It is committed locally, awaiting publication; do not
   repeat its isolated tests. Address actual tank/healer/recovery failures through
   their owning donor behavior.
2. Extend the connected loot decisions to natural random-affix drops using the
   existing collector and verified native roll metadata. Preserve actual Cata
   property/suffix/factor semantics and unsupported-effect distinctions. Quest/
   master synchronization, profession/vendor, token and disenchant decisions
   remain later item-usage groups. Choose subsequent ports to support the party's
   observed needs, without reopening infrastructure or making every missing
   category a dungeon prerequisite.

Useful optional observations can join that replay: occupied-slot equip and saved
relogin, command/state transitions, target loss and MultiBot ACK/STATE/restore.
Their absence is a documented limit, not a reason to force separate tiny tests.
Multi-tank checks require an actual two-tank fixture.

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
