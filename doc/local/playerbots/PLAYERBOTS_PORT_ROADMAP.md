# Cataclysm Playerbots roadmap

Updated 2026-10-05. The target is AzerothCore Playerbots and MultiBot functionality
on native TrinityCore Cataclysm 4.3.4. Reuse current upstream donor behavior where
it fits; keep Cata's session, map, spell, equipment, loot and database ownership.
The [dated roadmap](PLAYERBOTS_PORT_ROADMAP_HISTORY_2026-10-04.md),
[development history](PLAYERBOTS_DEV.md) and module PORTING.md retain the detailed
source and validation record. This file is the current resume plan.

## Current capabilities

The published infrastructure pair (module `70014ce`, core `92f41cf`) has accepted
native server-origin sessions, bounded character creation, managed roster,
optional module integration and MultiBot connection lifecycle. Later gameplay
work forms a local operational milestone; do not reopen infrastructure merely to continue it.

The shared combat, noncombat and dead-state engines support a bounded human-led
Warrior/Mage/Priest party: role-aware combat and support, movement/follow/stay,
spell reach, interrupts, buffs, recovery, corpse opening, ready-check basics and
learned ground mounts. These are donor-aligned slices, not full class or dungeon
parity. Earlier outdoor/Ragefire checks observed engagement, healing, tank rescue,
target-death return, corpse opening and clean logout. Later slices await a combined
client replay; accepted casts and source tests do not establish native effects.
The 2026-10-04 outdoor replay observed all four engaging, return to noncombat,
Priest Renew casts, native corpse opening and group loot removal in chat queries.
The realm shut down cleanly. Sustained support and addon ACK/restore observations
continue in the dungeon session; see PLAYERBOTS_STATE_MILESTONE.md for evidence.
The corrected October 5 Ragefire replay completed all four arrivals and normal
trash combat with a successful player report and clean shutdown. This closes
basic party operation; full clears and sustained coordination remain ahead.

Default-off MultiBot strategy controls include read-only STATE, single-bot and
authorized group mutations for the supported combat `focus/threat/potions` and
noncombat `food/loot` operators. Group dispatch uses copied identities, bounded
pending batches and a world-thread completion pump. A separate default-off
GroupMutations gate requires the base and addon-mutation gates. Requests are
revalidated at execution and unresolved timeouts remain unknown; refresh STATE
before retrying a toggle. The server closes an unresolved group batch at four
seconds, ahead of the pinned addon's five-second request timer. Client gameplay
timing still needs the bundled replay.

## Remaining dependencies

The October 5 retry stopped at dungeon entry: the selected recovery harness mode
skipped dedicated bot entry, and ordinary cross-map summons lacked bot transfer
completion. The realm stopped cleanly; this attempt adds no gameplay acceptance.
The recipe now uses explicit `-DungeonFixture` with recovery settings and checks
all four arrival logs against the human party's instance. Its parser and mocked
entry branch and corrected native replay passed. See the [handoff](PLAYERBOTS_WORK_PACKETS.md).
General far-transfer support can be ported separately; phase changes are not an
evidence-based remedy for this incident.

- Platform source validation is complete for this candidate: Windows and Linux
  modules-enabled worldserver builds passed all 318 checks; the Windows module-off
  worldserver passed 19. Linux used Ubuntu 22.04/GCC 11.4 with normal PCH enabled.
  Linux realm runtime remains untested. The installed Cata addon reader passed a
  Lua 5.1 mock of ACK-before-timeout and late-ACK behavior. These checks do not
  replace in-game qualification.
  A direct Linux GCC 13.3 strategy/protocol subset also passed 30 cases and 4,380
  assertions; see PLAYERBOTS_LINUX_STRATEGY_CHECK.md and the milestone evidence.
- Use the [prepared party fixture](PLAYERBOTS_PARTY_FIXTURE.md) with appropriate
  level, roles, equipment, consumables and durable enemies. Replay state/control
  transitions, target loss, sustained tank/healer behavior, recovery/loot and one
  group strategy ACK/STATE refresh/restore together in the dungeon continuation.
  Preserve the stopped fixture until a
  client session is available. Record actual failures as one corrective batch.
- The basic operational replay passed. The matching local milestone is module
  `520051d`, core `6b81a13e38`. The newer coordination/recovery module milestone
  is committed locally as `9f99b27`, with its evidence and harness in this core
  update. Remaining optional observations can join later dungeon
  sessions; record their limits when publishing.
- Continue the human-led dungeon attempt under tank/healer pressure. Fix observed
  coordination failures through their owning donor behavior. Autonomous account
  populations, quests, travel and dungeon formation are a separate track.

## Next two batches

1. Extend donor role coordination and recovery after the committed operational
   milestone. Local slices add optional healer mana conservation and consistent
   tank/front versus non-tank/rear chase decisions during aggro transitions,
   plus donor food/drink metadata consistency and resource-based rest completion.
   This batch builds on Windows/Linux and passes 324 tests on each platform;
   source validation is complete. A longer Ragefire session observed basic
   healing/aggro recovery, eating/drinking and owner-death hold/follow resumption,
   with clean shutdown. Quantitative mana savings and tank orientation remain open.
   Source/test qualification and sustained native behavior remain separate.
2. Port donor main-tank coordination as a bounded shared-role/target-selection
   batch. Compare explicit main-tank assignment and multi-tank target retention
   against native Cata group flags without changing session/thread authority.
   Continue the human-led dungeon toward a clear rather than repeating the
   accepted recovery check. Port larger donor feature groups where it exposes a gap;
   keep full class/spec coverage, pets, travel and autonomy on separate tracks.

Working rules: keep optional features default-off, retain immutable upstream pins
in PORTING.md, use copied command identities and native execution checks, and
distinguish compiled source from observed gameplay. The Warrior facing/idle episode
remains unconfirmed. No client Linux compatibility work is required.
