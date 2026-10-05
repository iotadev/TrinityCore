# Playerbots handoff history — snapshot 2026-10-03

Preserved verbatim from the development handoff before consolidation. These
are historical checkpoints, not current pending instructions. Use
[the active handoff](PLAYERBOTS_WORK_PACKETS.md) and
[roadmap](PLAYERBOTS_PORT_ROADMAP.md) for current priorities.

---

# Playerbots development handoff

Updated 2026-10-03. Read the [roadmap](PLAYERBOTS_PORT_ROADMAP.md) for priorities
and [development history](PLAYERBOTS_DEV.md) for dated evidence and superseded
work packets. Do not repeat accepted infrastructure work.

## Resume point

Current source slice wires the saved-position foundation through default-off
`Playerbots.Movement.Stay.Enabled`. Exact ordinary `stay` posts a copied requester
identity with map-thread controller/security/safe-state revalidation. Enabled
stay preserves the controller but stops follow/assist, activating the donor stay
strategy only in noncombat. `hold` remains plain hold; disabled stay falls back
to its prior hold behavior. Anchor identities include exact copied native phase/
terrain sets. Follow/hold/control, death, controller loss, transfer and phase
changes clear mode/anchors; native near ACK cannot conceal transfer invalidation.
Only a distinct owned Player point movement is cleaned up. Native returns yield
to casting/recovery/party combat and retry at most once per five seconds.
Broader random-return/guard travel, combat stay and persistence remain separate.
Next is platform and bundled control/lifecycle acceptance or another bounded
donor feature group, not extending this slice into autonomous travel. Keep the
prepared realm stopped while the user is remote.

Platform review: the newest Windows worldserver/tests-common build passed all
267 checks after final stay cancellation cleanup. The foundation had passed 262.
The preceding modules-disabled worldserver/tests-common build passed 19 core-only
checks on 2026-10-03 with both modules off. The new stay hook/native read-only
getters require a fresh module-disabled validation; those 19 checks do not cover
the newest core snapshot.
Linux remains pending: Docker's Linux engine is unavailable, and the existing
Ubuntu installation lacks the CMake/dependency setup needed for an alternative
build. No packages or host settings were changed to work around this.

The user is remote for the next few hours and deferred the bundled party check.
Keep the stopped fixture prepared; do not start the realm to wait for a client.
Next work may continue as bounded donor source ports/review while acceptance
waits. The milestone still needs Linux validation, bundled gameplay evidence
and an outgoing pair/provenance review before commit/publication.

The preceding slice ports default-off learned ground-mount following from donor
CheckMountStateAction. The map-thread follow adapter selects a native eligible
learned ground mount and yields to commands/combat/recovery. It pauses follow
refresh during its own cast and resumes native follow after rejection or cleanup.
It grants no riding/mount spells, manipulates no flight flags and does not port
flight/forms/preferences/item mounts or autonomous travel. Runtime acceptance
belongs in the bundled replay, with an already trained/learned ordinary ground
mount; the level-20 fixture does not guarantee either prerequisite.
Windows worldserver/tests-common built and all 257 checks passed. Linux
and bundled client acceptance remain pending; no runtime was started.

The preceding slice ports shared strategy-aware roles. An atomic combat role mask is
published through a narrow read-only session hook; no peer accesses another bot's
live engine. Ordinary players/uninitialized bots use native Cata tree/form roles.
Party ordering, tank-threat/rescue/target logic, DPS weighting and melee positioning
share the helper. Priest fallback healing is ranged; cure is utility, not a healer
role by itself. More human specs are recognized, not added as supported bot classes.
Windows worldserver/tests-common built and all 252 checks passed. Linux/module-off
and bundled client acceptance remain pending.

Ground-mount source is now present; broader donor travel still needs its owning
strategy/control dependencies. Choose the next bounded donor behavior group
from the remaining roadmap rather than extending this slice with flight or
an isolated spell. Close platform validation and the bundled acceptance before
calling the accumulated gameplay work a milestone.
Keep the newer role/support/readiness work in one party replay; role metadata and
compile success are not runtime acceptance.

