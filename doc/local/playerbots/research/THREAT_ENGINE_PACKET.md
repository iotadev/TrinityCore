# Single-target caster threat guard

Local development port, 2026-10-01. Donor revision:
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Donor basis

`src/Ai/Base/Value/ThreatValues.{h,cpp}` computes bot threat as a percentage
of the highest threat held by another living group tank. `ThreatStrategy.{h,cpp}`
vetoes single-target damage at 80%, with a reset-on-read `neglect threat` value.
The donor also has an AoE/attacker-list branch and FocusStrategy; neither is
included in this packet.

## Cata adaptation

PlayerbotCombatValues registers `threat` and `neglect threat` in the three
implemented class contexts. Only the existing controlled Creature current target
is supported, unqualified or qualified `current target`. Native threat reads
stay on the existing map thread; no threat mutations or retained Unit pointers.
Other qualifiers, including `aoe`, return zero and are not implemented.

Recognized tanks are living, same-map group Warriors with the native active
Protection talent tree, including human players. Other tank classes and
unassigned Warriors are not guessed. No recognized tank means no damage throttle.
With a recognized tank, combat startup at zero threat defers damage; fleeing
targets permit it. Positive bot threat against zero tank threat saturates at 255.
The ratio is clamped before integer conversion rather than allowing donor
division-by-zero or uint8 wraparound. Non-finite input defers damage conservatively.

The shared `threat` strategy is installed in Mage and Priest engines. Their
offensive single-target actions declare Single threat; self-target/support
actions remain None. Engine::Tick applies the multiplier before scheduled
execution, so damage can yield to other useful actions and resume below 80%.
Healing, cures, buffs and interrupts are unaffected. The reset-on-read bypass
matches the donor, but no new operator command exposes it.

The existing direct Engine::ExecuteAction path does not apply multipliers and
is unchanged. This is not interception of every manual/native cast. Warrior
auto-attacks are not guarded; its engine does not install this strategy yet.
Existing Mage/Priest engine feature gates remain default-off. No new config,
core lifecycle seam, scheduler or database change.

## Verification and follow-up

Four new pure tests cover ratio boundaries, startup/fleeing, saturation and
non-finite input, action-category gating and one-shot reset. One real Engine
scheduling regression uses a policy multiplier to check damage yielding at 80%
and resuming at 79%; it does not simulate native world threat objects.
Windows and Linux worldserver/tests-common built and each passed all 159 tests.
Native threat reads and strategy wiring are source-reviewed;
gameplay remains part of the next bundled party check.

Use an actually Protection-specialized Warrior before expecting the guard.
Learned Defensive Stance or a mob attacking an unassigned Warrior is insufficient.
Observe caster damage yielding/resuming while support remains available, if a
suitable encounter arises; no separate client session is required. Full tank
roles, AoE threat, coordinated tanking, balance and broader target values remain
future donor ports.
