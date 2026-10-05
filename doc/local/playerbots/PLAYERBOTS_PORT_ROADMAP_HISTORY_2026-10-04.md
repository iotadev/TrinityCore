# Cataclysm Playerbots roadmap

Updated 2026-10-04. This is the current plan. Dated details and superseded plans
are retained in [development history](PLAYERBOTS_DEV.md), research packets and
module PORTING.md. The target is AzerothCore Playerbots/MultiBot functionality
on native Cata, with upstream reuse preferred over replacement.

## Current capabilities

A bounded group strategy completion policy now has native batch correlation,
authorized/controlled roster dispatch, a synchronized inbox, bounded world-owned
pending batches and current-session reply delivery. GroupMutations is a separate
default-off gate requiring base/addon gates. Execution-time login, group membership,
controller/security/phase/idle checks preserve native ownership. Final Windows
validation/review passed; native timing/gameplay and Linux remain pending.
Use the [integration packet](PLAYERBOTS_GROUP_MUTATION_PACKET.md)
for that next bounded batch; queue acceptance must never count as completion.

Optional donor focus suppresses non-healing AoE and attacker-debuff actions via
explicit metadata, without changing roles/specs or adding spells. Existing Mage
Frost Nova is now a hostile self-area action, so focus/area-threat guards apply;
friendly self buffs remain threat-free. The classification is scoped to that
adapter, not full AoE targeting/geometry or crowd-control/pull safety. Focus is
not a class default and is removed when the base control gate is disabled.

Shared interrupts now include donor secondary "enemy healer" GUID targeting
for Warrior/Mage, where healer means a positive interruptible cast (including
buffs). Only engaged attached-party candidates already natively usable are
eligible; execution rechecks without retargeting/chasing. Class combat gates
remain authoritative. Landed interrupts and cast-race timing remain deferred;
cross-bot reservation/own-cast cancellation are separate future work.

Shared carried healthstone/healing/mana recovery now has a default-off combat
strategy for the supported classes, using donor 25% health / 40% mana thresholds
and healthstone-to-healing-potion fallback. Readiness/execution share supported
potion classification; stones do not replace its explicit potion-stock requirement.
Native item requests own consumption/cooldowns/restoration; no grants or direct
resource writes. Stone creation/distribution, flasks and channeled recovery remain
separate. Policies/engine fallbacks are covered; native effects and post-combat
cooldown timing await the same replay.

The shared area-threat prerequisite uses the existing engaged-PvE attacker GUID
value, current-map revalidation and the donor maximum ratio. Scheduled AoE damage
must pass both its 50% attacker and 80% current-target guards. No new offensive
area spell is enabled; geometry, crowd-control avoidance and pull safety remain
owning dependencies, not implied by this multiplier.

MultiBot structured strategy ACKs execute BOT/C focus/threat/potions and BOT/N food/loot under
an additional default-off addon-mutation gate. Completion follows map execution
and snapshot publication, with native authority, copied correlation and token
replay/rate guards. Group scopes require the separate opt-in; combat roles and
unsupported strategies reject. Self-bot/persistence remain later. Client timeout is an unknown
outcome, not a rollback guarantee. The base rest/loot settings remain authoritative.

Read-only MultiBot strategy framing now covers single-bot/global queries under
the default-off strategy-control gate. Immutable map-published snapshots keep
world-thread transports out of engine internals; native roster authority,
freshness and full-response preflight guard the output. Only read-only
`STATE_FRAMING_V1` is advertised. Latest addon reader `80148dff` was checked
without replacing the installed client addon. Structured mutation is limited to
the opt-in state/strategy subset above; this is not full strategy parity.

The donor strategy operator layer now has default-off ordinary chat transport:
`co`/`nc`/`de` queries, combat focus/threat/potions and noncombat food/loot operators. Copied,
expiring requests recheck map-thread controller/authority/phase; mutation requires
idle state. Whole-batch validation protects roles/specs/stay and keeps queues for
unchanged requests. Session-local overrides do not enable globally disabled
recovery/loot. Gate disable restores class utility defaults independently of
protected role/spec/cure routes. Broader routes need owning state policies and structured MultiBot
capability mapping; persistence/reset remain separate. Unsupported controls reject.

Saved-position stay is now wired behind default-off `Playerbots.Movement.Stay.Enabled`.
It retains the current controller, stops follow/assist and activates the donor's
noncombat stay/return layer with controller/map/instance/phase guards. Follow/hold,
other control and native lifecycle changes clear anchors; return cleanup uses an
exact owned native point ID. Disabled stay still acts as old hold; hold itself
remains plain stop. Persistence/random return/guard travel and combat stay remain later.