The preceding slice extends the default-off native bridge with carried usable
food/drink/healing-potion/mana-potion checks and optional deferred rebuff. Pass
serial/ownership separates finish from cancellation and preserves newer manual
work. Final replies reevaluate operational state and supplies; native world-thread
group/check validation remains authoritative. Windows worldserver/tests-common
compiled and all 247 checks passed;
Linux/module-off and client acceptance remain pending. The level-20 fixture has
food/drink but no guaranteed usable potions, so missing supplies mean not-ready.

That slice's next source choice was strategy-role coverage or ground mount/travel,
not another transport or isolated spell. Keep ready/rebuff runtime acceptance
in the existing bundled party replay. Full buff/encounter readiness remains out
of scope; native potion effect/use integration is not proved by possession checks.

The preceding slice added the default-off native basic readiness bridge. Authorized
world-thread initiation posts copied group/check/initiator/time identities;
map-thread HP/MP/proximity/life/combat/transfer/cast/rebuff checks post one reply.
The world thread rechecks group membership, initiator authority, generation and
30-second expiry before the one-byte Cata native answer. A replacement check or
authorized finish invalidates old work. Full supply readiness and automatic
rebuff/deferred replies are not implemented. Windows worldserver/tests-common
compiled and all 242 registered checks passed for this newest slice.
Linux/module-off and bundled client acceptance remain pending.

That slice's planned next batch was donor supply checks and optional
rebuff/deferred confirmation as one bounded dependency group, without reporting
ready solely because buff work ended. Keep native group replies on the world
thread. Do not add another ready-check transport or generic engine-command hook.

The preceding slice ports manual force-rebuff: exact ordinary chat `buff`, a specific
session-owned GUID/timestamp mailbox, map-thread authorization recheck, bounded
refresh window/margin and native buff-GCD tracking. Pending passes force fresh
buff checks and noncombat Priest heals yield to buff work/GCD. Death, transfer
or controller change cancel; combat pauses within the timeout. Pass end is no
current eligible work, not proof of all-party coverage or readiness. Windows
worldserver compiled and all 238 checks passed; Linux/module-off and client acceptance remain pending.

That slice's planned owning step was the native readiness bridge: Cata's handler is world-thread
only and answer payload is one state byte, unlike donor GUID+state. Review
initiation/group/initiator/generation/expiry and truthful readiness conditions
together. Do not call the native Group/ready handler from a map action, fabricate
ready replies, or mistake trigger scheduling/manual buff completion for readiness.
The new force-rebuff state stores no native Player/SpellInfo pointer.

The preceding slice adds Priest `party member to heal` and shared qualified
`party member without aura` GUID values. Healing triggers inspect the fresh
health/distance-selected patient; spell actions preserve full eligibility and
native rejection fallback. Aura qualifiers map the two existing Mage/Priest
buff routes to native Cata variants. Present auras satisfy normal coverage;
duration-based force-rebuff was added in the subsequent slice. Healing rejects unavailable,
transferring, GM, charmed and unfriendly candidates. Windows worldserver compiled
and all 234 checks passed; Linux and bundled client coverage remain pending.

That slice planned donor force-rebuff state/refresh/readiness dependencies together
if selected, with native GCD and Cata session ownership reviewed. Do not confuse
existing trigger force-check scheduling with the full rebuff state. Other coherent
follow-ons are strategy-role coverage or ground mount/travel; no blanket movement
rewrite is needed. See PORTING.md for unsupported qualifier and healing boundaries.

The preceding slice registers donor-named `party member to dispel` and Priest
`party member to resurrect` GUID values. Cure checks and resurrection consumers
use fresh context lookups; native map re-resolution and cast guards remain.
Cure execution retains ordered rejection fallback rather than casting only the
first value candidate. Numeric dispel qualifiers are strictly parsed and limited
to implemented Mage curse/Priest disease routes; self-cure remains separate.
Windows worldserver compiled and all 231 checks passed; Linux and bundled client
validation remain pending. See newest module PORTING.md for the in-range versus
approach distinction and donor adaptations.

