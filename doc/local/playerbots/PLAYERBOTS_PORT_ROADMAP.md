# Cataclysm Playerbots roadmap

Updated 2026-10-22. The goal is AzerothCore Playerbots and MultiBot functionality
on TrinityCore Cataclysm 4.3.4. This is a port: upstream behavior and architecture
are the primary reference. Adapt where native Cata APIs or ownership require it,
and record those differences in module PORTING.md.

The immediate gameplay milestone is a useful human-led dungeon party.
Autonomous populations, quest travel and group formation remain a separate track.
Other Cata ports may provide compatibility research; their feature lists do not
replace upstream behavior or evidence from this implementation.

## Current capabilities

| Area | Current scope | Remaining dependencies |
| --- | --- | --- |
| Foundation | Optional modules, native asynchronous sessions, managed rosters, bounded character creation, MultiBot lifecycle/control | Autonomous population scheduling and progression |
| Shared AI | Combat/noncombat/dead engines, control transitions, target reassessment, tank/healer support, recovery and nearby corpse looting | Wider encounter/positioning coverage and a complete human-led dungeon |
| Classes | Starter Warrior/Mage spec routes and Priest support; default-off Rogue/Hunter foundations | Rogue/Hunter live replay, missing spec abilities, other classes and high-level coverage |
| Hunter pets | Native control/call/revive/mend for an existing owned pet | Taming/creation and broader pet behavior |
| Inventory | Level-10–39 starter scoring for supported Warrior/Mage/Priest specs, explicit equip/bag upgrades, guarded native loot votes, positive retention | Rogue/Hunter scoring, broader item classification and mutation/persistence coverage |
| Quests | Native shares, selected-giver acceptance, inspection, explicit rewards and separately gated abandonment | Autonomous travel, chains, reward selection and master-progress synchronization |
| Maintenance | Selected-NPC repair, recovery resupply, limited gray-junk sales and class training | Bundled live qualification, broader vendor policy and autonomous scheduling |

Unknown or incomplete item facts do not authorize a sale, equip or reward.
Shared quest drops are exempt from optional human-first loot deferral.
Native eligibility, inventory, spell, session and database behavior remains
authoritative. Basic class admission is not full class parity.

## Published checkpoint and validation

The October 21 alpha is published as core `2e03c2a31ee39bd2c39f958014fed9b5de607307`
with module `39e7000b6a361bbd455ac006efb6d0d386febe13`.
The core README records matching optional-module pins.

The October 22 documentation refresh pins module
`1661edaf711ef175cd96a80630bb7738b6a54f18`. It changes documentation and config
comments only; gameplay scope and dated validation remain those of the milestone.

- October 13 Windows/Linux worldserver and tests-common builds passed **476/476**
  each with all three installed optional modules enabled.
- Windows worldserver/tests-common with all three disabled passed **20/20**.
- Later helper/documentation cleanup and the explicit Creature include correction
  have not received a new canonical full native build. Linux realm runtime is
  untested.
- Four-bot outdoor/Ragefire checks observed engagement, role actions, healing,
  recovery, corpse opening and instance entry. Separate equip, loot-vote and
  human-led quest checks have saved-result evidence.
- The October 13 party replay and human-reported manual populated-bag swap are
  accepted observations. They do not establish bot-driven bag replacement,
  maintenance purchases/sales/training, every spell effect or a full clear.

Six level-20 bots are prepared in a stopped disposable copy: the original four
plus Combat Rogue and Marksmanship Hunter with an existing saved native pet.
The reuse helper includes all seven actors in observer capture. Its service-free
checks passed; the expanded raid and Rogue/Hunter gameplay remain untested.
See the [handoff](PLAYERBOTS_WORK_PACKETS.md) and
[fixture](PLAYERBOTS_PARTY_FIXTURE.md) for reproduction prerequisites.

## Next two batches

1. Run the prepared combined outdoor raid with Rogue and Hunter. Confirm native
   login, group/map/phase, engagement, pet response, recovery and clean logout
   together. Address demonstrated blockers as connected donor ports. Further
   class work can continue offline while a client session is unavailable.
2. Use a five-player subset for one human-led Ragefire clear, combining combat,
   recovery, loot and convenient selected-NPC maintenance checks. Review the
   [MultiBot feature map](PLAYERBOTS_MULTIBOT_FEATURE_MAP.md) for interface gaps.
   Fix shared blockers before expanding isolated spells or maintenance features.

Use durable enemies appropriate to the roster's level and damage. A seven-player
outdoor raid is not the dungeon fixture. Dedicated dungeon entry must confirm
all bots in the party's instance; ordinary summons do not prove successful entry.

Broader classes, advanced spec mechanics, autonomous population, travel and
progression follow after these immediate batches. Missing suitable drops or
quests is deferred coverage, not a reason for repeated isolated client checks.

## Context companion

The separate context project owns its exporter, query/MCP interfaces and
expansion-specific adapters. Core/Playerbots provide optional hooks and bounded
passive engine history; the companion application is not shipped in this pair
of repositories. Its own current documentation owns release and interface status.

Use existing read-only context for fixture preflight and concrete failures:
identity/session, alive state, map/instance/phase, controller/group, target,
resources and recent engine actions. Check freshness and sample skew first.
Selected target is not necessarily attack victim; an action return is not proof
of a landed spell or completed asynchronous operation.

Observer expansion does not block the next gameplay port. Request a contract
extension only when an actual diagnostic gap warrants it. External readers
receive copied facts and never acquire live game pointers or mutation authority.

## Working rules

- Check current upstream master for each port; record immutable donor revisions,
  reused behavior, Cata adaptations and validation in module PORTING.md.
- Prefer connected feature batches and one build per meaningful batch. Use
  bundled gameplay checks for operational evidence, not per-spell certification.
- Keep map-engine reads on their owner and world/group mutations on native paths.
  Never retain live game pointers across asynchronous ownership boundaries.
- Inspect control, state, group, map, instance, phase and arrival before treating
  a fixture failure as a gameplay bug.
- Preserve default-off gates and optional-module builds. Linux portability is
  required for the server; Linux client compatibility is not a project goal.
- Keep public docs portable; private runtime captures and credentials stay ignored.

Dated implementation/build detail remains in the module's
[PORTING.md](https://github.com/iotadev/cata-playerbots/blob/main/PORTING.md),
[development history](PLAYERBOTS_DEV.md), [milestone evidence](PLAYERBOTS_STATE_MILESTONE.md)
and [older roadmap](PLAYERBOTS_PORT_ROADMAP_HISTORY_2026-10-04.md).
