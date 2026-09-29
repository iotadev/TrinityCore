# Local development scripts

This directory contains local test and preservation scripts. Their maintained
instructions and validation reports are collected in
[doc/local](../../doc/local/README.md).

Start with [runtime test instructions](../../doc/local/core/RUNTIME_TESTING.md)
or the [Playerbots roadmap](../../doc/local/playerbots/PLAYERBOTS_PORT_ROADMAP.md).
Generated databases, credentials, logs and evidence stay in ignored build/
directories. Module-owned documentation remains inside modules/mod-playerbots.

The smoke scripts take explicit dependency paths; continuation runs require
-Seed and -MySqlHome. test-environment.ps1 supplies shared input validation.
For a mixed-party replay whose valid stopped seed lacks Mage/Priest source
characters, `playerbot-lifecycle-smoke.ps1 -ClassDumpDirectory` can read the two
previously exported class dumps from a separate `build/playerbot-smoke-*`
directory. It copies only those dumps into the new disposable stage; the source
directory is not used as a database seed or modified.

Run test-test-environment.ps1 and test-playerbot-harness-waits.ps1 for checks
that do not start services. DBC inspection scripts require -DbcDir.

Use build-local.ps1 from PowerShell 7 with an existing Visual Studio CMake build
directory when a launcher
supplies duplicate `Path`/`PATH` variables. It normalizes the build child's
environment and builds serially without changing the calling shell. Pass
`-RunTests` to run CTest after a successful build.
Pass `-Configure` when new source files or CMake settings need regeneration.