That slice's next source batch was named healing/missing-aura values with their owning
eligibility/refresh policies. Do not alias donor names to incompatible blanket
spell rules or add generic engine commands. No new core/lifecycle work is needed
for these value registrations.

The preceding slice ports donor InvalidTargetValue control protection across target
ranking, explicit/automatic admission, retained combat and shared positioning.
Polymorph/charm/fear/isolation are excluded; root/stun are not blanket exclusions.
Existing cease cleanup cancels queued work and autoattack, not launched spells,
projectiles or periodic effects. Windows worldserver and all 229 checks passed; Linux and
native runtime timing remain pending.

Movement ownership audit is complete for the present bounded batch. Native chase
already owns angle/distance/LOS/collision/pathing. Full donor geometry requires
movement priority/history and recent-flee dependencies together, not copied
fragments. Do not extend this batch just to chase full travel/ghost/vehicle parity.

The preceding slice applies shared donor role/subgroup selection to Mage curse removal,
Priest disease removal and Mage/Priest party buffs. The old cure health sort is
removed; healthy candidates and cast-rejection fallback remain. Native living
support filters are shared, grouped support stays in the actual group, and
ungrouped attached-controller support remains an explicit Cata adaptation.
Self-cure keeps its separate higher-priority action; healing is unchanged.
Windows worldserver compiled and all 228 checks passed; Linux and bundled runtime acceptance remain
pending. See newest module PORTING.md for donor references and excluded features.

The preceding slice shares donor controller/healer/tank/other ordering with Priest
resurrection, preserving subgroup preference and stable ties. Cata active talent
trees/form classify native party members, not new supported bot classes. Corpse
eligibility stays native; approach discovery filters the controller envelope before
choosing a target. Healing keeps its separate health/distance policy. Windows
worldserver compiled and all 227 checks passed. Linux validation remains pending
while Docker's Linux engine is unavailable; the last accepted Linux run had 219
cases. No realm/client test/commit/push. See module PORTING.md for source pin,
adaptations and unported boundaries.

Next: validate the accumulated changes on Linux when its engine is available and
in one bundled party replay. Do not claim that the Warrior idle symptom, native
multi-corpse selection or full recovery parity has been runtime-qualified.

## Earlier slices — dated evidence, not pending instructions

The preceding slice exposes `range` via ordinary whisper/party/raid chat, using the
existing full-control policy and subgroup routing. One copied/expiring request
per module session crosses to the map update through a narrow native hook;
the named action rechecks authority/identity/map/transfer. Initial replies confirm
only queuing; action responses report the applied effective distance. Active
Mage chase refresh uses the validated current victim and existing native chase,
deferring while cast/control guards block movement. No generic engine-command
API, global registry, persistence or addon widget was added.
Windows worldserver compiled and all 225 checks passed. Linux could not connect to Docker and remains
pending. No realm/client test/commit/push. Next: complete platform validation and
include range query/change/reset in the next bundled party replay.

The earlier action-only slice registers the donor-named `range` engine action for Warrior/Mage/
Priest with strict spell/heal query/set/zero-reset parsing, bounded qualifiers,
effective/default responses and full-control rechecking against the event's
same-map requester GUID. This is NOT yet an external chat/addon command.
Next range work needs a bounded session-owned parameterized handoff and explicit
active-chase refresh policy; do not mutate context values in chat callbacks or
add a global command registry. Windows worldserver and all 222 checks passed.
Linux validation could not start: Docker's Linux engine was unavailable. Retry
the existing isolated build when available; 219-case prior Linux evidence is not
acceptance of the new slice. No realm, client test, commit or push.

