# Player-controlled infrastructure milestone

This checkpoint covers player-controlled small parties, not autonomous population
or full donor feature parity. Do not mark it complete from source review alone.

Scoped implementation and acceptance completed 2026-10-01. Publication remains
a separate action; see the core README for the exact matching module revision.

## Completed evidence

- Optional module boundary, native managed admission and lifecycle receipts,
  account-link control, bounded MultiBot transport and native character factory
  are implemented in the matching development checkouts.
- Windows worldserver/tests-common built and all 109 automated checks passed
  after the party-buff engine adaptation. Earlier factory builds also included
  authserver. The later Linux-only include correction has no gameplay changes.
- Disposable native factory enrollment/create/exact reuse/accounting repair,
  rejection gates and explicit managed login/save/logout passed with clean
  shutdown. Missing optional schema rejects before its fatal SQL query.
- Lua 5.1 syntax and real donor Comm mock checks passed. The earlier Windows
  client confirmed clean addon startup and Stay/Follow/main Attack only.
- The 2026-10-01 bundled ordinary-player check confirmed native character
  creation and realm accounting, discovery in MultiBot's My Bots roster,
  addon-driven connect/disconnect/reconnect, cleared bot-account online state
  after disconnect, and clean world/database shutdown.
- New source/documentation paths were checked for personal identifiers, host
  paths and credential patterns; generated fixtures remain ignored. Research
  provenance retains source evidence rather than tool-session identifiers.
- Both development repositories now select iotadev as their local commit identity.
- Linux worldserver/authserver/tests-common built with both modules enabled on
  Ubuntu 22.04/GCC 11.4, Release and no core/script PCH. All 109 CTest cases passed.
  Explicit array and map-store include corrections were required. This is build
  and automated-test evidence, not Linux runtime validation.

## Publication boundary

Keep module/core commits separate and record the exact accepted module revision
in the core README. Publishing is separate from local acceptance and commits;
no push is performed by this acceptance step.

Existing historical reports retain their dated evidence. Current status belongs
in the roadmap/work packets and this checklist. Linux server runtime, complete
rotations, autonomous population and full dungeon functionality are not certified
by this checkpoint. Party-buff engine execution stays with the next mixed-party
check rather than adding another isolated test before the infrastructure commit.

The first client fixture lost its processes without clean-shutdown evidence;
the cause remains unconfirmed. Recovery preserved the client-created character
and verified its realm count before the corrected check reused it. The successful
rerun does not establish the earlier stop's root cause. Password/name setup
errors were corrected in the harness and are not gameplay failures.
