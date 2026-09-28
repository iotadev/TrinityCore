# Cata Playerbots port roadmap

Updated 2026-09-26. This is the current sequencing and delegation plan;
`PLAYERBOTS_DEV.md` retains the implementation history. The subsequent module
foundation implementation has moved companion behavior/state, class helpers,
commands/config and tests into `modules/mod-playerbots`. Optional build and native
script/config registration are in place. The donor Engine/context port remains
pending. Implementation packet A has now been dispatched against a source-only isolated
snapshot; its first report and revised draft failed source review. The single
repair attempt completed but was rejected; no worker recommendation was integrated.
See `PLAYERBOTS_ENGINE_INTEGRATION_NOTES.md` for verified boundaries.
The full-party harness now supports interactive waits and a headless roster check;
all four mixed-class bots passed admission/readiness/logout in a copied database.
The first direct donor import, `Bot/Engine/NamedObjectContext.{h,cpp}`, now builds
with seven ownership/lookup regressions (41 total enabled tests passed). This
registry is not yet the active AI; complete Engine/state integration remains ahead.
The next imported slice is `Event` plus `NextAction`, with lifetime-safe owner
GUID storage and native Cata payload types. Enabled worldserver/tests-common build
and 47/47 tests pass. This is preparatory code, not an activated scheduling engine;
native owner lookup still needs lifecycle verification when the bridge is wired.

## Goal and porting policy

Deliver the capabilities of AzerothCore Playerbots in
Cataclysm: useful companions, class/spec identity, managed character creation,
an autonomous population, progression/questing, dungeons, and compatible optional
extensions. A playable human-led party is the first product milestone, not the
limit of the project.

Prefer an identifiable upstream port over a new implementation. Preserve upstream
component names, action/strategy names, directory organization, configuration
meaning, and extension interfaces where practical. Record donor revision, source
files, original notices/authors, and the reason for each Cata deviation. A small
native implementation is reasonable when the donor depends on an incompatible
core mechanism, but it needs an explicit mapping back to the donor responsibility.

Use Cata core APIs and Cata data as the authority for spells, talents, equipment,
quests, maps, and packets. WotLK behavior is a starting point, not proof of Cata
mechanical correctness. Do not carry WotLK content tables across merely because
they compile. Reuse the Playerbots architecture without attempting to turn the
entire TrinityCore fork into AzerothCore.

## Source and evidence snapshot

- Cata base HEAD: `efcf6ac83d11fdf4ce86a1b6f95c3b22dfaee14f` plus substantial
  uncommitted work, including required untracked Playerbot source files. HEAD alone
  does not reproduce the current implementation. AHBot changes coexist here.
- Local AzerothCore HEAD: `13933764ed31deed5eabe372e98e5764db8f62f3`.
- Local `mod-playerbots` donor: `8827dd6fcbb2bb25988787a40f06fc93daf8e02d`,
  remote `https://github.com/mod-playerbots/mod-playerbots.git`; its working tree
  was clean at review. These are local pins, not claims about latest upstream.
- Donor source: clone the public repository above at the pinned revision into a
  separate checkout. Its location is chosen by the developer, not fixed by this
  repository.
- Latest runtime evidence: `build/playerbot-smoke-20260926-042538` (ignored).

| Area | Established | Still missing or uncertain |
|---|---|---|
| Session lifecycle | Socketless login/save/logout; multiple accounts; previous four-bot instance/death tests | General roster management and production population behavior |
| Companion behavior | Follow, spacing, assist, greeting; latest three bots accepted invitations without preassigned follow | Controller changes/disband policy, normal chat command surface, complete upstream security |
| Classes | Warrior starter combat; user-confirmed Mage ranged attacks and buffs in latest run | Full rotations, actual tank role, talent-aware profiles, mana/rest behavior |
| Healing | Native accepted Flash Heal/Fortitude casts logged; user reports promising behavior | Sustained combat healing was not exercised; resurrection/recovery parity not established |
| Latest test | Mage repeatedly cast Frostbolt; all four bots logged out during normal shutdown | Testtwo never joined; mixed-party dungeon test did not complete |
| Population and extensions | Relevant upstream code available locally | Factories, autonomous scheduling/questing, module compatibility not ported |

The latest disconnect was the harness's party-join timeout and normal shutdown,
not evidence of another server crash. Testtwo was online with saved map 389 and
no account GM security; the precise reason for the invite lookup failure is still
unconfirmed. A database `online=1` is insufficient evidence that a player is
fully in-world and able to accept invitations. Also reconcile the manual
resurrection observation with fixture preparation; do not label automated revival
fully verified from a sent command alone.

## Architecture assessment

The prototype proved valuable Cata integration boundaries, but it is not yet an
upstream Playerbots AI port. `WorldSession.cpp` currently owns movement, party,
dungeon join, and combat orchestration. `Playerbot*Strategy` helpers implement
small custom priority lists. Growing those lists indefinitely would duplicate
the donor engine and make optional module ports harder.

