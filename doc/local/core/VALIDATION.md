# Cata baseline validation - 2026-08-29

This records the original runtime/client test. Subsequent source cleanup,
regression tests, and the newer integration build are recorded in CLEANUP.md;
they have not been through another graphical-client test.

## Result

The clean Win64 RelWithDebInfo build passed isolated database bootstrap,
worldserver startup/shutdown/restart, authserver TCP acceptance, and six Cata
world greeting/authentication-challenge exchanges. A subsequent real-client
test also passed authentication, character creation, world entry, movement
persistence, and logout. The historical connection-time ARC4 assertion did not
reproduce. This is not a comprehensive gameplay or Playerbots certification.

- Upstream checked: `9da95e6cc9c2cdd82c0d3778a3720d2fe77be8ff`.
- Built local source: `624fed881b9584277d25cdc3341c451168da3298`.
- Active local core patch: StormLib trailing search-mask array; see
  `LOCAL_PATCHES.md`.
- Dependencies in the tested runtime: MySQL 8.0.46, OpenSSL 4.0.1 with its
  matching legacy provider, Boost 1.83.0.
- Evidence directory (Git-ignored): `build/runtime-smoke-20260829-175926`.

## Verified checks

- Created four empty databases in a new disposable MySQL data directory.
- Imported the saved TDB 434.22011 world/hotfix dumps and applied the checkout's
  migrations. World bootstrap applied 172 update files.
- Migration ledger totals: auth 76, characters 75, world 4962, hotfixes 20.
- Latest world migration: `2026_07_25_00_world.sql`.
- Worldserver reached ready, shut down normally, then reached ready again with
  automatic database updates disabled.
- Authserver advertised realm `Cata isolated test`, build 15595, world port 18085.
- Six world connections returned the expected greeting followed by
  `SMSG_AUTH_CHALLENGE` (opcode `0x4542`, 37 payload bytes); the process survived.
- A disposable test account was created with expansion 3. Generated credentials
  were stored outside version control.
- Listener inspection verified loopback-only bindings for the configured test
  database, authserver and worldserver endpoints; see RUNTIME_TESTING.md.
- Tests used separate binaries, configuration and a disposable database directory.
  The harness managed only its own processes.

## Content warnings retained for investigation

Successful startup still emitted 167 diagnostic lines to `world.stderr.log`:

| Category | Lines |
| --- | ---: |
| World-state references to unavailable map/area IDs | 142 |
| Missing gossip-menu definitions | 10 |
| Missing safe proc definitions | 9 |
| Attempts to learn talent spells via spell_learn_spell | 4 |
| Unassigned script name | 1 |
| Spell-script effect/DBC hook mismatch | 1 |

Examples include map 2118/area 10176, script
`world_map_set_faction_worldstates_609`, and spell 85123 (`spell_siege_cannon`).
No rows, upstream migrations, or script bindings were edited to suppress these.
Treat this as a bootable baseline with content defects to triage, not a clean
gameplay certification. Inspect stderr as well as Server.log; DBErrors.log alone
did not capture these diagnostics with the inherited logging configuration.

## Historical crash interpretation

Earlier connection-time crashes asserted at `ARC4.cpp:31`. The validation run
above did not reproduce the failure; no crypto workaround was added. Historical
crash reports alone are insufficient to establish the cause of a current failure.

## Real-client check

A 4.3.4.15595 client connected to the disposable realm using the test authserver's
alternate port. Authentication, character creation, world entry, movement
persistence and logout succeeded. The saved character was offline after logout,
and its stored position reflected movement during the session. The server remained
alive without another ARC4 assertion.

For reproduction, use a disposable test account and configure the client to reach
the test authserver. Back up any client settings changed for testing and restore
them afterward. Stop the harness-owned authserver, worldserver and database, then
check that their test ports are released. Keep account details, configuration
backups and raw logs outside the source tree's publication set.

Additional diagnostics during character creation/world entry included
instance-socket packet warnings and `Could not load MMAP` warnings. Their
gameplay impact was not established. In particular `5301244.mmtile` exists,
has the expected magic and mmap version 14, and its declared payload length
matches its file size. The loader also returns false for already-loaded tiles,
so the warning alone does not establish missing or corrupt navigation data.
No map assets or core networking code were changed during this test.

The upstream wiki still describes the older Battle.net login arrangement, while
this checkout uses authserver after the
[July 2025 authentication refactor](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/commit/64b77e359d).
Use the current source and actual client connection logs when troubleshooting.

See RUNTIME_TESTING.md for the isolated test helper. Test process IDs and credentials are
ephemeral; never assume the test is still running solely from this document.
