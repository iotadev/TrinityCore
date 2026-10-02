# Frost proc follow-up

Source checked 2026-10-01 against donor mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` FrostMageStrategy.cpp and matching
TrinityCore Cata source/data. This is a bounded controlled single-target port,
not full Frost parity.

Donor Brain Freeze -> Frostfire Bolt precedes Deep Freeze on frozen/proc targets.
Cata Brain Freeze aura 57761 effect 1 is a percentage cast-time modifier (op 10)
affecting Frostfire Bolt 44614. Require learned base, current affecting effect
and reduction at least 100 percent; no hard-cast Frostfire filler. Native casting
owns final cast time, cost, proc consumption and glyph/periodic effects.

Deep Freeze 44572 has native frozen target aura-state requirement 4. Read it from
SpellInfo and use target.HasAuraState with this spell and caster, so an affecting
Fingers of Frost ignore-state effect is honored without copying Ice Lance's mask.
Keep ordinary learned/cooldown/GCD/range/LOS/target/native cast checks. Native
spell_mage_deep_freeze handles damage spell 71757 for immune creatures; the bot
never requests the triggered damage directly or injects a frozen aura.

Adapt priorities to Brain Freeze 23, Deep Freeze 22, existing Ice Lance 21.
This preserves donor relative order (19.5/19) and avoids the existing Cata
Ice Lance fallback starving the new actions. Trigger and action recheck the same
predicate; both use existing single-target threat control. Interrupt/pressure
support remains higher priority. No autonomous pull, pet, AoE or movement port.

Two pure policy tests cover learned/proc/cast-time and learned/frozen gates,
not native aura matching or immune-target execution. See module PORTING.md for
build results. Next useful runtime check is bundled with the other class ports,
using a native learned/talented Frost fixture and level-appropriate sturdy mobs.
