# Cataclysm Playerbots roadmap

Updated 2026-10-02. This is the current plan. Dated details and superseded plans
are retained in [development history](PLAYERBOTS_DEV.md), research packets and
module PORTING.md. The target is AzerothCore Playerbots/MultiBot functionality
on native Cata, with upstream reuse preferred over replacement.

## Current capabilities

The published infrastructure milestone is accepted: default-off optional module
integration, native server-origin sessions, asynchronous character loading and
cleanup, managed existing-character roster, bounded native character creation,
ordinary-player coexistence, party ownership and MultiBot connect/disconnect.
The matching revisions are module `70014ce` and core `92f41cf`. See
[infrastructure acceptance](PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md).

Local gameplay adds shared values/target selection, spec-aware Warrior/Mage
routes, Priest healing/cure/support, threat gating, interrupts, recovery, Mage
armor, loot movement and native corpse storage. Learned spell/proc/defensive
actions are implemented but not comprehensively qualified. These are bounded
donor ports, not complete class or dungeon parity.

A prior level-20 party check observed combat, healing, buffs, corpse opening
and clean logout. It did not qualify assigned talents, item awards, recovery
consumables or later role/target changes. Advanced spells await suitable fixtures.

The current shared-state batch separates combat, noncombat and dead engines.
Transitions, control changes and target loss discard queued work. Native
resurrection/transfer retain their existing session/core ownership. Autonomous
dead-state travel and graveyard release are not implemented. See
[state acceptance](PLAYERBOTS_STATE_MILESTONE.md) for current validation.

## Remaining dependencies

- Run the deferred integrated client check. The source/platform/fixture phase is
  complete and saved as local candidate commits; Windows and Linux validation
  passed. Linux realm runtime remains a separate untested boundary.
- Qualify state transitions with assigned roles, usable equipment, carried
  consumables and enemies durable enough for sustained combat.
- Establish tank/healer coordination under pressure: threat recovery, target
  agreement, healing priorities, positioning and post-death regrouping.
- Run one human-led low-level dungeon. Accepted casts do not prove effects;
  infrastructure acceptance does not establish dungeon competence.
- Expand classes/specs and MultiBot operations in bounded donor-aligned batches,
  keeping unsupported commands truthful.

## Next two batches

### 1. Shared-state gameplay milestone — current work

Code, platform validation, native fixture preparation and local candidate commits
are complete. The next action is the deferred bundled client check using the
saved baseline, followed by outcome documentation and acceptance. Do not rebuild
unchanged code or repeat the fixture's one-time provisioning unnecessarily.

Close stop/follow/attack resume, target loss, native death/recovery and transfer
suspension together. Reuse the decision engine/context and session mailboxes.
Prepare [one fixture](PLAYERBOTS_PARTY_FIXTURE.md), run a bundled operational
check, complete platform validation, audit outgoing provenance/privacy and
commit the matching module/core pair. Do not extend this batch with isolated spells.

### 2. Role coordination and one human-led dungeon

Use the same party fixture to address observed tank/healer and recovery gaps.
Port relevant donor coordination/state behavior, then take the party through
one suitable dungeon with the human leading. Consolidate failures into one
corrective batch. Autonomous dungeon completion is not the gate.

## Separate autonomy track

Population/account creation, autonomous login scheduling, questing, travel,
leveling, equipment selection and autonomous dungeon formation remain future
work. The native character factory is a foundation, not a random-bot population
manager. Reuse compatible donor systems without blocking the human-led dungeon.

## Working rules

Keep native Cata lifecycle/threading, spell, equipment and database authority.
Flags remain default-off. Refresh relevant upstream master references and pin
their revisions. Compile coherent batches and playtest integrated behavior.
Cheap source-discovery delegation is optional; final implementation/review stay
with the primary agent. Keep dated evidence out of the resume plan.
