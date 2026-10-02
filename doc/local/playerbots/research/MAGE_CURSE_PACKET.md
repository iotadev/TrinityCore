# Mage curse utility and shared support

Source checked 2026-10-01 against mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` and matching TrinityCore Cata.

Donor GenericMageStrategy.cpp MageCureStrategy schedules `remove curse` at 41
and `remove curse on party` at 40. MageTriggers.h uses native DISPEL_CURSE
NeedCure/PartyMemberNeedCure triggers. Cata data confirms Remove Curse 475,
effect 38 with MiscValue 2, friendly target 21 and native learn level 30. Use
that real spell; do not grant missing abilities or invent lesser-curse fallbacks.

Existing Priest self/controller/group gathering and unfiltered stable priority
order are extracted into PlayerbotPartySupport. Priest HealCandidates keeps its
class check; healing alone retains its original health cutoff. Full-health party
members remain eligible for both cures. Deduplicate candidates, require alive
same-map players within the existing 30-yard/LOS bound, and prefer lower health
with stable ties. Party cure excludes self, whose own trigger has higher priority.

Shared native eligibility validates matching SPELL_EFFECT_DISPEL metadata then
calls Unit::GetDispellableAuraList with the requested native type. The native
list handles polarity, charges, resistance/protection eligibility and passives;
the bot retains only emptiness, not Aura pointers. Trigger and action rerun
eligibility. At execution, a native rejection on one member permits trying the
remaining candidates. Native TryCast owns cost, range, cooldown/GCD and actual
dispel selection/removal. Existing Priest disease checks now use this same helper.

Mage execution uses the existing default-off EngineMageCombat flag, learned 475,
alive bot and controller on the same map within 35 yards. Transfers, own casts,
mount/flight, recovery and pending/pursued loot defer this utility. Cure is an
independent combat/noncombat strategy, preserved by spec sibling refresh. Enabled
Mages reuse the existing passive two-second engine timer so a curse can be removed
out of combat even if rest/armor/loot are disabled. Tick deduplication uses the
same passive-work predicate; other class behavior is unchanged. No new timer,
core callback, thread handoff, lifecycle admission or database schema is added.

Three new pure tests cover strategy states/names/priorities, cure gates and
healthy-member stable ordering/cast fallback. Existing Priest tests guard the
extracted helper. They do not prove live friendly membership, native dispel
metadata, resisted removal or timing. Build results are in module PORTING.md.
Bundle actual self/party curse removal with suitable learned level-30-or-higher
fixtures and sustained enemies. Spellsteal, offensive purge and other class
dispels are separate ports.
