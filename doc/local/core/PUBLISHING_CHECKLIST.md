# First public source snapshot: status and checks

The target is the
Cataclysm 4.3.4.15595 TrinityCore fork. AHBot and Playerbots are optional static
modules with narrow core integration seams. Both now have separate local Git
repositories ignored by the core checkout. The intended first public snapshot
is a coordinated three-repository set: core, Playerbots, and AHBot. No client,
extracted game data, database, credentials, build products or local evidence
bundles belong in any outgoing repository.

## Current boundary (2026-09-28)

- Reviewed source snapshots have been pushed to `iotadev/TrinityCore`,
  `iotadev/cata-playerbots`, and `iotadev/cata-ahbot`. Source upload and public
  repository visibility are separate steps. The core README is the authority
  for matching module revisions; GitHub shows each repository's visibility.
- The core publication branch was prepared in isolation from the development
  tree and retains upstream history, including the fork's existing StormLib
  fix. Playerbots starts from a new reviewed source snapshot rather than its
  earlier local commit history. The module sources live in independent checkouts at
  `modules/mod-playerbots` and `modules/mod-ahbot`; neither is included in a
  core clone. All three are still being developed.
- Older local development commits and evidence bundles are outside the
  publication branch. See [the historical privacy audit](PUBLICATION_AUDIT.md).
- AHBot-enabled and AHBot-disabled worldserver builds passed after the module
  move. A disposable replay loaded its active module config, made 12/12 seller
  listings, exercised both relocated ratio commands, and bought one of two
  player auctions under the buyer action cap. Earlier Playerbots build/lifecycle
  checks used the matching development module. These are checkpoint results, not
  tests of the final publication snapshot or all gameplay behavior.
- From the isolated publication candidate, `worldserver` and `tests-common`
  build in RelWithDebInfo with neither module, with each module individually,
  and with both modules. CTest passed
  19/19 core-only, 65/65 Playerbots-only, 19/19 AHBot-only, and 65/65 combined.
  The later Playerbots history recreation preserved its exact Git file tree.
  Subsequent publication edits changed documentation and ignore rules only.
  The final core rebase retained an existing StormLib CMake definition change;
  that rebased combination has not received a new build-matrix run.
- A disposable runtime replay of the final published combination and an in-game
  test of the opt-in Warrior engine path remain pending. A later AHBot replay
  attempt stopped during fixture preparation and supplied no new runtime proof.
  Publication is an experimental source checkpoint, not a production-readiness
  or complete dungeon-clear claim.

## Checks for publication and subsequent updates

1. Freeze a named checkpoint across all three repositories. Record the exact
   core, Playerbots, and AHBot commits intended to work together; document where
   each module should be cloned in a fresh core checkout.
2. Review the AHBot source snapshot, its retained notices and attribution, and
   the Playerbots donor provenance before publication.
3. Construct an isolated publication branch from the upstream base or sanitize
   the local commit range. Preserve upstream history and donor authorship, but
   do not publish the older local snapshots containing workstation details.
   Review the outgoing commit author/committer identity as well as file content.
4. Review the exact outgoing file list and diff for secrets, private paths,
   generated data, unlicensed or unattributed imports, and misleading readiness
   claims. A pattern scan is an aid, not a substitute for this review.
5. From a fresh candidate checkout, clone both modules at the recorded commits.
   Build core-only, each module individually, and the two together; run available
   tests when executable changes justify them. Record which source revisions
   were tested and distinguish build checks from runtime/gameplay evidence;
   disclose any pending runtime checks as above.
6. Verify the README's install paths, module URLs/revisions, configuration defaults,
   upstream attribution, license notices and status claims against the exact
   candidate. Check that upstream badges are not presented as this fork's CI.
7. After reviewing all three destinations and candidate commit IDs, publish
   module updates before the core documentation that pins them. Coordinate
   repository visibility separately for the initial public announcement.
   Do not include ignored checkpoints or historical evidence bundles as release
   assets.

No commit, remote change or push is authorized by this checklist itself.
