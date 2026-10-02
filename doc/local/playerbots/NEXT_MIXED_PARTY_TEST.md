# Mixed-party checks

The current next check is the [shared-state milestone](PLAYERBOTS_STATE_MILESTONE.md)
using the [repeatable role fixture](PLAYERBOTS_PARTY_FIXTURE.md). The observations
below are dated evidence and later class-qualification ideas, not instructions
to open separate per-spell sessions or extend this milestone.

## Spellsteal observations, when a suitable high-level fixture is ready

Use native learned Spellsteal 30449 (level 70) and a suitably buffed hostile
current target. Observe actual beneficial magic-aura transfer, not just accepted
casts; non-stealable/passive/fully resistant or empty-charge candidates must not
cause repeated useless requests. Keep the existing threat/control gates and
bundle this with broader class qualification rather than starter-zone fights.

## Mage curse observations in the next bundled check

Use native learned Remove Curse 475 (level 30). Observe self and friendly party
curse removal, including a full-health member, in and out of combat. Confirm
disabled/unlearned paths stay inactive and rest/loot do not overlap cure work.
Accepted cast logs are not proof of removal; native resistance/protection and
real aura changes need observation. Recheck Priest disease/healing behavior
with the shared support helper in the same suitable-fixture session.

## Mage defense observations in the next bundled check

Use native learned spells and talents. With sustained level-appropriate damage,
observe Mana Shield below 45 percent, Ice Block below 25 percent, and Frost
Ice Barrier below 65 percent or when the current enemy attacks the Mage. Check
native absorbs/mana spending, no active-shield clipping, Hypothermia preventing
repeat blocks, and follow/combat recovery after natural Ice Block expiry.
Reactive glyph/talent effects remain native. Do not force proc auras or claim
accepted cast logs prove protection. No separate per-spell test session is needed.

## Next Frost qualification, bundled with class checks

Use a natively learned/talented Frost Mage, not the previous unassigned level-20
fixture. Observe Brain Freeze -> Frostfire Bolt, Deep Freeze on a frozen target
or affecting Fingers of Frost proc, and Ice Lance fallback when Deep Freeze
cannot cast. Confirm native proc consumption and, separately, immune-creature
Deep Freeze damage if a suitable sustained target is available. Policy tests
and accepted requests do not establish these effects. No extra per-spell
client session is required; retain the level-appropriate sturdy-mob requirement.

## Latest bundled outdoor check — 2026-10-01

The current realm records accepted Mage Fireball/Fire Blast/Molten Armor,
Priest Smite/Renew/Heal, Warrior Strike and native corpse opening by all four
bots. Accepted casts do not prove every effect landed; opening does not prove
item awards. No eating/drinking start has been recorded at the checked snapshot.
The final harness summary recorded 45 accepted Mage combat casts and 11 Priest
healing casts. Logout, all four bot stops and server/database shutdown completed
cleanly; the test ports are closed. Full fixture/feature qualification remains
partial, especially eating/drinking, item awards and role-specific target/threat behavior.
Ignored evidence: `build/playerbot-smoke-20261001-210142`.

Repeated 35-yard leash disengages occurred. The player initially saw no disruptive
caster behavior, then reported Warriors not engaging a later pull. Logs showed
Warrior engagement/Strike before leash disengagement; saved talent trees were
unassigned. The Protection-only fallback left ordinary Warriors dependent on
player selection. A source correction now routes all enabled Warriors through
tank or general DPS fallback; Windows/Linux each passed all 171 tests, but the
completed live session did not include this correction.
Do not claim this resolves the separate distance cause.

Next fixture preparation must select a native-verified outdoor area with enemies
near the party's level and enough health for sustained combat, then place the
human and bots there before handoff. Do not use starter-zone enemies or make the
player search for suitable mobs. Confirm levels, carried consumables, learned
spells and actual spec assignment; do not equate level normalization or learned
Defensive Stance with a Protection role. Qualification remains bundled.

## Outdoor loot check — 2026-10-01

The copied realm's four bots joined the player outdoors. Logs recorded 17
accepted Mage offensive casts and native corpse opening by each bot. Bots
returned to follow after kills. Logout, bot save/stop and server shutdown
completed cleanly. Evidence is retained locally in
`build/playerbot-smoke-20261001-124002` (ignored, not distributed).

