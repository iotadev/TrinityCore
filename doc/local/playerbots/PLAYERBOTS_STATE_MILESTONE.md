# Shared-state gameplay milestone

Updated 2026-10-05. This implements the shared gameplay behavior batch identified
by the architecture audit; the outdoor replay below establishes partial gameplay
acceptance, with sustained dungeon/support observations still open. It does
not reopen accepted login/factory/module work.

## Post-milestone coordination/recovery source validation — 2026-10-05

The subsequent completed Ragefire session (`build/playerbot-smoke-20261005-113123`)
has player-confirmed eventual eating/drinking. Console evidence records native
drink starts for Botmage and Botpriest, 48 accepted Priest healing casts at the
checkpoint and repeated Testone party-aggro recovery requests. No assertion/fatal
match was present in that capture. Visible eating is player-reported; a food-start
log was not captured at this checkpoint. Conservation was enabled in the copied
test configuration, but its individual suppression decisions and quantitative
mana savings were not measured. Final capture records 86 accepted Mage damage
casts and 89 selected Warrior role/attack action matches. All four bots logged
owner-death holding and subsequent nearby-alive follow resumption; this does not
establish Priest resurrection. The harness exited zero after bot logout and
worldserver shutdown. Test-owned auth/world/MySQL processes exited, and MySQL
recorded normal shutdown completion. Detailed tank orientation remains unconfirmed.

Optional healer mana conservation, consistent tank/front chase decisions and
food/drink metadata/completion mode changes built worldserver/tests-common on
Windows and Linux. Each platform passed all 324 registered tests. Linux used
the existing Ubuntu 22.04/GCC 11.4 Release build, normal core/script PCH and
two workers against a refreshed native-filesystem source copy. This is an
uncommitted snapshot, not an exact published revision. Local configure/build/test
logs are retained in ignored `build/linux-coordination-20261005/`.

The isolated compiler container stopped after validation; game realms stayed
stopped. These results do not add gameplay acceptance. Sustained conservation,
positioning and native item recovery remain for the next useful party session;
Linux realm runtime remains untested.

## Dungeon setup attempt — 2026-10-05

The corrected replay below supersedes this setup failure for dedicated dungeon
entry. General cross-map summon support remains outside the accepted path.

All four prepared bots joined the human's party. The human entered Ragefire;
ordinary summon commands were recorded, but completed bot arrivals were not.
Source inspection found that far-transfer acknowledgement is gated by the
dedicated dungeon-entry budget. The selected `-RecoveryLoot` harness mode skips
that entry flow. This supports an incomplete-transfer explanation, not a confirmed
phase mismatch; no live transfer-state inspection was captured.

This attempt adds no dungeon gameplay acceptance. The console capture and MySQL
shutdown log confirm clean disposal of the realm. Evidence remains local in
`build/playerbot-smoke-20261005-101025`. Correct the harness recipe before retrying;
the prior platform builds and outdoor observations remain valid.

The harness subsequently added explicit `-DungeonFixture`, compatible with
recovery settings. It resolves the human party's bound instance, dispatches four
dedicated entry requests, and waits for matching arrival logs. Parser checks and
a mocked execution of this actual branch passed with recovery-only and combined
modes. No new native dungeon-entry success is claimed from this check.

## Corrected Ragefire replay — 2026-10-05

The corrected recovery/strategy/dungeon fixture completed dedicated entry for
all four bots into map 389, instance 1. The player reported that everything
seemed to work. Across several trash pulls, the full console capture records
both Warriors' combat, nine Mage cast submissions (seven in the damage summary),
one Priest Renew submission, tank Taunt/Shield Slam/Rend/Victory Rush submissions,
combat/noncombat transitions and one native corpse opening. No assertion was
found. All bots saved/logged out and world/auth/database shutdown completed;
the harness exited successfully. Local evidence is
`build/playerbot-smoke-20261005-103029`.

This accepts the current party's basic dungeon operation and corrected fixture
entry. It does not establish a full clear, measured healing or loot awards,
resource-pressure recovery, death/resurrection, stop/resume or aggregate addon
ACK/STATE/restore timing. Those observations remain deferred; no repeat realm
session is required solely to exhaust optional checks. Close this operational
milestone and use a longer human-led dungeon for the next coordination batch.

## Outdoor replay — 2026-10-04

The prepared level-20 Protection/Arms/Frost/Holy party completed Luzran and later
nearby combat. The player reported successful engagement; the console capture
records both Warriors using their role actions, Mage damage, three Priest Renew
casts, return to noncombat and seven native corpse-opening events. These are
accepted casts/open requests, not measured healing, consumable use or loot awards.
Luzran died quickly; sustained tank/healer pressure, resurrection and advanced
optional slices remain unqualified. Follow requests completed for all four bots;
the hold displacement itself was not explicitly confirmed by the player.

The strategy fixture initially omitted the MultiBot bridge gate. The harness and
copied runtime config were corrected, and the player reloaded config and retried.
A client screenshot of subsequent `nc ?` replies shows `loot` absent from all
four noncombat lists. The query's "unchanged" status describes the query itself.
Aggregate ACK timing/counts, framed STATE refresh and the requested restoration
were not supplied, so those observations remain pending for the next combined
session. In-memory strategy edits are not a persistence feature.

All four bots saved/logged out and worldserver, authserver and the copied database
stopped cleanly. No assertion was found in the complete console capture. Private
evidence is `build/playerbot-smoke-20261004-212953`; keep its raw account/runtime
details out of publication. Config reload reopened Server.log, so final harness
summary counts now use the complete process console capture instead.

## Source and platform validation

