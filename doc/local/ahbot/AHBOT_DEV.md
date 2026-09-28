# Cata Auction House Bot development plan

Status: the native TrinityCore seller and buyer now live in the optional static
`modules/mod-ahbot` source tree and have passed isolated
seller/buyout smoke runs. The seller can hold an exact small quality target,
including through runtime ratio changes. A default-off catalog export now
distinguishes the seller pool from profession-crafted candidates, and an
opt-in crafted source has passed the same replay. A default-off supply profile
now derives commodity/equipment/other segments and enforces per-item listing
ceilings. The overall feature remains disabled and no economy profile has been
selected for a real realm.

The core boundary is limited to world initialization/update dispatch and an
auction-mail identity check. `MODULE_MOD_AHBOT=OFF` builds a working worldserver
with no AHBot implementation or command registration. The module remains inert
until its account and seller/buyer settings are explicitly enabled.

## Data boundary

Do not create or maintain a second item database. The authoritative Cata item
catalog already comes from the core's item templates and related world data.
AHBot currently derives an eligible pool using:

- item class, subclass, quality, item level, required level, and required skill;
- binding and zero-price rules;
- vendor and loot-source membership;
- direct outputs of spells associated with profession skill lines;
- explicit force-include and force-exclude item IDs.

Any new persistent market data should describe policy or observed market state,
not duplicate item names, stats, spells, vendor values, or other template data.

## Milestones

### AH-01 Runtime correctness

- Exact configured listing totals for small and large markets.
- Runtime ratio commands must clamp to the same upper bound as config loading,
  rather than turning ordinary percentages into extreme supply targets.
- Auction duration must respect the configured minimum and maximum.
- A newly created auction is inserted into the in-memory house exactly once.
- Buyer aggregation must retain correct minimum bid and buyout observations.
- Seller and buyer checks run only against a disposable database clone until a
  realm profile is reviewed and explicitly enabled.

### AH-02 Cata market-catalog report

Generate an inspectable report from the actual world data and the same filters
used by the seller. At minimum, group eligible entries by:

- class and subclass;
- quality;
- required-level bands (0, 1-20, 21-40, 41-60, 61-70, 71-80, and 81-85);
- source category (loot, vendor, both, or other);
- binding type and maximum stack size.

The report should include item IDs so suspicious entries can be reviewed, but
it is a generated diagnostic artifact, not a runtime item-data fork. It should
also identify empty or very small category pools before a supply profile asks
the seller to fill them.

### AH-03 Supply profile

Define a conservative Cata placeholder profile from the catalog report:

- target listings by useful market segment, not only global quality;
- weighted selection within each segment;
- sensible stack-shape ranges for commodities versus equipment;
- per-item and per-segment supply ceilings;
- explicit exclusion of quest, bind-on-pickup, internal/test, obsolete, and
  otherwise non-market items;
- gradual refill and randomized expiration so the house does not reset in
  obvious synchronized waves.

Prefer ordinary configuration for realm-wide category choices. If item-level
exceptions become too numerous for include/exclude strings, add one small world
table keyed by item ID for AHBot policy overrides only. Initial fields should be
limited to enable/disable, supply weight, target/ceiling, and stack policy. Do
not add copied item metadata or speculative price columns.

### AH-04 Demand and turnover

Make the buyer produce believable liquidity without becoming an unlimited gold
faucet:

- separate item desirability from price attractiveness;
- cap purchases per house and cycle;
- vary demand by market segment and scarcity;
- prefer aged, under-supplied, and reasonably priced player listings;
- avoid repeatedly contesting the same player or auction;
- record enough aggregate decisions to diagnose why an auction was bought,
  bid on, or ignored.

Buyer-owned purchases remain a simulation sink/source decision that must be
measured. They should not be used to establish the eventual Cata price model.

### AH-05 Cata pricing

Pricing is deliberately deferred. The current vendor-value-derived calculation
is a placeholder suitable for mechanics tests, not a claim about a healthy Cata
economy. Calibrate pricing later from the selected realm's progression,
population, gold generation, profession demand, and observed player listings.
Do not import WOTLK price tables as Cata truth.

## Next implementation gate

AH-01 and the first AH-02 slice compile and pass the disposable seller/buyer
replay. With legacy source settings, the report found 9,186 seller-eligible
items plus 3,624 additional profession-crafted candidates. Enabling the new
`AuctionHouseBot.Items.Crafted` source admitted 3,185 of those candidates
through the remaining binding, price, quality, and class filters, producing a
12,371-item seller pool. The other 439 remain visible as diagnostic rows with
`seller_eligible=0`; they are not silently forced into the market.

The first AH-03 slices now label every catalog row as `commodity`, `equipment`,
or `other`, divide each quality target by configurable segment weights, and
enforce a configurable simultaneous AHBot-listing ceiling per item in each
segment. A disposable 120-listing run using 45/40/15 weights produced exactly
54 commodity, 48 equipment, and 18 other listings. With every ceiling set to
one, all 120 item entries were distinct. Commodities use configurable single,
quarter, half, and full-stack weights while equipment remains single-item. The
same run realized all four commodity shapes within each item's real stack
limit. Both runtime ratio commands, the buyer check, and clean shutdown passed.
The ordinary default-off 12-listing replay also remained unchanged.

The first turnover replay configured staggered 6-18 hour lifetimes and produced
59 distinct expiration timestamps across 120 listings. With the worldserver
cleanly stopped, the harness removed 24 listings from its disposable database
clone. Restarting refilled the market to 120 distinct item entries with fresh
auction IDs and the same exact 54/48/18 segment targets. The subsequent buyer
check and all three clean shutdowns passed.

The first demand-cadence slice now separates buyer evaluation throughput from
seller refill throughput. It adds independent normal/boost evaluation limits,
an optional successful-action cap per house cycle, and aggregate evaluated,
bought, bid, ignored, and limit diagnostics. Defaults preserve legacy behavior.
A disposable two-auction replay with an action cap of one bought exactly one
auction in its first cycle and retained the other.

Next, add segment-aware desirability and aged/under-supplied preference, then
exercise repeated buyer cycles. Retain the current placeholder valuation
boundary; do not add a world-table migration or production price model until
those behaviors are measured.
