# Shared-state candidate review

Initial review 2026-10-05; follow-up audit 2026-10-06. The dated findings below
record targeted source reviews, not a release approval or complete security audit.
Use the [handoff](PLAYERBOTS_WORK_PACKETS.md) for current qualification and the
[roadmap](PLAYERBOTS_PORT_ROADMAP.md) for priorities.

## Follow-up audit — 2026-10-06

October 7 follow-through: the connected native roll path passed Windows/Linux
worldserver/tests-common builds and 384 tests on each. Current Windows with both
optional modules disabled passed 19 tests. The controlled native need/greed/pass
and saved-award replay passed. Outgoing review included the new files and native
group fence; no new blocker was identified. The following paragraphs retain the
earlier audit snapshot and recommendations, now completed for this milestone.

The donor-aligned coordination/equipment direction remains appropriate. Current
Windows source passed 379 tests; Linux passed 372 through native equip, with
newer item-usage/template work pending. The copied Testone equip check established
one empty-slot move and saved item preservation. No complete dungeon clear or
native loot-voting acceptance is claimed.

Next finish the connected optional loot path for supported non-affixed items.
The pure policy currently accepts a usage category; its future caller must
establish actual roll identity, scope, freshness and native eligibility. Tests
should exercise expired/duplicate/ineligible requests at that boundary. The
current template-identity unit test constructs its own fact and does not exercise
the native reader. Consolidated current docs now separate these limits from
published and historical evidence.

Before milestone publication, complete Linux validation and one bundled party/
loot check, then review both repositories including new untracked files.
Return to the human-led dungeon goal; broader item classification can follow.

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

At this review's original snapshot, Windows and Linux modules-enabled builds
passed all 318 registered checks;
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

## Local coordination review — 2026-10-05

Qualification at the native-equip checkpoint (October 6): the bounded equipment/statistics,
starter-score and read-only inspection layers, followed by explicit single-step
native equip, passed Windows/Linux worldserver builds and 372 tests. The outdoor
read-only report was observed on Testone. The later copied-realm equip check
confirmed one empty-waist move and saved item preservation, with clean shutdown.
Relogin and occupied-slot displacement remain open; this does not imply
full equipment parity or automatic need/greed. Details and limits are recorded
in module PORTING.md and the current work packets.

The newer uncommitted source passed Windows/Linux worldserver builds and 330
checks. Review of the combined change confirms explicit main-tank selection
preserves unavailable assignees, fallback selection stores identities rather than
native pointers, and assignment does not grant a spec/rotation. Tank ranking,
rescue switching and automatic Warrior taunts share no-steal protection.

Active DPS reassessment applies only to engine-enabled auto-assisted Mage/damage
Warrior, not explicitly commanded attacks, tank/main-tank assignments, Priest
support or active native casts. Fresh map-thread creature resolution feeds the
existing party engagement, control/range/LOS and native attack checks. Successful
replacement uses the existing cease/start transition, which cancels obsolete
queued actions. Missing/unchanged candidates leave the current attack untouched.
This is source review, not multi-tank or multi-enemy gameplay acceptance.

Donor loot-roll review identifies a separate dependency: `LootRollAction` uses
`ItemUsageValue` for upgrade/use/vendor/disenchant classification and roll policy.
The current Cata bridge intentionally uses native pass-on-group-loot preference;
full automatic need/greed must wait for the item-usage/equipment layer and a
native group-owned execution path. Do not emulate it by iterating or changing
native Group/Roll state from the bot map update. No loot behavior changed here.
