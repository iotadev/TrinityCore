# Controlled-party DPS target fallback

Local development port, 2026-10-01. Donor revision:
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source basis

- `src/Ai/Base/Value/TargetValue.{h,cpp}` gathers typed target exclusions from
  active combat strategies; FindTarget iterates attackers. High priority uses
  skull and `prioritized targets`.
- `src/Bot/Engine/Strategy/Strategy.h` already supplied the imported
  AppendTargetExclusions / HasTargetExclusions contract in this Cata module.
  This slice adds its missing active-engine collector, not a second contract.
- `src/Ai/Base/Value/DpsTargetValue.cpp` selects explicit raid-icon target first.
  For casters with more than three nearby members, ranking prefers lifetime
  5–30 seconds, then below 5, then above 30, with in-range preference. Within
  short-life ties it prefers current target, otherwise longer lifetime; within
  the other bands it prefers shorter lifetime. General ranking uses in-range
  lower lifetime, otherwise distance. First high-priority candidate wins.
- `RtiTargetValue.cpp` supplies named icon indices; `RtiValue.cpp` defaults
  `rti` to skull and `rti cc` to moon. Donor configurable spell distance defaults
  to 28.5 yards, and ranking adds five; the Cata adapter keeps its narrower leash.

## Implemented boundary

Engine::GatherTargetExclusions collects fresh GuidSets from active strategies
for the requested type. None, no exclusion provider and removed providers yield
empty sets. No strategy pointer leaves the engine. The existing strategy/type
mask lifecycle remains authoritative; no global registry or new AI ownership.

PlayerbotTargetSelection registers manual `prioritized targets`, `rti` and
`rti cc` values in the three current class contexts, retaining donor defaults.
This adds no player command, addon capability or persistence. Native SelectDpsTarget
returns only a GUID; it does not register a Unit-pointer `dps target` value or
create another current-target owner. Cata Group lacks the donor marker getter, so the matching
core adds a bounds-checked read-only GetTargetIcon returning the existing GUID
or empty for an invalid index. Native marker updates/persistence are unchanged.
Priority-list candidates must already be
in the attackers list; the explicit icon may be outside it but must already be
in native combat with the controller. Icons and priority are not pull permission.

Every candidate must pass Dps strategy exclusions, moon/configured CC icon
exclusion, native life/hostility/detection/LOS, non-polymorph/non-evade/non-player
control, native immunity and both bot/controller 25-yard limits. The controller
must be alive, same-map, non-transferring, in combat and within the existing
35-yard leash. The same existing native map thread gathers values and resolves
GUIDs. No Unit pointer is stored after selection and no native threat is mutated.

The caster branch uses the current estimated-group-DPS service only when its
estimate is finite/positive and more than three living same-map members are
near. The count additionally excludes dead members (a conservative Cata
adaptation). Missing/unsupported DPS falls back to general range/health ranking,
which preserves the general lifetime ordering without dividing by zero.
The pure policy retains range bands; the adapter's existing 25-yard eligibility
is narrower than both its 30-yard ranking boundary (Cata leash plus five) and
the donor default 33.5-yard boundary, so admitted candidates are in range here.
Do not claim broad ranged target pursuit from the ranking tests.

Integration is deliberately only a fallback for idle auto-assist when the
player's selected creature is invalid or is not in native combat with them.
Mage requires the existing EngineMageCombat gate; Priest requires EnginePriestHeal.
Both stay default-off. Explicit attack requests and valid selected combat
targets retain precedence, including their existing targeting behavior. An
active attack is not interrupted/replaced by this slice. Selected/manual paths
do not inherit the new exclusion/CC policy. Warrior selection is unchanged.
Stop, hold, follow, target cleanup and movement remain with the existing adapter.

## Verification and remaining work

Four pure tests cover icon mapping, caster lifetime boundaries/current-target
ties, general range/distance/lifetime ordering, priority and invalid estimates.
One real Engine test covers typed dynamic exclusions and strategy removal.
Windows and Linux worldserver/tests-common built and each passed all 167 tests. These tests
do not simulate native threat, marker, map, control or attack/movement behavior.
Bundle fallback after a kill/cleared selection and marked-vs-unmarked engaged
targets with the next party session, not a separate micro-test.

Full named DPS target values, dynamic switching, group members' declared CC
targets, autonomous pulls, tank/combo/AoE selectors, raid-specific exclusion
providers, priority commands and persistence remain separate donor ports.
Current strategies do not yet supply encounter-specific exclusions; the new
collector is exercised with a test provider and is ready for real consumers.
The later TANK_TARGET_PACKET.md adds named GUID values and Protection fallback;
earlier statements here describe the DPS-only checkpoint.
