# MultiBot integration map

Updated 2026-10-11. This relates the pinned addon candidate to current server
behavior. The module's addons/MultiBot/README.md owns preparation and client evidence.

| Feature family | Current server support | Remaining dependency |
| --- | --- | --- |
| HELLO/PING, roster, connect/disconnect | Authorized lifecycle bridge; client roster/reconnect observed | Autonomous population remains separate |
| Follow, Stay, main Attack | Ordinary commands and `do attack my target`; client observed | Role-filtered attacks and full strategy set |
| Strategies | STATE queries and bounded ACK mutations, optional group gates | Bundled client ACK/STATE/restore timing; protected role/spec strategies |
| Inventory | `gear?`, one-slot `gear apply`, guarded native loot votes | Addon inventory/equip protocol; broader scoring and item classification |
| Quests | Native shares, ordinary accept/inspect/reward commands and batches | Addon quest data/UI protocol, discovery/travel and automatic chains |
| Maintenance | New ordinary `repair` at selected NPC, default off | Client qualification; safe sell classification and purchase budget/stock; addon maintenance protocol |
| Class/spec/talents | Warrior/Mage/Priest starter native behavior | Cata adaptation of donor UI data and broader talent/rotation controls |
| Travel, autonomous groups, professions | Future tracks | Travel/RPG/population/economy dependencies and Cata adapters |

Use this map to prioritize connected server ports. Ordinary chat support does
not imply matching LANG_ADDON replies. Before connecting a UI feature, trace its
actual request/reply shape and advertise only implemented capabilities. Keep
client observations separate from mock protocol tests; timeouts are unknown outcomes.
