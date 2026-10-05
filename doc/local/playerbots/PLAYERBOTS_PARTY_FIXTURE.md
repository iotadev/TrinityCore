# Repeatable level-20 party fixture

This is the shared-state operational fixture, not a high-level spell/proc suite.
Run only against a copied, cleanly stopped disposable DB. Never modify a live
installation or the source seed. Preserve a stopped, provisioned baseline for
subsequent runs; use the harness's verified roster replay instead of rebuilding
characters for every spell.

## Next replay: short version

The combined recipe uses `-RecoveryLoot -DungeonFixture`. Recovery alone stays
outdoors; dungeon mode waits for the human party's Ragefire bind, sends console
`joininstance` for all four bots and verifies completion in that instance.
Ordinary cross-map `.summon` lacks the bot transfer acknowledgement path.
The corrected branch passed parser/mock checks and the October 5 native replay.
All four entered the party's instance; normal trash combat worked and the realm
shut down cleanly. Longer support/recovery and optional strategy timing remain open.

The outdoor engagement and group loot-removal queries already ran. Do not repeat
them as isolated prerequisites. Continue with one human-led Ragefire session:

1. Join the party before entering; use dedicated console dungeon entry and
   verify all four bots actually arrive
   in the leader's instance. Request acceptance alone is not arrival evidence.
2. While safely idle, use one MultiBot group loot change, refresh STATE, then
   restore loot and refresh again. Observe completion rather than only clicking
   the control. Timeout means unknown: refresh before retrying.
3. Lead sustained trash pulls and a suitable boss, watching tank engagement,
   visible healing, post-fight recovery/loot and one ordinary stop/follow cycle.
4. Record natural deaths/regrouping if they occur; no forced wipe is required.
   If the party behaves well, continue toward a clear. End with clean logout and
   disposable-service shutdown.

The detailed optional checks below are references, not a requirement to test
every feature in this session. Missing prerequisites or no useful encounter
means deferred observation. The [candidate review](PLAYERBOTS_CANDIDATE_REVIEW.md)
records the source boundaries already checked offline.

## Party and preparation

| Character | Role | Native specialization | Equipment baseline |
| --- | --- | --- | --- |
| Test | Human leader, level 20 | Any suitable class | Normal level-appropriate gear |
| Testone | Tank, level 20 | Warrior Protection | One-handed sword and shield, mail |
| Testtwo | Damage, level 20 | Warrior Arms | Two-handed sword, mail |
| Botmage | Damage, level 20 | Mage Frost | Staff and cloth |
| Botpriest | Support, level 20 | Priest Holy | Staff and cloth |

The default-off `Playerbots.Dev.Fixture20.Enabled` tool prepares these roles
through native specialization selection and LearnTalent, spending only available
points in deterministic tier/column order. It grants the listed starter skills
and equipment through native learned-spell/inventory methods. This is explicit
disposable test preparation, not a production progression or equipment factory.

Invoke `server playerbotdev slot <1-4> fixture20` only after the configured slot
is ready. The console reports request acceptance; map-thread PB-FIXTURE completion
reports prepared/incomplete. Require alive, idle, ungrouped level-20 bots and
either no tree or the expected existing tree. The four-entry mailbox expires
after five seconds and is cleared when disabled. No Player pointers or live DB
talent/inventory edits cross the thread boundary. Existing gear is stored, never
destroyed; insufficient bag space/invalid equipment produce incomplete status.

These modest equipment/item records were verified against the extracted native
Cata Item-sparse.db2 and core DB2 loader/format on 2026-10-02:

