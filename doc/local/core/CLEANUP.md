# Baseline cleanup triage - 2026-08-29

This triage compares runtime diagnostics with the Cata source and matching
4.3.4.15595 DBC data. Reproduce database changes only against a disposable test
fixture before applying a reviewed correction to a deployment.

## Completed

### Navigation return-value correction

`MMapManager::loadMap` returned false for a tile that was already loaded.
`TerrainInfo::LoadMMap` interpreted that result as failure. A synthetic navmesh
regression test reproduced the problem for direct loads and parent-map fallback.
The repeated-load path now returns success without adding a second tile or
changing unloading behavior. See `LOCAL_PATCHES.md`.

Verification:

- Before the fix: 2 failing MMap cases, both at their second load request.
- After the fix: 3 MMap cases, 59 assertions, all pass.
- The common-test suite builds after repairing its Catch2 include and core
  compiler-settings linkage.
- CTest: 17 registered tests complete successfully. The older EventMap
  duplicate-event test is still explicitly marked `[!mayfail]` upstream; its
  allowed assertion failure is not a new regression or an unconditional pass.
- Tests generate their own tiny navigation files in a unique temporary
  directory and remove those files afterward. They do not need game data or a
  running server.
- Integration build of `worldserver`, `authserver`, and `tests-common` completed
  successfully in Win64 RelWithDebInfo at source commit `8ed44e40689c`. New
  binaries remain under `build/bin/RelWithDebInfo`; the saved Server binaries
  were not replaced and no server was started during this cleanup pass.

The old warning log is historical evidence, not proof that every warning it
contains is fixed by this patch. No post-patch graphical-client retest was done
in this cleanup pass.

## Remaining warnings

| Group | Evidence and meaning | Next action |
| --- | --- | --- |
| 142 invalid world-state map/area references | Cata DBCs contain map 571 and area 4197, but not 2118/10176. The Wintergrasp SQL explicitly pairs them. Arena and Violet Hold rows also contain absent IDs. | Prepare a separate guarded SQL correction, preserving valid Cata tokens and row values. Test only on the disposable DB before considering deployment. |
| Navigation-load warnings | The inspected `5301244.mmtile` exists, has version 14, and its payload length matches the file. Duplicate loads were one proven false-failure path. | Exercise paths in the eventual bot-follow test; capture genuine failures separately. Do not re-extract all assets from this warning alone. |
| Siege Cannon spell hook | DBC spell 85123 effect 0 has target A 89 (`TARGET_DEST_TRAJ`), while its area-target hook expects target 7 (`TARGET_UNIT_SRC_AREA_ENTRY`). Runtime validation rejects that hook. | Investigate intended Tol Barad behavior. Changing the target number alone would not make an area-target callback appropriate for a destination trajectory. |
| Map-609 built-in script binding | `MapManager::AddSC_BuiltInScripts` generates `world_map_set_faction_worldstates_609`; the script-name registry reports no database assignment. | Audit split-by-faction map binding and Death Knight starting-map behavior; do not attach it arbitrarily to a creature or world-state row. |
| 10 missing gossip-menu references | Saved logs name 9 unique menu IDs, including 55002 twice. | Resolve owning creatures and intended menus before inserting placeholders or deleting references. |
| 9 unsafe/missing proc definitions | The core deliberately refuses to auto-generate proc data that could loop indefinitely. | Review each spell's intended trigger, mask, and cooldown; retain the safety check. |
| 4 talent-learning rows | The core skips talent spells referenced by spell_learn_spell. | Review class/talent semantics before pruning rows. Not a reason to bypass talent validation. |
| Instance-socket warnings during character creation | Some creation-time packets have no destination socket before a character enters the world; the real login and movement test still succeeded. | Instrument the login/bot packet boundary when implementing the session adapter. Do not silence all network-opcode errors. |

### Exact world-state sources

- `sql/updates/world/4.3.4/2022_10_09_03_world.sql`: Wintergrasp map list
  `571,2118` and area list `4197,10176`.
- `sql/updates/world/4.3.4/2022_10_09_05_world.sql`: Violet Hold states 3815/3816
  include map 1544 beside Cata map 608.
- `sql/updates/world/4.3.4/2022_12_21_00_world.sql`: arena states 3600/3601/3610
  include 12 map IDs absent from this client's Map.dbc.
- `src/server/game/World/WorldStates/WorldStateMgr.cpp`: invalid tokens are
  logged and excluded while valid tokens remain in use.

These upstream migration files were not edited. A future data correction must
be a new migration with its own preconditions and before/after checks; retain
the upstream migration history and checksums.

## Development handoff

The basic runtime/login baseline is usable for a narrow bot-lifecycle prototype.
It is not a certification of all zones, spells, dungeons, or pathfinding. See
`../playerbots/PLAYERBOTS_DEV.md` for the first implementation milestone and boundaries.
