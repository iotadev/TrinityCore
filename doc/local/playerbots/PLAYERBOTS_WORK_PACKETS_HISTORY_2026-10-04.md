# Playerbots development handoff

Updated 2026-10-04. Use this for the next session, not as a claim of gameplay
acceptance. The [roadmap](PLAYERBOTS_PORT_ROADMAP.md) owns priorities;
[module PORTING.md](../../../modules/mod-playerbots/PORTING.md) owns donor pins
and adaptations. Dated evidence is in [development history](PLAYERBOTS_DEV.md)
and the preserved [handoff history](PLAYERBOTS_HANDOFF_HISTORY.md).

## Current capabilities and resume point

The published infrastructure pair (module `70014ce`, core `92f41cf`) is
accepted. Do not redo native sessions/login, factory, module integration or
MultiBot roster lifecycle merely to continue gameplay ports.

Local work now has shared combat/noncombat/dead engines, target/threat/role
values, Warrior/Mage routes, Priest support, recovery/loot, movement prerequisites,
range controls, optional ready-check/deferred rebuff and learned ground mounts.
These remain bounded donor adaptations, not complete class/dungeon parity.

Newest source: group dispatch, bounded pending batches and world-thread aggregate
reply delivery connect the completion policy/inbox. A separate default-off
GroupMutations gate requires base/addon gates. Native authorized/controlled roster
is frozen before posts; account/character/login and native membership revalidate.
No native pointers persist in tables/inboxes. Lost logins abandon replies;
canceled/expired/dropped results remain unknown, not false failures or rollback.
Ordinary/BOT requests retain their path. Final reviewed Windows worldserver built
and all 318 checks passed; both-modules-disabled worldserver built with 19/19
checks passing. Native timing/gameplay and Linux remain pending:
[group mutation packet](PLAYERBOTS_GROUP_MUTATION_PACKET.md).

The preceding optional donor `focus` multiplier suppresses non-healing area
actions and attacker debuffs, allowing healing and single-target actions. Explicit
action category metadata replaces donor RTTI. Existing Mage Frost Nova now has
hostile-area metadata and participates in focus/area-threat guards; no new AoE
spell, targeting or pull-safety system was enabled. Focus is not a class default;
base-gate disable removes it. Native data/gameplay timing remains pending.

Safe-idle combat utility controls cover `co` focus/threat/potions alongside
`nc` food/loot, including single-bot C/N MultiBot completion ACKs. Shared state
allowlists protect roles/specs/cure/stay; dead state is query-only. Utility
overrides persist until logout/base-gate disable, which restores class defaults.
Global recovery/loot/class gates remain authoritative. No self-bot/reset.

The preceding qualified `enemy healer target` GUID value plus Pummel/Counterspell
secondary trigger/action routes. Positive interruptible casts on engaged attached-
party enemies can be interrupted without changing the current attack target or
chasing. Native range/cost/cooldown/cast-state and controller checks revalidate;
existing class-combat gates apply. No own-cast cancellation or cross-bot reservation.
The donor name includes positive buffs; it is not an NPC role/HEAL-only classifier.

The preceding shared combat recovery now prefers carried native Healthstones
before the donor healing-potion fallback. `RecoverySpell` is shared by readiness
stock and execution, so unsupported flasks/later item effects cannot satisfy the
potion-stock requirement. Stones are not counted as healing-potion stock.
Warrior/Mage/Priest share default-off `Playerbots.Potions.Enabled`, donor 25%/40%
thresholds and typed native item requests. Native consumption/cooldowns remain
authoritative; no grants, stone creation or direct restoration. Flasks/channeled
recovery remain separate. Add item effects and post-combat cooldown timing to the
same deferred replay, not a new tiny test.

The preceding donor area-threat prerequisite now resolves existing engaged-PvE
attacker GUIDs and takes the maximum tank-relative ratio. Scheduled AoE actions
must pass the 50% attacker and 80% current-target guards. No new AoE spell is
enabled; targeting/geometry, crowd-control and pull safety remain separate ports.

The preceding default-off `Playerbots.StrategyControl.AddonMutations` enables
donor-shaped structured ACKs for BOT/C focus/threat/potions and BOT/N food/loot, requiring the base gate.
Native roster/authority, replay/rate and map-thread idle/controller checks remain
authoritative. Completion follows engine execution and snapshot publication;
group scopes require the separate opt-in; roles/specs and unsupported strategies
reject. Timeouts are unknown outcomes; refresh STATE before retrying a toggle.
No self-bot/persistence.

The preceding read-only MultiBot STATE framing uses immutable map-published
combat/noncombat registration snapshots, with native roster authority, identity,
freshness, rate and complete-response budget checks. Single-bot/global frames
share the existing default-off strategy-control gate; self-bot capability remains
unadvertised. No installed addon update is needed for these wire contracts.

The preceding default-off `Playerbots.StrategyControl.Enabled` wires ordinary
`co`/`nc`/`de` queries plus combat focus/threat/potions and noncombat food/loot operators through copied,
expiring requests. Map execution rechecks current controller/native authority and
phase; mutations require idle state. Engine validation is atomic and preserves
queues for unchanged/query requests. Overrides last until logout or gate disable;
global recovery/loot gates still apply. Roles/specs/cure/stay are protected. No
persistence/reset or broad strategy parity is advertised.

