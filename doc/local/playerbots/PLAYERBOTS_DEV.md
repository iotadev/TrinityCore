# Cata Playerbots development history

## Superseded roadmap and handoff snapshot — 2026-10-02

This snapshot preserves dated evidence, not current resume instructions.

### Archived roadmap

# Cata Playerbots roadmap

Updated 2026-10-02. This is the current plan and status. Use
[work packets](PLAYERBOTS_WORK_PACKETS.md) to resume implementation and the
module's `PORTING.md` for imported code and Cata adaptations. Dated validation
reports and [development history](PLAYERBOTS_DEV.md) describe earlier revisions.

## Current checkpoint

Current-target Mage Spellsteal is now local source, using native dispel candidates
plus the non-stealable-aura filter. See research/SPELLSTEAL_PACKET.md and module
PORTING.md. Level-70 native buff transfer remains unverified. Linux validation
of this and the preceding curse batch is pending Docker API recovery.

Mage self/party Remove Curse is now local source using shared native party
support, with no new lifecycle/database path. See research/MAGE_CURSE_PACKET.md
and module PORTING.md. Its native level-30 spell and actual curse removal need
the bundled class fixture; full-health members must remain cure candidates.

Mage defensive support is now local source: Mana Shield, Ice Block and Frost
Ice Barrier through native self casts. See research/MAGE_DEFENSIVE_PACKET.md
and module PORTING.md for provenance/validation. Absorb/immunity and recovery
after Ice Block remain bundled runtime checks, not confirmed gameplay.

Latest local Frost follow-up schedules Brain Freeze Frostfire Bolt and Deep
Freeze through native eligibility/casting, with Ice Lance fallback. See
research/FROST_PROC_PACKET.md and module PORTING.md for scope and validation.
This is not runtime-confirmed Frost parity; keep the next client check bundled
with the other learned/talented class fixtures.

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

The current unpublished gameplay batch adds carried food/drink recovery and
active-spec Mage armor through the same decision engine. Both are default-off,
module-local ports with no new core lifecycle seams or database schema. Windows
and Linux builds/tests each passed all 115 checks. Native item execution,
recovery/follow timing and armor replacement
remain one bundled mixed-party check, not prerequisites for every further port.

The first loot slice reuses native auto-pass for new group rolls, default-off,
with captured preference restoration on disable. A source-discovered native
pass-count correction and follow-loot-rules quest preference correction are
included in the matching development core. This is not corpse looting or donor
item-usage evaluation. See research/LOOT_ENGINE_PACKET.md for dependencies and
the next bounded corpse request/result path; native roll resolution stays a
bundled runtime check.

Nearby corpse opening/storage is now in local source behind
Playerbots.Loot.Corpses.Enabled. A typed native SendLoot result and GUID-only
map-to-world request let the module use permission-filtered native money/item
storage and release without parsing discarded outbound packets. Candidates are
interaction-range defeated/selected corpses only; distant movement and discovery
remain follow-ups. Final Windows and Linux builds/tests each passed all 123
checks; Linux also passed an incremental current-source recheck. The bundled
outdoor check confirmed native corpse opening by all four bots and clean
shutdown. Item awards, group rolls, food/drink recovery and Mage armor remain
unverified; see NEXT_MIXED_PARTY_TEST.md for fixture prerequisites and limits.
The local movement follow-up now keeps a bounded, expiring defeated/selected
corpse collection and makes short native-pathfinding detours through the
existing movement owner. Timeout and cancellation prevent permanent follow
loss; live detours remain unverified. Broad discovery and item valuation are
still follow-ups, not implied by this slice.
Final Windows and Linux worldserver/tests-common builds each passed all 126 tests.

Implemented combat routes now refresh from native active primary talent tree
rather than only at login. Warrior Protection and Mage Frost switch their
existing sibling strategies without removing shared recovery/loot/buff routes.
Priest and unsupported spec rotations retain explicit fallbacks. See
research/SPEC_STRATEGY_REFRESH_PACKET.md; Windows and Linux each passed all
129 tests. Live spec transitions remain pending.

Current-target interrupts are also local source: learned Warrior Pummel and
Mage Counterspell, retaining donor interrupt priority and using native Cata
interruptibility/cast checks. Windows and Linux each passed all 132 tests;
landed interrupts remain pending. No coordinated kicks, enemy-healer scan
or Mage own-cast cancellation is implied; see research/INTERRUPT_ENGINE_PACKET.md.

The following local spell batch adds known Heroic Strike with donor rage
reserves and conditional Frost Ice Lance for frozen/proc states. Native Cata
spell/resource/aura handling remains authoritative; no new core seam or AoE
selection is introduced. See research/RAGE_FROST_ACTION_PACKET.md. Windows and
Linux worldserver/tests-common each built and passed all 135 tests; live
resource/proc effects remain pending.

Priest self/party disease cure is the next local support port under the existing
healing-engine gate. Native disease eligibility and native casts are used;
Wrath Abolish Disease is replaced by the donor's real Cure fallback because
spell 552 is absent in Cata. Magic/talent-dependent dispels remain separate.
See research/PRIEST_DISEASE_PACKET.md; Windows and Linux each passed all 138
tests. Live disease removal remains unverified.
Follow-up review corrected cure ordering to retain healthy/full-health party
members, without changing healing's existing cutoff. Windows and Linux each
passed all 141 tests. The healer-DPS slice is now local source: native spells
through the
existing controlled GUID target/command owner, without melee attack or chase.
Healing demand below 90% or mana below 85% defers damage; native spells own
effects/costs. See research/HEALER_DPS_PACKET.md. Windows and Linux each passed
all 145 tests for the first Smite slice. The follow-up adds donor-order Shadow
Word: Pain, Holy Fire and Mind Blast with native caster-owned DoT checks;
Windows and Linux each built and passed all 147 tests. Shared estimated group
DPS/lifetime values now reuse the donor level/gear/role model and connect Shadow
Word: Pain's eight-second gate. The profile stops at 80; unknown estimates skip
that DoT. See research/COMBAT_VALUES_PACKET.md; Windows and Linux each built and
passed all 154 tests. The shared single-target threat follow-up now guards
scheduled Mage/Priest damage at 80% of a recognized Protection Warrior's threat.
No recognized tank means no throttle; healing/support remain unaffected.
See research/THREAT_ENGINE_PACKET.md. Windows and Linux each built and passed
all 159 tests. AoE, Warrior auto-attacks, full tank roles and
direct-action interception remain outside this subset. The engaged PvE attackers/
balance subset now reads native group threat references and enables Priest
donor-default 85/65/40 mana thresholds, without changing targets or healing gates.
See research/COMBAT_BALANCE_PACKET.md; Windows and Linux each built
worldserver/tests-common and passed all 162 tests. Native behavior remains bundled.
Full attacker priority/PvP, DPS target selection and Cata 81–85 profiles remain ahead.
The bounded DPS selection follow-up now supplies active-strategy exclusion
gathering, donor marker/priority values and caster/general ranking for idle
Mage/Priest fallback assist. It admits only already-controller-engaged targets,
without overriding selected targets, explicit commands or active attacks.
See research/DPS_TARGET_PACKET.md; Windows and Linux each built and passed all 167 tests.
Full target parity, dynamic switching and encounter providers remain ahead.
The named-target/tank follow-up adds fresh shared GUID values and idle Protection
Warrior fallback with donor aggro/range/threat ranking. See TANK_TARGET_PACKET.md
under research; Windows and Linux each built worldserver/tests-common and passed
all 170 tests. No active switching, taunts,
explicit-main-tank coordination or broader tank roles are claimed.
The subsequent bundled check exercised damage/healing/armor/corpse opening but
found unassigned Warrior fallback asymmetry after distance disengages. Source
now covers all enabled Warrior routes with tank/general DPS target values and
native melee ranking. Windows and Linux each built worldserver/tests-common
and passed all 171 tests; live correction verification remains pending.
Next test setup must place the party near level-appropriate mobs before handoff.
Native damage, healing responsiveness and
follow resumption remain for the bundled check, not a separate micro-test.

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
| 2. Managed party and first addon controls | Scoped infrastructure accepted: configured roster, console/player lifecycle receipts, capability-limited MultiBot and optional native factory; ordinary-player lifecycle and Linux build/tests passed |
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
`build/playerbot-smoke-20261001-210142` (ignored, not distributed). The
[release-check record](NEXT_MIXED_PARTY_TEST.md) explains its scope.
The core README pins its matching module revision; check the reference guide and
actual Git state to distinguish local work from published checkpoints. Runtime data,
credentials and historical private Git snapshots stay outside publication.