This establishes operational corpse opening, not successful item awards,
money sharing or group-roll resolution. No accepted Priest healing casts were
recorded. Food/water was not provisioned and the level-20 Mage had no armor
spell, so recovery and armor were not tested. The reused Warriors were level
one; the harness now uses native `character level <name> 20` while offline in
the copied fixture. This follow-up harness change has not been runtime-tested.

For the next bundled check, add `-RecoveryLoot` to the interactive mixed-party
invocation below. A verified complete stopped roster seed may instead use
`-ReuseFullPartyFixture` without `-ClassDumpDirectory`. This scenario enables
the new recovery/armor/loot flags in the copy and does not require dungeon entry.
It does not automatically provision inventory or armor spells.

Before pulling, select each bot and use these native GM commands to put simple
consumables directly into its carried inventory:

```text
.additem 117 5
.additem 159 5
```

Select Botmage and use `.learn 30482` to exercise Molten Armor in this disposable
fixture. Cata normally teaches it at level 34; this explicit test grant bypasses
normal progression and is not a production spell-learning policy. With no
assigned spec, the strategy should choose learned Molten Armor out of combat.
An armor appearance alone does not qualify spec switching or replacement.

Make several manageable pulls, then pause close to the bots and an unlooted
corpse. Recovery starts below 40% health or 20% mana; the low-level food/water
may take time. Native healing or regeneration can prevent those thresholds
from being reached. Look for actual eating/drinking and follow resumption,
not merely a quiet interval. For loot, corroborate opening with inventory or
money changes; group-roll handling needs a roll-eligible drop. Keep these
checks bundled; no forced wipe, full dungeon clear or separate armor session
is required.

The subsequent movement slice also needs a short detour check: defeat a target
within 15 yards of a bot and 20 yards of the player, pause, and observe approach,
opening and return to formation. During another approach, use a normal movement
command or engage a hostile target to check that looting yields. A failed path
should give up after ten seconds rather than leave the bot detached indefinitely.
These movement outcomes have not yet been observed in game.

When a caster mob is convenient, observe the new current-target interrupts in
the same session. Counterspell requires learned spell 2139 (normally level 9);
Pummel requires 6552 (normally level 38), so the level-20 Warriors should skip
it unless explicitly prepared for that case. A native accepted-cast log is not
proof the enemy cast was interrupted. Mage does not cancel its own current
cast to kick; coordinated timing is outside this check.

The subsequent single-target batch can be observed without a separate session:
Warriors with learned Heroic Strike (78, normally level 14) should spend rage
only at their donor medium/high reserve. A Frost-specialized Mage with learned
Ice Lance (30455, normally level 28) should prioritize it for native frozen/proc
states. The current level-20 Mage fixture and generic route do not qualify this
Frost check. Do not treat absence of an unlearned spell or absent spec/proc as a
failure; leave it for a suitable fixture. Actual rage spending, proc consumption
and damage remain unverified by the pure policy tests.

For Priest disease cure, use a suitable fixture with learned Cure Disease
(528, normally level 22) and an actually dispellable disease. The present
level-20 Priest is not sufficient without explicit disposable preparation.
Observe aura removal, not only accepted casting. Native immunity/resistance
and Unholy Blight protection remain native; magic dispels are not in this slice.

The Priest now has a bounded Smite assist route under EnginePriestHeal. With
learned Smite (585, normally level 1), eligible nearby party members at >=90%
health and mana >=85%, it should cast against the controller's combat target.
It pauses follow for stationary support, not melee/chase. During the same pulls,
observe healing demand taking priority, `stop` preventing new damage, `follow`
reenabling assist and formation resuming after combat. An already accepted Smite
is not cancelled by this slice. Verify actual damage/healing and movement, not
only accepted-cast logs; no separate session is required. The follow-up adds
Shadow Word: Pain (589, level 4), Holy Fire (14914, level 18) and Mind Blast
(8092, level 9) in donor order. Check that learned DoTs appear and are not
continually reapplied by the same Priest while their aura remains. Mind Blast
is below Smite in this healer strategy and may not be chosen when Smite succeeds;
this is not the Shadow rotation. Shadow Word: Pain now also requires the donor
model to predict at least eight seconds of target life. Use a sturdy target to
observe the DoT; a short-lived target can fall through to direct spells. The
group DPS model excludes the human and is not measured damage. Profiles above
level 80 are unavailable, so this DoT is skipped there until a Cata profile is
ported. Accuracy calibration is not an acceptance requirement for this subset.

