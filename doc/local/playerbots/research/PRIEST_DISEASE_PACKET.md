# Priest self/party disease cure

Source checked 2026-10-01 against donor
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source and result

Port the disease subset of PriestCureStrategy in GenericPriestStrategy.cpp,
CureDiseaseTrigger/PartyMemberCureDiseaseTrigger in PriestTriggers.h, and the
existing CurePriestStrategyActionNodeFactory fallbacks. Donor self/party
triggers have relevance 31/30 and prefer Abolish Disease with Cure Disease
fallback. Read-only Cata DBC inspection confirms Cure Disease 528, class mask
16, level 22, effect 38 (dispel) with MiscValue 3 (disease); spell 552 Abolish
Disease is absent. Wire `cure disease` and `cure disease on party` directly.
Do not create an unimplemented Abolish Disease action or grant missing spells.

## Existing owner and native boundaries

Register the donor `cure` strategy in the existing Priest context and engine.
Existing EnginePriestHeal gates execution; no new config key or scheduler.
Current map-thread caster and friendly candidates come from the existing
HealCandidates helper: self/controller/group, same-map alive players within
30 yards/LOS, deduplicated. Self cure has its own trigger; party cure excludes
self and tries eligible members in existing health order.

Ask Unit::GetDispellableAuraList using native disease dispel mask, as
Spell::EffectDispel does. Native selection excludes passives, wrong polarity,
100-percent resistance, zero charges and Unholy Blight disease protection.
Use only list emptiness during the current call, retaining no Aura pointer.
Revalidate target eligibility at execution; native TryCast owns cost, cooldown,
range/LOS, GCD and dispel execution. No manual aura removal or resistance roll.
Defer while resting or processing/pursuing loot to preserve current activity
ownership. Existing emergency healing priorities remain above disease cure.

Magic/poison/curse dispels, enemy purge, talent-granted dispel changes, Priest
Shadow rotations and AoE curing are excluded. No core/database changes.

## Acceptance

Pure regressions cover strategy names/priorities and enabled/alive/known-spell/
native-eligibility gates. Build worldserver/tests-common on Windows and Linux
as one batch, refreshing definitions for new test files. Native aura removal
and resistance/protection cases remain for a bundled suitable-spell fixture;
the level-20 Priest fixture does not normally know this level-22 spell.

Implementation is now local source. Windows and Linux worldserver/tests-common
each built and passed all 138 tests, including three new pure regressions.
No client test was run for this slice; no new core/database changes were needed.

Follow-up source audit found that the old TryInHealthOrder helper drops members
at >=90-percent health. Cure now uses a separate unfiltered stable priority
order in both trigger selection and action execution; healing retains its
original filter. Three regressions cover full-health/cutoff members, stable
ties/cast fallback and empty lists. Windows and Linux each passed all 141 tests.
Native disease removal remains unverified in game.
