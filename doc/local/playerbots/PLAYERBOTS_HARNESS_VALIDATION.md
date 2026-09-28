# Full-party fixture and wait-policy validation
Historical commands below record the original runs. For a new run, supply
`-MySqlHome <installation-directory>` and `-Seed <your-stopped-fixture>`;
see the current [runtime instructions](../core/RUNTIME_TESTING.md).


Date: 2026-09-26. No gameplay decision changes, new spells, donor engine import,
live database writes, commit or push occurred in this slice.

Changes:

- Reset all four offline bot positions to the established Eversong homebind in
  the copied database, including reused Testtwo. Preserve level, spells and gear.
- Reject existing party records instead of deleting them.
- Before human login, require each bot's database outdoor map and a fresh
  console slot status reporting ready/in-world. Online=1 alone is insufficient.
- `-Interactive -CheckFullParty` removes human-step deadlines and mandatory
  combat/death assertions; server startup, bot readiness/transfer and teardown
  remain bounded. A `stop.request` file in the printed test directory cancels a
  wait and enters existing test-owned cleanup.
- `-CheckRosterOnly -CheckFullParty` verifies the prepared roster without a client.
- Reuse of a stopped mixed-class pre-party fixture is supported.

Service-free `test-playerbot-harness-waits.ps1`: seven checks passed, including
immediate completion, unlimited wait completion, explicit stop, world exit,
bounded timeout and both human-wait policies. Parser and diff whitespace checks
passed. The entire harness is not evaluated by these unit checks.

An initial runtime attempt using `build/playerbot-smoke-20260926-042538` was
rejected for existing group membership and cleaned up test-owned processes.
This was not counted as a successful replay.

Successful command:

```powershell
.\contrib\local\playerbot-lifecycle-smoke.ps1 -Seed build/playerbot-smoke-20260926-032854 -ModuleConfig -CheckFullParty -MixedParty -CheckRosterOnly
```

Evidence: `build/playerbot-smoke-20260926-150625`. Feature-off fixture preparation
used native character dumps/imports and the native offline revive path. The final
enabled server admitted Testone, Testtwo, Botmage and Botpriest. Each had a fresh
ready/in-world slot response and database map 530. All four saved/logged out;
normal shutdown succeeded and all test-owned services stopped.

The previously saved Testtwo dungeon position is a plausible contributor to the
invite lookup incident, not a proven complete root cause. Client invitation,
combat/healing, manual stop-file cleanup and interactive dungeon pacing still
need integrated observation. Headless roster success does not establish them.
