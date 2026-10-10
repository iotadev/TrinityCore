# Human-led party and quest milestone

Release preparation: 2026-10-09. This checkpoint combines native gear/loot work,
human-led quest controls and optional diagnostic hooks. It is not autonomous
questing, a dungeon-clear claim or full AzerothCore Playerbots parity.

## Operational evidence

The prepared level-20 Warrior/Mage/Priest party accepted native quest 9156 from
its human controller. All four bots fought/looted objectives and reached complete
status. Testone's explicit reward choice 22979 was confirmed; after clean native
world/database shutdown, its rewarded history and one mapped owned reward item
were present. The human also turned in the quest. The other three bots remained
complete and unrewarded. Item properties and relogin were not tested.

Earlier outdoor/Ragefire checks established useful party combat, support,
recovery and dedicated instance entry. One native equip change and a controlled
need/greed/pass award were saved. Full dungeon clears, broad class/spec/item
coverage and quantitative positioning/threat guarantees remain open.

## Source scope

- Explicit nearby-giver acceptance, bounded accept/reward batches, native shares
  and confirmations, active-log filters, typed links and explicit turn-in.
- Separate destructive abandonment gate; no rewarded-history reset.
- Optional human-first quest loot, exempting native per-player drops.
- Qualified native item-affix comparison and bounded passive action history.
- Narrow native core repairs for quest-share availability and confirmation identity.
- Per-output build-helper exclusion, portable fixture settings and test evidence.

All optional mutation/diagnostic gates retain their defaults. Native Cata session,
map, loot, inventory, quest and database ownership is unchanged. No forced quest
completion, copied progress, automatic travel or general bot population is added.

## Release qualification

Windows and complete current Linux all-modules-enabled builds passed 431/431
tests each. Fresh Windows with all three installed modules disabled passed
19/19 tests. The separate observer reader suite passed 43/43 tests.
No Linux realm runtime claim is made. The optional context exporter is a separate
project, not a bundled module in a core-only or Playerbots-only checkout.

New per-player loot exemption, batch/link/party-confirmation flows, natural affix
outcomes and additional reward/relogin cases remain unobserved in gameplay.
These limits do not require separate tiny playtests before this source checkpoint.

See the [roadmap](PLAYERBOTS_PORT_ROADMAP.md),
[handoff](PLAYERBOTS_WORK_PACKETS.md) and module
[provenance](../../../modules/mod-playerbots/PORTING.md). The core README pins
the matching Playerbots revision. Private captures, credentials, client assets,
database copies and generated binaries are excluded from publication.
