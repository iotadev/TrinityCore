# Current-target Spellsteal

Source checked 2026-10-02 against mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` and matching TrinityCore Cata.

Donor GenericMageStrategy.cpp schedules `spellsteal` at 40; MageTriggers.h uses
TargetAuraDispelTrigger with DISPEL_MAGIC, and MageActions.h registers the native
cast action. Cata Spellsteal 30449 has effect 126 (steal beneficial buff), magic
type 1, hostile target 6 and native learn level 70. Validate this effect metadata
and learned spell before looking for candidate buffs.

On the already validated hostile current Creature, use native
Unit::GetDispellableAuraList with the magic mask. In this hostile case its
polarity/passive/dispel-chance/charge filters match the candidate portion of
Spell::EffectStealBeneficialBuff. Add the required CANNOT_BE_STOLEN filter:
ordinary offensive dispel candidates alone are not enough. The native methods
read owned auras with an application on this target. Retain only eligibility,
never an Aura pointer or selected buff across trigger/action execution.

Trigger and action recheck the same condition; request an ordinary native cast.
Spell::EffectStealBeneficialBuff owns random choice, resistance rolls, stack/
charge decrement, removal/transfer, duration and native client result packets.
Do not duplicate that execution or fabricate a successful transfer event.

The action is installed in generic/Fire/Arcane/Frost routes at donor priority 40
and remains under the existing default-off Mage combat-engine flag. Existing
controller/commands/leash/target eligibility, facing, range, LOS and cast checks
remain. Conservative single-target threat classification is retained even though
this is utility rather than direct damage. No fresh enemy acquisition, buff scan
outside the current target, PvP routing, general purge or permission expansion.

Two pure tests cover learned/native-candidate gates and the non-stealable flag.
They do not exercise native aura enumeration, selection or transfer. Build status
is recorded in module PORTING.md; Docker API failures currently prevent confirming
Linux validation of this and the preceding curse slice. Bundle actual transfer
with a learned level-70-or-higher Mage and a suitable buffed hostile fixture;
ordinary starter-zone fights cannot qualify Spellsteal.
