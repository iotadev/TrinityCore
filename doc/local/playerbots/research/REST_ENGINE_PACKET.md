# Shared food/drink recovery: next bounded port

Source checked 2026-10-01. The bounded implementation is now in development,
with Windows/Linux builds and all 113 tests passed on each, and
native client execution unverified. This packet follows
the accepted player-controlled infrastructure milestone; it is not runtime proof.

## Source basis

Upstream master was freshly fetched and remains
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.
Use `src/Ai/Base/Strategy/UseFoodStrategy.{h,cpp}` for the `food` strategy:
ordinary donor behavior maps `low health` to `food` and `low mana` to `drink`,
each at relevance 3. The donor cheat branch is outside this initial port.
`src/Ai/Base/Actions/UseItemAction.{h,cpp}` resolves `inventory items` using the
action name, checks native CanUseItem/casting state, and rejects food/drink in
combat. Inspect its inventory-value creators and health/mana trigger consumers
before importing; do not copy only the strategy and call it a functional port.

## Existing and missing dependencies

Implementation update: Warrior/Mage/Priest register the shared food strategy,
scalar triggers and cached carried-item actions behind Playerbots.Rest.Enabled.
Typed native pending item-cast requests preserve Cata ProcessItemCast rules.
Recorded spell identity coordinates follow pause/resume and interruption without
retained item/player pointers or another scheduler. The first version accepts
single-category regeneration consumables only; combined feasts are deferred.
Four new pure tests cover wiring, thresholds and eligibility. The historical
dependency observations below describe the starting point, not current absence.

The imported Cata `Bot/Engine/Strategy/Strategy.cpp` already registers food/drink
action-node names. That does not register executable actions or provide usable
inventory candidates. No current Cata food/drink implementation was found in the
module's actions/configuration. Native Player exposes CanUseItem, GetItemByPos
and CastItemUseSpell; confirm ItemHandler's validation and item-spell semantics
before selecting the server-origin adapter. Do not emulate a Wrath item-use packet.

The first batch should include strategy, scalar health/mana triggers, cached
inventory candidate value, executable food/drink actions and session follow/rest
coordination as one dependency-complete slice. Use carried eligible consumables
only: no item creation, purchases, cheat restoration or automatic account gearing.

## Ownership and acceptance

- Keep behavior default-off with one documented module configuration gate.
- One existing per-session engine owns decisions; do not add a second scheduler.
- Do not retain raw Item/Player pointers across ticks. Re-resolve an inventory
  identity and revalidate usability immediately before native item use.
- Trigger reads stay cheap; bounded inventory work belongs behind cached values
  and action usefulness. No SQL or world-owned group changes on map threads.
- Rest may pause follow, but interruption by combat, death, transfer, logout or
  explicit stay/stop must not leave a stale movement/casting owner. Preserve
  existing healing/resurrection priority over low-relevance rest.
- Confirm Cata item categories/effects and native item consumption/cooldowns;
  donor category numbers are leads, not sufficient compatibility proof.
- Batch policy/registry tests and one server build after the coherent edit.
  Reserve client confirmation for the next mixed-party check, not an isolated
  food button smoke test. Linux build/tests do not establish Linux realm runtime.

This packet does not authorize a population manager, inventory protocol, new
database schema, generalized core item API or an autonomous shopping subsystem.
