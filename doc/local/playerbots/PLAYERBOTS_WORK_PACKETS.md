# Playerbots development handoff

Updated 2026-10-05. Start here, then read only the linked document needed for
the task. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns priorities;
[PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns donor pins and
adaptations; [milestone evidence](PLAYERBOTS_STATE_MILESTONE.md) owns results.
Earlier detail remains in the existing dated histories.

## Current position

- Published infrastructure: module `70014ce`, core `92f41cf`. The shared-state
  operational pair is module `520051d`, core `6b81a13e38`. The newer coordination/
  recovery module milestone is published on GitHub main as `9f99b27`; this core
  publication handoff pins that revision.
- Windows and Linux modules-enabled worldserver builds passed 324/324 checks;
  The preceding Windows modules-disabled build passed 19. Addon reader/timer mock passed. Rebuild
  only when source changes justify it. Linux realm runtime remains untested.
- October 4 outdoor replay observed four-bot engagement, role actions, return
  to noncombat, corpse opening and group loot removal. Aggregate ACK/STATE/restore
  remains unobserved; the later recovery session is summarized below.
- October 5 dungeon preparation failed at bot transfer. All four had joined the
  party; the human entered Ragefire. Ordinary `.summon` did not produce completed
  bot arrivals. The copied realm subsequently shut down cleanly.
- The corrected October 5 replay completed all four arrivals in the same Ragefire
  instance, several trash pulls, Warrior/Mage actions, Priest Renew, state return
  and native corpse opening. The player reported working behavior; services
  stopped cleanly and no assertion appeared. Basic party operation is accepted.

## Coordination/recovery milestone

The published batch ports donor healer mana conservation from refreshed
master `037c01418b5d01506917a3db9b44fd56ac5f965c`. Optional module-local
`Playerbots.Healing.SaveMana.Enabled` defaults off. Both healing paths apply
the donor percentage/efficiency/tank rules at native candidate eligibility.
Three boundary tests cover the policy. Conservation was enabled during the later
party session, but suppression decisions and quantitative savings were not
measured. See module PORTING.md for adaptations and dated intermediate results.

The batch also unifies initial/reach/ongoing melee chase with existing
role-aware movement eligibility. A designated tank keeps front positioning
while recovering aggro; a non-tank victim also stays front until aggro is lost.
This is a consistency correction to the donor-backed Cata movement adapter,
not a verified fix for the historical Warrior idle observation. One regression
was added. Detailed tank
orientation remains unconfirmed; basic party operation passed the later replay.

Recovery execution and ready-check inventory counting now share donor food/drink
subclass and item-category translation. Active rest records the chosen recovery
mode so drinking completion uses mana even if the spell category differs from
the item's on-use category. Two regressions cover translation and completion/reset;
Windows and Linux worldserver/tests-common built and all 324 tests passed on each.
Linux used the saved Ubuntu 22.04/GCC 11.4 normal-PCH build with refreshed module
sources. Logs are local in `build/linux-coordination-20261005/`; the compiler
container is stopped. The subsequent Ragefire replay confirmed visible eating/
drinking and logged native drink starts for both casters, 48 accepted Priest heal
casts and repeated tank aggro recovery. All four held on owner death and resumed
following once the owner was alive nearby. The harness exited zero and test-owned
services shut down cleanly. Quantitative mana savings and Priest resurrection
were not established. Evidence: `build/playerbot-smoke-20261005-113123/`.
Native item handling and regen remain unchanged.

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

## Next bounded batch

Audit/port donor main-tank coordination: explicit main-tank assignment and
multi-tank target retention, using native Cata group flags and the existing role/
target-selection boundary. Keep session and map ownership unchanged. Continue
the human-led dungeon toward a clear without repeating accepted basic recovery.
Measured mana savings, detailed positioning, Priest resurrection, stop/resume and
addon aggregate ACK/STATE/restore remain optional observations in useful sessions.
Do not turn mounts, forced deaths or isolated spells into separate prerequisites.

## Working constraints

Prefer current upstream Playerbots/AzerothCore behavior with immutable provenance
over new local designs. Preserve Cata world/map/session authority. Work in bounded
feature groups, compile once per meaningful batch, and bundle runtime checks.
Avoid another round of general audits or isolated spell tests without new evidence.
The [candidate review](PLAYERBOTS_CANDIDATE_REVIEW.md) already covers selected
group authority, lifetime and publication paths; it did not validate general
far transfers. Warrior facing/idle remains unconfirmed. Broad class/spec coverage
and population autonomy follow the human-led party work on separate tracks.