The current Linux Release `worldserver` and `tests-common` build passed on
Ubuntu 22.04/GCC 11.4 with both optional modules and normal core/script PCH enabled.
CTest passed 318/318 checks with no failures. A native-filesystem copy of the
uncommitted source excluded generated builds, Git metadata and active `.conf`
files; this validates that source snapshot, not an exact published commit.
Raw configure/build/test logs are retained in the ignored local directory
`build/linux-milestone-20261004/`. No Linux realm runtime was tested.
The earlier [focused protocol check](PLAYERBOTS_LINUX_STRATEGY_CHECK.md) also
passed 30 cases and 4,380 assertions under GCC 13.3.

The follow-on opt-in group dispatch/delivery integration now adds bounded pending
batches, account/character/login binding and native execution-time membership
checks. Final reviewed Windows worldserver built and all 318 checks passed;
both-modules-disabled worldserver built with 19/19 checks passing. Evidence
below belongs to preceding transport/policy batches. Native group-command
timing remains open; see the partial outdoor replay above. Linux build/test
validation is complete as recorded above. The following counts are historical
batch checkpoints, not the current validation status.

The follow-on native batch-correlation hook and bounded completion inbox passed
Windows modules-enabled worldserver build and all 312 checks. Five added cases
cover copied mailbox/transport policy and concurrent producers/drain. The prior
307-case snapshot added six pure aggregation/correlation cases. Neither proves
native group dispatch, membership/session timing or gameplay. Group mutation
fanout was not yet connected at that snapshot. The matching both-modules-disabled worldserver build
also passed all 19 core-only checks. Linux validation remains pending.

The results below accept the saved shared-state candidate, not every later
uncommitted gameplay change. Follow-on movement/range/support work reached a
successful reviewed Windows worldserver build and 301 passing checks on 2026-10-04,
including the readiness/supply/deferred-rebuff bridge, shared strategy-aware roles
and default-off learned ground-mount follow slice. Mount checks are pure policy
coverage, not native cast/data or gameplay acceptance.
The latest three cases cover optional donor focus categories, scoped Mage
target/positivity metadata and a production-multiplier engine replay. Existing
Frost Nova now participates in focus/area-threat guards, but native spell data
and gameplay remain unqualified; no new AoE spell or pull-safety system was added.
The preceding two combat-utility control cases cover state allowlists/copied correlation
and class-default restoration, preserving unrelated roles/specs. Existing ACK
tests now cover C success/failure fields. Native chat/addon timing remains pending.
Combat focus/threat/potions and noncombat food/loot are supported; dead state is query-only.
Final secondary-interrupt review validation passed. Expanded primary/secondary
trigger coverage plus one new admission-policy case do not prove native preflight,
target lifetime/cast-race timing or landed effects. Existing class gates apply.
The preceding two cases cover Healthstone classification/lockout/fallback wiring and
engine preference/fallback with available, unavailable and rejected actions.
Readiness stock shares execution's bounded potion classifier; stones do not
substitute for explicit potion stock. Native effects/cooldowns remain pending.
The preceding combat-potion review validation passed. Its three cases cover
thresholds, availability policy and trigger priorities, not native consumption,
restoration or cooldown timing. The option defaults off; runtime remains pending.
The preceding two cases cover shared area-threat maximum aggregation and the donor
50%/80% guards/exemptions. Native attacker resolution is source-reviewed, not
gameplay-tested. No new AoE action or area pull-safety claim is included.
The preceding six cases cover bounded MultiBot mutation parsing/counts/replay and
copied correlation. Map-thread completion/snapshot ordering was source-reviewed;
native client behavior remains pending. Group/role changes reject, not succeed.
The preceding five cases cover read-only MultiBot request/framing/freshness policies.
GM-read review and modules-disabled snapshot-hook build validation passed;
native addon consumption is not confirmed by pure response tests.
The preceding four cases cover bounded strategy chat/state routing, protected
features and copied expiring/cancellable requests with timer wrap. Controls
default off; that initial slice exposed only food/loot mutations. The newer combat
utilities above extend it and remain native-runtime pending.
The preceding six cases cover the internal donor strategy-operator layer: bounded
requests, atomic rejection, queue preservation/cleanup, sibling permissions and
state isolation. It does not implement persistence, reset or spec overrides;
the owning transport above does not advertise structured addon mutation parity.
The preceding five cases cover the default-off stay control's mailbox, phase identity,
owned movement/lifecycle policy and retry timing. Enabled stay now activates the
donor noncombat strategy; disabled stay keeps its old hold behavior, while hold
remains plain stop. Native authorization/path/cancellation timing is client-pending.
Its latest Linux-validated subset had 219 cases (218 passed, one expected
failure); newer slices remain pending while Docker's Linux engine is unavailable.
See the roadmap and module PORTING.md for the current scope and adaptations.
Neither result replaces the outstanding integrated runtime acceptance.

On 2026-10-04 the regenerated Windows build with both optional modules disabled
also passed worldserver/tests-common and all 19 core-only checks for the current
strategy snapshot/command/correlation hooks and preceding stay hook/getter snapshot.
This closes the current Windows build boundary, not disabled
gameplay or Linux acceptance. The active handoff was consolidated; superseded
packets are preserved verbatim in PLAYERBOTS_HANDOFF_HISTORY.md.
A targeted source review checked copied ready-check identities, world-thread
reply revalidation, atomic role-mask reads and default-off feature settings.
Whitespace checks passed in both repositories. A targeted scan found none of
the earlier personal account identifiers in Playerbots docs/source/config/tests;
this is not a comprehensive security or final publication audit.
The user deferred the bundled replay while remote; the stopped fixture remains
prepared. No realm, commit or push was performed for this validation pass.

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