The earlier movement-permission slice ports the donor's shared CanMove permission seam across engine
combat positioning, session follow/catch-up/chase, support reach and loot movement.
Native control/charm/frozen/polymorph/controlled-slot/travel guards are shared;
vehicle/ghost movement remains rejected. Temporarily blocked initial follow and
Priest follow restoration retain a retry signature. Hold behavior was audited;
full donor stay-position/return semantics remain deferred, with no placeholder
strategy. Windows worldserver and all 219 checks passed. Linux worldserver
compiled; 219 cases ran with 218 passing and one existing expected failure,
with no unexpected failures.
No client replay, commit or push. Native control/recovery timing remains part of
the later bundled party session. See newest PORTING.md for Cata adaptations.

Latest slice ports the donor's specialized `reach party member to resurrect`
prerequisite. Typed heal/resurrect requests use one session-owned support movement
path with rechecked corpse/party/LOS/native spell guards. Resurrection approaches
are bounded and require a living attached controller, idle nearby party and no
eligible injured living patient. Released ghosts/autonomous recovery/full donor
travel remain separate. Windows worldserver and all 218 checks passed. Linux
worldserver compiled; 218 cases ran with 217 passing and one existing expected
failure, with no unexpected failures. Add natural party-corpse approach/cast observation to the
next bundled replay; do not spawn a realm or force a wipe merely for this slice.

Latest slice moves the start of bounded Priest healing approaches into donor-named
`party member to heal out of spell range` / `reach party member to heal`
trigger/action registration at donor priority. Same-update map-owned intent is
consumed by the existing session movement owner, which retains cancellation,
target re-resolution and bounded yield behavior. Priest qualified `range::heal`
now feeds approach positioning; native spell eligibility remains separate.
Windows worldserver and all 215 checks passed. Linux worldserver compiled;
215 cases ran with 214 passing and one existing expected failure, with no
unexpected failures.
No new client session, commit or push. Specialized resurrection reach and full
donor friendly movement remain follow-ons, not part of this slice.

Latest source slice ports qualified manual `range` values and the donor-style
GetRange fallback seam into shared movement. Spell chase/discovery/submission use
one context value; defaults remain 20 yards, with bounded overrides. The heal
qualifier is present for later specialized work, not active Priest movement.
No external range command or persistence is exposed. Windows worldserver and
all 212 registered checks passed. Linux worldserver compiled; 212 cases ran
with 211 passing and one existing expected failure, with no unexpected failures.
Audit correction: upstream generic CastSpellAction has no blanket
prerequisites; port specialized action prerequisites where present, rather than
assuming every spell needs a new prerequisite list. This is not per-spell maximum
range selection. See PORTING.md for donor paths and bounded Cata differences.

Latest source batch extends the shared movement contexts to Mage combat with
donor facing and `reach spell` actions, preserving the existing 20-yard native
chase envelope. Attack-entry facing is shared with the engine facing operation;
Mage engine ticks no longer also apply the session-loop facing fallback. Native
control/cast/spline checks remain. Priest healing movement is unchanged.
Final Windows worldserver and all 210 registered checks passed. Final Linux
worldserver compiled; 210 cases ran with 209 passing and one existing expected
failure, with no unexpected failures. That earlier slice left range and
specialized prerequisites for the subsequent donor audit above;
no live resolution of the Testtwo episode is claimed.

Earlier 2026-10-03 source batch: new `PlayerbotCombatMovement` contexts register donor
facing/reach/behind actions and triggers. Warrior combat strategies consume the
shared seam; casting/control/owner/target/native-victim guards remain. Stationary
melee facing is non-forced, reach preserves an existing chase, and behind uses
native angle-aware chase for non-tanks only. Windows worldserver and all 208
registered checks passed. Linux worldserver compiled; 208 cases ran with 207
passing and one existing expected failure, with no unexpected failures.
This initial movement port does not prove the Testtwo stall fixed or import the
donor's full collision/flee history, attack-time facing or spell prerequisites.
Continue those shared responsibilities in bounded batches rather than adding
one-off stall workarounds. This batch refreshed the earlier withdrawn-draft
outputs; do not deploy an old binary.