| Item ID | Item | Required level | Use |
| --- | --- | --- | --- |
| 4765 | Enamelled Broadsword | 9 | Protection main hand |
| 1202 | Wall Shield | 12 | Protection off hand |
| 4817 | Blessed Claymore | 17 | Arms two-handed weapon |
| 2866 | Rough Bronze Cuirass | 18 | Warrior chest |
| 2867 | Rough Bronze Bracers | 18 | Warrior wrists |
| 3472 | Runed Copper Gauntlets | 7 | Warrior hands |
| 1405 | Foamspittle Staff | 12 | Mage/Priest weapon |
| 2585 | Gray Woolen Robe | 16 | Mage/Priest chest |
| 3770 | Mutton Chop | 15 | Carried food, 20 per bot |
| 1205 | Melon Juice | 15 | Carried drink, 20 per caster |

The preparation tool equips these exact records and tops up carried items.
For manual repair use native GM `.additem <ID> <count>` with the right selected
character and native inventory handling. Verify weapon/class eligibility, shield
slot, learned role ability, carried counts and available bag space. No GM damage
or invulnerability on bots during the actual check. Restore `.gm off` on the
human before pulls. Potion 1710 was excluded because it requires level 21.

Mage armor is deliberately deferred: the native Cata records are Molten Armor
30482 at level 34, Frost Armor 7302 at level 54 and Mage Armor 6117 at level 68.
The old 168 record is absent. Do not grant these higher-level spells to turn this
state/role fixture into an artificial armor test.

## Fixed enemies and placement

The copied Cata world DB contains these level-21 enemies with HealthModifier 4:

| Entry | Enemy | Map | Verified spawn coordinates |
| --- | --- | --- | --- |
| 16245 | Luzran | 530 | 6615.78, -6438.40, 29.2661 |
| 16246 | Knucklerot | 530 | 7199.49, -6622.57, 63.6583 |

Use the Luzran location as the first durable pull and Knucklerot only if needed.
For the outdoor fixture, place the human with native `.go creature id 16245`
in GM mode, move to safe ground, and use `.summon <name>` only when the bots are
already on the same map. Invite them and restore ordinary combat mode.
Cross-map summons lack the required bot transfer support. Keep everyone within the
existing 35-yard leash; do not send the player searching for starter-zone mobs.
The DB establishes level/durability/location, not a tested safe pull path. Observe
the native terrain and enemy behavior before declaring the fixture ready.

## Replay

The newer shared-role layer uses configured combat roles for bots and native
spec/form roles for ordinary players. Include support ordering and tank rescue
observations in this same replay, not a separate role-only suite. Recognizing a
human tank/healer spec does not add that class as an admitted bot or prove its
rotation. Record unexercised role/spec changes as pending.

For server-only preparation, use `-CheckFullParty -ReuseFullPartyFixture
-MixedParty -CheckRosterOnly -RoleFixture -ModuleConfig` and the four Engine flags.
It prepares/saves each role and then stops the realm without needing a client.
The bots/human are placed safely at native Tranquillien before the combat check.

For the outdoor recovery session, the harness accepts a verified stopped roster with
`-CheckFullParty -ReuseFullPartyFixture -MixedParty -Interactive -RecoveryLoot
-ModuleConfig -EngineWarriorBuff -EngineWarriorCombat -EngineMageCombat
-EnginePriestHeal -RoleFixture`, plus explicit Seed, MySqlHome, BuildDirectory and DataDirectory.
Add `-StrategyFixture` for this milestone's group toggle/restore check. It enables
the MultiBot bridge, base strategy, addon mutation and group mutation gates in
the disposable copy.
For the bundled Ragefire continuation, also add `-DungeonFixture`. After all
four join the party, enter through the portal; the harness handles bot entry.
Both recovery and strategy settings remain enabled for the dungeon session.
All paths are caller-supplied. It normalizes only fixture-owned offline groups,
starts copied services and saves/stops them on completion. Its level-20 reset
alone does not train/equip; the explicit RoleFixture tool handles those steps.
Neither mode establishes gameplay acceptance.

For client-free same-map teleport verification, add `-CheckNearTeleport` to the
roster-only role-fixture run. Each online bot must acknowledge native teleports
to Silvermoon and back to Tranquillien, then save the expected landing position
on logout. This tests native near-teleport completion, not the in-game `.summon`
command, automatic following after summon, or combat acceptance.

