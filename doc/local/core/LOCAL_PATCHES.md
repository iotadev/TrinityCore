# Local patches

This file records source changes that are intentionally carried on the local
development branch. Re-check each patch after updating from upstream and retire
it only after the replacement has passed a clean configure and build.

## StormLib trailing search-mask array

- **Status:** Active
- **File:** `dep/StormLib/src/SFileFindFile.cpp`
- **Local change:** `char szSearchMask[1]` to `char szSearchMask[]`
- **Reason:** Required for this checkout to compile with the installed Windows
  compiler toolchain.
- **Upstream status checked:** 2026-08-29 at
  `The-Cataclysm-Preservation-Project/TrinityCore` commit `9da95e6cc9`.
  Upstream still contains `szSearchMask[1]`.
- **Provenance:** Reported to the upstream GitHub project by the server owner.
- **Retirement test:** Remove the local change after upstream adopts an
  equivalent fix, then complete a clean configure and `RelWithDebInfo` build.

## Idempotent navigation-tile loading

- **Status:** Active; regression-tested
- **File:** `src/common/Collision/Management/MMapManager.cpp`
- **Local change:** A tile already loaded successfully returns `true` from
  `loadMap`, without changing tile counts, ownership, or navmesh contents.
- **Reason:** The only runtime tile-load caller, `TerrainInfo::LoadMMap`, treats
  `false` as failure and logs a warning. Repeated successful loads should not be
  reported as failures. Missing/invalid data still returns `false`.
- **Verification:** Two new regression cases failed before the fix; all three
  MMap cases pass afterward (59 assertions), including parent fallback,
  unload/reload, missing map/tile, and generator-version mismatch.
- **Limit:** This does not prove every warning from the original gameplay test
  was a duplicate load. Genuine asset/pathfinding problems remain possible.
- **Retirement test:** Keep the tests; retire the implementation patch when
  upstream provides equivalent success/failure semantics.

## Explicit standard-array include

- **Status:** Active; Linux no-PCH worldserver/authserver/tests-common build and
  all 109 automated tests passed on 2026-10-01.
- **File:** `src/common/Utilities/Util.h`
- **Local change:** Include `<array>` directly for the public `std::array`
  templates rather than relying on a precompiled or transitive header.
- **Reason:** GCC 11 compilation without PCH exposed an undeclared `std::array`.
  This is an include-dependency correction, not a gameplay or API change.
- **Retirement test:** The upstream header must declare its standard-library
  dependencies and compile independently of PCH before retiring the local fix.

## Common-test build wiring

- **Status:** Active
- **Files:** `tests/CMakeLists.txt`, `tests/common/FlatSet.cpp`
- **Local changes:** Link the tests to `trinity-core-interface` to inherit the
  core's C++20 settings; use the existing Catch2 v2 header instead of the absent
  `tc_catch2.h` wrapper.
- **Reason:** Enabling the previously disabled suite exposed both build errors.
- **Verification:** The common-test target builds; CTest completes 17 tests.
  The pre-existing EventMap `Schedule existing event` case still has its
  upstream `[!mayfail]` marker and emits one allowed assertion failure when
  running the full Catch executable directly. It was not hidden or reclassified.
- **Retirement test:** An upstream-enabled common-test build must compile and
  run with the configured toolchain and Catch2 version.

## PB-00 server-origin session lifecycle foundation and admission

- **Status:** Default-off one-Warrior lifecycle prototype; isolated positive-path runtime proof passed
- **Files:** `src/server/game/Server/WorldSession.h`,
  `src/server/game/Server/WorldSession.cpp`,
  `src/server/game/Server/WorldSocket.cpp`,
  `src/server/game/Handlers/CharacterHandler.cpp`,
  `src/server/game/World/World.h`, `src/server/game/World/World.cpp`,
  `src/server/scripts/Commands/cs_server.cpp`,
  `src/server/worldserver/worldserver.conf.dist`,
  `src/server/database/Database/Implementation/CharacterDatabase.h`,
  `src/server/database/Database/Implementation/CharacterDatabase.cpp`