The human-led Ragefire replay `build/playerbot-smoke-20261002-232706` completed
four matching native instance transfers, repeated combat/healing and tank rescue,
then clean saves/logout/shutdown. It did not establish a dungeon clear. The
human observed Warriors facing away and Testtwo idling at Oggleflint after prior
logged attacks. That motivated the shared donor combat-movement port above,
not a standalone corrective adapter for each symptom. Source-supported facing
gaps do not establish the full cause of the stall. Preserve the stopped fixture.
Treat other nonblocking issues the same way; safety/crash/data/progress blockers
may require earlier fixes. See the newest PORTING.md checkpoint for evidence.
The standalone facing draft was withdrawn before this engine port. Its build
outputs have now been superseded by the validated shared movement batch; no
standalone correction was retained or live-tested.

Latest client checkpoint: the level-20 party completed a sustained Luzran pull,
healing/damage, target-death/noncombat return and native corpse opening. The human
reported automatic looting; individual item awards were not separately verified.
Four native summon acknowledgments and an earlier tank aggro rescue were logged.
Outdoor replay `build/playerbot-smoke-20261002-231751` saved and shut down cleanly.
Dungeon replay subsequently completed from that copy without `-RecoveryLoot`;
the existing harness sent console-only joininstance requests after the human
established the native Ragefire party bind. Do not give the user
`.server playerbotdev` commands: handlers explicitly reject in-game sessions.
Broader state/recovery policy qualification remains incomplete; see PORTING.md.

Close the shared-state gameplay milestone. Separate combat/noncombat/dead
strategy registrations share one context; transitions/control changes clear
pending actions. Native session ownership, resurrection and asynchronous
transfer remain unchanged.

Follow [state acceptance](PLAYERBOTS_STATE_MILESTONE.md) and use the
[repeatable fixture](PLAYERBOTS_PARTY_FIXTURE.md). Code, platform builds, native
fixture preparation, outgoing review and local candidate commits are complete.
Next, when the user is available, restart the saved baseline and run one
integrated transition/recovery/loot session. Record outcomes and promote or
correct the candidate. Do not rebuild unchanged code solely to resume testing.
Do not extend the milestone with an isolated Mage utility spell.

The native `fixture20` tool and `-RoleFixture -CheckRosterOnly` replay prepare
talents, equipment and consumables before the client session. Keep the feature
default-off and restricted to disposable configured slots; production character
progression remains separate donor-factory work. The user will test later, so
leave a saved/stopped baseline rather than an idle running realm.

Ready baseline/evidence: `build/playerbot-smoke-20261002-154407` (ignored).
All four native roles, equipped weapons/shield and carried food/water were
verified after logout, followed by clean shutdown. Final Windows suite passed
195 registered checks; regenerated Linux ran 195 Catch cases, 194 passed and
one failed as expected. Later client acceptance is still pending; local candidate
commits preserve this phase without claiming integrated gameplay success.

## Evidence boundaries

Published infrastructure pair: module `70014ce`, core `92f41cf`. The newer local
module candidate is `e659178`; its matching core pins it in README. Windows
passed 195 registered checks; regenerated Linux ran 195 Catch cases, 194 passed
and one failed as expected. Native fixture readiness/save/logout passed.
Integrated client acceptance and Linux gameplay remain untested.

The last client check established combat/healing/buffs/corpse opening and clean
shutdown. It lacked assigned roles and recovery items. Warrior late-pull/leash
observations remain evidence, not a universally fixed defect. New fallbacks and
advanced actions need integrated qualification, not separate spell sessions.

## Architecture constraints

- Keep native world/map/session ownership and command mailboxes. Mutate decision
  queues only on the map thread.
- Use explicit state registrations, as the donor does. Strategy type metadata
  is not an execution-state filter. Context objects can be shared without sharing
  pending queues; support healing belongs in both live states.
- Resolve live targets by GUID and retain owner/party/PvE/leash/security guards.
- Preserve native learned spells, cooldowns, talents, equipment, loot and DB
  transactions. Learning a stance alone does not assign a tank spec.
