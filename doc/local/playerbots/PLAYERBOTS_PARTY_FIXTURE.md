# Repeatable level-20 party fixture

This is the shared-state operational fixture, not a high-level spell/proc suite.
Run only against a copied, cleanly stopped disposable DB. Never modify a live
installation or the source seed. Preserve a stopped, provisioned baseline for
subsequent runs; use the harness's verified roster replay instead of rebuilding
characters for every spell.

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
Place the human with native `.go creature id 16245` in GM mode, move to a safe
nearby patch of ground, summon the four bots using native `.summon <name>`, invite
them and restore ordinary combat mode. Keep everyone together and within the
existing 35-yard leash; do not send the player searching for starter-zone mobs.
The DB establishes level/durability/location, not a tested safe pull path. Observe
the native terrain and enemy behavior before declaring the fixture ready.

## Replay

For server-only preparation, use `-CheckFullParty -ReuseFullPartyFixture
-MixedParty -CheckRosterOnly -RoleFixture -ModuleConfig` and the four Engine flags.
It prepares/saves each role and then stops the realm without needing a client.
The bots/human are placed safely at native Tranquillien before the combat check.

For the integrated session, the harness accepts a verified stopped roster with
`-CheckFullParty -ReuseFullPartyFixture -MixedParty -Interactive -RecoveryLoot
-ModuleConfig -EngineWarriorBuff -EngineWarriorCombat -EngineMageCombat
-EnginePriestHeal -RoleFixture`, plus explicit Seed, MySqlHome, BuildDirectory and DataDirectory.
All paths are caller-supplied. It normalizes only fixture-owned offline groups,
starts copied services and saves/stops them on completion. Its level-20 reset
alone does not train/equip; the explicit RoleFixture tool handles those steps.
Neither mode establishes gameplay acceptance.

After one-time native preparation and clean shutdown, retain that stopped copy
as the new seed. Re-check roster, talents, equipment, consumables, location and
health on replay. Use [state acceptance](PLAYERBOTS_STATE_MILESTONE.md) for the
single integrated check. Full dungeon and advanced spells use later fixtures.