The 2026-10-02 headless replay at `build/playerbot-smoke-20261002-192342`
passed eight native acknowledgments using the DB's `SilvermoonCity` destination,
saved all four return positions, and shut down cleanly. It preserves the role
fixture for later client replay. Keep in-game summon/follow and combat outcomes
separate from this result.

After one-time native preparation and clean shutdown, retain that stopped copy
as the new seed. Re-check roster, talents, equipment, consumables, location and
health on replay. Use [state acceptance](PLAYERBOTS_STATE_MILESTONE.md) for the
single integrated check. Full dungeon and advanced spells use later fixtures.

## Accumulated role-coordination checks

Cover these in the same party session, not a separate test per spell:

- Sustain one pull long enough to see healing and tank target choice. If a
  second already-engaged enemy turns on a non-tank, observe whether the
  Protection Warrior rescues that member. Do not add an autonomous new pull.
- Keep an injured member near the human while the Priest is just outside
  healing range (30–40 yards away). Observe native gap-closing, stopping in
  range and healing. Do not move the human outside the 35-yard bot leash.
- Issue stay/stop during the gap closure, then follow again. Confirm that owned
  reach movement ends and normal control resumes. Also observe target death
  or departure if it occurs naturally; do not create extra destructive tests.
- Observe ordinary caster trailing spacing and post-fight recovery/loot.
- Bundle the new chat controls into the same replay: whisper the Mage `range ?`,
  then `range spell 23`, and later `range spell 0`. Distinguish the initial queued
  acknowledgment from the effective-range response. During a durable pull,
  observe chase distance refresh without interrupting a cast or changing targets.
  Party/raid routing keeps the existing authorization/subgroup boundaries; no
  addon button is required. Restore defaults before evaluating other behavior.
- If a party member dies naturally, leave an unreleased corpse near the living
  leader. After nearby combat ends and living patients are healed, observe the
  Priest approach and native Resurrection cast. Use the existing 35-yard leader
  leash and a corpse within 20 yards of that leader; no deliberate wipe is needed.
  A submitted reach request is not evidence of arrival or resurrection acceptance.
  If multiple members happen to die, record selection order and whether an
  out-of-envelope corpse blocks another eligible corpse. Expected priority is
  controller, healers, tanks, then others, with local-subgroup preference and
  stable roster ties. Do not force a wipe just to exercise this case. Released
  ghosts and approaching a dead controller remain outside this port.
- Observe party buffs across the existing roster. If dispellable disease/curse
  effects occur naturally, observe the Priest/Mage cure without assuming low
  health is required. Self-cure has its existing higher-priority action; party
  candidates use role/subgroup order. Do not extend this check into a separate
  forced-aura suite; absent relevant effects, record cure runtime coverage as pending.
  Normal missing-aura selection treats either native buff variant as coverage;
  it does not proactively refresh an existing aura's duration. Under sustained
  mixed injury, record the Priest's selected patient and distances: named healing
  uses the health/distance probe, not lowest health alone. Actions still have
  spell-specific eligibility and native cast fallback. No separate value-only
  client test is required.
  Bundle one ordinary `buff` whisper to the Mage/Priest while idle. Separate the
  initial requested reply from map-thread pass started. Observe missing/aged
  supported buffs and absence of repeated top-offs; log pass end means no current
  eligible work, not ready-check acceptance. No forced duration or separate suite
  is required. If the separate default-off `Playerbots.ReadyCheck.Enabled` flag
  is enabled for the same replay, run one native `/readycheck` while idle. Treat
  confirmations as HP/MP/proximity/state plus carried-supply readiness, not complete
  buff/encounter coverage. The fixture supplies food/drink but not guaranteed usable
  healing/mana potions: expect not-ready unless level-appropriate items are present.
  Do not add an isolated ready-check suite; replacement/finish timing remains
  pending unless naturally exercised. With optional `Playerbots.ReadyCheck.ForceRebuff`
  enabled, Mage/Priest confirmation waits for the supported pass and then reevaluates
  readiness; otherwise a pending manual pass answers not-ready.
