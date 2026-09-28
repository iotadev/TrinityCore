# First public snapshot: release gate

This is a preparation checklist, not a release announcement. The target is the
Cataclysm 4.3.4.15595 TrinityCore fork. AHBot and Playerbots are optional static
modules with narrow core integration seams. Both now have separate local Git
repositories ignored by the core checkout. The intended first public snapshot
is a coordinated three-repository set: core, Playerbots, and AHBot. No client,
extracted game data, database, credentials, build products or local evidence
bundles belong in any outgoing repository.

## Current boundary (2026-09-27)

- The public fork exists, but this development checkout's `origin` still points
  to the Cataclysm Preservation Project. Do not push the development branch to
  `origin` or assume the public fork contains these changes.
- The development core working tree contains uncommitted integration and
  documentation work. A clean-history publication candidate is being prepared
  from the upstream base. The module sources live in independent checkouts at
  `modules/mod-playerbots` and `modules/mod-ahbot`; neither is included in a
  core clone. All three are still being developed.
- Existing local core commits predate the current privacy cleanup. See
  [the privacy audit](PUBLICATION_AUDIT.md) before selecting outgoing history.
- AHBot-enabled and AHBot-disabled worldserver builds passed after the module
  move. A disposable replay loaded its active module config, made 12/12 seller
  listings, exercised both relocated ratio commands, and bought one of two
  player auctions under the buyer action cap. Earlier Playerbots build/lifecycle
  checks used the matching private module. These are checkpoint results, not
  tests of the final publication snapshot or all gameplay behavior.

## Required before the first push

1. Freeze a named checkpoint across all three repositories. Record the exact
   core, Playerbots, and AHBot commits intended to work together; document where
   each module should be cloned in a fresh core checkout.
2. Review the AHBot source snapshot, its retained notices and attribution, and
   the Playerbots donor provenance before their initial public pushes.
3. Construct an isolated publication branch from the upstream base or sanitize
   the local commit range. Preserve upstream history and donor authorship, but
   do not publish the older local snapshots containing workstation details.
   Review the outgoing commit author/committer identity as well as file content.
4. Review the exact outgoing file list and diff for secrets, private paths,
   generated data, unlicensed or unattributed imports, and misleading readiness
   claims. A pattern scan is an aid, not a substitute for this review.
5. From a fresh candidate checkout, clone both modules at the recorded commits.
   Build core-only, each module individually, and the two together; run available
   tests and the relevant disposable runtime checks. Record failures and gameplay
   limitations in the public notes.
6. Verify the README's install paths, module URLs/revisions, configuration defaults,
   upstream attribution, license notices and status claims against the exact
   candidate. Check that upstream badges are not presented as this fork's CI.
7. Only after reviewing all three destinations and candidate commit IDs, publish
   the two modules and then the matching core branch in one coordinated window.
   Do not include ignored checkpoints or historical evidence bundles as release
   assets.

No commit, remote change or push is authorized by this checklist itself.
