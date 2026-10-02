# Active-spec combat strategy refresh

Source checked 2026-10-01 against donor
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source and existing owner

Donor `src/Bot/Factory/AiFactory.cpp::AddDefaultCombatStrategies` selects class
strategies using `GetPlayerSpecTab`; `PlayerbotAI::SelectiveResetStrategies`
rebuilds the relevant engine through that factory. Cata's session adapter
previously selected Warrior tank and Mage Frost only when constructing its
single engine. Mage armor already reads the current active spec each time.

The adaptation remains in the existing map-thread session adapter, class
contexts and donor Engine::AddStrategy/Init. It reads native
`GetPrimaryTalentTree(GetActiveSpec())`, not Wrath talent-point totals.
PlayerbotSpecStrategy.h selects only implemented routes: Protection -> tank,
other Warrior trees -> warrior; Frost -> frost, other Mage trees -> mage;
Priest -> heal as an explicit current fallback. Unsupported classes yield no
strategy. No missing Arcane/Fire/Shadow strategy is registered.

## Implementation and invariants

The adapter checks the desired route before any engine tick. An unchanged route
does nothing, preserving queued work. A changed route uses AddStrategy's sibling
exclusivity and Init to drop obsolete queued actions and rebuild triggers.
Mage combat siblings now have a separate sibling context, like Warrior, so
buff/rest/loot and armor strategies are preserved. The context/engine are not
recreated, and no Player pointer, talent pointer or second scheduler is added.
Existing native casts remain native; a strategy refresh is not a cast-cancel
or talent-learning command. Existing feature gates still control execution.

No database/config/packet/core seam changes, automatic spec assignment,
talent spending, saved user strategy overrides or complete rotations belong
to this slice. When player-selected strategy persistence is added, its override
precedence must be designed before this default route is expanded.

## Acceptance and handoff

Three pure regressions cover native-tree mapping and unsupported-class fallback,
sibling replacement while preserving shared strategies, and queue preservation
for unchanged routes versus reset on route changes. Windows worldserver and
tests-common built and all 129 tests passed. Linux worldserver/tests-common
also built and passed all 129 tests.
Live dual-spec/talent changes remain unverified; bundle them when a suitable
fixture exists rather than starting a standalone login for this helper.

The next class work should port complete bounded donor strategy/action families
and their Cata spell dependencies. Keep generic fallback and unsupported spec
behavior explicit, not disguised as full class identity.