Windows modules-enabled worldserver built and all 318 checks passed after group
dispatch/pending/login/membership integration and review. Six new pure checks cover
binding, limits, correlation, abandonment/cancellation and timer wrap. Native group
timing/gameplay remains pending. The preceding 312 checks covered native batch
correlation and the bounded completion inbox. Five of those checks cover
copied mailbox/transport policy and concurrency, not native group dispatch.
The preceding 307 cases covered the pure completion policy; the 301-case snapshot
covered focus/action metadata. This is not group-control runtime acceptance.
The current core passed a modules-disabled worldserver/tests-common
build and all 19 core-only checks, including the copied batch-generation hook and
snapshot getter.
Neither is native gameplay acceptance.
See the compact handoff for remaining scope and the handoff history for old packets.
Linux validation and the bundled replay remain open.
The user deferred the party replay while remote; preserve the stopped fixture.

Local ground-mount coordination now follows a mounted controller using learned
native eligible ground spells behind default-off `Playerbots.Mount.Ground.Enabled`.
It yields to commands/combat/recovery and uses the existing native follow adapter;
it adds no flight, travel forms, preferred/item mounts or autonomous travel.
The fixture must already have riding and learned ground mounts to exercise it.
Windows worldserver/tests-common built and all 257 checks passed. Linux/module-off
and bundled gameplay acceptance remain pending. Source presence is not gameplay
acceptance; see the handoff for the scope and remaining prerequisites.

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

Local shared movement now covers donor-named facing/melee/spell reach,
specialized healing/resurrection reach, a common movement-permission gate and
bounded spell/heal range controls. Range chat crosses a session-owned mailbox;
native chase and casting remain authoritative. Priest resurrection uses shared
controller/healer/tank/other ordering and per-corpse approach eligibility. Healing
retains its health/distance ordering. Windows worldserver and all 252 checks
passed; Linux acceptance stops at the earlier 219-case slice. Newer movement,
range and support changes still need Linux and bundled client validation.

The follow-on support search connects the same role/subgroup ordering to party
cures and buffs, superseding the earlier cure health sort and grouped self-first
buff traversal. Native spell/aura eligibility and cast-rejection fallback stay
authoritative. Self-cure remains separate; ungrouped attached-controller support
is retained as a documented Cata adaptation. Windows build validation passed;
native role/aura/effect behavior still needs the bundled runtime check.

Donor control protection is shared across ranking, attack admission/retention
and positioning. Polymorph/charm/fear/isolation prevent targeting; roots/stuns
are not blanket exclusions. Existing cease cleanup stops queued work and native
autoattack, not already launched spells or periodic effects. Runtime timing
remains unqualified.

The shared context now exposes a qualified `party member to dispel` GUID value;
Priest context also exposes `party member to resurrect`. Consumers query fresh
targets, preserve native guards and retain cure cast-rejection fallback. This is
the start of donor support-value coverage, not full generic party-value parity.

Priest named healing and shared missing-aura GUID values now extend that layer.
Healing triggers use the health/distance-selected patient while casts retain
spell-specific eligibility and fallback. Missing-aura qualifiers cover only
the existing Mage/Priest buffs and translate to native Cata aura variants.
Normal buffing remains absent-only; manual duration-based force-rebuff was added
in the follow-on batch. Windows validation passed; native target/value behavior
still needs the bundled client replay.

Manual force-rebuff is now implemented through ordinary `buff` chat with a
bounded session handoff, two-minute window, donor-default refresh margin and
native GCD/work tracking. Noncombat healing yields to buff work; combat does not.
Death/transfer/controller changes cancel it. Native ready-check handling remains
separate: Cata requires world-thread group authority and a different answer
payload. Manual rebuff completion must not report readiness. Validation of this
newest slice passed on Windows; Linux/module-off and client validation remain pending.

The next local slice implemented a separate default-off native basic readiness
bridge. Map updates evaluate health/mana/proximity and native life/combat/transfer/
cast/rebuff guards; world updates revalidate group/check/initiator/expiry and
send the native one-byte reply. Replacement checks and authorized finish discard
stale results. This is not inventory/encounter readiness or automatic rebuff.
Windows worldserver/tests-common compiled and all 242 checks passed. Linux,
module-off and client acceptance of this bridge remain pending.

The follow-on local batch adds carried usable food/drink and recovery-potion
requirements, plus optional donor-style rebuff/deferred confirmation. Finished
passes trigger a fresh state/supply check; canceled, replaced or expired work
cannot become ready. Only supported Mage/Priest party buffs participate. Full
buff/encounter readiness remains future coverage. The newer combat-potion port
above implements native submission; observed potion effects remain pending.
Windows worldserver/tests-common compiled and all 247 checks passed; Linux,
module-off and client acceptance remain pending. Fixtures without usable potions
should answer not-ready, not fabricate stock.

Shared role consumers now prefer published bot combat-strategy metadata and use
native Cata tree/form roles for ordinary players. Party ordering, threat/rescue/
target logic, DPS weighting and melee positioning no longer use separate Warrior/
Priest shortcuts. Other human tank/healer specs are recognized; no extra bot classes
or rotations were added. Priest retains its implemented healer fallback, including
Shadow-spec bots. Windows worldserver/tests-common and all 252 checks passed.
Linux/module-off and bundled gameplay remain pending; metadata is not role competence.

