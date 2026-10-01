# Bounded native character factory: execution packet

Completed server acceptance update: the fresh disposable factory batch passed
schema preflight/application, eligibility/enrollment, native creation, exact
reuse with realm-count repair, conflicting intent rejection and explicit managed
login/save/logout, with clean world/database shutdown. Both servers built and
all 106 automated tests passed. This supersedes the earlier pending/runtime
statements below, which record implementation stages. Missing schema originally
caused a fatal SQL error; metadata preflight now rejects before querying the
optional table. Ordinary client creation/accounting and addon-managed lifecycle
subsequently passed their separate bundled client check on 2026-10-01; this
server-only factory batch did not certify them. The subsequent Linux build
and all 109 tests passed; Linux realm runtime remains unverified.

Source review: 2026-09-30. The implementation-stage notes below are historical;
the completed acceptance updates above supersede their pending statements only
for the behavior explicitly verified.

Current operator slice: console-only, default-off enrollment of pre-created
empty accounts, native create submission, accounting-only exact reuse recovery
and status are now implemented in source. There is no automatic account creation,
roster/config publication or admission. Worldserver/authserver/tests-common built
with both modules enabled and all 106 automated tests passed; no schema
or operator query/write has run in the disposable realm yet. The next step is
the combined acceptance scenario below, not another isolated appearance test.

Current addition: creation-only contexts await both native creation and an
authoritative realm-count repair before reporting readiness. The original
realm-count write is awaited first; the repair confirms its own commit. The
const receipt distinguishes Reconciling and AccountingFailed, with separate
committed-GUID recovery evidence. Human creation behavior is unchanged.

Ownership/reuse decision helpers now exist under the donor factory directory.
They require verified ownership, eligible profiles and exact existing identity,
rejecting conflicts/additional characters. They do not acquire ownership proof.
The operator caller now gathers persistent evidence before native submission
or exact rerun recovery. No player/addon creation endpoint or live persistence
check exists yet.
The ownership-reader slice now supplies an optional manual auth schema and
default-off console inspection. Its evidence binds account ID/name/join epoch
and realm to the stored character intent. The operator slice builds on that
reader; no migration or live query was performed. See module sql/README.md.
The accounting/ownership slice built worldserver, authserver and tests-common
with both modules enabled and passed all 103 automated tests. The six new cases
cover receipt and ownership policy; database callback timing remains unverified.

The first implementation slice now provides a read-only appearance draft in
RandomPlayerbotFactory and a console-only `managed appearance` diagnostic.
It adapts donor selection to Cata CharSections fields, native race/class data,
creation masks/expansion and Player::ValidateAppearance. Selection is
deterministic and bounded for this explicit draft; random population remains
out of scope. It does not check a particular account, name, character limit
or Death Knight unlock, and is not permission to create that character.
The appearance diagnostic itself performs no persistence, cache publication,
session or managed-identity mutation.

The next native seam is now in source: WorldSession::BeginCharacterCreation
copies a typed CharacterCreateInfo and runs the preserved native validation/save
body. The ordinary client handler uses the same entry point. Its session-owned
receipt reports native failure or character-commit/cache success; destruction
before completion is abandoned, not proven rollback. Pending requests cannot
overwrite each other's receipt. A separate world-owned CharacterCreation context
now exists and the console factory uses it without admitting a player session.
Active/loading players and admitted bot sessions are ineligible.

The dedicated owner uses a separate bounded world registry, skips account-online
writes and reserves its account against human/bot admission until native receipt
completion. It pumps only creation callbacks, not normal session gameplay/update.
At most 16 contexts exist; online/privileged/banned profiles reject provisioning.
World destruction marks unfinished outcomes abandoned, not rolled back.

Validate module-owned dedicated-account authorization, persistent evidence and
retry/recovery together in the disposable realm. Existing account prefixes or name matches are
not ownership evidence. Do not take the native receipt as proof of cross-database
atomicity. No account/character writes or runtime context check were performed.
The combined build and all 95 headless tests passed for this native seam;
normal client creation through this seam and the factory caller remain runtime-unverified.
The later world-owned context slice also built authserver/worldserver and passed
all 97 automated tests. Its account-profile and reservation checks are headless
policy evidence, not a native persistence/callback timing check.

## Result and scope

Adapt the donor factory family to create or reuse a small explicitly configured
set of managed identities. Use native account/character APIs, then the existing
managed roster/admission service. Start with operator-requested provisioning;
no addon creation endpoint, automatic population, random leveling, guilds,
arena teams or deletion/cleanup. Do not modify existing unrelated identities.

## Source basis

