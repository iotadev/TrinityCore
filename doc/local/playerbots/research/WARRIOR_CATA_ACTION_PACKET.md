# Cata Warrior single-target additions

Source checked 2026-10-01 against the matching TrinityCore Cata source/data and
mod-playerbots donor `7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Provenance and native mechanics

Colossus Smash and Raging Blow are Cata additions, not unchanged Wrath donor
actions. Reuse the already adapted donor Arms/Fury strategies and named
WarriorCombatAction/Trigger; do not introduce another combat engine.

Read-only Cata DBC checks identify Colossus Smash 86346 (native level 81),
whose direct aura effect 345 is applied by the cast, and Raging Blow 85288,
whose CasterAuraState is native Enrage (17). Its spell effects trigger native
weapon-hit spells 96103 and 85384. Actual learning, equipment and cast validity
remain native; no level, spell or talent grants are made.

TrinityCore `spell_warr_sudden_death` (52437) resets Colossus Smash's cooldown.
The Wrath donor Arms strategy instead routes `sudden death` to Execute. Do not
copy that route into this Cata slice: Execute remains strictly below 20% health.
Native `spell_warr_colossus_smash` owns its glyph/Sunder interaction.

## Bounded scheduling

Arms and Fury schedule Colossus Smash at relevance 28, after their stance
priority and before their primary strike priority. Its usefulness and execution
both require the learned spell and absence of the bot's own 86346 target aura.
Another caster's aura is not substituted for the bot's own damage window.
Preserve an active own window rather than clipping it after a cooldown reset.
No separate proc handler is needed: native Sudden Death resets the cooldown,
and existing TryCast observes native cooldown eligibility on subsequent ticks.

Fury schedules Raging Blow at 26, behind Bloodthirst (27) and before proc Slam
(25). These two scheduling priorities are explicit Cata adaptations, not donor
rotation parity. Raging Blow reads its required CasterAuraState from SpellInfo,
uses native HasAuraState with the spell/caster, and fails closed if metadata is
absent. Both action and trigger recheck current eligibility.

Existing learned-spell, controlled melee victim, facing, LOS, owner, command,
transfer, leash and default-off EngineWarriorCombat boundaries remain. Native
casting owns rage, cooldowns, equipment, damage, armor effects and triggered
weapon attacks. No Enrage injection, proc removal, manual cooldown reset, AoE
or new acquisition permissions.

## Validation and remaining work

Pure tests cover learned/unlearned Colossus Smash with/without the owned aura,
and learned/unlearned Raging Blow with/without native Enrage eligibility.
They do not establish native proc or damage correctness. Cross-platform results
are recorded in module PORTING.md; runtime is still unverified and should join
the bundled level-appropriate Arms/Fury check.

Learning a level-81 ability does not complete 81-85 combat-value/gear profiles.
Those estimates remain a separate gap; these actions do not depend on them.
Enrage generation, offensive cooldowns, full priority tuning, Arms hard-cast
Slam, movement skills and AoE remain separate slices.
