# Party buffs through the imported engine

Result: worldserver/tests-common built with both modules enabled; all 109 tests
passed, including three new strategy/aura checks. The stale generated source
list required a CMake refresh to include new files. No realm/client was started;
native buff execution remains for the next mixed-party check.

Scope: move existing Mage Brilliance and Priest Fortitude upkeep into registered
donor-shaped buff strategies/triggers/actions. No new spell, wire protocol, core
hook, database operation, account automation or independent AI loop.

Basis: upstream master rechecked at
`7bae1b5c58c76a0aa20381155edc08096d1485b2`; reviewed
`src/Ai/Class/Mage/Strategy/GenericMageNonCombatStrategy.cpp` (MageBuffStrategy),
`src/Ai/Class/Priest/Strategy/PriestNonCombatStrategy.cpp` (PriestBuffStrategy),
and their class triggers/actions. Adapt only Intellect/Fortitude party upkeep;
Wrath-only Divine Spirit, armor selection, consumables and wider rotations are
excluded. Keep donor GPL notices and document the Cata reduction in PORTING.md.

Owner: the existing class context and session-owned Engine. The optional
EnginePartyBuff gate must select either the engine or existing direct fallback,
never both. Trigger candidate results use the existing CalculatedValue cache;
cache only a boolean, not Player pointers. Actions revalidate current native
targets and retain learned-spell, aura-variant, combat, map/range/LOS and cast
checks. Healing/resurrection priorities remain above party buffs.

Acceptance: creator/consumer names checked, strategy regression tests, one
combined server/tests build. Defer runtime confirmation to the next useful
mixed-party/addon check; do not restart a realm for this individual change.
