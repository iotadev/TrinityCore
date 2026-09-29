# Repository boundaries and publication

Updated 2026-09-29. The initial publication snapshots exist. Core, Playerbots and
AHBot are separate repositories; the current roadmap and work packets describe
the next implementation, while this file describes source ownership.

| Repository | Owns | Checkout location |
|---|---|---|
| iotadev/TrinityCore | Native session/lifecycle hooks, module build/config registration, project roadmap and local harness source | Core root |
| iotadev/cata-playerbots | Bot runtime, AI, commands, configuration, tests and port provenance | `modules/mod-playerbots` |
| iotadev/cata-ahbot | Auction seller/buyer, commands and market policy | `modules/mod-ahbot` |

The core ignores the two module directories. A core-only clone contains neither
implementation and can build without them. There is no implicit submodule update
or binary plugin loading. Clone selected modules manually and use the exact
commits recorded in the core README for a coordinated snapshot.

Runtime configs, credentials, client/game data, copied databases, logs, builds
and private recovery bundles remain local. Published test scripts consume
explicit environment paths and disposable fixtures; example evidence directories
are not downloadable fixtures.

## Publishing another milestone

The publication branches have curated history separate from the original
development branch. Reuse a clean publication checkout at the current remote
tip, apply only the reviewed change, and retain its existing contribution,
license and privacy documentation. Do not merge the private development ancestry
or force-push to reconcile this difference.

Commit the module first, then pin that commit in the corresponding core README.
Preserve GPL notices and donor attribution, confirm the author/committer identity,
review the outgoing paths and check that only the intended repository receives
the push. Publish the module revision before the core commit that references it.

Choose validation from the actual change. A code milestone needs a compatible
build and meaningful affected checks; a documentation-only correction does not
need a server rebuild. Recheck module-disabled configurations when their boundary
changes, rather than requiring a full matrix for every publication.

The 2026-09-29 checkpoint adds active roster/control hooks, normal whispers and
bounded class engine routes. Its short client check confirmed an operational
mixed party; it does not claim complete dungeon or autonomous behavior.
See the [roadmap](PLAYERBOTS_PORT_ROADMAP.md) and
[release-check record](NEXT_MIXED_PARTY_TEST.md) for scope and remaining work.