The donor instead has per-bot `PlayerbotAI`, `AiObjectContext`, `Engine`, and
Strategy/Trigger/Action/Value/Multiplier machinery, separate combat/noncombat/dead
states, `PlayerbotMgr`, factories, and `RandomPlayerbotMgr`. Companion commands
and autonomous goals feed the same engine. Port a dependency-complete subset of
these components; do not create a second permanent engine with similar names.

The bridge must cover more than a tick callback. Cata currently discards
server-origin outbound packets. The donor's `src/Script/Playerbots.cpp` routes
bot/master events to `HandleBotOutgoingPacket` and master packet handlers.
Port supported event semantics through Cata packet types or narrow native hooks;
do not parse Cata packets using WotLK byte layouts. Document the execution thread
and lifetime of each hook. AI gameplay runs in map context; session admission,
async loads, world-thread operations, and shutdown retain explicit ownership.

Target packaging:

```text
TrinityCore/
  src/server/...                 narrow lifecycle/event integration
  modules/mod-playerbots/
    src/Bot/{Engine,Factory,...}  donor-shaped runtime and managers
    src/Ai/{Base,Class,World,...} donor-shaped behaviors
    src/Mgr/                     movement, security, talents, travel, etc.
    src/Script/                  integration and commands
    src/Compat/                  small Cata-specific adapters as needed
    conf/playerbots.conf.dist
    data/sql/                    explicit module migrations
    PORTING.md                   source pins and deviations
```

Start with optional static build integration and module-owned config loading.
Use existing TrinityCore build/script facilities and adapt relevant AzerothCore
module conventions. Define config precedence and feature-off behavior; provide
no-op hooks when disabled. Arbitrary AzerothCore modules will still need API and
data adaptation. A universal compatibility layer or dynamic plugin ABI is not a
prerequisite. AHBot remains a separate native implementation and is now owned
by its own optional static module rather than the Playerbots module.

## Delivery sequence

| Stage | Result | Main work and exit evidence |
|---|---|---|
| 0. Preserve and unblock | Reproducible source and usable playtest | Snapshot current dirty source including untracked dependencies; record donor pins; fix Testtwo readiness/fixture issue; make interactive sessions explicitly stoppable without party/combat expectation timeouts disconnecting the player. Keep a separate bounded automated mode. |
| 1. Upstream foundation | Optional module running donor-shaped AI | Module/config boundary; port minimal Engine/context/state machinery and Cata lifecycle/event bridge. Move existing behaviors behind it with one active decision owner. Build enabled/disabled; verify admission, transfer, stop/shutdown, and one integrated companion session. |
| 2. Playable party | Invite bots and play a normal low-level dungeon session | Upstream commands/security/controller transitions; selected Warrior tank, Mage DPS, Priest healer profiles; appropriate spells/equipment; assist/stop/follow/stay, threat basics, rest, loot, resurrection and regroup. Create/reuse a small roster through the factory. Human leads route initially. |
| 3. Broader class/spec coverage | Useful leveling companions beyond the first party | Expand all Cata classes/specs in independent class packets; pets, dispels, interrupts, crowd control, resource/proc logic, level/talent changes and gear progression. Extend the tested level/content range explicitly. |
| 4. Autonomous population | Bots function without a human controller | Adapt RandomPlayerbotMgr scheduling and shared AI, bounded accounts/population, logout/relogin, travel/RPG/quest actions, vendors/trainers/progression and persistence. Start small; scale against measured update/DB cost. |
| 5. Dungeon and ecosystem parity | Port selected extensions and content coverage | Playerbots encounter strategies, dungeon leadership/clear, addons, population extensions, optional LLM modules, then broader Cata dungeons/raids/PvP. Cata-specific content requires its own validation. |

Stages are dependency boundaries, not a mandate to serialize all work. During
stage 1, source mapping, Cata spell/spec data review, and factory design can run
in parallel. Once interfaces are stable, class, group/recovery, and factory
implementation can proceed in separate files. A small autonomous login/logout
pilot can follow the factory before every class is finished. Do not hold the
first playable party for all classes, autonomous questing, or dungeon automation.

Stage 2 acceptance is a representative normal dungeon session: useful damage,
visible combat healing and tank threat, recovery after a member death, rest and
loot, and commands that let the player continue or stop. A complete clear is a
separate result; successful trash combat does not establish boss mechanics.

The factory should adapt `RandomPlayerbotFactory` and `PlayerbotFactory`, using
native account/character creation, saves, cache registration, and realm counts.
Reruns recognize owned accounts and characters. Preserve one world-owned session
per account initially; same-account alternate-character behavior needs a separate
ownership design. Remove the four-slot dev limit through the manager, rather than
extending numbered console handlers indefinitely.

## Optional module order

