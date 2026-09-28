# Cata AHBot market-catalog baseline
Historical commands below record the original runs. For a new run, supply
`-MySqlHome <installation-directory>` and `-Seed <your-stopped-fixture>`;
see the current [runtime instructions](../core/RUNTIME_TESTING.md).


This is a diagnostic baseline from the disposable native replay. It is not a
price model and does not import, export, or duplicate world item data.

## Provenance method

The seller continues to use TrinityCore `ItemTemplate` records as the source of
item metadata. The catalog annotates vendor and loot membership, then derives
direct profession outputs by joining loaded `SkillLineAbility` records to the
loaded spell effects `CREATE_ITEM` and `CREATE_ITEM_2`. Random craft-result pools
are already represented by `spell_loot_template` and remain part of the loot
source.

The raw CSV is a union of the actual seller pool and additional recognized
profession outputs. `seller_eligible=1` is the exact runtime posting pool;
`seller_eligible=0` is observation only. The feature is default-off through
`AuctionHouseBot.MarketCatalog.File = ""`.

## 2026-09-24 results

Evidence directories:

- legacy source behavior: `build/ahbot-smoke-20260924-204000`;
- opt-in crafted source: `build/ahbot-smoke-20260924-204353`.

The loaded skill/spell data exposed 3,843 direct profession output IDs. Eight
did not resolve to an available item template. The remaining 3,835 crafted
items appear once each in the catalog.

| Measurement | Crafted disabled | Crafted enabled |
| --- | ---: | ---: |
| Seller-eligible items | 9,186 | 12,371 |
| Crafted items already eligible | 211 | 3,396 |
| Additional crafted diagnostic rows | 3,624 | 439 |
| Total unique catalog rows | 12,810 | 12,810 |

The opt-in source therefore added 3,185 profession products without bypassing
the existing binding, price, quality, or class-specific filters. Of the 439
remaining crafted rows, 393 are bind-on-pickup; those should remain excluded
unless a later review identifies a narrow exception.

Before the source was enabled, the 3,624 additional candidates were dominated
by the following item classes:

| Class | Item class ID | Additional candidates |
| --- | ---: | ---: |
| Armor | 4 | 1,642 |
| Consumable | 0 | 505 |
| Gem | 3 | 485 |
| Glyph | 16 | 345 |
| Trade goods | 7 | 229 |
| Weapon | 2 | 203 |
| Miscellaneous | 15 | 155 |

This is enough evidence to avoid a hand-authored market item database. The next
data structure should describe supply policy over these runtime-derived
segments, not copy item names, stats, or speculative prices.

## 2026-09-25 supply-ceiling results

The first AH-03 slice derives three coarse segments from item class:

- commodity: consumables, gems, reagents, projectiles, trade goods, and glyphs;
- equipment: containers, weapons, armor, and quivers;
- other: recipes, miscellaneous items, and remaining classes.

The default-off supply profile applies configurable segment weights and a
simultaneous AHBot-owned listing ceiling per item and auction house. A zero
ceiling means unlimited. Each quality target is split across non-empty segments
with exact largest-remainder allocation, then divided among that segment's
classes using the existing class priorities. The catalog exposes
`market_segment`, `configured_segment_weight`, `configured_item_ceiling`, and
`supply_profile_enabled` so an exported policy can be interpreted correctly.
Its `stack_policy` field distinguishes shaped commodities, single-item
equipment, and legacy class behavior.

`build/ahbot-smoke-20260925-203322` enabled the profile, requested 120 neutral
listings, set 45/40/15 segment weights, and set all three ceilings to one. It
produced 54 commodity, 48 equipment, and 18 other listings using 120 distinct
item entries, retained the target after both live ratio commands, completed the
buyer buyout, and shut down cleanly. Commodity stack validation realized 14
single, 15 quarter, 10 half, and 15 full stacks; every stack matched a shape
derived from that item's actual maximum, and all equipment stacks were one.
The final default-off control in `build/ahbot-smoke-20260925-203604` still
produced exactly 12 of 12 listings.

`build/ahbot-smoke-20260925-204104` added the first turnover replay. Its 120
listings used 59 distinct expiration timestamps spanning 21,590 to 64,795
remaining seconds under a configured 6-18 hour range. After a clean shutdown,
the harness removed 24 listings from the disposable clone and retained 96.
Restarting created fresh auction IDs and restored 120 distinct item entries
with the exact 54 commodity, 48 equipment, and 18 other targets. A subsequent
buyer buyout and all three worldserver shutdowns passed.

`build/ahbot-smoke-20260927-173254` validated the first independent buyer
cadence controls. Two one-copper player-owned auctions were eligible, the
normal evaluation limit was two, and the successful-action limit was one. The
first buyer cycle reported one evaluation and one buyout, removed exactly one
auction, and retained the second for a later cycle. Seller, buyer, and cloned
MySQL shutdowns were clean.

The final enabled catalog reconciled all 12,371 seller-eligible rows into 2,216
commodities, 8,242 equipment items, and 1,913 other items. All 12,810 catalog
rows had unique item IDs and consistently recorded the enabled state and test
ceiling of one.

## Replay

After a `RelWithDebInfo` worldserver build:

```powershell
.\contrib\local\ahbot-smoke.ps1 -CheckBuyer
# Exercise a larger one-listing-per-item supply profile:
.\contrib\local\ahbot-smoke.ps1 -CheckSupplyProfile -CheckBuyer
# Prove staggered expiry and an exact stopped-server removal/refill cycle:
.\contrib\local\ahbot-smoke.ps1 -CheckTurnover -CheckBuyer
```

The replay uses a cloned disposable database and writes the raw and grouped
CSVs inside a timestamped `build/ahbot-smoke-*` directory. Base mode requires
exactly twelve seller listings and a six-hour lifetime; supply and turnover
modes exercise their larger targets described above. Every mode exercises both
live ratio command forms and requires clean shutdowns, while `-CheckBuyer`
proves a buyer buyout. It does not deploy or alter the installed realm.