The bounded Protection rotation slice (Devastate/Sunder, Revenge and Sword
and Board) is local development; see research/WARRIOR_TANK_ROTATION_PACKET.md.
Continue feature ports through existing class contexts. Full tank parity,
broader stance/cooldown support, AoE and dynamic target switching remain separate
work. The bounded Defensive Stance, Shield Block, Shield Wall and Last Stand
slice is now local source; see research/WARRIOR_DEFENSIVE_PACKET.md. It adds
no autonomous combat or idle stance manager.
Arms/Fury starter strategies are also local source: Mortal Strike, Bloodthirst,
Execute and their combat-only native stances. See
research/WARRIOR_DPS_SPEC_PACKET.md. Continue bounded donor feature ports;
do not treat these footholds as complete class/spec rotations.
The bounded Overpower/Taste for Blood and Bloodsurge/Slam response is also local
source; see research/WARRIOR_PROC_PACKET.md. Native casting owns reactive and
proc effects; broader Cata mechanics and AoE remain ahead.
Colossus Smash and Raging Blow are now bounded Cata adaptations through the
existing Arms/Fury context; see research/WARRIOR_CATA_ACTION_PACKET.md.
This does not close the 81-85 combat-value/gear-profile gap or full rotation tuning.
Mage Fire/Arcane starter routes and native proc-gated Arcane actions are also
local source; see research/MAGE_SPEC_ACTION_PACKET.md. Hot Streak's native
override path is a prerequisite for its next port; Fire DoTs, mana-phase logic
and AoE remain ahead. Do not restart the existing spec or scheduling layers.
The native Hot Streak override path is now implemented together with bounded
Scorch/Critical Mass eligibility; see research/FIRE_PROC_OVERRIDE_PACKET.md.
Loaded Scorch proc metadata and native Fire runtime behavior remain unverified;
Living Bomb belongs with AoE safety, not an unrestricted single-target port.

### Archived work packets

# Playerbots development handoff and work packets

Updated 2026-10-02. Read this with the
[roadmap](PLAYERBOTS_PORT_ROADMAP.md). This file defines the next work;
dated development/validation notes are historical evidence.

Use the [reference guide](PLAYERBOTS_REFERENCE_GUIDE.md) for authority, pinned
secondary comparisons and recovery ownership. Existing local work may be newer
than the published pair; do not plan solely from GitHub branch contents.

## Resume here

Latest local utility slice is learned current-target Spellsteal at donor priority
40. See [the source packet](research/SPELLSTEAL_PACKET.md) and module PORTING.md.
Do not substitute ordinary dispel eligibility for the non-stealable-aura filter.
Native transfer needs the bundled level-70 fixture. Resume Linux validation of
both this and the curse slice once Docker's API responds; do not infer current
Linux success from the earlier 187-case defensive-support build.

Latest utility batch adds Mage self/party Remove Curse with donor priorities
41/40 and native dispel eligibility, reusing extracted Priest party support.
See [the source packet](research/MAGE_CURSE_PACKET.md) and module PORTING.md.
The existing Mage engine flag gates cures; enabled Mages reuse the passive tick
out of combat. Native removal remains unverified and needs learned spell 475
(level 30), not the previous unassigned level-20 fixture.

Latest local Mage support batch adds common Mana Shield/Ice Block and Frost
Ice Barrier, using donor default health thresholds and native self casting.
See [the source packet](research/MAGE_DEFENSIVE_PACKET.md) and module PORTING.md.
No movement or early block cancellation is ported. Bundle native absorption,
mana cost, immunity/Hypothermia and post-block recovery with class qualification.

Latest local Frost slice adds Brain Freeze Frostfire Bolt and native frozen-state
Deep Freeze above the existing Ice Lance fallback. See
[the source packet](research/FROST_PROC_PACKET.md) and module PORTING.md for
validation. Proc consumption/immune-target damage require bundled runtime
confirmation; pets, AoE and full Frost parity remain deferred.

The infrastructure stop point has passed acceptance and documentation alignment.
The matching module is committed as 70014ce88cb2d99a370894baef7a32876ff94a50;
the core README pins that revision for the matching milestone. See
[the acceptance checklist](PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md). The bundled
ordinary-player check passed creation/accounting, addon-managed roster and
connect/disconnect/reconnect, account-online cleanup and clean shutdown on
2026-10-01. The Linux worldserver/authserver/tests-common build also passed all
109 tests after explicit header corrections. Scoped infrastructure acceptance
is complete. The matching infrastructure pair has been pushed to the publication
repositories; subsequent gameplay work remains local until its next milestone.
Linux runtime remains a separate future check. After the milestone, resume the
bounded donor feature ports below rather than reopening the foundation.
The next dependency-complete gameplay packet is
[shared food/drink recovery](research/REST_ENGINE_PACKET.md). Source selection
and native seam mapping are recorded. The default-off dependency-complete
implementation is now in development. Windows worldserver/tests-common and all
113 tests passed; Linux worldserver/tests-common and all 113 tests also passed.
Native item execution and rest/follow timing belong to the next mixed-party check.

The next module-local addition is Mage self-armor (`Playerbots.Mage.Armor.Enabled`,
default off), adapting donor `bmana`/`bdps` at the same pinned revision. Current
active spec and learned spells select armor; native casting owns replacement.
Windows and Linux builds/tests each passed all 115 checks. The local Cata DBC
checker confirmed the armor identities, class masks, learn levels and effects.
Bundle armor application/spec-change checks with rest, party buffs and normal
combat rather than requiring a separate client session for each action.

Loot follow-up is mapped in [the loot packet](research/LOOT_ENGINE_PACKET.md).
The first local implementation is a default-off native group auto-pass preference,
not donor item evaluation or corpse looting. It includes the necessary native
GroupLoot initial-pass count correction and preference handling for quest items
that follow group loot rules. Pure tests cover preference enable/restore only;
native roll creation/awards remain part of the bundled party check. Use matching
core/module development sources, not the older published core pin. Next port
the bounded corpse candidate/request/result path described in the packet before
equipment-aware Need/Greed; do not fabricate response events or call Group vote
mutations from map-thread actions.
The final combined Windows/Linux worldserver/tests-common builds passed all
119 tests on each platform, including the four new pure loot-preference tests.

The initial near-corpse opening/storage slice is now local source, default-off
under Playerbots.Loot.Corpses.Enabled. It supplies the typed native SendLoot
result dependency and a bounded map-to-world request mailbox; see the updated
loot packet and module PORTING.md. Only interaction-range corpses are included;
area discovery, loot movement, gathering, skinning and item valuation are not.
Windows worldserver/tests-common and all 123 tests passed after the final guard
and test-only GUID link/constructor fixes. Linux's larger core-interface rebuild
finished, followed by an incremental current-source recheck and all 123 tests
passed again. Native execution stays bundled.
The local harness now has an interactive mixed-party RecoveryLoot scenario:
it enables the new flags only in a copied fixture, moves all Playerbots settings
to module config, and can retire prior party membership only for groups wholly
owned by the five offline test characters. Original seeds remain unchanged.

The 2026-10-01 outdoor check confirmed native corpse opening by all four bots,
17 accepted Mage offensive casts and clean bot/server shutdown. No item-award,
group-roll, rest or armor qualification follows; no accepted Priest healing
casts were recorded. The reused Warriors were level one and consumables/armor
were not provisioned. The harness now normalizes the copied offline bots to
level 20 through the native console command (source/parser checked, not rerun).
See NEXT_MIXED_PARTY_TEST.md for the short prerequisite setup. Continue bounded
donor ports without repeating ordinary fights to qualify unexercised features;
bundle storage/roll and recovery/armor checks when the fixture is prepared.

The next bounded donor slice is now local source: an eight-entry expiring
defeated/selected corpse collection and `move to loot` at relevance 7. Short
native-pathfinding detours use the existing movement owner, time out after
ten seconds and yield to combat/commands/transfer. Rest/armor defer during
pursuit. No area scan, new scheduler or database seam was added. See the loot
packet and module PORTING.md for validation; live movement remains bundled.
Final Windows and Linux worldserver/tests-common builds each passed all 126
tests after the movement-control guard. No new client test was run for this slice.

The active-spec refresh in [the spec packet](research/SPEC_STRATEGY_REFRESH_PACKET.md)
is also local source. Warrior tank/generic and Mage Frost/generic no longer lock
to login-time spec. Existing engine sibling replacement clears obsolete work
only on route changes and preserves shared strategies; Priest remains heal
fallback, not Shadow parity. Windows and Linux built and passed all 129 tests
on each platform. Future strategy overrides need explicit precedence before expanding
this default selection policy.

The next bounded class-spell family is now local source: current-target Pummel
and Counterspell under the existing Warrior/Mage combat-engine gates. See
[the interrupt packet](research/INTERRUPT_ENGINE_PACKET.md) for donor sources,
Cata DBC evidence and native cast-state policy. Windows and Linux built and each
passed all 132 tests after build-definition refresh. Do not
claim landed interrupts, own-cast cancellation or coordinated interrupts.

