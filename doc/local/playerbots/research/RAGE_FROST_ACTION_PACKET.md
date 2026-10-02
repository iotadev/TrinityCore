# Rage spender and Frost conditional action

Source checked 2026-10-01 against donor
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source and scope

Extend implemented Warrior/Frost Mage strategies with learned Heroic Strike
and conditional Ice Lance. Donor FuryWarriorStrategy wires `medium rage
available` -> `heroic strike` at ACTION_DEFAULT + 0.1; TankWarriorStrategy uses
`high rage available` -> `heroic strike` at ACTION_HIGH. GenericTriggers.h/.cpp
define inclusive thresholds of 40/60 rage; StatsValues.cpp::RageValue divides
native power by ten. Preserve those names, thresholds
and relevance; generic Warrior uses the DPS fallback, Protection the tank route.

Donor FrostMageStrategy includes `ice lance` at default relevance 5.3 for
movement, and MageActions.h registers CastIceLanceAction. Its Fingers of Frost
trigger prioritizes Deep Freeze/Frostbolt, not a Cata Ice Lance rotation.
This slice deliberately adapts the Cata proc response rather than claiming an
unchanged donor proc strategy. Do not register unimplemented Deep Freeze.

Read-only Cata DBC checks confirmed Heroic Strike 78, class mask 1, level 14;
Ice Lance 30455, mask 128, level 28. Proc 44544 has aura type 262 (ability-ignore-
aura-state), not a trainer acquisition row. Native Unit.cpp's Mage damage path
checks frozen target state and the Mage aura-state override for Ice Lance/Fingers
of Frost. Reuse those eligibility identities; never set aura state, damage,
proc stacks or rage manually.

## Existing owner and invariants

Existing WarriorCombatTrigger/Action and MageSpellAction own execution.
Use current native active primary tree for the Warrior reserve threshold,
converting 40/60 displayed rage to 400/600 native power units. Native casting
still decides actual cost, stance, cooldown, GCD, range and resource validity.

For Frost only, add conditional Ice Lance at ACTION_HIGH + 1 when frozen or
Fingers of Frost is effective. The proc trigger keeps `fingers of frost`; a
bounded `ice lance` trigger covers genuinely frozen current targets. The action
rechecks that condition to reject expired proc/freeze observations. This priority
and frozen-only default usefulness are Cata adaptations, not donor parity.
Keep the existing default Ice Lance slot (5.3) but do not use it as an unrestricted
movement filler yet. Generic Mage and Priest rotations remain unchanged.

Existing combat-engine flags gate both actions. No spell learning, automatic
talents, multi-target/AoE selection, new scheduler, core hook, database or config
key. No own-cast cancellation or full rotation qualification in this slice.

## Acceptance

Pure tests cover rage unit boundaries and tank/DPS reserves, known-spell gates,
and frozen/proc eligibility. Build once for the batch on Windows/Linux, updating
build definitions for new test files. Bundle live use with an appropriately
learned-spell fixture, not another isolated low-level playtest. Native damage,
proc consumption and rage spending remain unverified until exercised.

Implementation is now local source. Windows and Linux worldserver/tests-common
each built and passed all 135 tests, including three new pure policy cases.
No client test was run for this slice; no new core or database seam was required.
