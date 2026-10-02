# Warrior tank rotation slice

Source reviewed 2026-10-01 against AzerothCore mod-playerbots revision
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Donor and Cata mapping

Donor `src/Ai/Class/Warrior/Strategy/TankWarriorStrategy.cpp` supplies default
Devastate (5.3), Revenge (5.2), Sunder Armor refresh -> Devastate (22), Revenge
trigger (22), and Sword and Board -> Shield Slam (40). `WarriorActions.h`
provides native melee spell actions. `WarriorActions.cpp::CastSunderArmorAction`
uses a six-second refresh window and a Wrath five-stack cap.

Read-only checks of Cata 4.3.4.15595 DBC identify Devastate 20243 (level 39),
Revenge 6572 (level 40), Sunder Armor 7386 (level 18), and Sword and Board
proc 50227. Cast 7386 triggers debuff 58567, whose native AuraOptions cap is
three; inspect that debuff rather than the cast identity. Revenge's native
CasterAuraState is defense. Read the cap/state from SpellInfo at runtime rather
than carrying Wrath constants. Cata `spell_warr_devastate` applies native Sunder;
`spell_warr_sword_and_board` resets Shield Slam's cooldown. The module does
neither manually.

## Bounded implementation

Extend the existing Protection `tank` strategy and Warrior trigger/action
registries, under the existing default-off EngineWarriorCombat flag. Devastate
is the learned filler; Sunder is used only without learned Devastate and when
stacks are incomplete or duration is at most six seconds. Any caster's Sunder
counts, as in the donor. Native cap zero fails closed; permanent full-stack
auras do not refresh. The action repeats its conditions at execution.

Preserve the current Cata Shield Slam default, raised to 5.4 to precede the
donor 5.3 Devastate filler; retain Strike as the final starter fallback. Sunder
fallback is an explicit secondary candidate rather than an ActionNode
alternative because this engine skips alternatives for actions that are not
useful (including unlearned spells). No claim of complete donor tank parity.

Revenge checks its native reactive state; Sword and Board checks the native
proc aura before scheduling Shield Slam. Existing TryCast owns costs, stance,
equipment, cooldown, GCD, cast validation and proc consumption. No item grants,
spell learning, stance switching, new target acquisition, ranged Taunt, AoE,
defensive cooldowns or leash changes. All actions still require the current
valid hostile melee victim and existing command/owner control.

## Validation

The pure refresh-policy test covers absent aura, stack deficit, full cap,
inclusive six-second boundary, permanent duration, invalid cap and a different
supplied cap. Windows/Linux build and test results are recorded in PORTING.md.
Native tank behavior is not client-confirmed. Bundle it with a future
level-appropriate Protection fixture that naturally knows the abilities and
has suitable equipment; the previous unassigned level-20 party cannot qualify
Revenge, Devastate or a talented Sword and Board proc.
