# Cata Playerbots lifecycle comparison

Date: 2026-09-21

Status: source comparison plus PB-00 implementation notes. The development
foundation is default-off and no Playerbots runtime is claimed working here.

## Inputs and scope

This compares the local Cataclysm 4.3.4 checkout at `efcf6ac83d` against the
public lifecycle audit in `firstuserlastname123/TrinityCore`, branch
`playerbots-434`, at `20cd12e4f7`. The local branch is five commits ahead of
its `origin/master` base, `9da95e6cc9`; those commits do not change the session,
login, player, map, world-loop, or shutdown files examined here.

The public comparison branch remains documentation-only. A 2026-09-21 check
also found no newer commit on `g0015590/TrinityCore_playerbots-cataclysm` than
`7037ad981b42`. This is not evidence that no private implementation exists; it
only describes the public sources checked.

Public references:

2026-09-27 read-only `git ls-remote` refresh: playerbots-434 still points to
`20cd12e4f7ced41fbf2a321a7e97ccc5b3e28ede`; playerbots-cataclysm still points to
`7037ad981b42e558b2928935f34ce4a428c11771`. Neither compared branch has advanced
from the snapshot above. This does not cover other branches or private work.

- <https://github.com/firstuserlastname123/TrinityCore/blob/playerbots-434/docs/playerbots-434-lifecycle-audit.md>
- <https://github.com/firstuserlastname123/TrinityCore/blob/playerbots-434/docs/playerbots-434-port-plan.md>
- <https://github.com/g0015590/TrinityCore_playerbots-cataclysm/tree/playerbots-cataclysm>

## Result

The audit applies to this checkout almost verbatim. Its preferred first proof
is also the least invasive local route: a real `WorldSession`, explicitly
marked as server-origin/socketless, owned by `World::m_sessions`, using the
normal asynchronous session and character-loading flows.

That recommendation is suitable for PB-00: one allowlisted Warrior on one
dedicated bot account. It is not yet a complete route to AzerothCore parity.
The local world session table is keyed by account ID, so it permits one active
session per account. Multiple same-account alts, or a human and bot from the
same account, would replace or reject one another. Before multi-bot parity, the
project must choose one-account-per-bot/linked bot accounts, a risky change to
session indexing, or a separately owned bot-session design.

## Audit claims checked against the local core

| Audit claim | Local evidence | Disposition |
| --- | --- | --- |
| A null socket is accepted at construction | `WorldSession.cpp:111-159` stores a realm socket only when supplied | Confirmed |
| A normal null-socket session cannot survive | `WorldSession.cpp:348-349` dereferences the realm socket in the idle path; `526-527` returns false in the unsafe update pass solely when the realm socket is absent | Confirmed; use an explicit bot-session identity, not a global null-socket exception |
| Outbound packets need an explicit policy | `WorldSession.cpp:260-263` safely drops packets without a destination, but logs each occurrence | Confirmed; safe from a null dereference, unsuitable as the final routing policy |
| The canonical character load should be reused | `CharacterHandler.cpp:733-779` performs ownership/duplicate checks and schedules `LoginQueryHolder`; `798+` enters `HandlePlayerLogin` and `Player::LoadFromDB` | Confirmed |
| The session itself also initializes asynchronously | `WorldSession.cpp:1230-1261` schedules account-data queries before the normal auth/setup response | Confirmed; PB-00 needs staged startup rather than immediate character login |
| The world should own the preferred session | `World.cpp:326-388` queues and inserts sessions; `3138-3166` updates and deletes them | Confirmed |
| Canonical logout should be retained | `WorldSession.cpp:534-680` completes teleports, saves, removes the player from the map, detaches it, and clears online state | Confirmed |
| `KickPlayer()` is not sufficient for a socketless bot | `WorldSession.cpp:696-705` only acts when a socket exists | Confirmed; bot teardown needs an explicit removal flag after canonical logout |
| Shutdown needs an earlier bot drain | `World.cpp:3058-3073` can set the stop event before `OnShutdownInitiate`; the update loop then exits. `Main.cpp:355-364` later calls `KickAll()` and only one session update | Confirmed; ordinary socket kick cannot drain a socketless bot |
| Commands that mutate a `Player` should execute in its map context | `Map.cpp:625-669` updates map sessions and players in the map update; `Map.cpp:758` invokes the map-script update hook | Confirmed; command receipt and command execution must be separated |

