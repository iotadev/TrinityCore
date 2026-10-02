# Arms and Fury starter combat strategies

Source checked 2026-10-01 against donor mod-playerbots revision
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Donor mapping

`src/Ai/Class/Warrior/Strategy/ArmsWarriorStrategy.cpp` supplies Mortal Strike
as a default at 5.1 and triggered at ACTION_HIGH + 3, Battle Stance at
ACTION_HIGH + 10, and Execute on target critical health at ACTION_HIGH + 5.
`FuryWarriorStrategy.cpp` supplies Bloodthirst default 5.5 and trigger
ACTION_HIGH + 7, Execute default 5.2, and Berserker Stance at ACTION_HIGH + 9.
The donor context registers sibling `arms` and `fury` strategies.
`HealthTriggers.h::TargetCriticalHealthTrigger` has a strict 20% upper bound.
These names, priorities and health boundary are retained.

Read-only Cata DBC checks identified Mortal Strike 12294, Bloodthirst 23881,
Execute 5308, Battle Stance 2457 and Berserker Stance 2458. Execute has native
target low-health state and stance requirements; these remain enforced by native
casting. Cata `spell_warr_execute` owns extra rage consumption and damage,
and `spell_warr_bloodthirst` owns its healing effect. Neither is duplicated.

## Existing engine and boundaries

Add the bounded strategies to the current Warrior sibling context. The native
active primary tree selects `arms`, `fury`, or `tank`; unassigned/unsupported
trees retain `warrior`. Session combat uses existing PlayerbotSpec::Refresh
rather than maintaining a second two-route policy. Existing engine Init removes
obsolete queued work on a route change; unrelated strategies remain intact.

Existing WarriorCombatAction/Trigger owns learned checks and execution. Self
stance support uses an explicit required primary tree: Arms stance cannot run
for Fury, and the existing defensive actions still require Protection. Hostile
actions retain the controlled native melee victim, facing and LOS checks.
Stances run only in the current routed combat, not while idle. Existing stop,
hold, owner, transfer and leash conditions remain outside and unchanged.

Execute usefulness and execution both check finite target health strictly below
20%; the target must also be alive through the existing validator. No above-20
Execute proc behavior is claimed. Native casting still decides actual costs,
cooldowns, equipment, stance and spell validity. All additions use the existing
default-off EngineWarriorCombat flag. No spells, talents or equipment are granted.

## Deliberate omissions

Keep Strike as the starter fallback and inherit the current generic interrupt,
Rend, Victory Rush and rage-spender behavior. This is not complete donor Arms or
Fury parity. AoE/Whirlwind/Bladestorm, Charge/Intercept, Overpower/Taste for Blood,
Bloodsurge/Slam, Cata Raging Blow/Colossus Smash, offensive cooldowns, DPS Sunder
coordination and Warrior threat throttling remain future slices. Do not copy
Wrath proc behavior or removed actions indiscriminately.

## Validation

Policy tests now cover all four Warrior routes, Arms -> Protection -> Fury ->
unassigned sibling replacement, stable-spec queue preservation and changed-spec
queue clearing. A new Execute test covers just below/exactly at 20%, healthy,
negative, NaN and infinite values. Cross-platform results are in module
PORTING.md. Runtime is unverified; bundle this with a native learned/talented
Arms/Fury fixture and level-appropriate mobs rather than a separate spell test.
