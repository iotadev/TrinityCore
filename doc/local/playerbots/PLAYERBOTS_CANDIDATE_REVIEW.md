# Shared-state candidate review

Reviewed 2026-10-05. This is a targeted pre-milestone review of the uncommitted
core/module working trees, not a release approval or a complete security audit.
See [milestone evidence](PLAYERBOTS_STATE_MILESTONE.md) for builds and gameplay.

## Boundaries checked

- Core hooks delegate to the optional module; ordinary client sessions do not
  execute server-origin strategy hooks. The added movement/phase getters expose
  existing native state rather than replacing native movement or phase ownership.
- Group strategy admission freezes authorized controlled identities before any
  post, rejects more than 128 bots, and bounds the world-owned table to 32 batches
  and one outstanding batch per account. Map execution rechecks the controller,
  native membership, phase, security, idle state and copied login/lease binding.
- Logout rotates the opaque login marker. Pending-entry removal revokes queued
  work; previously executed changes are not rolled back. Completion transport
  contains copied values, not native pointers, and caps its inbox at 4096 results.
- Map strategy snapshots are atomically published before completion submission.
  The world reply path resolves the requester again and checks login identity.
  Four-second server expiry precedes the pinned five-second addon timer, but
  stalls or network latency can still cause an unknown client outcome.
- Ready-check identities are generated on the world thread; queued replies are
  rechecked against current group membership, initiator authority and check age.
  Ordinary client ready-check replies retain their native path.
- Strategy mutation gates default off and require the base control gate.
  The optional disposable fixture explicitly enables the bridge and mutation
  gates. Its PowerShell parser check passed; this is a local test helper, not
  a Linux server installation dependency.

No new blocker was identified in these paths. This does not establish all
thread-interleaving behavior, every changed class action or native client timing.
The later October 5 client attempt exposed a separate fixture/transfer gap:
recovery mode bypasses dedicated dungeon entry, while ordinary cross-map summons
do not receive the required bot acknowledgement budget. The earlier review did
not cover that route. See the current handoff before preparing another replay.

## Publication hygiene checked

Targeted scans of module README/provenance/config/docs/command headers and the
active roadmap/handoff/group packet found no matches for the known private host
username, other-account name, disposable password, personal absolute paths or
the scanned API-key patterns. This is not an exhaustive secret scan of Git
history or every outgoing file. Build logs remain in an ignored local directory.
Both repositories pass whitespace checks. Full outgoing-file/history review and
the correct commit identity still need confirmation before a publication push.

## Remaining acceptance

Windows and Linux modules-enabled builds passed all 318 registered checks;
Windows modules-disabled passed 19. Linux realm runtime remains untested.
The outdoor replay established four-bot engagement and group loot removal in
chat queries, not aggregate ACK timing, framed STATE refresh or restoration.

Use one human-led Ragefire session to finish those observations together with
sustained tank/healer behavior, stop/follow recovery and natural recovery/loot.
Do not require a forced wipe, mount training or high-level spells. Preserve
unobserved features as deferred. Collect concrete failures into one donor-aligned
corrective batch, then review the matching core/module milestone for commit.
No realm was started or remote changed for that review. Subsequently, the
corrected October 5 replay passed dedicated entry and basic trash combat, with
clean shutdown and successful player feedback. The matching milestone commits
record these observations; longer support/recovery and addon timing remain deferred.