The preceding default-off `Playerbots.Movement.Stay.Enabled` wires the donor
position/stay foundation into exact ordinary stay chat. Enabled stay retains
the controller but stops follow/assist, captures a ground anchor and enables
stay only in the noncombat engine. Hold stays plain hold; disabled stay falls
back to old hold behavior. Follow/hold/control, death, controller loss, transfer
and phase changes clear anchors/mode. Returns yield to casting/recovery/party
combat and clean up only the exact owned native point movement.

The ground-mount option is also default-off and requires learned mounts/riding.
Combat stay, ghost movement, flight/forms, persisted positions, random-return/
guard travel and autonomous population/questing remain separate work.

## Evidence and outstanding gates

- Windows modules-enabled worldserver built and all 318 checks passed after group
  dispatch/pending/session/membership integration and review. Six new pure cases
  cover scope/login binding, atomic limits, out-of-order/admission results,
  abandonment/generation protection, cancellation and timer wrap. They do not prove
  native logout/group/gate timing or client ACK behavior. The preceding 312 checks covered the
  copied native batch hook and bounded completion inbox changes. Five new cases
  cover correlation/regression, cancellation/expiry, bounded copied transport,
  batch consumption and concurrent producers/drain; these are not runtime group
  fanout or session-delivery proof. The preceding 307 checks included six group
  aggregation cases. The 301-case snapshot covered focus/action metadata. Three cases cover multiplier
  categories, Mage target/positivity policy and production-multiplier engine replay.
  These do not qualify native area effects. The preceding two cases cover state
  allowlists/copied correlation and utility-default restoration; ACK tests now
  check C success/failure fields. Native command timing remains pending. Expanded
  trigger checks and one new admission-policy case are not landed-interrupt proof.
  The preceding two cases cover classification/wiring and engine preference/fallback;
  the preceding three cover thresholds, availability and priorities. None proves
  native item effects. The prior
  two area-threat cases do not validate native references or area spell behavior.
- Windows modules-disabled worldserver/tests-common: current batch-correlation/snapshot/strategy hook
  snapshot passed all 19 core-only checks with Playerbots and AHBot disabled.
  This is build proof, not gameplay acceptance.
- Linux: latest validated subset had 219 cases, 218 passed and one expected
  failure. Newer slices remain pending while Docker's Linux engine is unavailable.
  The existing Ubuntu installation lacks the alternative build setup; no
  packages or host settings were changed to bypass this.
- Earlier outdoor and Ragefire sessions observed engagement, healing, tank
  rescue, target-death return, corpse opening and clean logout. They do not
  establish a dungeon clear, item awards or acceptance of the newer slices.
- Latest stay/role/readiness/mount/native-path timing still needs the bundled
  replay. Pure policies, accepted casts and strategy metadata are not gameplay
  proof. The Warrior facing/idle episode remains unconfirmed, not proven fixed.

The user is remote and deferred the replay. Keep the stopped provisioned
[party fixture](PLAYERBOTS_PARTY_FIXTURE.md); no realm startup just to wait.
Do not rebuild unchanged source or recreate the party to resume testing.

## Next two batches

1. Close the accumulated gameplay milestone: finish current platform validation,
   run one deferred party replay covering control/state transitions, target loss,
   tank/healer support, recovery/loot and optional stay/readiness. Mount behavior
   may remain deferred if the fixture lacks riding. Record failures as one
   corrective batch, review outgoing provenance/privacy and only then stage the
   matching module/core milestone when authorized.
2. Extend tank/healer coordination into one sustained human-led dungeon.
   Continue bounded donor feature groups while the client is unavailable;
   select their owning dependencies together rather than isolated spells.
   Broader strategy/MultiBot controls next need state policies for additional
   donor routes and bounded group completion aggregation, building on the
   single-bot ACK/read-only framing layers. Classes/specs and travel stay on the
   roadmap. Autonomous play is a separate track, not the acceptance shortcut.

## Architecture and publication constraints

- Keep native world/map/session/thread, learned spell, cooldown, talent,
  equipment, loot and DB ownership. Mutate decision queues only on the map thread.
- Command transports carry copied identities; revalidate native security and
  live state at execution. Resolve by GUID; retain no native target pointers.
- Shared contexts do not imply shared queues. Explicit state registrations and
  current combat metadata remain authoritative; utility is not a healer role.
- Refresh upstream master and record immutable provenance. Last verified master:
  `037c01418b5d01506917a3db9b44fd56ac5f965c`; individual imports keep their pins.
  Bridge HEAD remains `1da05982`; latest addon reader checked at `80148dff`.
- Keep features default-off, server portability intact and personal identifiers,
  credentials and machine-specific runtime details out of publication artifacts.
- Commit validated milestones with the publication identity; never push or mark
  client acceptance implicitly. Optional archaeology can use a pinned Nemotron
  payload plus audit, without adding an unproven local manager.