The next spell batch is now local source: donor medium/high-rage Heroic Strike
and conditional Frost Ice Lance. See
[the rage/Frost packet](research/RAGE_FROST_ACTION_PACKET.md) for exact donor
ordering, Cata DBC/native aura-state mapping and intentional proc-priority
deviations. Existing contexts/gates own both actions. Windows and Linux
worldserver/tests-common each built and passed all 135 tests; no new client
session is required solely for these spells. Live resource/proc effects remain
unverified.

Priest's next support slice is now local source: the disease subset of donor
`cure`, using real Cure Disease rather than absent Cata Abolish Disease.
See [the Priest disease packet](research/PRIEST_DISEASE_PACKET.md). Existing
healing-engine gating and candidate selection are reused; native dispel lists
own disease eligibility. Magic/talent dispels are deferred. Windows and Linux
worldserver/tests-common each built and passed all 138 tests; landed cures
remain a bundled suitable-fixture check.

The disease follow-up corrects healthy-party targeting: TryInPriorityOrder
keeps all already-eligible members, while TryInHealthOrder still applies its
healing-only cutoff. Cure uses the former in trigger and execution. Windows
and Linux each passed all 141 tests.
The [healer-DPS packet](research/HEALER_DPS_PACKET.md) is now implemented in
local source: controlled GUID targeting through the existing map adapter and
real healer damage below heal/cure priorities. Shadow Word: Pain, Holy Fire,
Smite and Mind Blast retain donor order and caster-owned DoT checks. It requires
controller combat, eligible
party health >=90% and mana >=85%, and retains existing stop/follow ownership.
The first Smite slice passed all 145 tests on Windows and Linux; the action
expansion built and passed all 147 tests on both platforms. Native damage,
healing responsiveness and stationary-support follow resumption await the next
bundled check. The shared combat-value follow-up now supplies donor-style
`estimated group dps` / `estimated lifetime` and connects Shadow Word: Pain's
eight-second gate. See [the combat-value packet](research/COMBAT_VALUES_PACKET.md).
The model is bounded to supported bot roles/levels 1–80, with a donor 20-second
cache; unknown estimates skip the DoT. Windows and Linux each built and passed
all 154 tests.
The next shared slice is now local source: single-target Mage/Priest threat
guarding at the donor 80% threshold relative to a native Protection Warrior
group tank. See [the threat packet](research/THREAT_ENGINE_PACKET.md). No tank
means no throttle; support is unaffected. AoE, Warrior auto-attacks and direct
ExecuteAction are outside the guard. Windows and Linux each built and passed
all 159 tests. Bundle native behavior with the next party check.
The engaged PvE `attackers` and `balance` follow-up is now local source; see
[the balance packet](research/COMBAT_BALANCE_PACKET.md). Native threat references
feed a GUID-only list, not target selection. The Priest now uses donor-default
85/65/40 mana thresholds while retaining healing/control gates. Priority/skull/
PvP candidates and the solo bypass are unported. Windows and Linux each built
worldserver/tests-common and passed all 162 tests. The next TargetValue exclusion/
priority dependencies are mapped in the packet; port those before full DPS selection.
The bounded DPS fallback is now local source; see
[the target packet](research/DPS_TARGET_PACKET.md). Existing strategy exclusion
hooks now have an active-engine collector, with donor priority/icon values and
pure caster/general ranking. Idle Mage/Priest auto-assist can use an already-
controller-engaged target only when selected-target assist cannot proceed.
Existing commands, selected targets, active attacks and Warrior selection are
unchanged. Windows and Linux each built and passed all 167 tests. Full DPS parity,
dynamic switching, encounter-specific exclusions, Cata 81–85 profiles, wand
shooting and AoE remain ahead.
Named `dps target` / `tank target` GUIDs and Protection Warrior fallback are now
local source; see research/TANK_TARGET_PACKET.md. Windows and Linux each built
worldserver/tests-common and passed all 170 tests.
Dynamic switching, explicit main-tank coordination and broader tank roles remain ahead.
The bundled check exposed unassigned Warriors failing to resume after leash
disengagement when no selected combat target remained. Source now routes every
enabled Warrior through tank (Protection) or general DPS fallback. See the
latest NEXT_MIXED_PARTY_TEST.md note, including suitable-mob fixture requirements.
Windows and Linux each built worldserver/tests-common and passed all 171 tests.
The live session ended cleanly without this correction; verification remains
bundled with the next suitable fixture. Preserve the leash.
The next bounded tank rotation slice is local source: Devastate/Sunder,
Revenge and Sword and Board. See research/WARRIOR_TANK_ROTATION_PACKET.md.
It adds no target permissions or lifecycle work; native behavior awaits a
properly talented/equipped Protection fixture, not the unassigned level-20 party.
Windows and Linux built worldserver/tests-common; both test runs completed
successfully with 172 registered cases (Linux includes its expected-failure case).
Protection stance and defensive support are the next local slice; see
research/WARRIOR_DEFENSIVE_PACKET.md. Defensive Stance/Shield Block and the
donor 45/25 percent Shield Wall/Last Stand decisions reuse existing combat
routing and native self casting. Runtime remains bundled, not independently tested.
The final version built on Windows and Linux; Windows passed all 173 CTest cases,
and Linux completed its 173-case suite including the existing expected failure.
Arms/Fury starter strategies are now local source; see
research/WARRIOR_DPS_SPEC_PACKET.md. Native active-tree selection now covers
all three Warrior specs and retains the unassigned fallback. Mortal Strike,
Bloodthirst, Execute and combat-only stances reuse the current class context;
AoE/proc-heavy parity remains separate work. Native behavior is still pending.
Windows/Linux built worldserver/tests-common and completed their 174-case test
runs successfully (Linux includes its existing expected-failure case).
The bounded Cata action adaptation is local source: Colossus Smash for Arms/
Fury and native-Enrage Raging Blow for Fury. See
research/WARRIOR_CATA_ACTION_PACKET.md. Preserve native Sudden Death's Colossus
cooldown reset, not the donor Wrath Execute-proc route. Runtime remains pending.
Windows/Linux built worldserver/tests-common and completed their 178-case test
runs successfully (Linux includes its existing expected-failure case).
The next single-target proc-response batch is local source: Arms Overpower/
Taste for Blood and Fury Bloodsurge/Slam. See research/WARRIOR_PROC_PACKET.md.
Native target-bound reactive state and affecting spell modifiers supply
eligibility; no manual proc consumption or generic hard-cast Slam is added.
Windows/Linux built worldserver/tests-common and completed their 176-case test
runs successfully (Linux includes its existing expected-failure case).
Do not substitute native average item level for the donor mixed-gear score.

Fire/Arcane starter Mage routes and Arcane Blast/Missiles/Barrage are now local
source; see research/MAGE_SPEC_ACTION_PACKET.md. Both classes now use shared
native spec refresh for their implemented siblings. Arcane channels/procs are
native-owned. Next Fire proc work must resolve the native Hot Streak override
through the proper API, not force-cast the alternate spell. Runtime is pending.
Windows/Linux built worldserver/tests-common and completed their 180-case test
runs successfully (Linux includes its existing expected-failure case).

Fire Hot Streak override support and native-proc-metadata-gated Scorch are now
local source; see research/FIRE_PROC_OVERRIDE_PACKET.md. Shared TryCast checks
the learned base and follows the native override API, not a forced replacement.
Scorch fails closed if loaded proc metadata cannot apply Critical Mass. Native
proc behavior still needs the bundled Fire fixture. Living Bomb remains AoE work.
Windows/Linux built the final worldserver/tests-common and completed their
182-case test runs successfully (Linux includes its existing expected failure).

The static module system, imported scheduling kernel, bounded class contexts,
GUID-based active roster, authorization and whisper controls already exist.
Do not restart those ports. The latest combined build and short Ragefire check
passed. Mage opener and basic commands are operational; complete rotations,
resurrection/recovery and autonomy are still partial or absent.