Upstream mod-playerbots master was queried directly and remains
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

- `src/Bot/Factory/RandomPlayerbotFactory.cpp:65`, CreateRandomBot: race/class
  selection, CharSections appearance selection, native Player::Create and cleanup.
- Same file:461, CreateRandomBots: account selection/creation and bulk orchestration.
  AccountMgr creation call is at 642; temporary WorldSession starts at 720 and
  per-class creation/save at 734-741; immediate cache publication follows SaveToDB.
- Donor PlayerbotFactory is a separate progression/equipment feature family;
  do not import it just to obtain a level-one native identity.

Matching Cata core inspected in this working checkout:

- `src/server/game/Accounts/AccountMgr.{h,cpp}`: CreateAccount is the native
  account creation API; inspect its return and transaction behavior before reuse.
- `src/server/game/Handlers/CharacterHandler.cpp:313`, HandleCharCreateOpcode:
  native validation, async name/account/realm-limit checks and final creation.
- Same file:602-649: temporary Player ownership with CleanupsBeforeDelete,
  MotionMaster initialization, Player::Create, first-login flags, SaveToDB into
  a CharacterDatabase transaction, realm-count LoginDatabase update, and
  AsyncCommitTransaction success callback before OnPlayerCreate/cache publication.
- `modules/mod-playerbots/src/Bot/PlayerbotManagedRoster.{h,cpp}` and
  `src/Bot/Cmd/PlayerbotManagedControl.{h,cpp}`: identity and admission owners.

Line numbers describe this reviewed source snapshot, not a stable API.

## Owner and Cata invariants

The module owns provisioning selection/orchestration. Core remains authority
for character validation, persistence and player/session ownership. Inspect
whether a narrow native creation service can be extracted from the handler
without bypassing its rules; do not fabricate client packets or start a human
session as an implementation shortcut. Resolve callback ownership before code.

- Use Cata race/class/appearance data, including its different playable pairs;
  do not reuse Wrath masks or expansion constants as Cata validation.
- Do not reproduce the donor's unguarded random indexing into empty appearance
  collections. An unavailable appearance/name is a bounded failure.
- Never block the world thread waiting for an entire database queue to empty.
  A queue size of zero is not a per-character commit receipt.
- Publish a newly created character to cache/managed admission only after its
  native creation transaction succeeds. Keep async owners alive until completion.
- Character and login databases are separate: Cata currently submits the
  realm-count transaction before the character-commit callback. Do not claim
  atomicity; decide bounded failure/reconciliation behavior before adapting it.
- Reuse must verify account and character ownership and all required identity
  fields, not assume a matching name/prefix is ours. Do not reset passwords,
  change account security or adopt conflicting human accounts on rerun.
- Retain default-off gates, one active character per account and the existing
  explicit account-link policy; provisioning does not grant player control.
- No password logging, fixed/public credentials or production DB contents in
  provenance packets. Preserve donor notices and document deliberate reductions.

## Acceptance and stop points

### Operator slice implemented; integrated acceptance pending

- Console-only enrollment explicitly dedicates an existing empty ordinary
  account, capture its native name/join epoch and normalized character intent,
  and confirm the evidence write. Never silently adopt a conflicting record,
  reset credentials or infer dedication from names. An empty table after schema
  installation is expected; inspection cannot enroll an account.
- Native creation submission consumes that verified record and appearance
  draft, reserve through the world-owned context, retain its read-only receipt,
  and expose status without automatically granting admission/player control.
- Rerun of an exact existing character uses a reserved native accounting-only
  recovery path, not another character-create attempt. Verify account/GUID
  ownership before constructing recovery success; retain the same confirmed
  accounting readiness contract. Do not make a duplicate-name rejection look
  like successful reuse or manufacture a completed receipt in the module.
- Bundle schema/read checks, explicit enrollment, create, exact rerun/recovery
  and login/logout in the disposable-realm acceptance scenario. Also include
  missing evidence/schema, conflicting identities and ordinary client creation.

One bounded batch can create missing requested identities, reuse them unchanged
on rerun, and admit them through the managed native path after success. Failed
creation must not be reported as a ready bot. Check duplicate/ineligible names,
ownership conflicts, unsupported race/class and database failure outcomes.
Build once per coherent implementation batch; one disposable combined lifecycle
check is sufficient before expanding the provisioning family.

Stop for an unresolved temporary-session/callback lifetime, unclear cross-database
recovery, destructive migration or a wider core hook than native creation needs.
Do not defer these decisions to an unaudited external model output. Cheap donor
dependency mapping can be delegated separately; implementation and final review
remain with the primary development model.
