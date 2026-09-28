# Repository split and first preservation milestone

Originally drafted 2026-09-27 before the first private module commit. The
preparation sequence below records the intended split; the subsequent state is
summarized immediately below.

## Subsequent local checkout state

The first 32-file Playerbots alpha snapshot was committed to a separate private
repository. The module's Git-backed checkout now occupies
`modules/mod-playerbots`, which is the path consumed by the core build. The core
repository ignores that directory; its own pending framework and lifecycle
changes remain separate and have not been published. The original pre-split
module directory is retained under ignored `build/` as a local recovery copy.
The first standalone sibling checkout also remains local, but new module edits
should be made only in `modules/mod-playerbots` to avoid divergent copies.

The enabled worldserver and tests-common targets still build from the Git-backed
checkout, and 47/47 CTest cases pass. This verifies the checkout relocation, not
new gameplay behavior or compatibility with the public core fork.

## Intended boundary

- Public core: the project's TrinityCore fork, optional static module/config/test
  registration, and the narrow lifecycle/session hooks needed by Playerbots and
  AHBot. Preserve upstream history and GPL/authorship notices.
- AHBot module: `modules/mod-ahbot` owns the native seller, buyer, commands, and
  market-policy additions. Its publication/repository destination remains a
  separate decision from Playerbots.
- Initially private module: modules/mod-playerbots source, templates, tests,
  AUTHORS.md and porting documentation, kept in a separate Git repository. It
  remains dependent on a documented matching core revision, not arbitrary Cata
  TrinityCore or binary drop-in compatibility.
- Local only: build directories, generated databases, server/client configuration,
  credentials, logs, crash dumps, map data and worker snapshots. Source inspection
  and automated scans precede any push; ignored files alone are not a full audit.

The public GitHub fork is already public. GitHub public forks cannot independently
be made private, so private module development uses a separate ordinary private
repository rather than a private branch of the public fork. Branches inherit their
repository's visibility. Reference: https://docs.github.com/en/pull-requests/reference/forks

## State at planning time (historical)

The local development branch's origin still points at
The-Cataclysm-Preservation-Project/TrinityCore. The publication fork is not currently
a configured remote. Changes include Playerbots, modules, AHBot and unrelated
baseline fixes; do not stage the entire tree as one feature commit.

modules/mod-playerbots is currently an ordinary untracked source directory, not
an independently versioned repository or registered submodule. No split should
discard its contents or omit it from a reproducible snapshot.

Prefer a private module checkout under the existing modules directory while core
does not track its implementation. Add an explicit core ignore rule only during
the approved split. Document manual clone placement and required core revision.
Defer a private submodule: it would put a private URL/access requirement into the
public core and complicate clean cloning. An optional public submodule can be
considered when the module becomes public. Do not git-init or move the module
until the source inventory and preservation snapshot are verified.

## Milestone to preserve

The module-enabled server builds and 47 automated tests pass. Headless mixed-bot
readiness/save/logout previously passed. Upstream registry, Event and NextAction
imports are preparatory, not the active full Playerbots engine.

The local playtest target is all four mixed-class bots accepting invitations,
following into Ragefire Chasm, several successful engagements with visible Mage
damage and sustained Priest healing, then normal logout/save/shutdown. The user
report and logs must both be recorded. A full dungeon clear, tank intelligence,
complete resurrection handling and autonomous population are not acceptance
claims for this first preservation milestone. A failed playtest does not prevent
backing up a clearly labelled experimental checkpoint.

## Preparation sequence

1. Finish the bounded playtest and record observed behavior and remaining issues.
2. Preserve the complete dirty state in a source-only local snapshot with a file
   manifest, including untracked module files; verify it before moving anything.
3. Review existing local commits plus pending changes for credentials, runtime
   data and machine-specific content. The fixed disposable PB01 test password is
   fixture data, not a production secret; inspect other matches individually.
4. Inventory separate baseline fixes, native AHBot work, generic module framework,
   Playerbots core integration and private module content. Shared files need
   reviewed hunks or dependency-grouped commits, not blanket add or reset.
5. Create the private module destination with explicit user approval/name, preserve
   donor notices and pin core/module revisions. Keep both checkouts reproducible.
6. Build core with module disabled from a clean checkout, and enabled with the
   private module checkout. Run automated tests and the relevant lifecycle proof.
7. Review the exact outgoing commits and visibility, then push only to the chosen
   destination. Do not use upstream origin as the fork's publication target.
8. Eventually publish the module with installation instructions, known limits,
   pinned compatibility and provenance; retain a clean core/module revision pair.

No need to wait for the entire upstream Engine or feature parity to preserve the
project privately. Repository preservation and gameplay completeness are separate
milestones.
