# Priest healer-DPS slice

Bounded implementation in local source. Source checked 2026-10-01
against donor `7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Source and dependencies

PriestHealerDpsStrategy in GenericPriestStrategy.cpp wires `healer should
attack` to Shadow Word: Pain (5.5), Holy Fire (5.4), Smite (5.3), Mind Blast
(5.2) and shoot (5), plus a separate AoE branch. GenericTriggers.cpp's
HealerShouldAttackTrigger checks party healing demand, mana and group balance.
The donor's default almost-full-health threshold is 85; mana thresholds are
85 for balance <= 50, configured highMana (default 65) for <= 100, otherwise
mediumMana (default 40). Its solo exception bypasses those party checks.
DpsTargetValue supplies broader target selection/threat/exclusion dependencies.

Cata currently has one existing Priest healing engine, current native talent
tree, alive/map/range/LOS candidate selection and casting through TryCast.
Before this slice it had neither donor balance nor full DPS target values.
The later balance packet adds the engaged PvE subset; full DPS selection remains
unported. Before the initial healer-DPS slice,
the session's beginAttack path supported Warrior/Mage only and auto-assist
excluded Priest. The changes below supply a controlled target before ticking
the Priest engine, rather than adding Smite against an empty combat target.

## Implemented scope

1. Disease cure uses unfiltered support ordering; healing keeps its existing
   cutoff. See PRIEST_DISEASE_PACKET.md.
2. Native Cata DBC rows identify Smite 585, school-damage effect 2, level 1 and
   Priest class mask 16. The real learned spell is cast through TryCast, under
   the existing EnginePriestHeal gate. Strategy/trigger names are `healer dps`
   and `healer should attack`; Smite keeps donor relevance 5.3.
   The follow-up adds Shadow Word: Pain 589 (level 4, periodic damage), Holy
   Fire 14914 (level 18, direct plus periodic damage) and Mind Blast 8092
   (level 9, direct damage), all native Priest mask 16. The shared spell table
   retains donor order/priorities 5.5, 5.4, 5.3, 5.2. The common trigger no
   longer depends on knowing Smite; each action checks its own learned spell.
3. The existing map-thread combat adapter owns the same GUID-only target and
   assist flag. Priest does not call native melee Attack or MoveChase. It pauses
   idle follow for stationary support, then explicitly restores formation when
   support ends, including while native combat flags are draining.
4. Commands are consumed and offensive target validity checked before the
   Priest's existing 750-ms healing tick. Stop disables auto-assist; follow
   reenables it through the existing movement path. Hold/controller loss, death,
   transfer, feature disable, leash failure and controller combat ending clear
   the target. Explicit attack can supply the selected creature, but Priest
   damage still requires the controller to be fighting it; it does not initiate
   an independent pull. No separate damage permission flag or scheduler exists.
5. Trigger and action execution check live target eligibility, learned spell,
   native map/hostility/range/LOS and absence of casting/rest/loot. Damage defers
   if any eligible healing candidate is below 90% health, or mana is below 85%.
   The initial slice used the donor's conservative mana branch without its solo
   exception. The later COMBAT_BALANCE_PACKET.md supplies the engaged PvE balance
   subset and donor-default 85/65/40 mana thresholds; the solo bypass remains
   absent and the existing 90% healing cutoff is unchanged.
6. Periodic spells check native HasAura with the bot's caster GUID and do not
   reapply while their own aura remains. Another Priest's aura does not block
   them. Native casting still owns range, cooldown, resources, aura duration
   and effects. Holy Fire uses the donor's zero minimum-lifetime behavior.
   Shadow Word: Pain's donor eight-second lifetime gate is now connected to the
   shared estimated group DPS value; see COMBAT_VALUES_PACKET.md. Unknown or
   unsupported estimates skip this DoT, not the remaining healer damage spells.
   The estimate is a donor level/gear/role model, not measured Cata damage.

Existing heal/cure priorities outrank damage; native casts own costs/cooldowns.
No own-cast cancellation, AoE, Shadow strategy, automatic spell/talent learning,
pet or unrestricted autonomous targeting. Preserve existing fallback healing
and module-off behavior. No new core hook/database seam should be required.

## Verification and remaining work

Four added tests cover donor names/relevance, gates/mana boundaries, changing
healing/target eligibility and an actual engine-queue recheck after healing
demand, target loss or mana spending. Windows and Linux worldserver/tests-common
built and each passed all 145 tests.
The follow-up adds Cata identity and periodic-aura policy checks and expands
the donor wiring regression to four actions. Windows and Linux
worldserver/tests-common built and each passed all 147 tests.
The shared combat-value follow-up adds seven estimate/gear/lifetime regressions;
Windows and Linux each built and passed all 154 tests. Native traversal and cache/context
lifetime are source-reviewed, not simulated world-object tests.
Control/movement invalidation is source-reviewed, not natively simulated by
those policy tests. Bundle healthy-party Smite, healing demand and stop/follow
with other pending gameplay checks. No own-cast cancellation means an accepted
Smite may finish before a newly injured party member receives a heal. Native
damage, follow resumption and healing responsiveness remain unverified in game.

Next donor additions are full DPS target values, broader attacker parity, Cata 81–85 estimate
profiles, wand shooting and the separately gated AoE branch, as needed by
broader class porting. Do not recreate those services as ad-hoc rotation rules.
