# Fire/Arcane starter strategies and Arcane actions

Source checked 2026-10-01 against donor mod-playerbots
`7bae1b5c58c76a0aa20381155edc08096d1485b2` and matching native Cata source/data.

Donor FireMageStrategy.cpp defaults Fireball 5.3, Frostbolt 5.2 and Fire Blast
5.1; preserve that starter order, omit shooting and deferred Fire triggers.
ArcaneMageStrategy.cpp defaults Arcane Blast 5.6, Missiles 5.5, Barrage 5.4,
Fire Blast 5.3 and Frostbolt 5.2. Preserve the implemented action order and its
`arcane blast 4 stacks and missile barrage` -> Missiles relevance 15 trigger.
Use explicit Barrage/default candidates instead of the donor ActionNode
alternative because this engine skips alternatives for unlearned/useless actions.

Cata DBC identifies Arcane Blast 30451, Missiles 5143 and Barrage 44425.
Missiles requires caster aura 79808. Native spell_mage_arcane_missiles_trigger
applies/removes that aurastate with the proc. Read the requirement from SpellInfo
and fail closed if it is absent. Arcane Blast aura 36032 has native cap four;
read the cap rather than hardcoding it. The trigger requires a usable learned
Missiles proc and a full native stack. The action repeats proc eligibility before
casting, including when selected as a default candidate below Blast.

Existing MageSpellAction owns execution and reports single-target threat for
these damage spells. Existing cast/channel, controlled target, 30-yard range,
LOS/facing, owner, command, transfer, leash and default-off combat gates remain.
Native casting owns mana, stacks, channels, cooldowns and proc consumption.
No manual aura clearing, channel interruption, mana injection or burn/conserve
manager. The current pressure-only Fire Blast condition is preserved, so this
is not complete donor movement fallback parity.

All four Mage sibling routes now use native primary-tree selection: `fire`,
`arcane`, `frost`, or unassigned `mage`. Session routing uses the shared spec
refresh, preserving unrelated strategies and clearing old queued combat work
on a change. Existing Frost behavior and generic fallback are unchanged.

Fire here is a named starter route, not a full Fire rotation. Scorch, Living
Bomb, AoE and offensive cooldowns remain ahead. Hot Streak needs a separate
native override adaptation: Cata aura 48108 overrides base Pyroblast 11366 with
92315 through Unit::GetCastSpellInfo. Current TryCast constructs a Spell directly
and does not resolve that native override. Do not bypass learned base-spell
authorization or force-cast the replacement as a shortcut.

Tests cover all Mage routes and sibling replacement preserving shared strategies,
Missiles learned/proc gating, and native stack-cap boundaries/invalid cap.
Cross-platform results are recorded in module PORTING.md. Native Arcane behavior
remains unverified; bundle a naturally learned/talented fixture and appropriate
mobs with the next class-party check. No isolated spell test is required.
