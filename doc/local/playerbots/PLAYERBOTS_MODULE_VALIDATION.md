# Optional Playerbots module foundation validation
Historical commands below record the original runs. For a new run, supply
`-MySqlHome <installation-directory>` and `-Seed <your-stopped-fixture>`;
see the current [runtime instructions](../core/RUNTIME_TESTING.md).


Date: 2026-09-26. Cata base HEAD `efcf6ac83d11fdf4ce86a1b6f95c3b22dfaee14f`
plus the existing dirty working tree and this refactor. Existing AHBot work was
preserved. Validation used isolated build/runtime fixtures.

## Implementation

- Module discovery and independent `MODULE_MOD_PLAYERBOTS` build control.
- Module source and native ScriptMgr registration, installed config template,
  module-owned tests, and an explicit disabled-module implementation.
- Movement/party/combat/dungeon behavior and timers moved out of WorldSession to
  `modules/mod-playerbots/src/Bot/PlayerbotSessionBehavior.*`.
- Class/formation/casting helpers and console command handlers moved into the module.
- Session lifecycle, account admission/reservations, async login/save/logout and
  shutdown drain remain native core integration.
- WorldSession owns the behavior object, forwards requests and consumes updates
  in the original map/world contexts. Player pointers are resolved per update.
- `ConfigMgr::LoadAdditional` atomically merges a single-section module config.
  Module settings override legacy settings; reload rereads main and module files.
- The headless harness's `-ModuleConfig` mode writes actual separate module settings.

This is packaging of the current prototype. It does not port the donor Engine,
normal chat commands, factories, autonomous population or complete class rotations.

## Build and deterministic checks

Enabled: configured with `-DMODULE_MOD_PLAYERBOTS=ON`; Win64 RelWithDebInfo
`worldserver` and `tests-common` built and linked. All 34 CTest cases passed.
Two new config cases also exercise reload, dotted-key overrides, preservation of
the main filename/arguments, missing files, duplicate keys, empty sections and
multiple sections. Existing 15 Playerbot cases retain their behavior and now live
with the module.

Disabled: configured with `-DMODULE_MOD_PLAYERBOTS=OFF`; Win64 RelWithDebInfo
`worldserver` built and linked. Module config/script lists were empty, Playerbot
sources were excluded, and the core used the disabled implementation. After moving
tests into the module, `tests-common` built with all 19 core/config cases passing.
Module detection uses actual registration rather than a stale cached option, so
a missing module directory does not advertise a compiled implementation.

The first enabled compile exposed lambda captures of the now-local Player pointer;
these were fixed with explicit synchronous captures. No failed build is counted
as a passing verification. The enabled configuration was then restored;
`worldserver` and `tests-common` rebuilt successfully, and the final CTest run
passed all 34 cases. The final binary includes the optional Playerbots module.

PowerShell parser and `git diff --check` passed. CMake reports the existing Boost
toolset and Catch2 minimum-version notices.

## Copied-database runtime checks

Enabled command:

```powershell
.\contrib\local\playerbot-lifecycle-smoke.ps1 -ModuleConfig -IdleSeconds 10 -CheckDuplicateStart
```

Evidence: `build/playerbot-smoke-20260926-140639`. The server logged loading
`modules/playerbots.conf`, registered the optional module's startup script, admitted
Testone, rejected a duplicate admission while it remained online, held it online
for ten seconds, saved/logged it out, and shut down normally. The harness confirmed
database online-state changes. All test-owned processes stopped.

Disabled command (against the disabled binary):

```powershell
.\contrib\local\playerbot-lifecycle-smoke.ps1 -ModuleConfig -SkipBot -IdleSeconds 0
```

Evidence: `build/playerbot-smoke-20260926-141056`. This staged a module config with
development enablement requested, while the compiled module/config/script lists
were disabled. The core started and shut down normally without admitting a bot.
The run verifies ordinary startup/shutdown; absence of the command subtree and
forced-off admission are additionally source/build verified. No user client ran.
All test-owned processes stopped.

## Remaining verification

Final state: the enabled build is restored and the sandbox is stopped. No listeners
were present on the sandbox ports 13306, 3724, 8085 or 8086 at handoff.

Movement, combat, party invitations and dungeon transfer after extraction still
need an integrated client pass. Deterministic helper tests and idle lifecycle
success do not establish those gameplay results. Combine that pass with the next
substantial ported behavior rather than repeating every earlier microtest.

Testtwo's prior invitation/readiness issue is not fixed by module packaging. The
interactive harness timeout policy remains a separate stage-0 repair. Neither is
classified as complete here.
