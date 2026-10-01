# Local development documentation

These are documents created for this development fork, not original TrinityCore
documentation. Upstream files remain in their original locations. Paths to source,
scripts and ignored build evidence inside reports are repository-root-relative
unless stated otherwise.

Documentation describes project requirements, implementation decisions and
validation results. Keep personal machine inventories, unrelated installations,
account details and development-tool session history out of these files.
Historical evidence directory names identify past runs; they are not fixtures
distributed with the repository. Reproduction instructions must specify required
inputs and allow developers to supply their own environment paths.

Start with the [core README](../../README.md) for compatible module revisions,
then the roadmap and implementation handoff below for current development.
Dated reports retain earlier outcomes; their old "pending" statements apply to
those revisions. Local commit IDs and ignored evidence are archival references
and need not exist in a fresh public clone.

## Playerbots

- [Roadmap](playerbots/PLAYERBOTS_PORT_ROADMAP.md)
- [Infrastructure milestone acceptance](playerbots/PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md)
- [Reference policy and behavior comparisons](playerbots/PLAYERBOTS_REFERENCE_GUIDE.md)
- [Development history](playerbots/PLAYERBOTS_DEV.md)
- [Engine integration notes](playerbots/PLAYERBOTS_ENGINE_INTEGRATION_NOTES.md)
- [Implementation handoff and work packets](playerbots/PLAYERBOTS_WORK_PACKETS.md)
- [Repository split plan](playerbots/PLAYERBOTS_REPOSITORY_PLAN.md)
- [Low-level party milestone](playerbots/PLAYERBOTS_PARTY_MILESTONE.md)
- [2026-09-29 mixed-party release check](playerbots/NEXT_MIXED_PARTY_TEST.md)
- Validation: [lifecycle](playerbots/PLAYERBOTS_LIFECYCLE_VALIDATION.md),
  [harness](playerbots/PLAYERBOTS_HARNESS_VALIDATION.md),
  [module foundation](playerbots/PLAYERBOTS_MODULE_VALIDATION.md)
- [Lifecycle source comparison](playerbots/PLAYERBOTS_LIFECYCLE_COMPARISON.md)

## Auction House Bot module

- [Development plan](ahbot/AHBOT_DEV.md)
- [Market catalog analysis](ahbot/AHBOT_MARKET_CATALOG_ANALYSIS.md)
- Module source and configuration live in the separate `modules/mod-ahbot`
  checkout; those files are not part of a core-only clone.

## Core and test infrastructure

- [Local patch register](core/LOCAL_PATCHES.md)
- [Cleanup triage](core/CLEANUP.md)
- [Baseline validation](core/VALIDATION.md)
- [Runtime test instructions](core/RUNTIME_TESTING.md)
- [Publication privacy audit](core/PUBLICATION_AUDIT.md)
- [Milestone publication checklist](core/PUBLISHING_CHECKLIST.md)

Maintained executable scripts remain in [contrib/local](../../contrib/local/).
Some historical validation notes also name local-only test harnesses or ignored
evidence that are not distributed with a core-only checkout.
Playerbots module documentation remains with its separate source checkout at
`modules/mod-playerbots` (including its README, porting provenance, and donor
authorship). Those files are not part of a core-only clone.
Generated reports, logs, exported diffs and snapshots remain in ignored build/
directories rather than this maintained documentation tree.