A prior level-20 party check observed combat, healing, buffs, corpse opening
and clean logout. It did not qualify assigned talents, item awards, recovery
consumables or later role/target changes. Advanced spells await suitable fixtures.

The current shared-state batch separates combat, noncombat and dead engines.
Transitions, control changes and target loss discard queued work. Native
resurrection/transfer retain their existing session/core ownership. Autonomous
dead-state travel and graveyard release are not implemented. See
[state acceptance](PLAYERBOTS_STATE_MILESTONE.md) for current validation.

## Remaining dependencies

- Run the deferred shared-state acceptance check and replay the newer uncommitted
  coordination/movement/support changes together. The saved candidate pair passed
  Windows/Linux checks, but newer slices have only Windows validation so far.
  Linux realm runtime remains a separate untested boundary.
- Qualify state transitions with assigned roles, usable equipment, carried
  consumables and enemies durable enough for sustained combat.
- Establish tank/healer coordination under pressure: threat recovery, target
  agreement, healing priorities, positioning and post-death regrouping.
- Extend the successful human-led Ragefire engagement into a sustained dungeon
  attempt. Accepted casts do not prove effects; infrastructure acceptance does
  not establish dungeon competence or a completed dungeon.
- Expand classes/specs and MultiBot operations in bounded donor-aligned batches,
  keeping unsupported commands truthful.

## Next two batches

### 1. Shared-state gameplay milestone — current work

The saved shared-state candidate has source/platform validation, native fixture
preparation and local commits. Its integrated acceptance remains open; newer
uncommitted coordination/movement/support work must be validated alongside it.
Use the saved baseline for the next bundled client check, then document outcomes
and acceptance. Do not rebuild unchanged code or repeat one-time provisioning.

Close stop/follow/attack resume, target loss, native death/recovery and transfer
suspension together. Reuse the decision engine/context and session mailboxes.
Prepare [one fixture](PLAYERBOTS_PARTY_FIXTURE.md), run a bundled operational
check, complete platform validation, audit outgoing provenance/privacy and
commit the matching module/core pair. Do not extend this batch with isolated spells.

### 2. Role coordination and one human-led dungeon

The bounded source batch now covers tank rescue, attached-party target admission,
healing health/distance priority, duplicate direct-heal/resurrection suppression,
rest/loot combat yielding, trailing caster formation, common movement permission,
facing/reach prerequisites, range controls and shared support/control-target rules.
It is ready for integrated qualification, not full donor parity. Outdoor and
human-led Ragefire checks established repeated engagement, healing, tank rescue,
target-death return and clean shutdown; they did not establish a dungeon clear
or accept the newer movement/support slices.

Use the saved [party fixture](PLAYERBOTS_PARTY_FIXTURE.md) for one combined replay:
stop/follow/attack and target loss, sustained tank/healer pressure, loot/rest yield,
range query/change/reset and natural recovery/control effects when available.
Then extend the human-led dungeon attempt. Collect failures into one corrective
batch rather than requiring a client test for each isolated feature. The Warrior
facing/idle episode remains unconfirmed; source ports are not proof of its repair.

Further source development is allowed while runtime is deferred. Select a
coherent donor feature with its prerequisites, not another geometry fragment.
The movement ownership audit is recorded in module PORTING.md: native chase
already handles angle/distance/LOS/collision/pathing. Full donor behind/reach
geometry needs movement priority/history and recent-flee state together. Keep
native movement authoritative rather than adding a parallel path controller.

Remaining feature groups include native readiness/full rebuff coverage and strategy-role
coverage, broader mount/travel coordination beyond the learned-ground slice,
full stay/return behavior, pets and
additional classes/specs. Persistence and shoot/flee/per-spell ranges are separate
from the current spell/heal control. Released ghosts, dead-controller approaches,
vehicle/flight and autonomy remain separate boundaries. These are future ports,
not mandatory additions before accepting the current level-20 party batch.
Generic donor CastSpellAction has empty prerequisites; do not invent blanket
spell reach dependencies. Autonomous dungeon completion is not the gate.

## Separate autonomy track

Population/account creation, autonomous login scheduling, questing, travel,
leveling, equipment selection and autonomous dungeon formation remain future
work. The native character factory is a foundation, not a random-bot population
manager. Reuse compatible donor systems without blocking the human-led dungeon.

## Working rules

Keep native Cata lifecycle/threading, spell, equipment and database authority.
Flags remain default-off. Refresh relevant upstream master references and pin
their revisions. Compile coherent batches and playtest integrated behavior.
For nonblocking issues, record the owning donor feature and address them in that
port. Do not assume they will fix themselves or require an isolated playtest.
Crashes, security/data correctness and genuine progress blockers take precedence.
Cheap source-discovery delegation is optional; final implementation/review stay
with the primary agent. Keep dated evidence out of the resume plan.
