# Playerbots development handoff

Updated 2026-10-05. Start here, then read only the linked document needed for
the task. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns priorities;
[PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns donor pins and
adaptations; [milestone evidence](PLAYERBOTS_STATE_MILESTONE.md) owns results.
Earlier detail remains in the existing dated histories.

## Current position

- Published infrastructure: module `70014ce`, core `92f41cf`. The shared-state
  operational module milestone is committed locally as `520051d`; the matching
  core milestone pins that revision. No publication push has been made.
- Windows and Linux modules-enabled worldserver builds passed 318/318 checks;
  Windows modules-disabled passed 19. Addon reader/timer mock passed. Rebuild
  only when source changes justify it. Linux realm runtime remains untested.
- October 4 outdoor replay observed four-bot engagement, role actions, return
  to noncombat, corpse opening and group loot removal. Sustained support and
  aggregate ACK/STATE/restore remain unobserved.
- October 5 dungeon preparation failed at bot transfer. All four had joined the
  party; the human entered Ragefire. Ordinary `.summon` did not produce completed
  bot arrivals. The copied realm subsequently shut down cleanly.
- The corrected October 5 replay completed all four arrivals in the same Ragefire
  instance, several trash pulls, Warrior/Mage actions, Priest Renew, state return
  and native corpse opening. The player reported working behavior; services
  stopped cleanly and no assertion appeared. Basic party operation is accepted.

## Next bounded batch

The corrected recipe adds `-DungeonFixture` alongside `-RecoveryLoot`.
Recovery-only mode still stays outdoors. The current bot
adapter acknowledges far transfers only when the dedicated `joininstance` path
sets its acknowledgement budget; ordinary cross-map `.summon` is not a supported
substitute. Do not diagnose this incident as phasing or tell the user to change
phases. General far-transfer support is a separate donor-porting decision.

The harness sends console `joininstance` after the human party has a Ragefire
bind and confirms all four completion logs against that instance. Parser and a
mocked execution of the actual entry branch passed: recovery alone skips entry;
combined recovery/dungeon dispatches and checks all four. Native entry passed
the corrected client replay. Preserve the prepared roster and use the
[fixture](PLAYERBOTS_PARTY_FIXTURE.md) recipe.

Continue development with donor tank/healer coordination and recovery for a
longer human-led dungeon. Measured healing, resource-pressure recovery, stop/resume,
death/resurrection and addon aggregate ACK/STATE/restore were not established by
this brief replay; observe them in the next useful party session. Optional spells,
mounts and forced deaths are not separate prerequisites. Collect concrete failures
into one donor-aligned corrective batch.

## Working constraints

Prefer current upstream Playerbots/AzerothCore behavior with immutable provenance
over new local designs. Preserve Cata world/map/session authority. Work in bounded
feature groups, compile once per meaningful batch, and bundle runtime checks.
Avoid another round of general audits or isolated spell tests without new evidence.
The [candidate review](PLAYERBOTS_CANDIDATE_REVIEW.md) already covers selected
group authority, lifetime and publication paths; it did not validate general
far transfers. Warrior facing/idle remains unconfirmed. Broad class/spec coverage
and population autonomy follow the human-led party work on separate tracks.
