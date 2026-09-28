# Initial Playerbots port work packets

Prepared 2026-09-26 from `PLAYERBOTS_PORT_ROADMAP.md`. These are dispatch contracts,
not claims of completed work. Use the pinned local donor, not an invented generic
Playerbots implementation. Lead integrates changes into the working Cata tree.

## Shared handoff contract

- The lead supplies an isolated source snapshot containing the required current
  dirty-tree changes and untracked dependencies, with a baseline manifest. Never
  give a worker only Cata HEAD and assume it contains this prototype.
- Donor root is the local `mod-playerbots` revision
  `8827dd6fcbb2bb25988787a40f06fc93daf8e02d`. Read its applicable guidance. Preserve
  notices, names, source references, and deliberate deviations.
- Use the development tools chosen for the task. Source snapshots must exclude
  credentials and runtime data; donor checkouts remain read-only references.
- Inputs contain required source/docs and extracted public-source facts only.
  The lead performs local DBC queries if needed and supplies the relevant results;
  runtime configurations, database dumps, and account/player data are excluded.
- Return changed files, donor-to-Cata mapping, actual commands/results, deviations,
  remaining uncertainties, and a short playtest checklist. Do not claim acceptance
  based solely on the visible tests. Reports must cite real file/symbol locations.
- Implementation jobs get exact editable paths and the build/test invocation after
  their dependency snapshot exists. The lead verifies these before dispatch. A
  missing API is a reported integration dependency, not permission to redesign the
  core. One focused repair round follows supervisor review if necessary.

## A: Donor engine and module compatibility map

State: ready for source snapshot and read-only dispatch. Can run with B.

Inputs: donor `src/Bot/PlayerbotAI.{h,cpp}`, `src/Bot/Engine/`,
`src/Script/Playerbots.cpp`, `src/Bot/PlayerbotMgr.*`, `src/Script/WorldThr/`;
Cata session/world/login integration and ScriptMgr/build sources; representative
`mod-dungeon-clear` and `mod-multibot-bridge` consumers.

Task: trace the minimum dependency-complete engine/context/state subset needed to
run follow/stay, attack/assist, one class action, and a dead-state action. Map each
required core hook and packet/event to its execution context and lifetime. List
downstream APIs actually consumed by the two example modules. Distinguish directly
reusable code, API adaptations, WotLK data dependencies, and deferred features.

Output scope: one report in the isolated task's `out/engine-port-map.md` with file,
symbol, dependency, Cata counterpart, and blocker columns. No source edits.

Acceptance: every essential proposed hook maps to inspected source; include bot
outgoing events, owner commands/events, map tick, world-thread operations, load,
transfer and logout. Explain optional factory registrations so disabled systems
do not pull in the entire module. No new parallel AI engine proposal.

## B: Cata class/spec compatibility tables

State: ready for source snapshot and read-only dispatch. Can run with A.

Inputs: donor Mage, Priest and Warrior contexts/strategies/actions; Cata Player
talent APIs, relevant spell scripts, current starter helpers, and the lead's
targeted Cata data query results.

Task: map the first playable-party abilities to actual Cata class/spec and level
requirements. Include signature abilities, resources/procs, role, buff aura versus
cast spell, ranks where applicable, range/target semantics and unavailable actions.
Separate an unspecialized character from the first talent tree. Cover selected
Frost Mage, healing Priest and Protection Warrior profiles first; list other specs
as later coverage rather than presenting them as implemented.

Output scope: `out/class-spec-map.md`. No spell teaching, SQL or gameplay edits.

Acceptance: source/data citation for every enabling claim; explicit unknowns where
evidence is absent. Reconcile donor rotation assumptions with Cata changes. Do not
substitute remembered IDs/levels or WotLK tables for missing Cata evidence.

## C: First real C++ worker pilot - Mage profile port

State: queued after lead integrates the minimum module/engine seam and B is reviewed.

Inputs: pinned donor `src/Ai/Class/Mage/`, new Cata module interfaces, reviewed
Mage table from B, existing casting adapter, and focused tests/build instructions.

Task: adapt a bounded Frost Mage combat/noncombat profile using upstream action,
trigger, value and strategy responsibilities. Include an explicit unspecialized
fallback. Retain native learned-spell, cooldown/resource, range, LOS and cast checks;
avoid restarting an in-progress cast. Unsupported specs must take a documented
fallback rather than masquerading as complete rotations.

Editable scope: the lead enumerates module Mage files and the narrow spec resolver
plus focused tests. No session/world/DB changes and no second action engine. If a
shared interface is insufficient, return the exact gap for lead integration.

Acceptance: compile target succeeds; relevant checks cover missing talent tree,
unknown/unlearned spell, failed-cast fallback, active cast and resource/cooldown
eligibility. Client pass covers ranged combat, buff/rest behavior included by the
packet, and resuming after target death. Do not add tests that merely restate a
table; test the decisions and regressions.

## Next implementation packets after C

| Packet | Donor basis | Boundary and useful acceptance |
|---|---|---|
| D: Priest healing/recovery | `Ai/Class/Priest`, party health/resurrection values, `AcceptResurrectAction` | Heal living reachable members even if controller dies; triage, mana/rest and supported resurrection. Client combat healing plus one recovery. |
| E: Warrior tank | `Ai/Class/Warrior`, tank/threat/stance actions | Selected Cata spec, threat, target/facing and defensive basics. Multi-enemy pull with DPS/healer; no complete tank claim from autoattack alone. |
| F: Group and chat control | `AcceptInvitationAction`, `FollowActions`, `StayActions`, `AttackAction`, command/security layers | Invite by an eligible human, adopt/change controller, disband/leave, follow/stay/attack/stop. Map Cata packets; do not add a hardcoded owner allowlist. |
| G: Small managed roster factory | `RandomPlayerbotFactory`, `PlayerbotFactory` | Native creation/save/cache/count lifecycle; existing roster reuse; selected class/spec spells and equipment. No raw character row cloning, automatic deletion, or unrelated account changes. |
| H: Autonomous manager pilot | `RandomPlayerbotMgr`, shared contexts, travel/RPG actions | Small bounded login/logout and ownerless behavior; persisted state and clean shutdown. Requires G and lead-reviewed session ownership. |

D/E/F/G can proceed independently after their shared interfaces exist. The lead
owns overlapping registry changes, core hooks and final integration. H does not
need every class completed. Optional module work follows the dependency table in
the roadmap. Each packet ends in a usable playtest slice, not an open-ended audit.
