# Cata Playerbots roadmap

Updated 2026-09-29. This is the current plan and status. Use
[work packets](PLAYERBOTS_WORK_PACKETS.md) to resume implementation and the
module's `PORTING.md` for imported code and Cata adaptations. Dated validation
reports and [development history](PLAYERBOTS_DEV.md) describe earlier revisions.

## Current checkpoint

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
The managed identity list has no account/character factory, human-facing
connect permission, completed-operation ledger or automatic population.
MultiBot, complete class/spec profiles and autonomy are not implemented.

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

| Layer | Current responsibility | Next extension |
|---|---|---|
| Core `World` / `WorldSession` | Socketless admission, account/session ownership, active GUID lookup, general identity admission, lifecycle and module hooks | Completed-operation reporting; keep world-thread ownership |
| Module `PlayerbotManagedRoster` | Default-off configured existing identities and console list/start/stop | Eligibility/permission model and lifecycle outcomes before player/addon connect |
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
| 2. Managed party and first addon controls | Configured existing-character roster and console lifecycle slice started; next: outcomes, player permission model, creation and a capability-limited Cata MultiBot bridge |
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
The core README pins the corresponding published module revision. Runtime data,
credentials and historical private Git snapshots stay outside publication.
