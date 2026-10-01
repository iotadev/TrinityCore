# Managed lifecycle research pilot

Date: 2026-09-29. Status: **desktop report received; corrections required**.

## Audit of the desktop report

A completed externally generated report was supplied for review. Its exact model
and generation settings were not recorded in the result. The
[original output](NEMOTRON_LIFECYCLE_OUTPUT.md) is preserved without repairs.
The audit used the supplied immutable source revision. No runtime or Cata
implementation conclusions follow from this source review.

Verified: `PlayerbotHolder::AddPlayerBot` at `src/Bot/PlayerbotMgr.cpp:85`,
its account-cache/online/eligibility guards, the database callback at 158-189,
the null-Player cleanup at 212-220, and `LogoutPlayerBot` at 350 with native
logout and session deletion at 408-409. The report is useful for initial
navigation but incomplete on the requested async/completion boundary.

Corrections and missing evidence:

- `PlayerbotOperations.h` is inside the supplied `src/Script/WorldThr` subtree.
  `OnBotLoginOperation` is defined at 485; `Execute` resolves the bot and holder,
  then calls `holder->OnBotLogin(bot)` at 512. `PlayerbotHolder::OnBotLogin`
  registers AI data and the holder roster at `PlayerbotMgr.cpp:470-473`.
  Login callback 209 only invokes native loading; after the null check it still
  queues registration at 235-236. Loading and completed manager registration
  must not be conflated. Actual native world-entry semantics need core inspection.
- `BotLogoutGroupCleanupOperation` is defined at `PlayerbotOperations.h:418`.
  It re-resolves Player/AI, may save repository state and returns a result.
  Queueing it is separate from the inline native logout at `PlayerbotMgr.cpp:408`.
  Its queue call is at 360, not 359 (which constructs the operation).
- `PlayerbotWorldThreadProcessor.cpp:33` defines `QueueOperation`; it returns
  false for a null operation or full queue (35-52). Processing checks validity
  at 99 and calls `Execute` at 112, tracking aggregate statistics/logs at 123-143.
  Login callback and logout callers do not inspect the queue return value.
  These observations do not establish a durable per-request outcome ledger.
- Caller corrections: `LogoutAllBots` calls logout at 305, while 295 begins its
  loop. Named bot command processing calls `ProcessBotCommand` at 1318/1324,
  then `AddPlayerBot` at 706; 1300 inserts a name into a set. The autonomous
  caller is also present at `src/Bot/RandomPlayerbotMgr.cpp:1380`.
- `ProcessBotCommand` returns `"ok"` at 707 immediately after the void admission
  call. That response cannot establish successful admission: guards and holder
  initialization can return without loading. `botLoading` prevents repeated
  submissions at 87-88. If the master disappears during the callback, routing
  can fall through to the random manager at 188. These are useful additional
  lifecycle scenarios for the next implementation review.

Decision: this pilot supplies a usable navigation starting point but needs too
much correction to count as demonstrated savings. Continue this already-inspected
lifecycle batch directly with Astra/Sol. For later source gathering, require
following queued operations through execution and checking the supplied tree
before declaring a dependency unavailable. Do not promote original worker
claims into the roadmap or porting provenance. No measured token savings exist.

## Scope and evidence

One direct OpenCode request to NVIDIA `nvidia/nemotron-3-super-120b-a12b`,
using the plan agent and an isolated public-source checkout. Read/list/glob/grep
were allowed; edits, shell commands, delegation, external-directory access and
web tools were denied. No local LLM manager was used.

Upstream master was checked and the snapshot pinned to
`7bae1b5c58c76a0aa20381155edc08096d1485b2`. The supplied subtrees were
`src/Bot`, `src/Mgr` and `src/Script`. This historical pilot covered lifecycle
archaeology only; later MultiBot implementation is tracked in the current roadmap.

Earlier provider submissions failed with an HTTP 401 missing-authorization
response and produced no model output. This is transport-configuration evidence,
not a model-quality result or proof of an invalid credential. Separate OpenCode
instances may have different provider configuration; validate the specific
worker endpoint before delegation. No secrets or tool-session identifiers are
needed in a source handoff. The reviewed report above is separate evidence from
those failed submissions.

## Reusable prompt

Read-only research pilot for Cata Playerbots. Repository mod-playerbots/mod-playerbots at 7bae1b5c58c76a0aa20381155edc08096d1485b2 (freshly checked upstream master). Only src/Bot, src/Mgr, src/Script are supplied. Use read/grep/glob only within this directory; no editing, shell, web, delegation or unrelated files. Begin src/Bot/PlayerbotMgr.{h,cpp}; trace relevant callers and operations within supplied source. Produce <=650 words: table of existing-character login/logout entry points, callers, async operation/callback boundaries, and where success or failure becomes observable. Every factual row needs exact file:line plus symbol. Explicitly distinguish queued/accepted from completed; do not invent a durable completion ledger. Add at most four source-supported failure/test scenarios and mark any missing dependency unknown. No architecture recommendations, security verdicts, Cata compatibility claims or code changes. Report the supplied immutable revision. This is evidence for a separate human/senior audit, not implementation approval.

## Resume and audit

Confirm the intended OpenCode instance has working NVIDIA authentication without
printing or storing credentials in project files. Then submit once and retain
the original output separately from reviewer corrections. Refresh the source
pin if upstream changes before resumption.

Verify every reported symbol/line and the relevant caller before accepting a
finding. Check especially acceptance versus completed login/logout and omitted
dependencies. A useful report can become a navigation aid for the implementation
batch; it is not approval of architecture, threading, security or database
behavior. Keep those decisions, implementation and final review with Astra/Sol.
Allow at most one focused correction before deciding that direct work is cheaper.
No token-saving or researcher-reliability result has been established yet.
