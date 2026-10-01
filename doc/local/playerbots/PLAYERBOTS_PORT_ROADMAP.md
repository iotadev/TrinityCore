# Cata Playerbots roadmap

Updated 2026-10-01. This is the current plan and status. Use
[work packets](PLAYERBOTS_WORK_PACKETS.md) to resume implementation and the
module's `PORTING.md` for imported code and Cata adaptations. Dated validation
reports and [development history](PLAYERBOTS_DEV.md) describe earlier revisions.

## Current checkpoint

For player-controlled small parties, the main infrastructure is in place:
optional modules, native session admission/lifecycle, ownership/control,
decision scheduling, MultiBot transport and bounded native provisioning.
The bundled ordinary-client creation/accounting and addon-managed roster/lifecycle
check passed on 2026-10-01 with clean shutdown. The matching Ubuntu 22.04/GCC 11
server build with both modules enabled and no PCH also passed all 109 tests.
This completes the scoped player-controlled infrastructure acceptance, not
Linux runtime or full feature parity. Autonomous population will need
its own bounded manager later; it is not a prerequisite for broader class,
rest/loot/recovery and dungeon feature ports now. Add core seams only when a
concrete donor consumer requires them, rather than building speculative services.

The completed feature-alignment slice routes existing Mage/Priest party buffs through
registered class strategies/triggers/actions, gated by EnginePartyBuff. It adds
no new spell behavior and defers runtime confirmation to a useful party check.
See research/PARTY_BUFF_ENGINE_PACKET.md and module PORTING.md for its scope.
Worldserver/tests-common built with both modules enabled and all 109 automated
tests passed. This is not runtime proof of the new buff route.

The earlier factory checkpoint built worldserver/authserver and passed all 106
automated checks; the later party-buff checkpoint above raised the total to 109.
The first factory slice provides a bounded, read-only Cata appearance draft
and console diagnostic. The bundled server-only factory runtime check now passed.
The core now shares a typed creation entry point and outcome receipt with
ordinary client creation; the bounded console factory caller is now in source.
The dedicated creation-only owner is now in a bounded world registry, separate
from human/bot sessions. It reserves accounts against overlapping admission and
does not maintain account-online flags. The module now has pure ownership/reuse
decision rules, an optional manual ownership schema, native reader and default-off
console inspection/enrollment/provision/status. Enrollment explicitly dedicates
a pre-created empty account without credential changes. Native submission creates
missing identities; exact reruns use a reserved accounting-only context rather
than another create attempt. The operator slice built both executables and passed
all 106 tests. Native database/runtime verification also passed on a fresh clone:
absent-schema rejection, enrollment/eligibility gates, creation, exact reuse with
realm-count repair, conflicting-intent rejection and explicit managed login/logout.
The missing-schema case originally exposed a fatal SQL error; optional column
metadata is now checked first without weakening core SQL error handling.
Provisioning retains the reservation through realm-count reconciliation
and exposes a ready GUID only after character creation and the corrective
accounting commit both succeed. No automatic account creation, roster/config
mutation, admission or player-control grant occurs. The disposable batch confirmed
save/logout and clean world/database shutdown. Ordinary client creation and
addon-managed lifecycle were subsequently verified in the separate bundled
client check, not by the server-only factory batch.
The 2026-09-30 Windows MultiBot check confirmed clean addon startup, Stay,
Follow and main Attack. Two client startup adaptations corrected library load
order and Cata macro-icon enumeration. The existing 25-yard combat gate was
observed in rejection logs and engagement succeeded after moving closer.
On 2026-10-01, an ordinary explicitly linked player used My Bots to connect,
disconnect and reconnect a managed bot. Native records and the harness confirmed
completion and clean shutdown. This does not certify an exhaustive live
authorization matrix.
These local changes are not yet a
published matching snapshot; prior dated test counts below describe earlier slices.

The optional module, server-origin session lifecycle, imported scheduling
engine, bounded Warrior/Mage/Priest contexts, active roster, and first whisper
commands are integrated. Gameplay belongs to `modules/mod-playerbots`;
core owns session admission, lookup, lifecycle and the module hooks.