The bounded native character-factory operator slice has passed its server-only
runtime batch. Do not repeat its implementation. Broader donor feature porting
can proceed after the infrastructure checkpoint; ordinary client creation and
managed MultiBot roster/lifecycle now have bundled client evidence. The current
feature-alignment packet is research/PARTY_BUFF_ENGINE_PACKET.md: existing
Mage/Priest party buffs move into the class engine, not a new subsystem.
That slice now built worldserver/tests-common and passed all 109 checks.
Runtime confirmation stays bundled with the next mixed-party/addon check.
Continue with donor class/spec, rest/loot or recovery consumers below rather
than another foundation rewrite; preserve the documented behavior ownership.
An isolated full donor addon candidate and reproducible compatibility patch
now exist under the module's addons/MultiBot handoff. Interface 40300, older
roster events and MBOT prefix registration are adapted; modified Lua passes
Lua 5.1 syntax and the real donor Comm module passes mocked channel/registration
checks. The Windows client now confirms clean startup and basic Stay, Follow
and main Attack; this is not confirmation of every donor feature.
Only implemented managed roster/lifecycle capabilities are now advertised when
player lifecycle access is enabled; each request still rechecks permission.
The Windows client candidate is staged without overwriting an existing addon.
Linux portability is server-only; client Linux support is out of scope.
Managed My Bots roster and native connect/disconnect/reconnect passed the
ordinary linked-player check.
Keep WotLK talent/spec data and other feature ports separate. The main Attack
path reached the server; requests outside its temporary 25-yard bot/controller
target gate were rejected, and engagement worked after approaching the target.
Client startup fixes now cover library load order and Cata macro-icon enumeration.
The expanded Lua mock also validates donor roster decoding/sender filtering and
pending-to-completed lifecycle responses. It captures timers and does not prove
native timing. Portable CMake/CTest and relative Git/Lua entry points are now
documented; PowerShell helpers are optional local conveniences. Add a clean
Linux build of the matching core/module pair at a publication checkpoint;
do not describe Windows-only build evidence as cross-platform validation.
Basic gameplay requests now use MultiBot's actual whisper/party/raid path,
not a new addon opcode. Shared parsing routes follow/stay/hold/attack/stop/cease
through existing per-bot control checks, preserving raid subgroup boundaries.
Do not map these onto COMBAT/POSITION: donor COMBAT changes strategies and
POSITION changes disperse. Those behaviors remain later feature ports.
The refreshed addon donor is `1eac0d9106b8cdf0a79da3974ee1f516f8ca3fbc`;
use it instead of the older local addon snapshot for client work. Current
upstream source does not register the MBOT prefix; the compatibility patch
does; client loading and basic chat controls are now confirmed. The exact donor main
attack command `do attack my target` is also accepted server-side now; role
filters remain unsupported.
Initial default-off Cata HELLO/PING/live ROSTER transport is now in source.
Managed connect/disconnect/status requests now call the managed player service;
their receipt mapping preserves queued versus completed outcomes. Mutation
tokens and rate/storage limits are bounded. Only ALT_ROSTER_V1 and
BOT_LIFECYCLE_V1 are advertised when the player service is enabled; other
capabilities remain absent. Managed ALT_ROSTER discovery
is now framed and bounded using the donor schema, current account-link
authorization, native receipts and roster-query rate limiting.
It uses native prefix framing, world-thread routing and existing full-control
authorization. The patched donor addon has now been live-tested for startup
and basic controls, followed by the bundled managed lifecycle check. This is not
proof of unsupported endpoints or every donor UI feature.
Managed player authorization now has a default-off service using explicit
trusted account links and existing party control. The native addon transport
now calls it; an ordinary explicitly linked player completed the live lifecycle
check. Negative authorization coverage remains source/headless evidence, not
an exhaustive live permission matrix.
An initial configured
existing-character roster and console connect/disconnect path are in source;
the earlier combined build and 67 automated checks passed. The latest slice
adds per-session lifecycle receipts and the managed player service; the combined
worldserver build and all 88 automated checks passed, including lifecycle,
account-link/policy, addon parser, lifecycle replay/rate and roster framing,
presence, truncation, amplification-limit, basic chat/subgroup and exact
managed-capability advertisement regressions.
A later integrated runtime check still needs
to exercise that configured admission path.
Account/character creation follows the manager contract; extensive class
polish is not a gate.
Preserve native account/session ownership and keep runtime admission default-off.

## Source and repository contract

- Core and Playerbots are separate repositories; AHBot is a third optional repo.
  Modules live at `modules/mod-playerbots` and `modules/mod-ahbot`. The core
  README records the matching module pins. An arbitrary core/module pair is
  not assumed compatible.
- Before editing, inspect status and the actual source. Preserve unrelated work.
  The build checkout and publication checkout may have different histories;
  transfer reviewed changes onto the existing publication branch without
  force-pushing private development history.
- Check upstream donor default-branch HEAD, record its immutable commit and
  inspect the relevant source/consumers. The previous local donor includes five
  custom additions described in the roadmap; distinguish these from upstream.
- Use Cata spell/talent/packet APIs and data, retain source notices and document
  deviations. Read donor guidance relevant to the files being ported.
- No production/runtime data is needed in a source handoff. Supply the core and
  module revisions, required pending diffs, donor files and a clear editable scope.

## Existing seams to extend

All module paths below are relative to `modules/mod-playerbots`.

| Source | Responsibility |
|---|---|
| `src/Bot/PlayerbotRoster.{h,cpp}` | Online controllable roster; currently no persistent/offline identities |
| `src/Bot/PlayerbotManagedRoster.{h,cpp}` | Configured offline identities, latest receipts and directional account links; no creation or auto-login |
| `src/Bot/Cmd/PlayerbotManagedControl.{h,cpp}` | Authorized offline list and native start/stop with receipts, called by MultiBot transport |
| `src/Mgr/Security/PlayerbotManagedSecurity.h` | Server-derived account-link/faction/party policy facts; never trust addon-supplied facts |
| `src/Bot/Cmd/PlayerbotControl.{h,cpp}` | World-thread resolve/authorize/queue boundary for normal controls |
| `src/Mgr/Security/PlayerbotSecurity.{h,cpp}` | Invitation and full-control relationship; current party controller plus GM override |
| `src/Script/PlayerbotChatCommands.cpp` | Ordinary whisper transport; addon messages deliberately not handled here |
| `src/Bot/PlayerbotSessionBehavior.{h,cpp}` | Queued requests and map/world behavior; per-bot AI lifetime |
| `src/Bot/Engine/`, `src/Ai/Class/` | Imported scheduler and partial class contexts; extend instead of another decision loop |
| Core `World::{FindServerOriginPlayerbot,GetServerOriginPlayerbotSessions}` | Borrowed active-session lookup on world thread |
| Core `World::TryStartServerOriginPlayerbot` and `WorldSession` | General native admission/save/logout; dev slots remain callers |

A command reply saying "requested" acknowledges queuing, not successful casting
or completed transfer. Native admission receipts now expose loading, online,
exit pending and terminal closure/failure states. They track only the latest
attempt in memory, without guaranteeing asynchronous database commit success.
Whisper `stop`/`cease` ceases combat; it does not disconnect the
character. Console `managed stop GUID` instead queues native logout/save.

## A. Managed existing-character roster/lifecycle — in progress

Donor basis: PlayerbotMgr, RandomPlayerbotMgr ownership/selection, relevant
PlayerbotSecurity relationships, and their login/logout callers. Inspect exact
paths at the selected donor revision before designing the reduced Cata port.

Scope:
- Configured identity and console list/start/stop are implemented separately
  from four numbered development slots. Reuse existing characters first.
- Session-owned receipts now report native login completion, failed loads,
  stop pending, session closure and shutdown. Retain this contract in later
  request-ID/response mapping; a normal command acknowledgment is not completion.
- Separate managed account ownership from temporary party control. Preserve
  eligible human invitations; group membership alone is not full authorization.
- The new player lifecycle service uses default-off AllowPlayerControl plus
  bounded directional AccountLinks. Normal users require links/same faction;
  stop/list of grouped bots also uses existing full party control. Keep settings
  reload revocation and GM/native-identity boundaries in the transport mapping.
- Route later player/addon connect/disconnect through the same world-owned
  native admission, async loading and logout/save path after permission checks.
- Keep one active character per account for this slice. Reject duplicates,
  conflicting human sessions and stale/ineligible characters.
- Keep the current development fixture usable until the replacement is operational.

Useful acceptance: an existing managed character can be listed offline, admitted,
listed online, disconnected/saved and admitted again; duplicate and unauthorized
requests fail without replacing a human session. Run a combined build and the
relevant headless lifecycle checks. Add focused regression coverage for changed
ownership/state transitions, not a new test for every accessor.

## B. Cata MultiBot contract and initial bridge

Donor basis: current upstream MultiBot Chatless addon and mod-multibot-bridge,
including HELLO/HELLO_ACK, capability negotiation and command responses.

Map message fields, bounds, authorization, response semantics and Cata client
API differences. Implement a module-owned transport over the existing roster,
security and control services. Start with handshake, supported capabilities,
online roster and follow/hold/attack/cease. Existing online controls do not need
to wait for all of A; connect/disconnect depends on A.