## Minimal lifecycle design implied by this checkout

PB-00 should be a narrow core integration with a small controller. The intended
state sequence is:

1. Validate the feature flag, one-bot limit, dedicated account, allowlisted
   character GUID, class, and duplicate-login conditions.
2. Construct a real `WorldSession` in explicit server-origin mode and submit it
   through `World::AddSession` so the world becomes its sole owner.
3. Wait for `InitializeSessionCallback` to complete account-data setup before
   scheduling the normal character-login query holder.
4. Let `HandlePlayerLogin` and `Player::LoadFromDB` perform normal validation,
   map insertion, object registration, and online-state updates.
5. Keep only explicitly identified bot sessions alive without a realm socket.
   Human sessions must retain existing disconnect behavior.
6. For stop, interrupted load, or rejection, cancel future bot work, run the
   canonical logout where a player exists, and mark the session for deletion by
   the normal world-session update.

The controller must never retain an owning raw `WorldSession*` across
asynchronous callbacks. The current core's callbacks capture the session as
`this`; therefore the world-owned session has to remain alive until callbacks
have either completed or been drained/cancelled.

## Map-thread delivery

The audit correctly treats this as the highest-risk detail after lifecycle.
`MapUpdate.Threads` supports multiple worker threads, and no generic public
"enqueue arbitrary work on this map" primitive was found in the inspected
source. Calling movement, spell, or combat methods directly from a console,
world, network, or model thread is out of scope.

For the deliberately narrow PB-00/PB-01 proof on one known outdoor map, a
map-specific `WorldMapScript::OnUpdate` is a plausible place to consume a
thread-safe command queue in map context. It is only a prototype seam: map
scripts are selected by map type/ID, so this does not yet solve instances,
battlegrounds, transfers, or a general multi-map bot architecture.

## Shutdown ordering

`WorldScript::OnShutdownInitiate` exists, but immediate shutdown can set the
world stop event before that callback runs. `WorldScript::OnShutdown` is later
still, after the world update loop and I/O have stopped. Neither hook alone
proves a clean asynchronous bot logout.

The first implementation should therefore add a synchronous, idempotent
"begin bot drain" step before the stop event becomes final, reject new bot
loads once draining begins, and allow enough normal world/map/session updates
to complete logout. The emergency path still needs a bounded forced cleanup
that cannot wait forever on database work.

## Capacity and account policy

`World::m_sessions` is keyed by account ID. `AddSession_` replaces or rejects an
existing session for the same account and also participates in player-limit and
queue accounting. PB-00 can avoid ambiguity by using one dedicated bot account
and one character. Before adding population bots, decide explicitly:

- whether every bot receives a separate account;
- whether bot sessions count toward the realm player cap and login queue;
- how an authorized owner is linked to bot accounts without sharing account
  credentials; and
- whether the desired same-account experience justifies revisiting the more
  isolated session-ownership alternative.

## Source provenance

Use the documented public donor revision and native Cata APIs as implementation
references. Record source revisions and any adaptations when importing code.

## PB-00 decision gate

Proceed to implementation only when these points are explicit in the patch:

- server-origin sessions are distinguishable from disconnected human sessions;
- one world-owned session has one clear account and character owner;
- initialization and character-login callbacks cannot outlive the session;
- wrong-account, duplicate, non-Warrior, and non-allowlisted loads fail closed;
- feature-off behavior is unchanged;
- the idle bot survives normal updates for at least two minutes;
- stop and shutdown save, remove from map, clear online state, and delete the
  session without relying on a socket; and
- no model output is involved in the lifecycle proof.

The lifecycle comparison supports beginning PB-00. It does not yet justify
porting combat AI, population management, or LLM-authored spell/talent data.

## Implementation progress