The 2026-09-29 disposable Ragefire session admitted four bots, accepted the
human's invitations, entered the instance, and shut down cleanly. Logs recorded
13 accepted Mage offensive casts, six Priest healing casts and one Fortitude
cast. The player confirmed good overall behavior and basic whisper controls.
Warrior combat routing was logged; this session did not establish tank threat.
The earlier Battle Shout engine check was also confirmed in the client.
The matching publication build of worldserver and tests-common passed with
both modules enabled; all 65 automated tests passed. These checks establish an
operational development checkpoint.

A whispered `attack` after `stop` was rejected while the selected target was
Botmage. Later logs show an explicit attack on an Earthborer and offensive casts.
Record the target-selection ambiguity for command/addon work; it does not block
infrastructure development. No new client session is required solely for it.
Resurrection, controller death, removal/re-invite and full dungeon completion
were not verified by this release check.
The fixture human had GM privileges; ordinary-player authorization boundaries
were source-reviewed but not independently exercised in this session.

Playerbots admission and all experimental engine routes remain default-off.
Accounts/characters are manually supplied. Four development slots remain for
the prior fixture; an initial, separate configured roster now permits
console-requested admission/logout of existing identities through the same
native path. That new path passed a combined build and 67 automated checks;
it has not had a configured managed-roster runtime check.
The latest local slice adds session-owned lifecycle receipts: loading, online,
exit pending, stopped, login failed, unexpected disconnect and shutdown. The
roster retains the latest receipt after session deletion and preserves it across
matching settings reloads. New admissions have separate receipts. This is an
in-memory outcome contract; it does not guarantee asynchronous DB commit success
or persist outcomes across process restarts. The combined worldserver build
with both modules enabled passed, as did all 71 automated checks, including
four transition regressions. Native managed start/stop remains runtime-unverified.
The latest player lifecycle service adds explicit trusted account links and
same-faction access; stop/list of grouped bots also requires current full party
control, with the donor GM override retained. It is separately default-off and
returns authorized roster views/receipts for later transports. Malformed links
disable player access. The default-off MultiBot endpoint now calls this service. The combined
worldserver build and all 75 automated tests passed for this addition; live
ordinary-player permissions remain unverified.
The managed identity list has no account/character factory or automatic population.
MultiBot's initial transport and patched Windows client are present; complete
class/spec profiles, broader addon services and autonomy are not implemented.

## Direction and source policy

The objective is the AzerothCore Playerbots feature set on Cataclysm:
companions, class/spec behavior, character creation, autonomous login/logout,
travel/questing/progression, dungeons and compatible optional extensions.
The low-level party is a starting point.

Prefer direct upstream ports with small Cata adapters. Preserve component names,
directory organization, strategy/action relationships, configuration meaning and
extension interfaces where useful. Record donor repository, exact revision,
source paths, retained authorship and each deliberate deviation.

Before each bounded port, check the upstream repository's current default branch
(`master` for mod-playerbots). Pin that commit for the batch and examine changes
in the relevant files since the previous pin. The local WotLK installation is
a behavior/compatibility reference; local custom changes are a separate donor
layer. Do not update a running WotLK installation as part of a Cata port.

On 2026-09-29 upstream mod-playerbots master was
`7bae1b5c58c76a0aa20381155edc08096d1485b2`. The recorded local donor
`8827dd6fcbb2bb25988787a40f06fc93daf8e02d` contains that commit plus five
local changes. It is not behind that upstream revision. Public upstream can
reproduce the upstream pin; the local custom commit may not exist in its history.
Earlier provenance entries remain valid and must not be relabelled retroactively.

Cata APIs and data decide spells, talents, resources, equipment, maps and packet
layouts. WotLK data is a reference, not proof of Cata mechanics. Unsupported
talent trees use an explicit limited fallback. Never advertise a complete spec
because its generic class spells compile.

## Architecture and boundaries

The [reference guide](PLAYERBOTS_REFERENCE_GUIDE.md) records the source hierarchy,
dated working/public revisions, and ArkCORE's limited role as a Cata behavior
reference. Its Creature-based architecture is not a donor for Player sessions.
Shared recovery coordination belongs at the session/manager boundary; native
core lifecycle rules and class-specific spell decisions retain their owners.
Apply these comparisons within the existing stages, not as a new prerequisite.

