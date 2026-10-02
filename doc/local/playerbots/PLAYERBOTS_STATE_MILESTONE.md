# Shared-state gameplay milestone

Updated 2026-10-02. This closes the shared gameplay behavior gap identified by
the architecture audit. It does not reopen accepted login/factory/module work.

## Source and platform validation

- Implemented: separate combat/noncombat/dead engines sharing one class context.
  Only the active engine supplies decision strategies/target exclusions.
- Implemented: state changes clear all pending queues; same-state updates keep
  prerequisites/continuers. Stop, movement control and target replacement/loss
  cancel pending work even when native combat flags have not cleared yet.
- Implemented: suspended transfers do not tick decisions. Death selects an empty
  dead engine. Native resurrection/transfer and follow recovery remain external
  session responsibilities; no autonomous ghost movement was added.
- Implemented: spec refresh changes only combat strategies. Recovery/loot/buffs
  belong to noncombat; Priest healing and cures are registered in both live states.
- Windows worldserver/tests-common: successful build, 195/195 registered checks
  passed on 2026-10-02.
- Linux GCC 11 worldserver/tests-common: successful regenerated build; 195 Catch cases,
  194 passed and one failed as expected, no unexpected failures, 2026-10-02.
  This includes the prior outstanding curse/Spellsteal source. Linux gameplay
  remains untested.

New fixture translation units require explicit CMake regeneration with the
current source collector. An initial incremental link omitted the new source;
regenerated Windows/Linux builds included it and passed. Do not mistake old
generated target lists for validation of newly added files.

The new tests execute real engines and queues: interrupted prerequisites restart,
idle/dead states cannot run combat defaults, continuers survive steady state but
are removed by stop/transfer invalidation, and recovery restores noncombat work.
These tests do not prove native session wiring or live effect outcomes.

## Integrated acceptance — pending

The user deferred the client check. Server-only native fixture preparation passed
on 2026-10-02: Protection 845, Arms 746, Frost 823 and Holy 813, zero free points,
saved talent records, equipped weapons/Protection shield and carried food/water
verified after logout. The copy shut down cleanly. Reusable stopped seed/evidence:
`build/playerbot-smoke-20261002-154407` (ignored; never publish its DB or credentials).
This is fixture readiness, not integrated combat/death/transfer acceptance.

Use [the fixture](PLAYERBOTS_PARTY_FIXTURE.md), then run one session covering:

1. Party buffs/follow, sustained engagement and target fallback.
2. Stop during combat, follow/resume and an explicit fresh attack. No stale
   queued offensive action should execute against the cleared/previous target.
3. Target death/loss followed by another pull; no obsolete prerequisite/continuer.
4. Rest/loot between pulls and interruption by movement or renewed combat.
5. One bot death/native resurrection and follow/combat recovery, if safely
   achievable in the same session. Record if this portion was not exercised.
6. Clean human logout, bot saves/stops and realm/database shutdown.

Corroborate actual behavior with PB-STATE, combat, recovery and loot logs.
Accepted casts/opening alone do not qualify damage, healing or item awards.
High-level utility/procs are outside this level-20 acceptance fixture.

## Outgoing review and candidate commit

Reviewed the outgoing gameplay/state code, native loot/roll/icon seams, map/world
ownership, default-off flags, fixture safety/provenance and source/test packets.
Whitespace checks and harness parsing passed. The public-doc/source scan found
no personal machine/account strings or API credentials in the scoped content.
Both checkouts use the verified publication identity; no runtime artifacts or
private DB/config files belong in the commits. The module candidate is committed
first, then the core pins it. Push and client acceptance are separate steps.
Candidate snapshots are not an accepted integrated milestone. Record the later
party outcomes before changing acceptance status or publishing that claim.

Local module candidate: `e6591786a21e36bb5bdea55168bf63fafc095c38`.
The matching core commit pins it in README; neither candidate was pushed in this
pass. Published infrastructure pins remain historical acceptance evidence.

After acceptance, prioritize tank/healer coordination and one human-led dungeon;
autonomous population/questing remain a separate track.