The threat guard can be observed in the same session if a native active
Protection Warrior is actually in the group. An unassigned Warrior or learned
Defensive Stance alone does not qualify. Scheduled Mage/Priest single-target
damage should yield at 80% of that tank's threat and resume below it, without
blocking healing, buffs or interrupts. Without a recognized tank it deliberately
does not throttle. Do not infer full tanking/AoE behavior from this check;
Warrior auto-attacks and direct action execution are not guarded. Native threat
behavior has not yet been observed in game; no separate micro-test is required.

The balance follow-up changes Priest damage's mana reserve from a fixed 85%
to donor 85/65/40 thresholds based on living party levels versus engaged native
PvE enemy levels/ranks. Healing demand still blocks damage below the existing
90% party-health cutoff. Observe this during normal multi-enemy pulls, with
healing taking priority and stop/follow unchanged. No new target-selection
behavior is expected. This heuristic and native attacker traversal remain
gameplay-unverified; do not treat them as a dungeon-difficulty prediction.

The target fallback can be checked during those same pulls: after a kill or a
cleared selection, idle Mage/Priest may assist another creature already fighting
the controller within the existing range/LOS limits. A valid selected combat
target still wins. For fallback only, an eligible skull takes priority and moon/
configured CC icon targets are excluded. Marking an unengaged enemy must not
start a pull. Active fights are not switched and explicit attack requests remain
the existing selected-target path. Stop/hold must still prevent auto-assist.
These native outcomes remain unverified; pure ranking tests are not proof of them.

Fallback now also includes an actually Protection-specialized Warrior under
EngineWarriorCombat, reading `tank target`. Observe acquisition of another
already-controller-engaged enemy after a kill/cleared selection. No active
switching or automatic taunt is expected. Unassigned/non-Protection Warriors
retain the old path. Native tank selection remains unverified.

## Earlier mixed-party release check — 2026-09-29

Four bots accepted the development human's invitations and entered Ragefire
Chasm. The Warrior, Mage and Priest engine routes were enabled. Logs recorded
13 accepted Mage offensive casts, six Priest healing casts and one Fortitude
cast. The player reported good overall behavior and basic whisper/movement
controls. Logout completed and all test-owned services stopped cleanly.

This confirms the Mage opener correction and an operational mixed party.
The human account had GM privileges, so ordinary-player authorization boundaries
remain source-reviewed rather than independently exercised by this session.
No full dungeon clear, tank-threat qualification, complete rotation, resurrection
or removal/re-invite claim follows from this run.

One `attack` after `stop` was rejected with Botmage selected rather than a hostile
unit. A later explicit Earthborer attack and casts were logged. Keep the command
target-selection ambiguity with future control/addon work; it is not a reason
to block the manager and roster port or schedule a separate playtest.

## Reproduction inputs and procedure

Use a cleanly stopped disposable seed with `test-db-credentials.json` and the
human/Warrior fixture. If it lacks Mage/Priest source characters, supply a
separate stopped `build/playerbot-smoke-*` directory containing nonempty
`mage-template.dump` and `priest-template.dump`. This is a read-only source of
class dumps, not another database seed. The harness prepares a new copied realm.

From PowerShell in the core root, substituting your own prepared input paths:

```powershell
./contrib/local/playerbot-lifecycle-smoke.ps1 `
  -Seed '<stopped disposable fixture directory>' `
  -ClassDumpDirectory '<class-dump directory under build>' `
  -MySqlHome '<MySQL installation directory>' `
  -ModuleConfig -CheckFullParty -MixedParty -Interactive `
  -EngineWarriorCombat -EngineMageCombat -EnginePriestHeal
```

The harness prints its new ignored output directory and announces readiness.
Log into the human fixture, invite Testone, Testtwo, Botmage and Botpriest,
whisper `list`, `stay` and `follow`, then enter Ragefire through its portal.
Make a normal pull; select a hostile unit before whispering `attack`, then try
`stop`. Log out to finish. Human steps have no deadline in interactive mode;
a `stop.request` file in the printed directory ends the wait and shuts down
test-owned services. The installed server and client configuration are not
changed by this harness.

Accepted-cast logs confirm that native casting accepted an attempt; they do
not prove every spell landed or that a role was played well. Combine the logs
with the player's observation.

The actual run's ignored evidence is
`build/playerbot-smoke-20260929-111951`. Its input fixture combination was
validated by this run. Databases, credentials, dumps and logs are local evidence
and are not distributed with the repository. The legacy filename of this report
is retained so existing links continue to work.