| Layer | Current responsibility | Next extension |
|---|---|---|
| Core `World` / `WorldSession` | Socketless admission, account/session ownership, active GUID lookup, general identity admission, lifecycle and module hooks | Completed-operation reporting; keep world-thread ownership |
| Module `PlayerbotManagedRoster` / `PlayerbotManagedControl` | Configured identities, console lifecycle receipts, default-off authorized player list/start/stop service and account links | MultiBot transport/operation mapping, then wider donor eligibility |
| Module `PlayerbotSessionBehavior` | Party, movement, combat/transfer orchestration and queued controls; lazily creates AI after Player load | Gradually hand supported behavior to donor runtime/state/event mechanisms |
| `PlayerbotAI`, `AiObjectContext`, `Engine` | Imported scheduler, registries and bounded class contexts | Broader dependency-complete actions/values and combat/noncombat/dead-state integration |
| `PlayerbotSecurity` / `PlayerbotControl` | Invitation-controller authorization and queued follow/hold/attack/cease | Reuse for roster lifecycle and addon requests |
| `PlayerbotRoster` | Online, in-world, fully controllable bots | Managed identities and offline availability |
| Whisper PlayerScript | `list`, `follow`, `stay`/`hold`, `attack`, `stop`/`cease` | MultiBot structured transport over the same services |

An eligible human can invite an available ungrouped bot. Ordinary full control
belongs to the adopted inviter while they remain in the party; other party
members do not automatically gain full control. The donor GM override remains.
Console development follow is a separate explicit override and may work outside
a party. Preserve that distinction when replacing the numbered dev commands.

AI gameplay runs in map context. Active-session enumeration/admission, queued
world operations and teardown retain their native ownership. Keep GUIDs across
updates, re-resolve Players, and validate current authorization before acting.
Do not add synchronous map-thread database work or a second permanent scheduler.

Server-origin outbound delivery is discarded today. Full donor packet/event
semantics are still missing. Add typed Cata events or narrow native hooks with
explicit thread/lifetime contracts as consumers need them; do not parse Cata
traffic using WotLK byte layouts. One decision owner must control each migrated
behavior while transitional companion fallbacks remain available.

The static module/config/test convention already exists. AHBot is already a
separate optional module with narrow core hooks. Dynamic plugins, a universal
AzerothCore compatibility layer and another module-system rewrite are not
prerequisites for the next Playerbots work.

## Delivery sequence

| Stage | State and next result |
|---|---|
| 0. Operational foundation | Build, copied-realm startup, four-bot login/instance/logout and basic controls established |
| 1. Donor runtime foundation | Scheduler/context and gated class routes integrated; complete state/event contracts incrementally |
| 2. Managed party and first addon controls | Configured roster, console receipts and player authorization service added; next: capability-limited Cata MultiBot bridge, integrated lifecycle/permission check and creation |
| 3. Class/spec coverage | Extend donor profiles, roles, rest, loot, dispels, interrupts, pets and recovery against Cata data |
| 4. Autonomous population | Bounded RandomPlayerbotMgr login/logout, ownerless behavior, travel/RPG/quests and persistence |
| 5. Dungeon and ecosystem features | Encounter strategies, tank leadership/one-dungeon clear, wider addon features and optional modules |

These stages express dependencies, not a requirement to finish every behavior
before progressing. Existing-character roster/lifecycle does not need to wait
for account creation or complete rotations. Addon handshake/control work can use
the existing active roster while managed connect/disconnect is being added.
Advertise each capability only when its backing service works.

Replace the four-slot orchestration through a manager, not by adding more
numbered commands. Initially preserve one admitted character per account.
Managed ownership, creation permission and a human's temporary party control
are separate concerns; do not tie every bot permanently to one player's GUID.
Provisioning must be repeatable and use native creation/save/cache/realm-count
paths. Do not duplicate raw character rows or delete unrelated accounts.

## MultiBot and optional modules

The inspected local MultiBot Chatless addon was
`5b4f1a558650d10e37b99a4cf85d8afbbfdc82ce`; the bridge was
`1da05982e478cb00e0b6c87314afe7e0e9653ffb`. Refresh upstream before porting.
Its WotLK interface 30300 and MBOT HELLO/HELLO_ACK protocol require Cata
adaptation. Map the current addon/server contract together.

