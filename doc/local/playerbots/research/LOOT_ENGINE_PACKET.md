# Shared loot: first native policy and next donor port

Source checked 2026-10-01. Upstream master was freshly fetched and remains
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.
The final Windows and Linux worldserver/tests-common builds each passed all
119 tests at the initial auto-pass checkpoint. Later opening and movement
evidence is recorded below; native awards and roll resolution remain unverified.

## Current bounded implementation

`Playerbots.Loot.PassOnGroupLoot` defaults off and is cached at configuration
load/reload. A session/map-owned preference bridge sets the native Player
auto-pass preference for admitted server-origin companions. Disabling restores
the preference captured before enabling; no Player/Group/Roll pointers are kept.
Native Group Loot and Need Before Greed create and count the votes. This is a
temporary native policy, not imported donor equipment evaluation or corpse looting.
It applies to new rolls only; existing pending rolls still use their native timer.
Master Loot, Free For All and Round Robin are not changed by the preference.

Source inspection found a required native correctness fix in Group::GroupLoot:
normal items marked auto-passing members PASS without incrementing totalPass,
unless CanRollOnItem also rejected the member. Initial passes now count exactly
once. The follow-loot-rules quest-item branches in GroupLoot and NeedBeforeGreed
also ignored the preference; both now record/count it. Native reward distance,
item eligibility, roll masks, vote resolution and item awards remain unchanged.
This correction also applies to ordinary players using native opt-out, even
with the module feature off. It requires the corresponding core source change;
do not enable this development feature against the older published core pin.

Four pure tests cover default-off noninterference, snapshot/restore, repeated
updates and a fresh baseline after reenable. They do not execute Group's native
roll creation or award paths. Bundled runtime coverage must include Group Loot
and Need Before Greed, a human vote plus bot passes, follow-loot-rules quest
items when available, disable/reload, and a roll already pending when enabling.
An all-pass group may still wait for native timeout; this slice does not replace
native timeout handling or promise instant resolution of every roll.

## Donor dependency map

| Donor source | Responsibility | Cata follow-up |
|---|---|---|
| src/Ai/Base/Strategy/LootNonCombatStrategy.cpp | loot available -> loot (6), far from loot target -> move to loot (7), can loot -> open loot (8), often -> add all loot (5) | Keep registry names and relevance; wire dependency-complete stages, not empty creators |
| src/Ai/Base/Value/AvailableLootValue.h, HasAvailableLootValue.cpp | available-loot collection, current target, cached eligibility | Bounded GUID-only collection; cached searches, O(1) triggers |
| src/Mgr/Item/LootObjectStack.h | timestamped GUID candidates and nearest selection | Do not copy its retained Player pointer into the session adapter |
| src/Ai/Base/Actions/LootAction.cpp | select/open corpse, response-driven native money/item/release requests | Cata response/permission mapping and context-safe request routing; no Wrath packet copy |
| src/Ai/Base/Actions/LootRollAction.cpp | item-usage-driven Need/Greed/Disenchant/Pass | Requires item usage, equipment/unique checks, loot policy and safe native group operation |

The native Cata entry points are Player::SendLoot, Player::StoreLootItem,
Loot::LootItemInSlot, and WorldSession's loot/open/money/release handlers.
WorldSession::SendPacket intentionally discards outbound server-origin traffic;
the donor's response-driven StoreLootAction therefore cannot simply be copied.
An explicit bounded result/view path is needed; do not infer successful storage
from a queued request or overwrite the active loot GUID as a shortcut.

The Cata opcode table marks LOOT, LOOT_MONEY, LOOT_RELEASE and LOOT_ROLL
PROCESS_THREADUNSAFE, while AUTOSTORE_LOOT_ITEM is PROCESS_INPLACE. These are
not interchangeable map-thread action calls. Preserve native session dispatch
and keep Group mutation off map-thread AI. No synchronous SQL, manual awards,
currency duplication or second permanent scheduler is acceptable.

## Next bounded implementation

Implementation update: the initial near-corpse slice is now in local development
under Playerbots.Loot.Corpses.Enabled (default off). The `loot` strategy wires
`can loot` to `open loot` at donor relevance 8. A two-second cached candidate
considers the last defeated combat target or selected nearby corpse, and checks
bot/group recipient, native interaction range and LOS. No distant movement or
generalized candidate queue/area scan is yet imported. An eight-entry attempt
history backs off the same corpse for 30 seconds, including native inventory
failures, instead of looping each tick.

The dependency identified above is now met by an optional typed output from
native Player::SendLoot. The ordinary null-output path remains unchanged;
provided output is reset at entry and populated by the native permission builder.
A single GUID-only, generation-checked mailbox crosses to the existing unsafe
world-session update. That consumer rechecks controller identity/control and
current actor/corpse eligibility, then opens and attempts native coins and
ALLOW_LOOT/OWNER item slots, followed by release. It refuses an unrelated active
loot window. Locked/master/ongoing-roll slots and currencies are not collected.
Native storage/awards remain authoritative; an accepted request/open is not a
storage success receipt. An explicit resume flag handles completion before the
next map tick so stopped follow movement is restarted.

Four new pure tests cover wiring, mailbox bounds/cancel/stale completion,
resume signaling, backoff identity and unsigned millisecond wrap. Native storage,
permission sharing, full bags and timing remain bundled runtime checks. Windows
worldserver/tests-common and all 123 tests passed after the final interruption
guard and test-only GUID link/constructor corrections. Linux's larger rebuild
also finished successfully; an incremental current-source recheck and all 123
tests passed again. Native Linux runtime is still unverified.

## Bounded corpse collection and movement follow-up

The local follow-up adapts LootObjectStack's timestamped identities/nearest
selection and MovementActions.cpp::MoveToLootAction, retaining the donor
`far from loot target` -> `move to loot` names and relevance 7. It uses an
eight-entry GUID-only collection with 60-second expiry. Inputs are observed
defeated combat targets and eligible controller-selected corpses, not an area
scan. Candidate checks inspect at most eight entries at the engine's bounded
cadence and revalidate native recipient/group, lootable state and LOS.

A detour starts only within 15 yards of the bot and 20 yards of its live
controller. Native MovePoint pathfinding owns the route; the existing session
movement owner suppresses follow during pursuit and restores formation when
it ends. One map-owned GUID/timestamp tracks the pursuit, with a ten-second
timeout and the existing 30-second backoff on timeout. Combat, explicit
movement, transfer, lost movement control, feature disable or failed current
eligibility ends the detour. Rest and Mage armor defer during pursuit.
No new world-thread movement call, lifecycle hook, configuration key or
database change is introduced. Opening/storage keeps the existing mailbox.

Three new pure tests cover collection capacity/deduplication, expiry/wrap and
single-pursuit timeout/reuse; the strategy test now checks both donor stages.
Build results belong in PORTING.md. Live detours and path cancellation remain
unverified and should be bundled with the already-planned recovery/loot check.

The remaining follow-up is:

Extend discovery only when a concrete donor consumer warrants it; the bounded
defeated/selected collection and short detours are now local source. Defer
gathering, game objects, skinning, corpse runs, arbitrary area scans,
vendor/AH valuation and full autonomous population. Equipment-aware rolling
comes after native eligibility and cached item-usage evaluation exist; until
then the optional auto-pass preference must not be presented as donor parity.
