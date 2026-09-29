# Local publication privacy audit

Historical audit of the initial publication preparation. Subsequent snapshots
have been published using curated history. For new milestones follow
PUBLISHING_CHECKLIST.md and inspect the new outgoing diff; the findings below
describe the original audit and do not certify later changes.

Date: 2026-09-27. This audit covers local changes against the recorded upstream
base plus untracked source, and the five existing local commits. It is a targeted
source/privacy review, not a certification of all upstream code or server security.

## Findings and fixes

- Removed an embedded workstation account name from runtime-smoke.ps1 and its
  instructions. The script grants access to the executing identity, SYSTEM and
  Administrators; optional HostUser adds an explicitly chosen account. Existing
  sandbox helper access remains conditional. No personal account is the default.
- Removed a personal branch name, publication-account references and an internal
  worker-session identifier from local documentation. Original donor authorship
  and upstream attribution remain intact.
- Added ignore rules for generated test-db-credentials.json and test-login.txt
  even if accidentally copied outside ignored build directories.
- Scanned candidate source for workstation identities/paths, common provider key
  formats, private-key headers, literal credential assignments, email addresses
  and private-network addresses. No actual API keys or private keys were found.
  The two literal password assignments are the known disposable PB01 fixture
  credential; other fixture creation/output uses the same test credential.
  This is not a production credential and must only be used on the local test realm.
- Reviewed runtime-smoke's generated random database/login secrets and local
  bindings. Generated credentials/configs are inside the restricted, ignored
  test directory. The continuation harnesses consume copied fixture configuration;
  this audit did not perform a new runtime/network test.

Verification: the final scan covered 100 current candidate files; all added lines
in the five local commits were also checked for the key/private-key, personal-path
and private-network patterns. The remaining current scan hits were disposable
fixture password assignments and a false-positive session-ID match inside the
upstream CORPSES_FROM_MAP identifier. The revised smoke script parses successfully.
Its actual ACL block was exercised on empty temporary directories with both the
default identity and an explicitly supplied current account: inheritance was
disabled and only the expected identities were granted access. Ignore checks and
diff whitespace checks passed. No server or database was started for these checks.

## Publication still requires clean outgoing history

A second editorial pass removed references to unrelated host services and game
installations, acquired packages, client-backup hashes and personal workspace
layouts. Coding-provider setup and session diary details were replaced with
tool-independent contribution/review guidance. Relevant technical evidence and
donor attribution were retained. Test-helper documentation now states its Windows,
dependency-path and prepared-fixture requirements explicitly; cross-platform
helper execution has not been established by documentation changes.

Follow-up implementation: the smoke scripts now accept dependency/build/data
paths, continuation seeds are explicit, and fixture credentials have no historical
fallback. Each clone carries its own credential file. The DBC checks require an
explicit data directory. Service-free environment checks cover relative/absolute
paths, incomplete or unstopped fixtures, credential isolation and malformed or
unexpected endpoints; existing seven wait-policy checks also pass. All nine
PowerShell files parse. Full service startup with the revised arguments remains
runtime-test pending.

Four earlier local commit snapshots contain the old workstation account name in
the smoke script and documentation. Current-file cleanup does not remove it from
those commits. Commit author/committer metadata also carries the previously
configured GitHub identity and noreply address. Review the intended publication
identity before creating outgoing commits.

The existing local source checkpoint, history bundle, exported diffs and worker
snapshots predate this cleanup and may retain personal details. They remain
ignored local evidence and must not be uploaded as release artifacts. No historical
backup or Git history was rewritten or deleted during this audit.

Before the first push, construct a clean publication branch from the upstream base
and reviewed current source, retaining required attribution, or sanitize the local
commit range in an isolated checkout. Re-scan the exact outgoing commits and all
non-ignored additions. Do not push the existing development branch wholesale.
The separate module repository should start from the reviewed module contents.

No repository was created, no commit was made and no push was performed by this
audit. Pattern scans can miss unknown secret formats; file/history review remains
part of preparing the actual publication snapshot.
