# Protection stance and defensive support

Source checked 2026-10-01 against donor mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source and scope

Donor `src/Ai/Class/Warrior/Strategy/TankWarriorStrategy.cpp` schedules
Defensive Stance at ACTION_HIGH + 9, Shield Block at ACTION_INTERRUPT + 1,
Shield Wall on low health at ACTION_MEDIUM_HEAL, and Last Stand on critical
health at ACTION_EMERGENCY + 3. `WarriorActions.h` supplies self buff actions.
`HealthTriggers.h::ValueInRangeTrigger` uses a strict upper health boundary;
`PlayerbotAIConfig.cpp` defaults low health to 45 and critical health to 25.
These defaults are the bounded port's thresholds, not new configurable settings.

Cata DBC identifies Defensive Stance 71, Shield Block 2565, Shield Wall 871,
and Last Stand 12975. Native shapeshift form FORM_DEFENSIVESTANCE identifies
the stance. Native spell requirements, equipment checks and cooldowns remain
authoritative through TryCast; no shield or talent grants are made.
Native `spell_warr_last_stand` applies triggered health aura 12976; inspect that
aura, not the 12975 cast identity. Shield Block and Shield Wall have direct
native aura effects. No temporary maximum-health manipulation is duplicated.

## Adaptations and ownership

Reuse WarriorCombatAction/Trigger with an explicit self-target mode. Existing
hostile melee actions retain their original validators. Self support requires a
living Protection Warrior in combat with its existing living hostile victim on
the same map, but not melee reach, facing or target line of sight. Parent combat
routing still owns the controller, command, transfer and leash gates. No new
engine tick, target acquisition, callback or retained Player pointer.

The action casts on the bot, repeats its conditions, and declines existing
buff auras. Health trigger names are `warrior low health` and `warrior critical
health`: this avoids colliding with the current rest layer's `low health` name.
Health comparisons reject nonfinite/negative values and preserve donor strict
45/25 percent thresholds. Dead characters fail the native living-bot gate.

All additions share the existing default-off EngineWarriorCombat flag and are
scheduled only by the Protection strategy. Defensive Stance is maintained only
inside the current routed fight, not while idle or while a stop/hold suppresses
combat routing. This does not port all stance transitions, Enraged Regeneration,
Spell Reflection, AoE, cooldown coordination or donor tank parity.

## Validation boundary

The policy test covers both exact health boundaries, just-below values, healthy,
negative, NaN and infinite values. Cross-platform build/test results are recorded
in module PORTING.md. Native behavior remains pending one bundled properly
talented/equipped Protection-party check, including stance and shield cooldowns.
Use level-appropriate enemies, not instantly dying low-level targets.
