# Low-level companion-party prototype checkpoint

Historical 2026-09-27 evidence. The later gated-engine and whisper checkpoint
is recorded in NEXT_MIXED_PARTY_TEST.md (2026-09-29); the roadmap is the current
status. Statements below apply to this earlier revision.

Date: 2026-09-27. Status: client-observed low-level mixed-party prototype;
not a complete upstream Playerbots Engine or general dungeon-clear implementation.

Evidence directory: build/playerbot-smoke-20260927-122450 (local, ignored).
Reproduction: playerbot-lifecycle-smoke.ps1 -Seed <stopped-mixed-party-fixture>
-ModuleConfig -CheckFullParty -MixedParty -Interactive.

The isolated copied database admitted Testone, Testtwo, Botmage and Botpriest.
All four accepted party membership and the harness completed instance-entry
checks for Ragefire Chasm. The user reported good party behavior and healing,
including the Priest healing itself, and judged it close to a functional
low-level party. Logs recorded 18 accepted Mage offensive casts, 17 accepted
Priest healing/shield casts and three Fortitude casts. These are accepted cast
attempts, not a claim that every cast completed or every encounter succeeded.
Examples include Heal on Botmage and Heal on Botpriest.

After human logout, all four bots logged out and the harness verified offline
state. worldserver exited normally, database pools closed and the harness stopped
all test-owned processes (exit code 0). Ports 13306/3724/8085/8086 were free at the
post-run check. The 47-case enabled automated suite also passed this day.

Known limitations:

- Test and Testone needed manual resurrection during setup/play. Testone accepted
  an invitation while dead but did not initially start following. This is a
  revive-after-invitation gap; do not count automatic recovery as verified.
- Priest positioning uses close formation rather than healer-range positioning.
- Starter class kits only: actual tank/threat behavior, mana/rest management,
  complete spec-aware rotations and dependable death/recovery remain unfinished.
- Upstream NamedObjectContext, Event and NextAction imports compile and are tested,
  but do not yet own live bot decisions. Current companion behavior is transitional.
- No forced wipe, full dungeon clear, autonomous population or general extension
  compatibility claim is made from this run.

This run supported the original source-preservation checkpoint. Current source
publication practice is recorded in PLAYERBOTS_REPOSITORY_PLAN.md; the
limitations above apply to this historical playtest evidence.