Reuse the addon implementation where compatible. Do not advertise WotLK item,
bank, quest, talent or provisioning endpoints before their services exist.
A narrow optional core hook is acceptable where the native scripting surface
cannot route addon traffic. Keep gameplay out of that hook.

Acceptance: malformed/unauthorized requests have bounded failure behavior;
capabilities describe real handlers; responses distinguish queued and completed
operations. Batch the initial addon interaction with the next useful party check.

## C. Account/character factory

Start with the [native factory execution packet](research/NATIVE_CHARACTER_FACTORY_PACKET.md).
Upstream master was rechecked on 2026-09-30 and still matches the recorded
factory donor. Its bulk deletion, queue-draining waits and direct cache-after-save
sequence are not appropriate to copy into this runtime slice.
The initial factory now has a console-only read-only Cata appearance draft and
bounded selection helper. Continue from that owner, not a second factory.
The appearance preview does not certify eligibility to create; the console
factory separately verifies persisted dedication and native account identity.
The core now has a typed native creation entry point with a per-attempt outcome
receipt, shared by normal client creation and the console factory.
The dedicated world-owned context is now present, bounded and outside normal
session admission, with account reservations and no account-online lifecycle writes.
Validate persistent module account/reuse evidence and rerun recovery without
pretending a client login or reusing an admitted bot session. Include ordinary
client creation in the next combined disposable factory/lifecycle check.
The typed native seam passed the combined worldserver build and all 95 tests;
two new cases cover terminal receipt identity/rejection and abandonment.
The separate provisioning-context slice built worldserver/authserver and passed
all 97 tests, including bounded account reservation and account-profile policy.
Native context creation and accounting recovery now have disposable runtime
evidence from the completed server-only factory batch described below.
Provisioning contexts now await authoritative realm-count reconciliation and
return a read-only outcome view. Accounting failure does not expose a ready GUID.
Module ownership/reuse helpers require verified evidence and exact native
identity. Do not treat passing helper tests as a runtime-proven provisioning flow.
The ownership-reader slice adds a manual optional auth schema and default-off
console `managed inspect` diagnostic. It validates stored evidence against the
native account and character identity without writes or admission. It built both
executables and passed all 105 tests.
The later operator slice now implements explicit console enrollment of existing
empty accounts, native submission, accounting-only exact reuse recovery and
per-account status. It defaults off, keeps 16 account histories, rejects pending
overlap, confirms enrollment commits/actual evidence and does not auto-admit or
grant player control. Both executables/tests-common built and all 106 tests passed.
The bundled disposable server run now passed absent-schema rejection, manual
schema application, enrollment/eligibility gates, native creation, exact reuse
and deliberately stale realm-count repair, conflicting intent rejection, managed
login/save/logout and clean shutdown. The missing-schema case exposed a fatal
core SQL error; module metadata preflight now rejects before querying the absent
table. Do not weaken the core SQL handler. See module sql/README.md and PORTING.md.
Next bundle ordinary client creation with addon-managed roster/connect/disconnect;
those client paths remain unverified. Broader factory behavior can build on this
bounded operator slice without repeating each passing server case in isolation.
The accounting/ownership slice built worldserver, authserver and tests-common
with both modules enabled and passed all 103 automated tests. Its six new cases
cover receipt transitions and ownership/reuse policy, not live persistence.
The earlier appearance-only slice passed the combined worldserver build and all
93 automated tests.
Native appearance validation and provisioning were exercised by the server-only
factory batch; ordinary client creation and gameplay remain separate checks.

After A's identity/ownership contract, adapt RandomPlayerbotFactory and
PlayerbotFactory through native account/character creation, save, cache and
realm-count updates. Reuse previously created managed identities on rerun.
Preserve Cata class/race/spell/gear constraints; do not clone raw character rows.

Acceptance: a small configured batch can be created, reused and admitted through
A, without duplicate identities or changes to unrelated accounts. No autonomous
mass population or automatic cleanup/deletion belongs in this first batch.

## Subsequent batches

- Extend donor class/spec, rest, loot and recovery actions with Cata data. Keep
  generic fallback behavior explicit. No separate client session per spell.
- Add state/event coverage as concrete donor consumers require it; preserve one
  active decision owner and map/world lifetime rules.
- Integrate the roadmap's local WotLK fixes with their owning feature families.
- Adapt RandomPlayerbotMgr for a bounded autonomous login/logout pilot after
  A/C. Add shared activity reservations before competing optional consumers.
- Expand dungeon and addon feature families after their backing services work.

## Build and finish a batch

Before a substantial port, write a short execution packet with:

- **Result and scope:** the capability, affected subsystem and editable files.
- **Source basis:** actual core/module revisions and pending diffs; donor commit,
  exact files/symbols and relevant consumers; secondary references separately.
- **Existing owner:** the service/strategy being extended, its callers and the
  fallback being retained, gated or retired. Do not add a competing owner.
- **Cata invariants:** native API/data differences, thread/lifetime boundaries,
  authorization, default-off gates and module-off behavior where affected.
- **Non-goals:** feature families, compatibility surfaces and polish excluded.
- **Acceptance:** bounded source/build/regression checks and, only when useful,
  one integrated runtime scenario; distinguish each kind of evidence.
- **Stop/escalate:** unresolved ownership, a required wider core hook, ambiguous
  source rights, destructive migration, or new external authority. Routine Cata
  API adaptations within the packet do not require a new planning round.

The implementer should be able to proceed from that packet without recreating
the design. Review it again when evidence changes its assumptions, not after
every accessor or spell addition.

Use the existing configured build tree and installed toolchain. For the Windows
Visual Studio tree, `contrib/local/build-local.ps1` normalizes child PATH entries:

From a PowerShell 7 session in the core root:

```powershell
./contrib/local/build-local.ps1 -Targets @('worldserver','tests-common') -RunTests
```

Use `-Configure` when new files/build registrations need discovery. This helper
expects a configured Visual Studio build tree; other platforms use their normal
CMake build/test commands. It is not a toolchain installer.

Report changed behavior, donor basis, compile/test outcome, known limitations
and the next dependency. Build once per coherent batch, adding checks only when
new failures or affected boundaries justify them. Commit at meaningful milestones;
do not push every intermediate edit. The next client check should exercise a
useful integrated capability.

## Earlier development history


Current checkpoint (2026-09-29): a disposable mixed-party client session reached
Ragefire with four bots, logged 13 accepted Mage offensive casts, six Priest
healing casts and one Fortitude cast, and shut down cleanly. The player reported
good overall behavior and basic whisper control. This establishes an operational
low-level party, not complete rotations, tanking, death recovery or autonomous
play. Playerbots remains default-off. The dated sections below retain their
historical implementation and test status, including earlier failed runs.

Current sequencing and implementation task allocation are in
[`PLAYERBOTS_PORT_ROADMAP.md`](PLAYERBOTS_PORT_ROADMAP.md), with concrete handoff
contracts in [`PLAYERBOTS_WORK_PACKETS.md`](PLAYERBOTS_WORK_PACKETS.md).
That roadmap supersedes older next-step ordering below. Earlier sections retain
historical design and validation states; they are not all descriptions of the
current implementation.

The optional module foundation has extracted companion behavior/state,
class helpers and development commands into `modules/mod-playerbots`, with
module-owned configuration and tests. Native session ownership, admission and
shutdown hooks remain in core. The upstream Engine/context port is partial;
packaging does not itself establish full parity. See
`modules/mod-playerbots/README.md` for build/config controls and
`PLAYERBOTS_MODULE_VALIDATION.md` for verification evidence.

## What is established

- Client/core target: Cataclysm 4.3.4.15595, upstream baseline `9da95e6cc9c2`.
- A clean native build and isolated real-client login, character creation,
  movement persistence, and logout succeeded. See `../core/VALIDATION.md`.
- The common-test target now builds and includes navigation-loader regression
  coverage. Remaining baseline warnings are triaged in `../core/CLEANUP.md`.
- Development tests use disposable fixtures; deployed databases and source
  donor checkouts are separate inputs.

## First engineering hurdle: a player without a game-client socket

The current source is not already a server-side Playerbots host:

- `WorldSession` can be constructed with a null socket, but its world-session
  update path returns false when the realm socket is absent. That removes the
  session. Merely constructing a Player and attaching AI will not solve this.
- The normal login path checks account/character ownership, loads characters
  through an asynchronous `LoginQueryHolder`, initializes session/player state,
  and routes client packets. A bot needs an explicit lifecycle integration that
  preserves those checks, not a shortcut around them.
- `PlayerAI` and `SimpleCharmedPlayerAI` contain useful Cata-specific helpers,
  but charm AI is not a bot-account/login/group/command system.
- `src/server/scripts/Custom/custom_script_loader.cpp` is currently empty. It
  can host dev commands later, but script registration alone does not address
  session removal and packet routing.

Relevant entry points:

