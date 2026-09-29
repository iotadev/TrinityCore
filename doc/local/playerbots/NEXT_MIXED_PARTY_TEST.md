# Mixed-party release check — 2026-09-29

Four bots accepted the development human's invitations and entered Ragefire
Chasm. The Warrior, Mage and Priest engine routes were enabled. Logs recorded
13 accepted Mage offensive casts, six Priest healing casts and one Fortitude
cast. The player reported good overall behavior and basic whisper/movement
controls. Logout completed and all test-owned services stopped cleanly.

This confirms the Mage opener correction and an operational mixed party.
The human account had GM privileges, so ordinary-player authorization boundaries
remain source-reviewed rather than independently exercised by this session.
No full dungeon clear, tank-threat qualification, complete rotation, resurrection
or removal/re-invite claim follows from this run.

One `attack` after `stop` was rejected with Botmage selected rather than a hostile
unit. A later explicit Earthborer attack and casts were logged. Keep the command
target-selection ambiguity with future control/addon work; it is not a reason
to block the manager and roster port or schedule a separate playtest.

## Reproduction inputs and procedure

Use a cleanly stopped disposable seed with `test-db-credentials.json` and the
human/Warrior fixture. If it lacks Mage/Priest source characters, supply a
separate stopped `build/playerbot-smoke-*` directory containing nonempty
`mage-template.dump` and `priest-template.dump`. This is a read-only source of
class dumps, not another database seed. The harness prepares a new copied realm.

From PowerShell in the core root, substituting your own prepared input paths:

```powershell
./contrib/local/playerbot-lifecycle-smoke.ps1 `
  -Seed '<stopped disposable fixture directory>' `
  -ClassDumpDirectory '<class-dump directory under build>' `
  -MySqlHome '<MySQL installation directory>' `
  -ModuleConfig -CheckFullParty -MixedParty -Interactive `
  -EngineWarriorCombat -EngineMageCombat -EnginePriestHeal
```

The harness prints its new ignored output directory and announces readiness.
Log into the human fixture, invite Testone, Testtwo, Botmage and Botpriest,
whisper `list`, `stay` and `follow`, then enter Ragefire through its portal.
Make a normal pull; select a hostile unit before whispering `attack`, then try
`stop`. Log out to finish. Human steps have no deadline in interactive mode;
a `stop.request` file in the printed directory ends the wait and shuts down
test-owned services. The installed server and client configuration are not
changed by this harness.

Accepted-cast logs confirm that native casting accepted an attempt; they do
not prove every spell landed or that a role was played well. Combine the logs
with the player's observation.

The actual run's ignored evidence is
`build/playerbot-smoke-20260929-111951`. Its input fixture combination was
validated by this run. Databases, credentials, dumps and logs are local evidence
and are not distributed with the repository. The legacy filename of this report
is retained so existing links continue to work.