- **Local change:** Every `WorldSession` now has an explicit `Client` or
  `Server` origin. The network-authentication path explicitly constructs a
  client-origin session. The idle check is null-safe, and only an explicitly
  server-origin session may remain world-owned without a realm socket. Session
  initialization records `Created`, `Loading`, `Ready`, or `Failed`; server
  sessions retain account/tutorial loading but skip client-only response
  packets. An explicit server-session exit request performs canonical logout
  in the safe world-session update and then returns the session to normal world
  ownership for deletion. A world-thread-only admission method is gated by
  `Playerbots.Dev.Enabled` (default false), `Playerbots.Dev.AccountId`, and
  `Playerbots.Dev.CharacterGuid`. It permits only one server-origin session,
  a dedicated ordinary-player account, and its offline Warrior. It checks
  account ban, character ownership/class/online state, cache identity, and
  realm capacity before loading RBAC and handing the session to the world.
  Once account/tutorial initialization reaches `Ready`, a server-origin-only
  entry point rechecks character identity and uses the canonical asynchronous
  `LoginQueryHolder` and `HandlePlayerLogin` path. Server-origin outbound
  packets are deliberately discarded after opcode/connection validation;
  client packet errors remain unchanged. The three settings are loaded through
  the typed world configuration and documented in `worldserver.conf.dist`.
  While PB-00 is enabled, authenticated human-client admission for its
  dedicated account is rejected before a client `WorldSession` is allocated;
  the world-thread collision guard remains as defense in depth.
- **Reason:** PB-00 needs to distinguish an intentional socketless bot session
  from a disconnected human session. A blanket null-socket exception would
  change normal disconnect behavior.
- **Current limit:** Console-only `.server playerbotdev start|stop|status`
  exposes the allowlisted one-Warrior proof through the existing server-debug
  RBAC gate; in-game invocation is rejected to preserve world-thread ownership.
  Enabling the config alone still does not create a bot. Normal shutdown
  requests bot exit and allows up to 30 seconds for the world-session update
  to drain it; a timeout logs an error and falls through to normal cleanup.
  Force/exit/OS termination paths are not covered by that grace period. This
  is not yet a functional Playerbots implementation.
- **Verification:** Win64 `RelWithDebInfo` `worldserver` build passed on
  2026-09-23. On a clone of the prior isolated database, the allowlisted
  Warrior logged in without a client, remained online for 125 seconds,
  logged out to offline state, and the worldserver shut down with exit code 0.
  The cloned MySQL instance also shut down normally. See
  `../playerbots/PLAYERBOTS_LIFECYCLE_VALIDATION.md` for evidence. Targeted
  admission, pending-query stop/shutdown, drain-timeout, duplicate-start, and
  saved-level restart checks passed. After moving the settings into typed world
  configuration and reserving the enabled bot account at client admission, a
  fresh build/link and isolated start/duplicate/stop/shutdown replay also
  passed. A subsequent real 4.3.4.15595 client login attempt on the reserved
  account was rejected before client-session allocation while the original bot
  remained in-world, then saved/logged out and shut down cleanly.
- **Retirement test:** Replace only if a later lifecycle owner preserves the
  explicit origin boundary and unchanged client disconnect semantics.

## Outdoor PvP capture-point ownership on map 530

- **Status:** Fixed and exercised by the isolated PB-00 shutdown test.
- **Files:** `src/server/scripts/OutdoorPvP/OutdoorPvPZM.h/.cpp` and
  `src/server/scripts/OutdoorPvP/OutdoorPvPNA.h/.cpp`.
- **Local change:** Zangarmarsh's graveyard point and Nagrand's Halaa point
  now transfer ownership to `OutdoorPvP::m_capturePoints` when registered;
  their derived-script pointers are non-owning. Nagrand retains ownership
  only until its capture-point game object appears.
- **Reason:** Both scripts previously passed a pointer still held by a local
  `unique_ptr` to `AddCapturePoint`, whose map also takes `unique_ptr`
  ownership. Map-530 shutdown reproducibly double-deleted Zangarmarsh's
  point (`0xC0000374`). Nagrand had the same structural defect.
- **Verification:** The same one-Warrior map-530 lifecycle and normal
  shutdown failed before this change, while a no-bot control shut down
  cleanly. After the ownership fix, the 125-second bot test and normal
  shutdown passed. Nagrand's capture-point spawn path was source-reviewed,
  not separately exercised in-game.

## Auction House Bot market-foundation corrections

- **Status:** Active; isolated seller and buyer runtime proofs passed.
- **Files:** `modules/mod-ahbot/src/Bot/AuctionHouseBotSeller.cpp`,
  `modules/mod-ahbot/src/Bot/AuctionHouseBotSeller.h`, and
  `modules/mod-ahbot/src/Bot/AuctionHouseBotBuyer.cpp`.
- **Local change:** Distribute each configured quality total across eligible
  item classes with largest-remainder allocation. Empty or zero-priority
  classes remain at zero; fractional ties resolve by item-class ID. Runtime
  ratio commands now apply the same 10,000% upper bound as config loading,
  configured auction minimum time is honored, each new auction is inserted
  into the in-memory house once, and buyer minimum-bid aggregation retains the
  observed minimum.
- **Module boundary:** The implementation and command script now live in
  `modules/mod-ahbot`. Core code retains only initialize/update dispatch and an
  auction-mail bot-identity query. Both enabled and `MODULE_MOD_AHBOT=OFF`
  worldserver builds link; the enabled module also passes the disposable
  seller/buyer replay, including active `ahbot.conf` loading, at
  `build/ahbot-smoke-20260927-175330`.
