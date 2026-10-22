# MultiBot integration map

Updated 2026-10-13. This relates the pinned addon candidate to current server
behavior. The module's addons/MultiBot/README.md owns preparation and client evidence.

| Feature family | Current server support | Remaining dependency |
| --- | --- | --- |
| HELLO/PING, roster, connect/disconnect | Authorized lifecycle bridge; client roster/reconnect observed | Autonomous population remains separate |
| Follow, Stay, main Attack | Ordinary commands and `do attack my target`; client observed | Role-filtered attacks and full strategy set |
| Strategies | STATE queries and bounded ACK mutations, optional group gates | Bundled client ACK/STATE/restore timing; protected role/spec strategies |
| Inventory | `gear?`, one-change `gear apply` with build-qualified swap-scoped native bag replacement; human reported a manual swap working | Bot migration/identity/persistence; bank/nested/specialized containers; addon inventory/equip protocol; broader scoring/classification |
| Quests | Native shares, ordinary accept/inspect/reward commands and batches | Addon quest data/UI protocol, discovery/travel and automatic chains |
| Maintenance | Ordinary `repair`; local food/drink/potion/bandage `buy` and qualified-gray-junk `sell vendor` at selected NPC, independent default-off gates | Client qualification; automated bandage use, full selling retention and autonomous budgets/scheduling; addon maintenance protocol |
| Class/spec/talents | Warrior/Mage/Priest starter behavior; build-qualified Rogue/Hunter baselines and native existing-pet control; local native `trainer` inspection, `trainer learn` batch and `train <ID>` | Rogue/Hunter/pet client qualification; discovery/travel and Cata donor UI data; broader talent/rotation controls |
| Travel, autonomous groups, professions | Future tracks | Travel/RPG/population/economy dependencies and Cata adapters |

Use this map to prioritize connected server ports. Ordinary chat support does
not imply matching LANG_ADDON replies. Before connecting a UI feature, trace its
actual request/reply shape and advertise only implemented capabilities. Keep
client observations separate from mock protocol tests; timeouts are unknown outcomes.
