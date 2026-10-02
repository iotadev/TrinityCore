# Shared combat estimate values

Local source implementation, donor revision
`7bae1b5c58c76a0aa20381155edc08096d1485b2`, checked 2026-10-01.

## Donor basis

- `src/Ai/Base/Value/EstimatedLifetimeValue.{h,cpp}`: level/gear/role group DPS,
  20-second cache, role multipliers tank 0.3/healer 0.1/DPS 1, gear modifier
  bounds 0.75–4, raid/party bonuses and health divided by predicted DPS.
- `src/Bot/PlayerbotAI.cpp`: GetMixedGearScore, _fillGearScoreData and
  GetItemScoreMultiplier. The estimate uses best usable equipped/carried gear
  per slot, including paired ring/trinket slots, compares two-hand against both
  weapon slots, then averages the top twelve scores. It does not equip items.
- `src/Bot/Factory/PlayerbotFactory.cpp`: CalcMixedGearScore baseline conversion.
- `src/Ai/Base/Actions/GenericSpellActions.{h,cpp}` and PriestActions.h:
  CastDebuffSpellAction uses target health / estimated group DPS; Shadow Word:
  Pain requires eight seconds, Holy Fire zero. This direct action gate does not
  use EstimatedLifetimeValue's separate multi-attacker penalty.
- `src/Ai/Base/ValueContext.h`: donor names `estimated group dps` and
  `estimated lifetime`. PlayerbotAIConfig.cpp defaults sight distance to 100.

This is a model, not measured damage or an exact time-to-death prediction.

## Cata implementation

PlayerbotCombatValues registers the two names in Warrior, Mage and Priest
contexts. PlayerbotDpsEstimate holds reusable arithmetic and gear aggregation.
The existing native map thread gathers live same-map server-origin group bots
within the donor's default 100-yard sight distance. Human players are excluded,
as in the donor; current selfbot operation is not implemented. Self is included.
Native CanUseItem filters equipped/carried items; bank items are not inspected.
Robe-to-chest and holdable-to-offhand mappings are explicit Cata corrections to
the donor switch. The scorer otherwise retains the donor's slot/top-twelve
arithmetic and quality multipliers, including integer truncation.

Role weights follow implemented strategies: Protection Warrior tank, current
Priest healer fallback, Mage/other Warrior DPS. Unported classes are not given
invented roles. Profiles cover levels 1–80 only; an unsupported contributing
bot yields zero/unavailable when the estimate is calculated. No Wrath DPS/gear
curve is extrapolated to levels 81–85. Even within 1–80 this remains the donor
approximation, not a Cata-calibrated damage model.

The 20-second cache stores a float and scalar group/map/level identity, not
player/item pointers. Get invalidates it on the bot's group identity, map or
level change. Other roster/role/gear changes may wait for the donor cache
interval; no promise of instantaneous population/gear accuracy is made.
PlayerbotAI exposes its borrowed engine context through the donor-style getter;
AiObjectContext binds it on construction and clears it on destruction. Existing
session ownership destroys engine/context before the AI adapter. All reads and
bindings are map-owned; no new thread, callback, scheduler or native core hook.

Estimated lifetime resolves only the existing controlled current target, either
unqualified or qualified `current target`. Unknown qualifiers, dead/missing
targets and invalid/zero estimates return zero. Other target values and the
donor multi-attacker penalty are not implemented by this single-target subset.

Shadow Word: Pain rechecks native current health against the named estimated
group DPS value at execution and requires at least eight seconds. Unknown
estimates skip that DoT, allowing the other healer actions to remain available.
Holy Fire retains zero minimum lifetime. Healing, mana, aura ownership and
command checks remain unchanged; native casting owns all effects and costs.
The existing healing-engine flag stays default-off. No new config or SQL.

## Verification and next work

Seven new pure tests cover donor curve boundaries, baseline truncation/quality,
role and gear bounds, group bonuses, gear slot pairs/Cata mappings, two-hand
selection and lifetime rejection/boundaries. Windows and Linux worldserver and
tests-common built and each passed all 154 tests. Native inventory traversal,
member filtering, context lifetime and
cache invalidation are source-reviewed; the tests do not simulate world objects.

Use the next bundled party session to observe a sturdy target receiving Shadow
Word: Pain, while short-lived targets can fall through to direct spells. Do not
treat a skipped DoT as a casting failure without checking the estimate's scope.
No measured DPS, raid behavior, high-level profile or calibrated accuracy claim.
The subsequent [threat packet](THREAT_ENGINE_PACKET.md) covers the bounded
single-target caster guard. The later COMBAT_BALANCE_PACKET.md adds engaged PvE
attackers/balance. Next shared services remain full DPS target values; levels 81–85,
additional classes/roles and multi-attacker lifetime need their own Cata port.
