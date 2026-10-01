# Playerbots development handoff and work packets

Updated 2026-10-01. Read this with the
[roadmap](PLAYERBOTS_PORT_ROADMAP.md). This file defines the next work;
dated development/validation notes are historical evidence.

Use the [reference guide](PLAYERBOTS_REFERENCE_GUIDE.md) for authority, pinned
secondary comparisons and recovery ownership. Existing local work may be newer
than the published pair; do not plan solely from GitHub branch contents.

## Resume here

The infrastructure stop point has passed acceptance and documentation alignment.
The matching module is committed as 70014ce88cb2d99a370894baef7a32876ff94a50;
the core README pins that revision for the matching milestone. See
[the acceptance checklist](PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md). The bundled
ordinary-player check passed creation/accounting, addon-managed roster and
connect/disconnect/reconnect, account-online cleanup and clean shutdown on
2026-10-01. The Linux worldserver/authserver/tests-common build also passed all
109 tests after explicit header corrections. Scoped infrastructure acceptance
is complete. Publication is a separate action; no push is requested by this step.
Linux runtime remains a separate future check. After the milestone, resume the
bounded donor feature ports below rather than reopening the foundation.

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
