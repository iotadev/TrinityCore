# Milestone publication checklist

Updated 2026-09-29. Initial coordinated snapshots already exist. Use this
checklist when publishing subsequent core/module work; repository boundaries
are documented in [the repository plan](../playerbots/PLAYERBOTS_REPOSITORY_PLAN.md).

1. Identify the tested core and module contents. Review pending changes in each
   repository separately and leave unrelated runtime assets out.
2. Fetch the intended publication branches. Use their current history as the
   parent of the new commits. Preserve existing fixes and documentation;
   private development ancestry is not an outgoing dependency.
3. Verify the destination and configured author/committer identity. The core
   publication destination is `iotadev/TrinityCore`, not its upstream project.
   Never resolve a mismatch by an unreviewed force push.
4. Review actual outgoing files and new history for personal paths/identities,
   credentials, generated data, missing source attribution and unsupported
   readiness claims. Pattern scans complement review.
5. Run checks proportionate to the change. For new core/module code, verify the
   matching build and affected tests. Recheck disabled-module boundaries when
   changed. Use one representative client session for integrated gameplay work;
   do not repeat it for documentation edits or every individual spell.
6. Commit the module and record that exact revision in the core README. Check
   documentation links, configuration names/defaults and the current roadmap.
   Keep dated validation notes clearly historical.
7. Push the module, then the matching core revision, using ordinary fast-forward
   updates. Verify both remote heads and the recorded pairing.

Client files, extracted game data, copied databases, live configuration, logs,
private history bundles and worker snapshots are not release assets. Portable
test/build script source can be published after review; its required local
fixtures and dependency paths must remain explicit.

The 2026-09-29 playtest established four-bot admission/instance entry, basic
whispers, Mage offensive casting and Priest healing with clean shutdown.
Full rotations, dependable death recovery, tank threat and autonomous population
remain outside that evidence. Publication notes must retain those limits.
