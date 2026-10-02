# Current-target Warrior/Mage interrupts

Source checked 2026-10-01 against donor
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Result and source basis

Add Pummel and Counterspell to the existing Warrior/Mage combat contexts and
strategies, using donor interrupt triggers/actions rather than a new combat loop.
Donor WarriorTriggers.h declares PummelInterruptSpellTrigger through
INTERRUPT_TRIGGER; WarriorActions.h declares CastPummelAction. FuryWarriorStrategy
wires `pummel` at ACTION_INTERRUPT. MageTriggers.h declares
CounterspellInterruptSpellTrigger, and MageActions.h declares CastCounterspellAction.
GenericTriggers.cpp::InterruptSpellTrigger::IsActive checks current-target casting
and interruptibility. Enemy-healer variants exist but are outside this slice.

Read-only Cata 4.3.4 DBC inspection confirms spell 6552 Pummel, class mask 1,
learn level 38; spell 2139 Counterspell, class mask 128, learn level 9.
Both have effect 68 (SPELL_EFFECT_INTERRUPT_CAST). Use known native spells only;
no automatic grant, Wrath rank IDs or presumed level-based availability.

## Existing owner and native invariants

Existing class contexts register actions/triggers; implemented Warrior/Mage
strategies add the interrupt at donor ACTION_INTERRUPT (40). The current target
is the GUID-based combat target already selected by the session adapter.
Revalidate at action execution, not only at the trigger. Inspect generic/channel
spells using the same preparing-with-cast-time/channeling and
SpellInfo::CanBeInterrupted checks as native Spell::EffectInterruptCast.
Skip auto-repeat and instant spells; no manual InterruptSpell, school lockout,
cast cancellation or native immunity bypass.

Native PlayerbotDecision::TryCast owns range, LOS, resource, stance, cooldown,
GCD and cast validation. Existing EngineWarriorCombat/EngineMageCombat flags
gate the new actions. No Priest Silence, enemy-healer scans, coordination,
movement-to-interrupt, own-cast cancellation, database or config change.

## Acceptance and stop point

Pure regressions should cover cast-state/interruptibility policy and registry
name/relevance. Build worldserver/tests-common on Windows/Linux as one batch.
These tests do not prove landed interrupts or coordination. Bundle a caster-mob
check when appropriate; low-level Warriors lacking Pummel should simply skip it.
Document results and the Mage-own-cast limitation. Stop if a wider native hook
or speculative spell acquisition policy appears necessary.

Implementation is now local source. Three pure regressions cover preparing/
instant/native-allow policy, channeling protection and names/relevance. Windows
worldserver/tests-common built and all 132 tests passed after explicit build
definition refresh to include the new source and test files. Linux
worldserver/tests-common also built and passed all 132 tests after refreshing
its build definitions. No client interrupt test has been run for this slice.