| Concern | Current source |
| --- | --- |
| Session lifetime and socket removal | `src/server/game/Server/WorldSession.cpp` |
| Account-bound character loading | `src/server/game/Handlers/CharacterHandler.cpp` |
| Session insertion/update ownership | `src/server/game/World/World.cpp` |
| Cata player AI and spell validation helpers | `src/server/game/AI/PlayerAI/PlayerAI.h` |
| AI update/ownership | `src/server/game/Entities/Unit/Unit.cpp` |
| Navigation and following foundation | `src/common/Collision/Management/MMapManager.cpp` and movement code |

The local WOTLK `mod-playerbots` checkout (inspected at `89f7da90`, origin
`https://github.com/mod-playerbots/mod-playerbots.git`) is a reference for bot
holders, asynchronous login, packet handling, and logout. Its current local
files are not assumed pristine, and its AzerothCore interfaces must not be
copied into Cata unchanged. No WOTLK files were modified.

## Proposed milestone PB-00: one idle bot with a complete lifecycle

Keep this smaller than a combat or leveling bot.

Current local prototype: after explicitly setting `Playerbots.Dev.Enabled = 1`,
`Playerbots.Dev.AccountId`, and `Playerbots.Dev.CharacterGuid` for an isolated
ordinary-player account with an offline Warrior, an authorized console
operator can use `.server playerbotdev start`, `status`, and `stop`. These are
manual development controls, not an automatic population system. An isolated
one-Warrior positive-path test passed login, a 125-second idle hold,
save/logout to offline state, and normal worldserver shutdown on 2026-09-23.
Feature-off, unknown-character, wrong-account, wrong-class, banned-account,
already-online, duplicate-bot, interrupted-loading, drain-timeout, and saved
level persistence checks also passed. While the feature is enabled, the
dedicated account is now rejected during authenticated client admission before
a client `WorldSession` is allocated. A real 4.3.4.15595 client collision
replay confirmed that rejection while the bot remained in-world. Normal
shutdown allows up to 30 seconds to drain the bot;
force/exit/process termination does not.

1. Add an explicit, default-off development feature and bot-session identity.
   Do not globally keep every disconnected/null-socket human session alive.
2. Allow a GM/console command to load one pre-created, allowlisted test character
   owned by a dedicated test account. Reject foreign characters and duplicate
   human/bot login attempts. Do not expose raw SQL or shell commands.
3. Reuse the character-loading checks and asynchronous database flow. Give
   bot-only outbound packets an explicit destination/handling policy without
   suppressing errors for normal client sessions.
4. Keep the character alive across normal world updates for at least two
   minutes, with no game client connected for that character.
5. Save and log out cleanly; cover server shutdown and interrupted loading too.
   Prove the session, Player, AI, and pending callbacks have clear owners.

Acceptance checks: feature-off behavior unchanged; one bot limit enforced;
wrong-account GUID rejected; duplicate login rejected; idle bot survives; save
and logout complete; no crash or dangling callback on teardown. Use only the
isolated Cata database/ports for runtime verification.

See `PLAYERBOTS_LIFECYCLE_VALIDATION.md` for the test sequence,
evidence directory, map-530 shutdown fix, and remaining decision gates.

## Subsequent milestones

- **PB-01 Follow/stop:** follow an authorized owner on one known-good starting
  map, then stop immediately on command or owner logout. Log path failures;
  do not compensate by teleporting or disabling collision checks.
- **PB-02 Single-class combat:** one class, auto-attack, and a small reviewed
  spell set. Respect known spells, target legality, range, line of sight, power,
  cooldowns, death, and crowd control. No raids or all-class rotations yet.
- **PB-03 Capability catalog:** pin Cata spell/talent data, generate reviewed
  action proposals offline, and add deterministic tests/replays before enabling
  additional capabilities.
- **PB-04 Addon control contract:** replace the development console-only surface
  with an authenticated, versioned, capability-negotiated addon-message bridge.
  Begin with bot discovery/status plus the already proven start/stop,
  follow/hold, and attack/cease controls. Keep authorization and action
  validation server-side; do not expose an arbitrary command executor.
- **PB-05 Cata control addon:** port the WOTLK MultiBot control experience to a
  separate Cataclysm 4.3.4 addon only after PB-04 is stable. Treat the existing
  WOTLK addon and its `MBOT` bridge as behavioral/protocol references, not as a
  drop-in client. Selectively adapt useful PlayerBotManager roster, gear, spec,
  strategy, and raid-planning views after their corresponding server
  capabilities exist.

LLMs can help author code, data proposals, tests, dialogue, and plans. Runtime
combat actions remain deterministic and validated by the core. Player chat,
model text, and arbitrary spell IDs must not become unrestricted commands.

### PB-04/PB-05 addon-control boundary

Two WotLK addon designs were evaluated as control-interface references:

- `MultiBot` is the broad live-control UI. Its current fork targets interface
  30300 and prefers structured addon messages through a companion bridge with
  explicit capabilities such as `BOT_LIFECYCLE_V1`, while retaining a limited
  set of legacy chat-command paths.
- `PlayerBotManager` is the roster/gear/spec/strategy/raid-management UI. It
  also targets interface 30300, and its current command layer sends party,
  raid, whisper, and admin commands through chat.

The Cata work should therefore port the user workflows, not copy either addon
wholesale. Build the server-side PB-04 contract first, then create a separate
interface-40300 client addon that negotiates only implemented capabilities and
disables unsupported controls. Audit Cataclysm API changes, talents/specs,
classes, spell and item data, roster discovery, equipment slots, saved-variable
migrations, and licensing/provenance before adapting each feature family.

Initial PB-05 acceptance is intentionally small: the addon loads without Lua
errors on the 4.3.4.15595 client, discovers only authorized bots, shows
authoritative online/control state, and can invoke start/stop, follow/hold, and
attack/cease through PB-04 without automated SAY/WHISPER command traffic. It
must time out cleanly when the bridge or a capability is unavailable. Advanced
inventory, talents, professions, quests, formations, raid tools, and bulk bot
population controls remain deferred until their server behavior exists and has
its own deterministic tests.

Use a separate Cata addon project and explicit server capability discovery.
Do not assume that friends-list roster scanning provides an authoritative bot
roster; validate discovery and authorization through the server API.

### PB-01 local follow prototype

With the PB-00 bot in-world and a human character on the same map, enter
`server playerbotdev follow <human character GUID>` in the worldserver console.
`server playerbotdev hold` stops the movement; `status` reports the active
follow GUID or holding state. Commands are console-only. The map update rejects
an absent, dead, or bot target, and holds if the owner logs out, changes map,
or dies. No teleport or combat behavior is added. The command acknowledges a
request; the map-thread log reports acceptance or rejection on the next tick.
The 2026-09-24 local live-client check covered follow/hold/resume commands,
human logout, and automatic hold. The user reported that the in-client behavior
looked good; see
`PLAYERBOTS_LIFECYCLE_VALIDATION.md`.
This uses the core's existing follow generator; route/path-failure diagnostics
are not implemented yet, and the first live check used clear terrain. A later
follow-only replay sampled both characters once per second around the test player's
pillar/stairs route: the largest sampled center-to-center gap was about 9 yards
for one second on the stairs, then it closed. When the owner stopped, the bot
went to a point about 3 yards away, consistent with the configured forward
follow offset and the repeated waypoint-like destination; that offset is now
2 yards behind.
No corrupt map geometry or failed 35-yard combat leash was demonstrated.

### PB-02 controlled Warrior auto-attack prototype

While the bot is following an in-world human, the worldserver console accepts
`server playerbotdev attack`. On the map thread it checks that the human's
selected target is a nearby hostile, non-player-controlled creature with line
of sight. Only then does the Warrior enter the core's ordinary melee auto-swing
and chase. `server playerbotdev cease` stops its attack/chase and resumes
following. `hold` and a new `follow` request also cease combat. The bot ceases
if the target dies, becomes invalid, or exceeds a short leash from the owner.
While engaged, a Warrior evaluates a small priority list once per second:
Victory Rush when its proc is active (level 5), Rend when its applied debuff
is missing (level 7), then Strike (level 1). The core still checks known spells,
range, line of sight, facing, power, and cooldowns; auto-swings continue when
none is castable. This adapts the WotLK Playerbots trigger/action priority
pattern, not its full engine. While following,
the bot also assists the owner's selected hostile creature once the owner is
in combat with it, subject to the same entry checks and 25-yard range. A
manual `cease` disarms auto-assist until a new `follow` request. There is no
independent target search, PvP, a broader class rotation, loot,
or threat policy yet. This is a narrow local prototype, not a complete PB-02
milestone. The 2026-09-24 live-client checks confirmed engagement, cease-fire,
and core acceptance of a Strike cast against a Mana Wyrm. A landed Strike hit
or damage was not independently verified. The target-death stop was verified
in a second live-client run; leash and invalid-target paths remain untested
live, and follow movement after the kill was not independently confirmed. A
later attack-entry rejection was traced to the selected creature being about
35 yards from the owner and 36 yards from the bot, beyond the 25-yard entry
limit; it was not a target-legality or line-of-sight failure.

