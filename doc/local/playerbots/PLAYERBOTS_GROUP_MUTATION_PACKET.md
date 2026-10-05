# Group strategy mutation integration packet

Updated 2026-10-04. Group dispatch and delivery are now connected behind the
separate default-off GroupMutations gate. Final reviewed Windows worldserver built
and all 318 checks passed; both-modules-disabled worldserver built with 19/19 checks
passing. The focused Linux protocol/group-policy subset passed 30 cases and
4,380 assertions under GCC 13.3. The full Linux modules-enabled worldserver and
tests-common build subsequently passed with 318/318 CTest checks on GCC 11.4.
The outdoor client replay observed removal of loot from all four bot strategy
lists, but aggregate ACK timing, STATE refresh and restoration remain open.
See PLAYERBOTS_STATE_MILESTONE.md. This does not authorize publication.

## Current integration

Authorized/controlled scope selection freezes at most 128 IDs before posts.
The world-owned table admits 32 batches, one per account, with fresh generations.
Copied binding holds account/group/scope and weak opaque login/cancellation markers.
Logout rotates the login identity; map execution rechecks identity, lease, native
group/raid membership and existing controller/security/phase/idle rules. The world
pump drains copied results and re-resolves current account/character/login before
replying once. Lost logins abandon replies; transfer/group/gate cancellation revokes
unexecuted work without undoing executed changes. Missing results remain unknown.
The gate requires StrategyControl.Enabled and AddonMutations, with MultiBot.Enabled
providing the transport. The disposable StrategyFixture enables these explicitly;
production defaults remain off. Six pure ownership/limit/correlation tests
accompany integration.
The implementation steps below are retained as the original review checklist;
their former missing pieces are now connected, not a claim of gameplay acceptance.

## Existing pieces

Single-bot C focus/threat/potions and N food/loot changes use copied native
requests, map execution revalidation and completion ACK after snapshot publication.
`PlayerbotStrategyBatch.h` now supplies a pure, world-owned aggregation policy:
fixed unique bot IDs (maximum 128), requester/token/state plus nonzero batch
generation, exactly-once terminal results and a four-second deadline. Queued work
cannot succeed; unresolved timeout counts remain unknown. It contains no roster
authority, dispatch, thread synchronization or transport implementation.
The pinned addon's strategy timer is five seconds, leaving one second for a
normal timeout ACK. Pending-entry removal revokes the execution lease so queued
work cannot run after the server closes the batch.

Bridge source: `1da05982e478cb00e0b6c87314afe7e0e9653ffb`,
RunStrategyMutationCommand/SendStrategyMutationAck. Addon reader refreshed at
`80148dff3f3a25a56d38dba0ecbd4f165b8c1d3f`: it accepts succeeded+failed <= matched
and preserves reason. Its UI labels partial/failed are not proof that unresolved
changes rolled back. Keep timeout an unknown outcome requiring state refresh.

## Original implementation checklist and preceding evidence

The preceding transport-only snapshot passed 312 enabled checks and 19 disabled
checks. Its once-missing table, dispatch, membership/session binding and world
pump are now connected; the integrated snapshot passes 318 enabled checks.
The inbox remains bounded at 4096 results. None of this proves native group-command
timing or gameplay. Linux source validation subsequently passed; runtime is untested.

1. Resolve scope membership on the world thread using native roster/group
   identities and current authorization. Define ALL/GROUP/PARTY/RAID semantics
   from donor/native group types; do not broaden controlled bots into arbitrary
   visible characters. Freeze admitted identities and reject oversized batches
   before posting anything. Reuse existing replay/rate guards.
2. Own a bounded pending-batch table on the world thread, with at most one
   outstanding mutation batch per requesting account. Assign a fresh generation
   so a later reuse of the same client token cannot accept old completions.
   Bind requester character/account/current session identity, not only a name.
3. The copied generation is carried through the existing native strategy hook.
   Connect authorized dispatch while preserving ordinary and single-bot paths. Admission
   rejections are known failures; accepted posts stay pending. Do not inspect
   another session's engine from the world thread or retain native pointers.
4. On each map update, retain existing controller/security/phase/idle checks.
   After engine execution and snapshot publication, the adapter submits a copied
   terminal result through the bounded, synchronized completion inbox. Add one world-thread
   pump aggregates results and re-resolves the current human session before
   sending a group ACK. No native packet delivery from a foreign map context.
5. Treat logout, transfer, cancellation, gate disable and missing completions
   honestly. Expired requests cannot become success; timeout does not prove that
   an already executed mutation was undone. Emit at most one group ACK. Refresh
   registrations before retrying a toggle; never auto-retry unknown toggles.

## Verification and activation boundary

Scope semantics were checked against bridge `BotMatchesCombatScope` at the pin
above: ALL matches its authorized visible roster; GROUP and PARTY are aliases
for the requester's current group, including a raid; RAID additionally requires
that group to be a raid. PARTY must not be changed into a non-raid-only filter.
For Cata mutations, intersect the native authorized roster with the existing
controlled-bot requirement before freezing identities. ALL is not permission to
control arbitrary online bots. Carry copied group identity/type where needed
and recheck native membership on execution, without retaining Group pointers.

Validation/review is complete on Windows; the group gate remains default-off.
Pure tests cover out-of-order/admission results, replacement login identity,
abandonment/cancellation, timeout/late/duplicate results, timer wrap, limit rejection
and ordinary/BOT mailbox regression. Native disconnect/reconnect, group/controller
changes and gate/transfer timing remain gameplay qualification, not claims from
these tests. Matching hooks built with modules enabled/disabled on Windows;
the Linux modules-enabled build also passed.
The deferred party replay can cover one group toggle/restore once activated;
keep it bundled rather than starting a separate realm for this feature.