The following module designs are port candidates. Each requires a source revision
and compatibility review before integration with Cata.

| Candidate | Dependency and treatment |
|---|---|
| `mod-multibot-bridge` and its client addon | After stable Playerbots commands/query APIs; adapt addon/client differences. Good early usability improvement. |
| `mod-dungeon-clear` | After donor Engine/Strategy/Action/Value interfaces, party roles and recovery. Begin with one Cata dungeon; its README's general routing claims are not Cata validation. |
| `mod-playerbot-dungeon-sim`, `mod-playerbots-world-pvp`, `mod-optimal-bot-raid` | After managers/factories/reservation interfaces; separate content and behavior audits. Simulation is not proof of real dungeon clearing. |
| `mod-llm-chatter`, `mod-playerbots-characters`, `mod-ollama-chat`, `mod-llm-guide` | Optional later adapters using stable bot events/identity. Select deliberately where features overlap. Development tooling does not introduce a hosted-model runtime dependency. |
| `mod-dungeon-master`, `mod-autobalance`, `mod-individual-progression`, loot/transmog/vendors/world buffs | Separate server feature track with per-module compatibility/data review; not all are Playerbots prerequisites. |
| Native AHBot and local enhancements | Continue as a separate native feature; no module extraction. |

## Implementation and review responsibilities

Assign bounded tasks with explicit source revisions and acceptance criteria.
Contributors may choose their development tools; this project does not require a
specific hosted provider, model or desktop application. Generated changes require
source review and meaningful tests before integration.

| Work | Primary owner | Acceptance focus |
|---|---|---|
| Donor dependency maps, API diffs, source-backed spell/spec tables | Implementation contributor | Supervisor spot-checks consequential mappings and missing dependencies |
| Class/spec actions and triggers, known API substitutions, module config/docs, focused regressions | Implementation contributor after shared interface is settled | Changed semantics, Cata data, actual diff, compile and targeted behavior checks |
| Group/recovery and factory internals | Implementation contributor with explicit contract | Supervisor reviews ownership, native handler use, persistence and failure paths |
| Session lifetime, map/world thread bridge, packet adaptation, DB ownership, build/module interface | Lead supervisor | Direct design/integration review; worker may prepare evidence or a bounded patch |
| Merge/integration, upstream deviation decisions, final acceptance | Lead supervisor | Combined behavior and regression risk; no worker self-approval |
| Feel, usefulness, dungeon behavior | User playtest | Brief checklist for the changed behavior; no claim of complete edge-case coverage |

Start with one real worker implementation pilot. Then allow two independent
implementation workers at once, increasing only when their diffs integrate
cleanly and provider behavior supports it. Do not assign overlapping engine/core
files to parallel workers. Give workers enough context to compile and repair
their own changes; avoid supervising every tool call.

For each packet: donor files/revision, desired behavior, Cata constraints, exact
editable paths, exclusions, build command, acceptance cases, and a short handoff.
Provide source-only snapshots, not runtime databases/config secrets or the entire
workspace. The current dirty tree means an ordinary checkout of HEAD is not
enough: overlay the required tracked diff and untracked source onto the isolated
baseline and record the manifest. Keep WotLK donor files read-only.

After worker completion, inspect the diff and critical semantic boundaries, run
the meaningful checks, and return concrete defects for one focused repair round.
Escalate persistent design problems instead of maintaining an open-ended repair
loop. Preserve first-attempt and repaired outcomes. Tests and confident worker
summaries alone are not acceptance. Use `source-reviewed`, `build-verified`,
`playtest-pending`, `client-confirmed`, and `known-issue` labels accurately.

Record elapsed worker time, changed files, build result, defects, repair rounds,
supervisor review effort, and available usage counts. Judge savings from several
accepted real patches; do not promise a savings ratio from benchmark timing.

## Next batch

1. Lead: stage-0 harness repair is implemented: normalize the complete offline
   roster, check fresh slot readiness, and separate interactive human waits from
   bounded automated checks. Four-bot headless replay passed; Testtwo invitation
   behavior remains client-unverified. The module/core extraction is implemented. No further expansion
   of the temporary class lists before the donor engine/context port.
2. Implementation packet A: dependency and compatibility map for the smallest complete
   donor Engine/context slice, with downstream module API consumers identified.
3. Implementation packet B: Cata Mage/Priest/Warrior spec/spell mapping with donor references
   and explicit unknowns; read-only and independent of packet A.
4. Lead integrates the module/engine seam. Implementation packet C then ports a bounded
   Mage profile as the first real C++ implementation pilot. Review, compile, and
   playtest it; continue Priest/tank/group/factory packets in parallel afterward.

Concrete handoff contracts are in
`PLAYERBOTS_WORK_PACKETS.md`. This roadmap is ready for implementation;
this work has used headless copied-database verification and source-only dependency
mapping, with no client session or fork publication.