The 2026-09-24 live-client auto-assist run confirmed Testone joined the
owner's Mana Wyrm fight without a console attack request. The server recorded
Strike, target death, and cease/return-to-follow; the user confirmed the
behavior in game. The disposable realm shut down cleanly. See the validation
log for the retained evidence directory.

The first live-client run with the priority list exposed a pre-existing
`ChaseMovementGenerator::DoMovementInform` null dereference when player-bot
chase arrived: its creature guard was inverted. The callback now safely runs
only for creatures. After rebuilding, a fresh play replay recorded three
auto-assist engagements, two Strike casts, target-death stops, and return to
follow, with clean worldserver/MySQL shutdown. Victory Rush and Rend were
checked against pinned Cata data. A later level-7 play session on a cloned
fixture confirmed both were known and logged successful cast starts: Rend and
Strike in several fights, and Victory Rush before Rend and Strike in two
later fights. The original level-1 fixture was not changed; the level-7
character and trained spells existed only in that disposable clone.

The next code-only pass moved the ordered trigger/action evaluator and common
spell-cast checks into `PlayerbotCombatDecision`, and the Cata Warrior
conditions and priority list into `PlayerbotWarriorStrategy`. `WorldSession`
still owns admission, follow/assist target and leash, and the one-second
decision tick; it no longer contains Warrior spell IDs or cast construction.
The `RelWithDebInfo` worldserver build passed after regenerating CMake. The
2026-09-25 level-20 play sessions replayed this extracted decision layer;
the level-7 evidence above predates it.

The read-only `contrib/local/playerbot-warrior-capabilities.ps1` check now
pins the early Warrior spell IDs, levels, class masks, and acquisition data
against the installed 4.3.4 DBCs. It verifies Strike (1), Charge (3),
Victory Rush (5), Rend (7), Thunder Clap (9), Heroic Strike (14), and Battle
Shout (20), including Rend's cast-spell-to-periodic-aura link (772 to 94009).
Strike, Victory Rush, and Rend are live-tested in the prototype. A later
source-only pass added an explicit self-target action mode and Battle Shout
when the engaged Warrior lacks its own 6673 aura. The pinned data shows the
6673 cast has a self trigger (92049) and two party aura effects. This action
is evaluated only on the existing engaged-melee tick; it does not add
out-of-combat buffing. The 2026-09-25 level-20 live-client replay recorded
Battle Shout cast starts, and the player confirmed the buff appeared. A
second diagnostic replay recorded Battle Shout, Rend, Strike, and repeated
target-death returns to follow with good reported behavior. The first replay
also had one stationary combat engagement before a working second fight; its
cause was not established, and it did not recur in the second replay. Charge,
Thunder Clap, and Heroic Strike remain port candidates requiring movement/entry, area-effect,
and resource/attack-semantics review respectively. The DBC check is
source-side evidence only; it does not replay combat or confirm actions in
game.

The priority/fallback loop is now isolated from spell execution and covered
by three `tests-common` cases: inactive actions are skipped, a failed attempt
falls through in order, and evaluation stops after the first success. All
three passed (five assertions), and the `RelWithDebInfo` worldserver build
linked afterward. These are deterministic selection tests, not spell-cast or
client-behavior tests.

The next PB-02 slice reuses the core-checked spell attempt for a 2-second
out-of-combat Battle Shout check while the Warrior is following. It casts only
when the bot knows 6673 and lacks its aura; the existing combat priority is
unchanged. The `RelWithDebInfo` worldserver build and 20/20 CTest cases passed;
the 2026-09-25 level-20 disposable replay then recorded Battle Shout immediately
after follow and before the first auto-assist engagement. The player confirmed
the buff in the client; one engagement and clean worldserver/MySQL shutdown
followed. Evidence is in `build/playerbot-smoke-20260925-011614`.

The original dungeon-facing prototype accepted an ordinary party invitation only
when its leader is the human player the bot is already following on the same
map. It reuses the core's normal invite-accept handler and does not enable
unrelated invitations, additional bots, or dungeon navigation. The
`RelWithDebInfo` worldserver build and 20/20 CTest cases passed. A 2026-09-25 disposable replay in
`build/playerbot-smoke-20260925-012416` recorded `Testone joined Test's party`,
then an auto-assist engagement and clean shutdown. The server-side invitation
path passed, and the player confirmed the party frame and behavior in the client.

The 2026-09-26 invitation revision removes that preassigned-owner restriction.
Following mod-playerbots' `AcceptInvitationAction`, an ungrouped development bot
accepts a valid human-led invitation through the core handler, adopts that
human as controller, and requests follow when both are alive on the same map.
Invalid invitations are declined through the core handler rather than left
pending. Core party restrictions remain; full PlayerbotSecurity is not ported.
The mixed-party harness does not prebind follow before invitations, and revives
the saved roster through the native command before starting the test. Runtime
confirmation of this revision is pending.

For a first dungeon-entry proof, `server playerbotdev joininstance <map ID>`
requests a console-only transfer after the human-led party has bound that
non-raid dungeon. The bot validates that it is alive, out of combat, and still
grouped under its previously followed leader. It uses the configured map
entrance and normal `Player::TeleportTo`/worldport-ack path, then requests
follow again in the destination map. A short-lived remembered leader GUID
allows the same owner's invitation to be accepted even if the owner changed
maps before inviting; explicit hold or a failed new follow clears that memory.

The first disposable test (`build/playerbot-smoke-20260925-013921`) did not
enter a dungeon: a long coordinate command placed the human high on the
outdoor map, and the bot correctly rejected an unbound instance request. A
second run (`build/playerbot-smoke-20260925-014742`) reached the named
teleport before the party invite; it exposed the order-sensitive invitation
check and shut down without a dungeon transfer. The harness now uses the
short `.tele RagefireChasm` command, waits for a real party instance bind,
and accepts a late invitation from the same followed leader.

The 2026-09-25 successful replay in
`build/playerbot-smoke-20260925-015556` recorded party join, target-map
transfer to Ragefire Chasm (map 389, instance 1), resumed follow, and clean
bot/worldserver/MySQL shutdown. The player confirmed Testone appeared in the
dungeon and followed. This verifies one-bot entry and regroup, not dungeon
combat, survival, route planning, or general multi-bot support.

A follow-up disposable replay in `build/playerbot-smoke-20260925-020423`
recorded Testone joining the party, entering the same Ragefire Chasm
instance, auto-assisting against a Molten Elemental, and starting Rend and
Strike casts there. The player reported that the in-game behavior worked;
both characters later died. The bot, worldserver, and cloned MySQL shut down
cleanly. This verifies dungeon entry plus a combat engagement, not dungeon
survival, death recovery, route planning, or repeatability across dungeons.

A second explicit bot slot is available through default-zero
`Playerbots.Dev.AccountId2` and `Playerbots.Dev.CharacterGuid2`, with matching
console-only `start2`, `stop2`, `status2`, `follow2`, `hold2`, `attack2`,
`cease2`, and `joininstance2` controls. Two more default-zero slots use the
same `AccountId3`/`CharacterGuid3` and `AccountId4`/`CharacterGuid4` pattern;
the console-only `server playerbotdev slot <1-4> <action> [argument]` command
controls all four. Every account and character GUID must be distinct; no slot
admits a GM, banned account, online character, or a class without a bot
strategy (currently anything except Warrior, Mage, and Priest). All configured
dedicated accounts are reserved against client login while the feature is
enabled. This is a fixed full-party development path, not a general bot
population manager.

The isolated `build/playerbot-smoke-20260925-021701` run logged both Warriors
in simultaneously, stopped and restarted the second without disturbing the
first, and drained both during normal shutdown. The `RelWithDebInfo`
worldserver build and 20/20 CTest cases passed. That early two-bot run did
not yet cover party invitations, simultaneous combat, or dungeon entry; the
four-bot replay below later covered those paths.

For the four-bot replay, the isolated harness uses the core's `pdump`
write/load commands to make three disposable Warrior imports with new
accounts/GUIDs, then starts all four sessions. That preparation exposed an
older PlayerDump null-field bug: its importer changed a quoted `nullptr`
placeholder into the bare token `nullptr`, which MySQL rejected and caused a
worldserver assertion. The narrow repair converts that placeholder to SQL
`NULL` after dump field rewriting. The fresh-clone replay
`build/playerbot-smoke-20260925-093255` completed three imports and admitted
all four Warriors. The client did not log in before that run's ten-minute
window elapsed; its test-owned processes shut down cleanly.