PB-00 slice 1 was added after this comparison on 2026-09-21. `WorldSession`
now records a typed `Client` or `Server` origin; the existing network path is
explicitly client-origin. The idle check no longer dereferences an absent realm
socket, and the world update retains a missing-socket session only when it is
explicitly server-origin.

This slice compiled in the Win64 `RelWithDebInfo` `worldserver` target with zero
warnings and zero errors. It is intentionally inert: there is no server-origin
constructor call, loader, command, configuration switch, character login, or
runtime test yet.

PB-00 slice 2 was added on 2026-09-22. Session initialization now records the
states `Created`, `Loading`, `Ready`, and `Failed`. Server-origin sessions reuse
the per-realm account/tutorial query holder but do not emit the client auth,
addon, cache, or tutorial packets after it completes. A server-origin exit
request is consumed only by the unsafe/world session pass; it waits for an
active character-login query, performs canonical saved logout when a player is
present, and then lets `World::UpdateSessions` delete the session.

The second slice also completed a Win64 `RelWithDebInfo` worldserver build and
link. It remains inert. Before adding the first loader, the controller must load
RBAC before `World::AddSession`: `World::AddSession_` calls `HasPermission` for
queue admission and assumes `_RBACData` already exists. The controller also
needs independent account/GUID/class validation because a socketless session
never receives the client character-enumeration packet that populates
`_legitCharacters`. Immediate shutdown still requires a bounded early drain;
the ordinary exit request alone does not solve that ordering.

PB-00 slice 3 was added on 2026-09-22. `World::TryStartDevPlayerbot` is a
world-thread-only, default-off admission boundary for one configured account
and one configured character GUID. It rejects an existing same-account or
server-origin session, a full realm, missing or banned accounts, non-player
account security, and characters that are deleted, online, on another account,
or not Warriors. It also verifies the character cache identity, loads RBAC
before `AddSession_`, and pins the allowlisted GUID on the new server-origin
session. `World::RequestStopDevPlayerbot` requests the existing canonical
exit path. The Win64 `RelWithDebInfo` worldserver target built and linked.

This is deliberately still inert: neither method has a caller, no character
login is initiated, and no worldserver/runtime test has been performed. The
next slice must use the session `Ready` state to initiate the canonical
character-login flow, define bot-only outbound packet handling, and add an
early shutdown drain before exposing a development command.

PB-00 slice 4 connects the staged server-origin session to the canonical
asynchronous character-login path only after account/tutorial initialization
reaches `Ready`. It rechecks the pinned Warrior's cache identity and connected
state, then schedules the existing `LoginQueryHolder` instead of fabricating a
`Player`. Failed holder setup or `Player::LoadFromDB` requests server-origin
exit; a stop request during loading waits for the callback before logout.
Outbound packets for server-origin sessions are intentionally discarded after
opcode and connection validation, without changing client-session handling.
The dedicated account cannot be replaced by a second bot or client session.

The methods remain uncalled and no in-game bot has been tested. Early shutdown
drain and a bounded development command remain prerequisites for the live
one-Warrior proof.

The Win64 `RelWithDebInfo` worldserver build and link passed for this slice.

PB-00 slice 5 adds console-only `.server playerbotdev start|stop|status` under
the existing server-debug permission. Command handling is on the world thread and the
feature remains default-off. Normal immediate or timed shutdown requests bot
exit before stopping and grants at most 30 seconds of world updates for
asynchronous login/logout to drain. A timeout is explicit in the log; force,
exit, and process termination still use their existing immediate paths.
The isolated live lifecycle proof remains unperformed.

PB-00 slice 6 completed an isolated positive-path proof on 2026-09-23:
one offline Warrior on the disposable Cata database was admitted without a
client, stayed online for 125 seconds, stopped and logged out, and the server
exited normally. The initial bot run exposed a pre-existing double-owner
capture point in map-530 OutdoorPvP; Zangarmarsh was fixed and the same issue
was corrected in Nagrand. See `PLAYERBOTS_LIFECYCLE_VALIDATION.md` for evidence
and the negative/interrupted-loading checks still outstanding.
