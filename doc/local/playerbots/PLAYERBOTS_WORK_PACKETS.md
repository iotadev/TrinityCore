# Playerbots development handoff and work packets

Updated 2026-09-29. Read this with the
[roadmap](PLAYERBOTS_PORT_ROADMAP.md). This file defines the next work;
dated development/validation notes are historical evidence.

## Resume here

The static module system, imported scheduling kernel, bounded class contexts,
GUID-based active roster, authorization and whisper controls already exist.
Do not restart those ports. The latest combined build and short Ragefire check
passed. Mage opener and basic commands are operational; complete rotations,
resurrection/recovery and autonomy are still partial or absent.

The next implementation batch is **managed existing-character roster and
lifecycle, plus the first Cata MultiBot protocol mapping**. Account/character
creation follows the manager contract; extensive class polish is not a gate.
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
| `src/Bot/Cmd/PlayerbotControl.{h,cpp}` | World-thread resolve/authorize/queue boundary for normal controls |
| `src/Mgr/Security/PlayerbotSecurity.{h,cpp}` | Invitation and full-control relationship; current party controller plus GM override |
| `src/Script/PlayerbotChatCommands.cpp` | Ordinary whisper transport; addon messages deliberately not handled here |
| `src/Bot/PlayerbotSessionBehavior.{h,cpp}` | Queued requests and map/world behavior; per-bot AI lifetime |
| `src/Bot/Engine/`, `src/Ai/Class/` | Imported scheduler and partial class contexts; extend instead of another decision loop |
| Core `World::{FindServerOriginPlayerbot,GetServerOriginPlayerbotSessions}` | Borrowed active-session lookup on world thread |
| Core `World::TryStartDevPlayerbotSlot` and `WorldSession` | Current admission/teardown path to generalize carefully |

A command reply saying "requested" acknowledges queuing, not successful casting
or completed transfer. The next lifecycle API must expose pending/completed/failed
outcomes. `stop` currently ceases combat; it does not disconnect the character.

## A. Managed existing-character roster/lifecycle — next implementation

Donor basis: PlayerbotMgr, RandomPlayerbotMgr ownership/selection, relevant
PlayerbotSecurity relationships, and their login/logout callers. Inspect exact
paths at the selected donor revision before designing the reduced Cata port.

Scope:
- Represent managed bot identity and availability independently of four numbered
  development slots. Reuse existing characters first.
- Separate managed account ownership from temporary party control. Preserve
  eligible human invitations; group membership alone is not full authorization.
- Route authorized connect/disconnect through world-owned native admission,
  async loading, logout/save and final-state reporting.
- Keep one active character per account for this slice. Reject duplicates,
  conflicting human sessions and stale/ineligible characters.
- Reconcile pending requests during disconnect, transfer failure and shutdown.
  Keep the current development fixture usable until the replacement is operational.

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