- Refresh upstream master and record immutable pins. The state audit refreshed
  master to `037c01418b5d01506917a3db9b44fd56ac5f965c`; its newer AI changes
  do not alter the separate-engine pattern. Existing action packets retain
  their actual older import pins.
- Keep features default-off and Linux server portability intact.
- Commit validated milestones using the publication identity. Do not infer
  client acceptance from a successful build or push automatically.

## Parallel source work while acceptance is deferred

The user authorized continued bounded development without a client session.
Role coordination may proceed; the shared-state candidate remains unaccepted
until the integrated check. Do not interpret this as permission to skip builds
or claim dungeon readiness.

The first coordination slice connects the existing donor tank-target ranking
to auto-assist acquisition and ongoing combat. Once per action cadence, a
Protection Warrior can replace its target to protect a same-party player.
Explicit attack commands, other recognized tanks, native attack rejection,
crowd-control exclusions and the existing PvE/leash gates are
preserved. It does not pull new enemies or rebalance owned targets by threat.
The next source slice adds shared direct/engine health-distance healing order
and wider Mage/Priest trailing slots. Cure ordering and native range/cast guards
are unchanged. Caster spacing applies to follow, not a new combat repositioning
system. Include tank rescue, healing selection and trailing formation in the
deferred bundled fixture check; these changes are uncommitted on top of the
saved shared-state candidate, not a newly accepted milestone.

Routine direct heals now defer when another live same-map group member is
already casting a direct heal at that target. Emergencies and raids may overlap;
this is native cast inspection, not a predicted-heal reservation system.

Bounded healing reach is now implemented in the native session adapter. It
closes only a 30–40-yard friendly gap near the human leader, yields to eligible
nearby healing, and keeps stay/cast/transfer/leash guards and owned-movement
cleanup. It is snapshot pathing, not the complete donor reach prerequisite
system or continuous tracking. Include a sustained gap and stop-during-reach
case in the same deferred party session, not separate spell smoke tests.

Next dependency is integrated operational qualification of the accumulated role
batch, then one human-led dungeon. If the client remains unavailable, prepare
the dungeon fixture/checklist and audit remaining shared coordination rather
than defaulting to isolated class spells. Preserve native cast/transfer ownership.

The coordination review bounds snapshot reach ownership to native point-motion
completion or three seconds, preventing a stale GUID from indefinitely
suppressing healing decisions. The existing fixture document now includes the
Ragefire human-led follow-on procedure. These are source/preparation results;
the realm remains stopped and client/dungeon acceptance is pending.
Pre-acknowledgment uncommitted coordination source passed Windows worldserver plus all 202
registered checks, and Linux worldserver plus 202 cases (201 passed, one existing
expected failure). Keep this distinct from the saved shared-state candidate's
older 195-check evidence above. Do not push or mark client acceptance implicitly.

The short client attempt in `build/playerbot-smoke-20261002-163445` prepared
all four roles and observed party joins/follow attachment. The human teleported
to the durable enemy, but reported individual summons failed; traces showed
bots still walking from the original area. No Mage offensive or Priest healing
casts were recorded, and the alternate group summon was not confirmed before
logout. Treat this as incomplete setup, not combat acceptance or a diagnosed
summon root cause. All four bots and world/auth/database stopped cleanly; local
test listeners are closed. Preserve logs and fix/verify placement before the
next client session. User is remote; do not leave a realm running for them.

