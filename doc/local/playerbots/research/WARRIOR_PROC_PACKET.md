# Overpower and Bloodsurge response

Source checked 2026-10-01 against mod-playerbots donor revision
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Donor and native source

Donor ArmsWarriorStrategy.cpp schedules both `overpower` and `taste for blood`
-> Overpower at ACTION_HIGH + 4. FuryWarriorStrategy.cpp schedules `instant slam`
-> Slam at ACTION_HIGH + 5. WarriorAiObjectContext.cpp registers those trigger
names; WarriorTriggers.h uses a can-cast trigger for Overpower and a `slam!`
aura trigger for instant Slam. Preserve names and priorities, adapt eligibility
to native Cata rather than importing the Wrath name-based proc resolver.

Cata DBC identifies Overpower 7384, Taste for Blood 60503, Slam 1464 and
Bloodsurge 46916. Taste for Blood has an ability-ignore-aura-state effect whose
native spell mask affects Overpower. Bloodsurge effect zero is a percent
ChangeCastTime modifier of -100 for Slam. 52437 is Sudden Death, not Bloodsurge;
do not identify Cata procs from remembered Wrath spell IDs alone.

Native Unit.cpp::ProcSkillsAndReactives awards a target-bound combo point on
Warrior dodge reactions. UpdateReactives clears it when the timer expires.
Spell.cpp::CheckCast permits an affecting ability-ignore-aura-state effect to
bypass combo requirements. Reuse those identities without awarding, clearing
or retaining reactive state in the module.

## Bounded implementation

The existing WarriorCombatTrigger/Action still checks learned spells, current
living controlled melee victim, facing and LOS, and the default-off combat flag.
Arms schedules Overpower when native combo points belong to that exact target
or when Taste for Blood's current native effect actually affects Overpower.
The separate Taste for Blood trigger schedules the same donor action; execution
rechecks combined eligibility, rejecting stale reactive/proc observations.

Fury schedules Slam only with Bloodsurge's current effect zero, correct native
percent-modifier aura type, ChangeCastTime operation, an affecting spell mask,
and at least a 100% cast-time reduction. It is not a generic hard-cast filler.
Native casting remains authoritative for the final calculated cast time and
other simultaneous modifiers, cooldowns, rage, damage and proc charges.
The module does not force instant casting, remove a proc or manipulate swings.
Native spell_warr_slam and spell_warr_slam_triggered own triggered weapon hits,
Bloodsurge damage and Battle Trance interactions.

No extra scheduler, cached Aura/Player pointer, new target acquisition or
permission changes. No Sudden Death/Colossus Smash adaptation, Raging Blow,
normal Arms Slam, AoE or offensive cooldowns in this batch.

## Validation

Pure tests cover learned/unlearned Overpower, target reaction versus affecting
proc, neither/both conditions, and the instant-Slam modifier boundary (-99,
-100 and -101), absent/mismatched modifier and unlearned Slam. Native pointer,
spell-mask and proc-lifecycle behavior is source checked, not established by
those policy tests. Cross-platform results are recorded in module PORTING.md.
Runtime remains bundled with a naturally learned/talented Arms/Fury fixture and
level-appropriate mobs; no isolated spell-by-spell client check is required.
