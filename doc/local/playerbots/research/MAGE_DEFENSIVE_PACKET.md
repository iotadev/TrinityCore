# Mage defensive support

Source checked 2026-10-01 against donor mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` and matching TrinityCore Cata.

GenericMageStrategy.cpp schedules critical-health Ice Block at 90 and low-health
Mana Shield at 85. FrostMageStrategy.cpp schedules medium-health or being-attacked
Ice Barrier at 29. PlayerbotAIConfig.cpp donor defaults are 25/45/65 percent;
this slice uses those defaults, not the donor configurable-health value layer.
The Frost pressure condition is deliberately limited to the current controlled
enemy attacking the bot. It does not scan for attackers or acquire targets.

Native scaled spell identities are Ice Block 45438, Mana Shield 1463 and Ice
Barrier 11426. Require learned spell, absent current aura, alive in-combat Mage,
alive hostile current victim on the same map, and no own non-melee cast. During
Ice Block, defensive actions defer. Trigger/action recheck the same conditions.
Native SpellInfo exclusion metadata supplies Hypothermia 41425 for Ice Block;
cooldown/GCD/cost/equipment and final aura restrictions remain native cast checks.

Self protection does not require enemy-facing, LOS or melee range. The existing
session controller/command/transfer/leash routing still determines when this
combat context ticks; this is not a new idle manager or autonomous combat path.
Self actions report no direct threat so the damage throttle does not suppress
protection. Fire/Arcane inherit common defenses; Frost explicitly installs them
and its own barrier; the generic unassigned route keeps only common defenses.

Native spell_mage_ice_block applies Hypothermia and glyph cooldown reset. Native
Ice Barrier/Mana Shield scripts own scaling, absorption, mana spending and
talent callbacks. Those callbacks can include reactive nearby freeze/knockback:
do not characterize this as having no area effects. No new offensive AoE strategy,
manual triggered spell, aura removal, damage/absorb calculation, cast interruption,
Blink movement or early Ice Block cancellation is implemented here.

Three pure tests cover strict health boundaries, pressure, learned/blocked gates
and invalid health. They do not verify actual native absorbs, costs, immunity,
Hypothermia application or post-block follow/combat recovery. See module PORTING.md
for builds. Bundle those observations with the pending native class fixtures,
using learned/talented/equipped bots and level-appropriate sustained enemies.