The follow-up client replay in `build/playerbot-smoke-20260925-094634` reused
the stopped fixture. Testone, Testtwo, Testthree, and Testfour all followed
the human Test, accepted party invitations, and entered the same Ragefire
Chasm instance (map 389, instance 1). All four auto-assisted a Molten
Elemental and an Earthborer, with Rend and Strike cast starts recorded.
Testone then died and ceased attack/held; the other three continued combat.
When Test died, all three surviving bots held. The player confirmed the logs
matched the visible behavior. Human and bot logouts, worldserver exit, and
cloned MySQL shutdown completed cleanly. This proves one full-party encounter
and death transitions, not resurrection/recovery, a dungeon clear, class-role
coverage, or reliable navigation across dungeons.

Playerbots architecture direction: the four explicit slots and console
commands are a lifecycle/test harness, not the desired gameplay design. Keep
the Cata core changes to socketless session, admission, and safe lifecycle
hooks; move follow formation, party interaction, and later class/role behavior
into bot strategies/actions modeled on the local WOTLK `mod-playerbots`.
Source examples: `Formations.cpp` computes per-bot angles from the group
roster, and `AcceptInvitationAction.cpp` accepts the invite, changes to follow
strategy, then optionally sends the master a configurable greeting. Adapt
those responsibilities to Cata APIs rather than copying WOTLK code blindly.
The client-visible polish observed in the full-party pass is therefore real
Playerbots work. The 2026-09-25 client replay confirmed four distinct follow
positions after party join and one hello whisper per bot. The player then
pointed out that spacing must begin on attachment, not party join. The
follow-up source change now derives formation slots from same-map bots
attached to the same owner, whether or not they have joined a party; this
specific pre-invite revision is built and unit-tested, not yet client-tested.

The same batch adapts two other local WOTLK Playerbots movement ideas to Cata:
long-gap follow switches at 18 yards to a path-generating point move and
returns to normal follow within 12 yards, while melee Warriors chase behind
a target unless they have aggro, when they take a front/tank position. Cata's
native `MoveFollow` and `MovePoint` use different movement generators, so
this is an adapter, not a copied WOTLK pathing implementation. The original
pillar/navmesh bounce and these new dynamic behaviors still need a later
in-game observation; a successful compile is not navigation proof.

The next mixed-role source batch broadens the allowlisted bot classes from
Warrior-only to Warrior, Mage, and Priest without weakening account, offline,
security, or duplicate-session admission checks. Mage uses the shared Cata
cast validator for a small Frostbolt/Fireball ranged priority with Fire Blast
and Frost Nova under close pressure. Priest scans the attached owner and its
shared same-map party in lowest-health-first order, excluding unreachable
members and duplicate candidates. It selects Shield, Flash Heal, Heal, or
Renew by severity, tries another injured member if no cast is accepted, and
stops after one accepted cast. Automated tests cover health ordering, failed
cast fallback, equal-health ties, empty candidates, and invalid health values.
The pinned 4.3.4 DBC confirms
these spell IDs, Mage/Priest class masks, and early trainer levels. These are
initial roles, not WOTLK-equivalent talent builds, threat control, kiting, or
complete healing. No mixed-role client behavior is claimed yet.

Remote follow-up adds out-of-combat Fortitude (21562) and Arcane Brilliance
(1459) upkeep for self, attached owner, and their shared reachable party.
The core's generic buff script converts these casts into single/party auras
79104/79105 and 79057/79058 respectively; upkeep checks both variants rather
than the dummy cast ID. `contrib/local/playerbot-caster-buffs.ps1` verifies
their Cata levels, class masks, and effect mappings without starting a realm.
These buffs and the mixed-role combat still need client validation.

Rotation development must use the bot's active talent tree, learned spells,
and current proc/resource state, not class alone. Cata exposes
`GetPrimaryTalentTree(GetActiveSpec())`; `PlayerAI::GetPlayerSpec` resolves its
TalentTab order but returns zero for an unset tree too. Preserve an explicit
unspecialized fallback instead of silently assigning the first spec. The next
profiles should separate Arcane/Fire/Frost Mage, Discipline/Holy/Shadow Priest,
and Arms/Fury/Protection Warrior priorities. Armor selection, role selection,
and signature/proc actions belong to those profiles; the current starter
lists are not complete spec rotations or automatic talent allocation.

## Next integrated Playerbots slice

### Long-term target: WotLK Playerbots feature parity

Playerbots should eventually have an identifiable optional module directory
and module-owned configuration, with only necessary integration hooks in the
core. Use TrinityCore's existing script/build facilities and suitable
AzerothCore module conventions rather than making a general plugin framework
a prerequisite. AHBot stays native to TrinityCore; extracting it into an
external module is not part of this plan. The mixed-role live test precedes
the Playerbots packaging refactor so its behavior can be checked afterward.

The target is a Cata adaptation of the local AzerothCore Playerbots feature
set, not merely socketless companions attached to a human. This includes
managed account/character creation, population login/logout scheduling,
independent world activity, progression/questing, and group/dungeon behavior.
Existing companion tests prove reusable foundations, not a limit on scope.

Prefer adapting identifiable upstream components and retaining their names,
responsibilities, and provenance over inventing parallel systems. Keep Cata
core/data/API differences in narrow adapters; similar architecture does not
mean rewriting TrinityCore to imitate AzerothCore's internals or importing
WotLK quest, item, spell, or navigation data.

The next enabling port should be a bounded account/character factory based
on `RandomPlayerbotFactory`, before adding more manual client fixture setup.
Both cores provide `AccountMgr` creation and `Player::Create`; Cata's native
creation path also owns transactional character saves, realm character
counts, character-cache registration, and creation hooks. Preserve those
invariants rather than synthesizing characters with SQL row copies. Begin
with explicit creation of a small managed roster, then reuse it for the
mixed-role playtest. Reruns must recognize existing managed characters,
avoid unrelated accounts, and never delete a population automatically.

Follow with adaptations of `PlayerbotFactory` for spells/talents/equipment
and `RandomPlayerbotMgr` for bounded independent login/logout scheduling.
Companion and autonomous modes should share the same AI context and class
actions; an owner command is an input to that AI, not a prerequisite for
every decision. Introduce autonomous behavior with a small default-off
population, then port questing/progression and dungeon layers in substantial
testable slices. The full feature-parity target is not claimed implemented.

The full-party replay is the structural gate for this phase: four socketless
sessions, distinct account ownership, ordinary invites, common dungeon
instance, shared Warrior combat, death hold, and clean teardown all ran in a
real client. More isolated proofs of those same hooks have diminishing value.
The remaining gaps are primarily absent bot behavior, not unexplained core
failures. In particular, the current death hold clears the active follow
target; it does not implement corpse release, resurrection, or regrouping.

Port one substantial vertical slice from the local GPLv2 WOTLK Playerbots
architecture, with Cata-specific adapters rather than a wholesale file copy:

1. A per-bot AI context with trigger/action/strategy/value boundaries, driven
   by the existing server-origin session tick. Keep the core-owned session,
   admission, and teleport hooks narrow and default-off.
2. Group behavior: invitation acceptance and configurable greeting, distinct
   roster-based follow positions, regroup/hold, and controlled dungeon join.
3. Death behavior: stop combat, recognize a living/ghost owner, accept a
   resurrection, and use a bounded corpse/graveyard recovery path with a
   human-controlled stop. Do not silently teleport a dead bot into combat.
4. Combat roles: the Cata-checked Warrior, Mage, and Priest starter actions
   now share the same spell validation path. Continue toward actual tank,
   caster, and healer class identity through role actions and triggers. Audit
   each imported WOTLK spell/action for Cata ID, talent, resource, range, and
   packet differences before enabling it.

Build and deterministic action-priority tests should run during the port, but
the next client acceptance pass should cover several newly ported behaviors
together: pre-invite spacing, path catch-up, melee stance, then mixed-role
pulls and recovery. Do not gate each source adaptation on another isolated
client run. A full clear and general dungeon planner remain later milestones.
This deliberately avoids treating all 1,000-plus WOTLK AI source files as a
drop-in Cata implementation.

## Lifecycle audit comparison

The public `playerbots-434` lifecycle audit has now been checked against this
exact checkout. Its world-owned, explicitly socketless `WorldSession` approach
is a good fit for the one-account/one-character PB-00 proof, with important
local constraints around asynchronous session initialization, same-account
session replacement, map-thread command delivery, and shutdown ordering.

See `PLAYERBOTS_LIFECYCLE_COMPARISON.md` for the source evidence,
open decisions and the PB-00 decision gate.
