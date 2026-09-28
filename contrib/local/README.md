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
Run test-test-environment.ps1 and test-playerbot-harness-waits.ps1 for checks
that do not start services. DBC inspection scripts require -DbcDir.