- **Reason:** Independently rounding every weighted class share did not
  preserve the configured quality total. A twelve-listing test realized only
  nine listings: gray 0/2, white 3/4, green 5/4, and blue 1/2. The legacy live
  ratio setters used `max` instead of `min`, so entering 100% could silently
  request 10,000% or 100,000%. The other corrections remove similarly direct
  state/statistics errors before market-policy work.
- **Verification:** Win64 `RelWithDebInfo` `worldserver` compiled and linked.
  `contrib/local/ahbot-smoke.ps1` then produced exactly 12/12 neutral-house
  listings with valid item instances and distinct item entries, preserved that
  target through both runtime ratio-command forms, and kept all expirations in
  the configured six-hour window. Its `-CheckBuyer` phase converted one listing
  to a one-copper non-bot auction; the native buyer detected and bought it out
  through the normal auction/mail path. Both staged worldserver runs and cloned
  MySQL shut down normally.
- **Market catalog:** `AuctionHouseBot.MarketCatalog.File` is a default-off CSV
  diagnostic generated from the live item templates and seller filters. It
  annotates vendor, loot, and direct profession-craft provenance, with an
  explicit `seller_eligible` boundary. `AuctionHouseBot.Items.Crafted` is a
  separate default-off source switch; when enabled, it admits recognized
  profession outputs without bypassing binding, price, quality, or class
  filters. It does not add an item database or pricing table.
- **Catalog verification:** The legacy-source replay retained its 9,186-item
  seller pool and exposed 3,624 additional crafted candidates. With the
  crafted source enabled, 12,371 items were seller-eligible and 439 crafted
  rows remained diagnostic-only. The full seller/buyer replay still passed.
  Latest retained evidence: `build/ahbot-smoke-20260924-204353`; analysis is
  recorded in `../ahbot/AHBOT_MARKET_CATALOG_ANALYSIS.md`.
- **Supply-profile slice:** `AuctionHouseBot.SupplyProfile.Enabled` is
  default-off. When enabled, runtime-derived commodity, equipment, and other
  segments receive configurable relative listing weights and enforce
  configurable simultaneous AHBot-owned listing ceilings per item and house.
  Each quality uses exact largest-remainder segment allocation before existing
  class priorities. A ceiling of zero is unlimited. The catalog records the
  segment, configured weight, configured ceiling, enabled state, and active
  stack policy. Commodities use configurable single/quarter/half/full lot
  weights, equipment uses one item, and other segments retain legacy stack
  behavior. No item metadata or pricing is persisted.
- **Supply verification:** A 120-listing disposable replay with every segment
  ceiling set to one and weights set to 45/40/15 produced 54 commodity, 48
  equipment, and 18 other listings using 120 distinct item entries. It retained
  all 120 through both live ratio commands, completed a buyer buyout, and shut
  down cleanly. The run also realized 14 single, 15 quarter, 10 half, and 15
  full commodity stacks, all valid for their item maximums, while equipment
  remained single-item. Evidence: `build/ahbot-smoke-20260925-203322`. A separate
  default-off control retained exactly 12/12 listings at
  `build/ahbot-smoke-20260925-203604`.
- **Turnover verification:** `-CheckTurnover` implies the supply profile and
  uses randomized 6-18 hour lifetimes. Evidence in
  `build/ahbot-smoke-20260925-204104` produced 59 distinct expiration
  timestamps, then removed 24 listings only after a clean shutdown. Restarting
  refilled 96 retained rows to 120 distinct entries with fresh auction IDs and
  the same exact 54/48/18 segment targets. The buyer buyout and all three
  worldserver shutdowns passed.
- **Buyer cadence:** Buyer evaluation throughput is now independent of seller
  refill throughput through `AuctionHouseBot.Buyer.EvaluationsPerCycle.Normal`
  and `.Boost`. `AuctionHouseBot.Buyer.ActionsPerCycle` caps successful bids
  plus buyouts per house cycle; zero preserves legacy behavior. Each cycle logs
  aggregate eligible, evaluated, bought, bid, ignored, and limit counts.
  Evidence in `build/ahbot-smoke-20260927-173254` exposed two guaranteed
  player auctions with an action cap of one, bought exactly one in the first
  cycle, and retained the other.
- **Economic boundary:** This patch does not import AzerothCore/WotLK pricing.
  The current Cata buyer valuation remains a placeholder based on vendor sell
  price or quality fallback, adjusted by same-item observations and configured
  chance multipliers. Calibrate it separately against Cata-specific data.
- **Retirement test:** An upstream replacement must preserve exact configured
  totals for small and large markets, preserve a 100% target through runtime
  ratio commands, and pass both isolated seller and buyer replays.