Local implementation now has a default-off native Cata addon seam and initial
HELLO/PING/authorized active ROSTER replies. The bridge reference was refreshed
2026-09-29 and remains at the pin above. ALT_ROSTER_V1 and BOT_LIFECYCLE_V1
are advertised only when the validated player lifecycle service is enabled.
Other capabilities remain absent. Managed lifecycle
request/poll endpoints are now mapped to native receipts with bounded mutation
replay/rate protection (2026-09-30); native completion and authorization still
need the bundled runtime check. Authorized managed ALT_ROSTER frames are implemented
with donor count/truncation boundaries and query limits. Next map donor gameplay
extensions onto existing services; do not invent a parallel
wire protocol. Basic follow/stay/attack/stop controls now use the donor's
normal whisper/party/raid chat path with subgroup and per-bot authorization.
COMBAT and POSITION are strategy/disperse endpoints, not replacements for that
path. The addon upstream was refreshed to
`1eac0d9106b8cdf0a79da3974ee1f516f8ca3fbc` on 2026-09-30; client adaptation
should use this pin rather than the earlier local addon snapshot.
An isolated candidate now applies the module's portable Cata compatibility
patch (interface/events/prefix registration/library order/macro icons); Lua 5.1 syntax and mocked donor
Comm checks passed. The donor main attack alias is accepted server-side. No
existing addon was overwritten. The installed candidate passed startup and
basic Stay/Follow/Attack; managed roster/lifecycle validation,
capability mapping and class/spec/talent-data adaptation remain pending.
Keep the server/module portable through native C++/CMake and the addon through
Git/Lua/client APIs. Local PowerShell harnesses are not runtime requirements.
A Linux build and all 109 automated tests passed at the infrastructure milestone.
Neither that result nor Windows/Lua evidence certifies Linux server runtime.

First implement handshake/capabilities, authorized roster/presence and existing
follow/stay/attack/stop controls. Add connect/disconnect when the managed
lifecycle exists. These requests call shared module services; they must not
invoke console-only dev commands or treat a queued request as completed.

Dungeon-clear, dungeon simulation and world-PvP consumers follow managers,
activity reservations, roles and recovery. Start actual dungeon automation with
tank leadership and one dungeon including abort/regroup behavior. Optional LLM,
character/personality, progression, loot and server-economy modules remain
separate feature tracks. Their existence is not a prerequisite for Playerbots.
AHBot changes stay independent of the Playerbots module.

## Local donor fixes to incorporate deliberately

These are local WotLK additions, not upstream-master commits:

| Donor commit | Behavior | Planned Cata treatment |
|---|---|---|
| `ece6af79` | Respect greeting settings | Compare existing GreetingOnJoin gate; carry settings through later donor chat paths |
| `969cb11f` | Quote SQL-hook paths | Apply where equivalent deployment hooks exist; avoid importing unused shell hooks |
| `8ac6ed0e` | Shared bot-activity reservations | Adapt before autonomous/optional modules compete for bots; define release on failure/logout |
| `12ab98a3` | Refresh social roster after login | Incorporate with managed presence and MultiBot, using Cata's actual social protocol |
| `8827dd6f` | Engage current target when enabling self-bot | Incorporate the applicable connect/control behavior when self-bot support exists |

Inspect source and callers for each item, preserve attribution, and record
ported/replaced/deferred status in PORTING.md. Similar symptoms alone do not
prove a WotLK patch is needed unchanged. The current Mage opener is a separate
Cata fix and is already client-confirmed.

## Working and validation cadence

Work in substantial bounded batches with stable interfaces. Build after a
coherent batch and run relevant existing tests; add tests for actual decisions,
lifecycle failures or regressions. Group client checks into integrated operational
milestones. Do not block further infrastructure work on spell polish, pathing
feel or every untested edge case unless a concrete failure prevents progress.

For structural changes, check thread ownership, admission/teardown and module-off
behavior when affected. For public checkpoints, review the outgoing diff,
authorship, source provenance, module pins and privacy. Preserve the existing
publication history through ordinary follow-up commits.

The latest local runtime evidence is
`build/playerbot-smoke-20260929-111951` (ignored, not distributed). The
[release-check record](NEXT_MIXED_PARTY_TEST.md) explains its scope.
The core README pins its matching module revision; check the reference guide and
actual Git state to distinguish local work from published checkpoints. Runtime data,
credentials and historical private Git snapshots stay outside publication.