- If a control effect occurs naturally on an offensive target, observe whether
  bots cease autoattack/chase rather than select it again while protected.
  Polymorph, charm, fear and isolation are excluded; roots/stuns are not blanket
  exclusions. In-flight spells and existing damage-over-time effects are not
  canceled by this port. Without a suitable control effect, record this as pending.
- When nearby party combat occurs without leader engagement, confirm that rest
  and corpse-loot work yield, then become eligible again after combat ends.
  Record actual aura/path/mailbox behavior; policy tests alone do not prove it.
  Duplicate-heal coordination needs another actual direct-heal caster; the
  single-Priest roster alone cannot establish that runtime result.

Record sustained operational behavior and failures together. Moving-target
tracking and obstacle pathing are not established by the snapshot reach adapter.

## Human-led dungeon follow-on

Reuse the stopped level-20 role fixture; do not create a second roster. Ragefire
Chasm (map 389) is the first candidate because earlier project history recorded
four-bot entry and combat there. Those old runs do not accept the current role
changes or establish dungeon completion. This is a prepared procedure, not a
newly inspected live dungeon or a guarantee that every enemy is durable enough.

1. Continue directly from the accepted outdoor check. Preserve the current realm on a failure
   long enough to collect evidence, then shut down cleanly; do not silently
   reset characters or respawn enemies to make a failure disappear.
2. Keep the human as party leader. Use `.tele RagefireChasm`, then enter through
   the actual portal so the core establishes the party's instance bind. Restore
   ordinary combat mode; invulnerability/GM behavior can invalidate observations.
3. From the server console, request `server playerbotdev slot <1-4> joininstance
   389` for each configured bot after the native bind exists. Require completion
   logs showing the same map and instance as the human, not just request
   acceptance. Do not hard-code an instance number from an old run.
4. Human leads the normal route, chooses pulls and remains within the companion
   leash. Observe the whole party through sustained trash combat, post-fight
   recovery/loot and the first suitable boss. If enemies die too quickly, record
   fixture inadequacy rather than calling healing/tanking proven or granting
   high-level spells to compensate.
5. Continue toward a human-led clear if behavior permits. An ordinary wipe is
   useful recovery evidence, not by itself a server defect. Use native corpse/
   resurrection behavior; do not edit live death state or deliberately add a
   crash/mass-death scenario for every small change.

Collect one outcome summary: target agreement/rescue, visible heal effects,
party defense when the leader is not personally engaged,
movement/stop recovery, consumable/loot behavior, death/regrouping if observed,
and assertion/disconnect evidence. Turn failures into one corrective batch.
Optional ground-mount check: enable `Playerbots.Mount.Ground.Enabled` only in
the disposable config and use bots already trained in riding with learned
ordinary ground mounts. The existing level-20 fixture does not grant these.
Outdoors, mount/dismount the controller and observe cast completion/follow;
include a normal stop/follow or combat interruption. Verify no repeated idle
cast loop. Flight, travel forms and dungeon mounting are outside this slice.
If prerequisites are absent, record this check as deferred rather than granting
them through the runtime port or claiming acceptance from the policy tests.

Optional saved-position stay: enable `Playerbots.Movement.Stay.Enabled` only in
the disposable config. While following and safely idle, request `stay` and require
the map confirmation, then move the leader and check that bots do not follow.
Request `follow` to restore ordinary movement; `hold` should remain plain stop.
If a natural knockback/displacement occurs, observe bounded native return after
combat; do not create a separate forced physics test for this source slice.
Native teleport invalidates stay rather than serving as a displacement test.
An expired/busy/rejected request is not a confirmed mode change. Combat stay and
ghost movement remain out of scope; include any observed controller/transfer
invalidation in the same bundled replay.

