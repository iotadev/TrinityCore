# Engaged attackers and healer balance

Local development port, 2026-10-01. Donor revision:
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source basis

- `src/Ai/Base/Value/AttackersValue.{h,cpp}` gathers native threatened-by-me
  references from self and nearby living group members, filters validity and
  returns deduplicated GUIDs. The donor also appends priority/skull/duel/arena
  candidates, which are outside this PvE controlled-party port.
- `src/Ai/Base/Value/AttackerCountValues.{h,cpp}` defines BalancePercentValue.
  Living party levels are divided by total roster size, then multiplied by
  min(roster size, 10). Enemy levels are weighted normal 1, rare 2,
  elite/rare elite 3 and world boss 20. The ratio caps at 200; no enemies gives
  100. No group contributes zero party levels when enemies exist.
- `src/Ai/Base/Trigger/GenericTriggers.cpp`: HealerShouldAttackTrigger uses
  mana 85 for balance <=50, configured highMana for <=100 and mediumMana above
  100. Current donor defaults are 65 and 40. Its solo bypass is not ported.

## Implemented subset

PlayerbotCombatValues registers named `attackers` (vector of GUIDs) and `balance`
(uint8) in all three implemented class contexts. The existing map thread reads
native GetThreatenedByMeList from self and living, in-world, non-transferring
group members on the same native map within 100 yards in 2D. Human group members
count too. Creature candidates must be nearby, alive, visible/detectable, within
LOS, native attackable, non-player-controlled, non-evading and non-polymorphed;
fully physical/magic-immune candidates are excluded. Native tap, bot combat,
controller threat and victim-owner/group checks preserve the donor's applicable
PvE claim protections. Nothing is attacked or retargeted by this value.

Temporary native references are consumed only during the read. Stored results
contain GUIDs, not Unit pointers; balance resolves them again on the same map.
Both values recompute on Get rather than using the donor attacker's one-second
cache, so queued action eligibility does not deliberately reuse stale combat
information. No native threat mutation, new scheduler, callback or core seam.

Balance keeps donor rank weights, roster denominator, ten-member cap, integer
truncation and maximum 200. Its living-member numerator is restricted to
in-world, non-transferring members on the bot's exact map, a conservative Cata
adaptation instead of global cross-map player lookup. Offline/dead/other-map
roster slots remain in the denominator. Invalid numeric input returns zero.
This is a level/rank heuristic, not measured encounter difficulty or DPS.

Priest trigger and action execution now consult the value and use 85/65/40 mana
thresholds. Missing value retains the conservative 85 branch. Existing >=90%
eligible-party-health, controller combat, native target/LOS, learned spell,
command, rest/loot and feature gates remain. Healing and cures still outrank
damage. No solo exception, lower health cutoff, new settings or SQL are added.

This is not full AttackersValue parity: priority/skull candidates, pets as
independent threat contributors, PvP/duels/arena and broader activity policy are
unported. Full DPS target selection still requires TargetValue exclusions,
raid icons and role/CC/priority services; do not expose autonomous targeting
by pretending this GUID list supplies those dependencies.

## Verification and next work

Three pure regressions cover rank weights, roster/raid math, truncation and
saturation, plus healer mana thresholds and retained control/healing gates.
Windows and Linux worldserver/tests-common built and each passed all 162 tests.
Native reference
traversal and candidate filtering are source-reviewed, not simulated by these
tests. Bundle a multi-enemy pull and Priest healing-vs-damage observation with
the existing party session; no separate client test is required.

Next map the donor TargetValue exclusion/priority dependencies before porting
DpsTargetValue's caster lifetime and range ranking. Add further class features
through existing class contexts rather than building a second combat manager.

### Next target-selection dependency map

Checked at the same donor revision, not implemented by this slice:

- `TargetValue.{h,cpp}`: FindTarget consumes the `attackers` GUID list and gathers
  combat strategies' AppendTargetExclusions for the requested exclusion type.
  This needs an explicit strategy-owned exclusion contract, not ad hoc filters
  buried in the session adapter. The Strategy hooks were already imported;
  their active-engine collector was missing at this balance checkpoint.
- FindTargetStrategy::IsHighPriority uses skull (icon 7) and `prioritized targets`.
  FindNonCcTargetStrategy checks group CC targets and moon (icon 4); do not assume
  every DPS strategy inherits that helper. Current DpsTargetValue ranking itself
  skips moon and uses Dps exclusions.
- `RtiTargetValue.cpp`: explicit named raid-icon targets precede ordinary ranking.
  They can be outside the attacker list but must pass native target, LOS, sight
  and controller-distance checks. Retain current Cata permission/leash ownership
  before enabling a new icon to initiate combat.
- `DpsTargetValue.cpp`: when more than three group members are near, caster
  ranking uses estimated lifetime bands 5–30 seconds, below 5 and above 30, plus
  range and current-target preference. General ranking favors in-range targets
  with lower remaining lifetime, otherwise nearer targets. Combo and AoE paths
  have separate dependencies and should not be silently treated as caster logic.
- Estimated group DPS can be unavailable in this Cata subset. Guard zero and
  non-finite estimates before donor health/DPS ranking; do not inherit unsafe
  divisions or convert an unavailable estimate into a new pull permission.

Implement the bounded priority/exclusion and pure ranking contracts first,
then connect only native-valid already-engaged candidates through the existing
GUID target/command owner. This does not require a new lifecycle manager.
The later [DPS target packet](DPS_TARGET_PACKET.md) implements that bounded
fallback; full target-selection parity remains outside its scope.