The remote source audit traced the missing near-teleport acknowledgment and
added a typed native map-thread completion bridge, including native allowed/
active-mover guards. `Player::IsHasDelayedTeleport` is exposed read-only to wait
for native preparation. The broad rebuild and final chained-transfer guard
passed Windows worldserver/all 202 checks and Linux worldserver/202 cases
(201 passing, one existing expected failure, no unexpected failures).
The existing fixture runner now supports opt-in `-CheckNearTeleport` with
`-CheckRosterOnly -RoleFixture`; native acknowledgment and persisted landing
positions are the gates. The first headless attempt at
`build/playerbot-smoke-20261002-192109` stopped before any near teleport because
the exact `Silvermoon` destination name was absent; shutdown was clean. The
runner now resolves one unambiguous native Silvermoon-prefixed name from the
copied world DB instead of guessing. Replay passed at
`build/playerbot-smoke-20261002-192342`: native `SilvermoonCity`/Tranquillien
teleports completed twice per bot (eight acknowledgments), offline saved return
positions matched native coordinates, and roles/equipment/consumables remained
valid. All disposable services shut down cleanly; test listeners are closed.
This stopped copy may be reused for the next party replay. Do not rerun builds
or recreate roles just to resume the client test. In-game summon/follow and
integrated combat remain client-pending; Linux runtime remains untested.

## Attached-party combat scope — current source batch

Donor `AttackersValue.cpp` at upstream master
`037c01418b5d01506917a3db9b44fd56ac5f965c` gathers group attackers. The Cata
candidate list already gathered them, but target selection, session auto-assist,
ongoing combat and Priest damage admission still required the leader's own
combat relationship. Those gates now share one map-thread engagement check.

The leader must remain alive, in world, on the same map and within the existing
35-yard bot leash. Another member qualifies only in the bot/leader's shared
native group, alive, not transferring, on that map, within 35 yards of the
leader, and already engaged with the candidate creature. The leader's own
engagement remains valid for an ungrouped attached companion. Native attacker
discovery now explicitly includes the controller as well as bot/group members.
PvE, target-distance, visibility, crowd-control, command and native attack guards
remain authoritative. This is party defense, not autonomous pulling or a new
ownership/permission rule.

Windows worldserver and all 203 registered checks passed. Linux worldserver
compiled; 203 cases ran with 202 passing and one existing expected failure,
with no unexpected failures. The added test covers the Boolean admission
policy, not native combat-reference lifetime or live party behavior. In the
deferred bundled fixture session, include one enemy engaged with a party member
while the human leader is not engaged; confirm defense, tank rescue and normal
stop/follow behavior. Do not start a separate realm or isolated spell test.

## Incoming resurrection coordination — current recovery slice

The subsequent remote recovery slice ports donor incoming-resurrection exclusion
from `PartyMemberToResurrect` / `PartyMemberValue` at the same upstream pin.
Priests skip corpses already receiving another group member's resurrection cast
and may select a different eligible corpse. Direct-heal and resurrection native
cast inspection share an implementation; no pointer/reservation survives the
map-thread scan. Native unit/corpse target GUIDs and spell effects determine the
reservation. Existing range, corpse/request and native cast gates remain, with
explicit in-world/transfer/friendliness guards added to resurrection discovery.
Windows worldserver and all 204 registered checks passed. Linux worldserver
compiled; 204 cases ran with 203 passing and one existing expected failure,
with no unexpected failures. Integrated recovery remains client-pending.

## Party-aware recovery — current source slice

The latest remote source slice aligns recovery with attached-party defense:
rest and corpse-loot start/continuation/final processing now wait while a living,
nearby same-map member of the bot/leader's shared native group is in combat.
Unrelated/distant members do not block. This is a documented Cata adapter guard,
not a copied donor group-combat strategy or a change to engine-state transitions.
Member eligibility is shared with target engagement; native loot permissions,
owned movement/aura cleanup and mailbox handling remain. Windows worldserver
and all 205 registered checks passed. Linux worldserver compiled; 205 cases
ran with 204 passing and one existing expected failure, with no unexpected
failures. Later bundled testing should cover interrupted rest/loot and normal
recovery after party combat ends.

## After acceptance

Next is donor-aligned tank/healer coordination, recovery and one human-led
low-level dungeon. Autonomous population/questing remain the separate track.
Optional source archaeology can go directly to Nemotron with a pinned payload
and Sol audit; adding a local manager is unnecessary.