Optional strategy controls can join the same replay: enable only the disposable
`Playerbots.StrategyControl.Enabled` setting, attach an idle bot and whisper
`nc ?`, `nc -food,-loot,?`, then `nc +food,+loot,?`. Require map-thread final
responses and confirm removal is not immediately undone by the next query.
`co ?` and `de ?` query only; `nc +stay` and `co -tank` must be rejected.
These are registration checks, not proof of consumption, loot awards or role
changes. Restore food/loot before continuing the integrated party check.
The same optional gate advertises read-only MultiBot `STATE_FRAMING_V1`.
Refresh the bot roster and check food/loot state matches an ordinary `nc ?` query;
include one refresh after a change. A stale/oversized snapshot abort
is not a successful UI refresh. Client consumption remains pending until observed.
Optionally also enable `Playerbots.StrategyControl.AddonMutations` in the same
disposable config. Use an individual bot's food/loot toggle, not a group-wide
button, and require its structured completion result plus a matching state refresh.
Group requests reject while the separate GroupMutations gate is disabled;
role/unsupported-strategy requests always reject. Restore both strategies.
With `-StrategyFixture`, while idle, use one group food/loot
toggle, require a single aggregate ACK plus refreshed STATE for each matched bot,
then restore it. ALL selects authorized controlled bots; GROUP/PARTY select the
current group including raids, and RAID requires a raid. Do not auto-retry a
timed-out toggle or infer rollback. No separate realm session is required.
While safely idle, use one Mage/Priest's ordinary `co -potions,?`, then
`co +potions,?` to restore its default. Optionally use its individual MultiBot
combat potion toggle and require a C-state completion ACK and matching refresh.
Threat can be toggled/restored in the same way; class/spec/cure controls reject.
Optional `co +focus,?` and `co -focus,?` should register/remove focus while idle;
leave it removed for the normal replay. If existing Frost Nova naturally triggers,
observe that optional focus suppresses it while ordinary single-target/support
actions remain available. Its hostile-area metadata also enables donor threat
throttling. No new AoE spell or pull-safety behavior should be inferred. If the
encounter lacks a useful observation, leave the gameplay check deferred.
These changes cannot enable globally disabled recovery or grant consumables.
Do not leave the utility disabled for the party replay. Gate-disable default
restoration can wait for the normal session shutdown/reconfiguration, not a
separate forced restart test.
Timeout means unknown outcome: refresh before retrying a toggle; do not infer
that it was rolled back. This is part of the existing replay, not a separate test.

Optional combat recovery can join this same replay: enable
`Playerbots.Potions.Enabled` only in the disposable config, with usable carried
healing potions and mana potions for mana users. Under natural sustained combat,
observe potion consumption and actual health/mana restoration below the donor
25%/40% thresholds. `PB-POTION` reports submission only. Observe no repeated use
during native last-potion lockout and normal cooldown behavior after combat;
missing stock or enemies dying too fast means this observation remains deferred.
If a native Healthstone is already carried, observe its preference over a healing
potion and ordinary native cooldown handling. No stone creation/distribution is
implemented, and readiness still requires explicit potion stock rather than
counting stones or unsupported flasks. Do not grant stock through the runtime
port, force resource values or add a separate test just for this source slice.
Flasks/channeled potions are outside this port; food/drink recovery retains its
separate gate.

Secondary interrupt coverage can join the same replay if a durable engaged
secondary enemy casts a positive interruptible spell. Watch for learned Pummel/
Counterspell interrupting it while the bot keeps its primary attack target;
do not expect movement/chase toward an out-of-range caster or own-cast cancellation.
The donor "enemy healer" label also includes positive buffs. Native cast-start
logs are not landed-interrupt proof. If the encounter lacks such a caster, leave
this observation deferred rather than rebuilding the fixture for one feature.

Autonomous routing, automatic group formation and full class parity are not
acceptance gates for this human-led milestone. Stop all disposable services when
the session ends. No runtime was started to prepare this checklist.
