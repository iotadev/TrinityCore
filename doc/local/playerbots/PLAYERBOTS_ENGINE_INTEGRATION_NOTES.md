# Engine integration: lead-verified starting points

Date: 2026-09-26. Donor mod-playerbots
`8827dd6fcbb2bb25988787a40f06fc93daf8e02d`. These are inspected source facts,
not a dependency-complete port or runtime implementation.

## Boundaries that must survive the port

| Inspected donor source | Consequence for the Cata port |
|---|---|
| `src/Bot/PlayerbotAI.cpp:136-164`, `PlayerbotAI(Player*)` | One per-bot AI owns an AiFactory-created context and three state engines. Do not introduce an independent custom rotation scheduler next to it. |
| `src/Bot/PlayerbotAI.cpp:1491`, `DoNextAction` | Preserve the combat/noncombat/dead state decision owner. The behavior bridge must not keep making competing combat decisions after activation. |
| `src/Bot/Engine/Engine.cpp:17`, `Engine(PlayerbotAI*, AiObjectContext*)` | Engine is invoked by the per-bot runtime, not a timer-driven singleton with an `Update` entry point. |
| `src/Bot/Engine/AiObjectContext.cpp`, constructor and `BuildAllSharedContexts` | Constructor accepts shared context lists; explicit builders populate registrations. Full builders reference all class/content systems. Reduced registration is required for a staged dependency closure. |
| `src/Script/Playerbots.cpp:240`, `OnPlayerAfterUpdate` | Map-context AI tick. Keep world-owned admission, asynchronous loading and teardown separate from gameplay. |
| `src/Script/Playerbots.cpp:404,516,519` | Owner incoming events, bot outgoing events and owner outgoing events all have donor routes. Ignoring outbound packets permanently would lose event semantics. |
| `src/Bot/PlayerbotAI.cpp:1126,1431,1436` | Actual event entry points are `HandleBotOutgoingPacket`, `HandleMasterIncomingPacket` and `HandleMasterOutgoingPacket`. Cata packet layouts require adaptation. |

The current Cata seam is `PlayerbotSessionHooks`: WorldSession owns its instance,
commands post requests, and map/world passes consume them. `SendPacket` still
drops server-origin delivery. Establish typed, queued Cata event semantics or
validated packet adapters before treating donor packet-driven behavior as ported.
Do not invoke gameplay synchronously from an arbitrary packet send context.

`src/Bot/Engine/AiObject.cpp` captures the bot Player, context and ChatHelper
from its PlayerbotAI at construction. Unlike the present Cata session behavior
(which resolves Player on each update), these objects must be created only after
the canonical Player load completes and destroyed before Player removal. Do not
construct the imported context in the pre-login WorldSession constructor or keep
it across a logout/relogin merely because the session-owned wrapper survives.

## Real downstream consumers

The supplied `mod-multibot-bridge/src/MultiBotBridge.cpp` calls
`sPlayerbotsMgr.GetPlayerbotAI(bot)`, `GetAiObjectContext()` and typed
`GetValue<GuidVector>` for query results; it also queries
`GetValue<Item*>("item for spell", spellId)`. Returning an opaque custom
companion object does not supply these contracts.

`mod-dungeon-clear/src/DcStrategyGate.cpp` consumes `GetAiObjectContext`,
`HasStrategy` and `ChangeStrategy` with explicit combat/noncombat states.
Its `src/TestRun/DcTestRunJob.cpp` additionally changes masters and uses
`sRandomPlayerbotMgr` for managed admission/logout. Its automation therefore
requires more than the initial companion engine slice. Do not claim those modules
are compatible merely because the directories can now be built optionally.

## Rejected dependency-map proposals

Two generated dependency-map drafts failed source review. They invented constructor
and timer signatures, contradicted map-thread execution, and omitted downstream
consumer contracts. A proposed `WorldSessionOrigin::Client` identity for socketless
bots was specifically rejected: outgoing events need an adapter while server-origin
session semantics remain intact. Neither proposal was integrated.

Future dependency maps must cite actual file/symbol locations, include the full
required dependency set, and validate ownership and execution-context assumptions.

Still required: a real source-file dependency closure, reduced creator tables,
ownership/destruction review, event bridge contract and a compile-tested upstream
kernel slice. Do not begin a worker class port until those interfaces exist.

## Direct port progress and inspected next dependencies

`NamedObjectContext.{h,cpp}` is now imported from the pinned donor with a
small reviewed adaptation diff (documented in the module's PORTING.md).
Enabled worldserver/tests-common built and 41/41 tests passed, including seven
registry regressions. No live decision owner was switched.

The next layer is not just Engine.cpp. These inspected edges define its work:

| Donor component | Immediate dependencies or semantics requiring adaptation |
|---|---|
| `Engine/AiObject` | PlayerbotAI's GetBot/GetMaster/GetAiObjectContext/GetChatHelper; player-bound object lifetime |
| `Engine/WorldPacket/Event` | Native WorldPacket/ObjectGuid; donor retains raw event owner Player pointer, requiring lifetime-safe Cata event handling |
| `Engine/Value/Value` | AiObject, Unit, Timer, PerfMonitor; cached calculation intervals and manual values |
| `Engine/Action/Action` | Event/Value/AiObject; target value lookup, ActionNode prerequisites/alternatives/continuers, timestamped ActionBasket |
| `Engine/Trigger/Trigger` | Action/context/runtime; forceRebuff state is consulted by needCheck, not merely the clock |
| `Engine/Strategy/Strategy` | Trigger/Action/Multiplier/registries; default ActionNode factory registers fallback names that must resolve |
| `Script/WorldThr/Queue` | ActionBasket/ActionNode, native time, expireActionTime config; despite its directory, this is the relevance queue, not the world-thread operation processor |
| `Engine/Engine` | Above components, context, config, performance hooks, forceRebuff state, master/debug messages and per-bot runtime |
| `Engine/AiObjectContext` | Four typed per-bot registry lists; direct std string splitting and reduced shared/class creator tables |

Port the dependency-complete scheduling layer before importing class creators.
Do not call full BuildShared* registries and hope linker pruning removes travel,
content, DB and population systems: their creator lambdas establish dependencies.
Shared creator registration must finish before parallel map updates. This table
is an inspected immediate-dependency map, not a claim of transitive closure for
all behaviors or downstream modules.

Event/NextAction follow-up: imported from the same donor pin, with owner identity
stored as a GUID and native owner lookup isolated in EventOwner.cpp. Payload tests
use real Cata types without linking a fake AI/runtime; six new cases bring enabled
CTest coverage to 47/47. Enabled worldserver/tests-common builds pass. No live
event producer or decision owner is switched, and native owner logout behavior
remains lifecycle-test pending. The remaining dependency rows above still apply;
NextAction alone does not supply ActionNode, ActionBasket or the relevance queue.
