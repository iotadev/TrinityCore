# Named combat targets and Protection tank fallback

Local development port, 2026-10-01, donor revision
`7bae1b5c58c76a0aa20381155edc08096d1485b2`.

## Donor and Cata scope

TankTargetValue.cpp's active FindTankTargetSmartStrategy ranks lost aggro before
owned melee targets, then owned distant targets. Lost-aggro ties use distance;
other ties use lower own threat. Its explicit-main-tank/multiple-tank preference
is unported; the older inactive FindTargetForTankStrategy is not imported.
HasAggro in AttackerCountValues.cpp accepts self, no victim or another tank for
non-explicit-main-tank bots. This subset recognizes only Protection Warriors.

Both selectors share DPS_TARGET_PACKET.md's eligibility, typed exclusions and
CC-marker checks. Tank marker priority applies to an eligible icon attacking a
recognized non-tank player (Mage/Priest/non-Protection Warrior). Other roles and
another tank bot's rti ownership are not guessed. Remaining cases use ordinary
tank ranking. No taunt, threat mutation, automatic role assignment or new pull.

Shared `dps target` and `tank target` values return fresh ObjectGuid results,
not donor Unit pointers. The existing session/current-target GUID owns combat.
Missing engine returns empty; tank target rejects non-Protection Warriors.
PlayerbotAI borrows a const engine accessor, bound by Engine construction and
cleared on destruction if still bound to it. Existing session ownership
destroys Engine before context and AI. No new scheduler/callback/core seam/SQL,
retained Player/Creature pointer or concurrent API. All reads are map-owned.

Idle fallback reads the named values. Mage/Priest retain existing gates;
Protection Warrior requires EngineWarriorCombat. Gates remain default-off.
Valid selected combat targets, explicit requests and active fights retain
precedence. Other Warriors keep the old path. Stop/hold/follow, native
attack/chase and target cleanup remain owned by the existing adapter.

## Verification and follow-up

The preceding DPS fallback built Windows/Linux worldserver/tests-common and
each passed 167 tests. Three additional pure tests cover tank bands, threat/
distance ties and recognized-aggro policy. Windows and Linux worldserver/
tests-common built and each passed all 170 tests, including the final role-filter
recheck.
Native reads, role checks and borrowed-engine lifetime are source-reviewed,
not simulated world-object tests.

Bundle an actually Protection-specialized Warrior with the next party check:
clear selection after a kill while another enemy already fights the controller
and observe fallback acquisition. Do not expect active switching, taunts or
main-tank coordination. Broader roles, group CC declarations and encounter
exclusion providers remain separate donor ports.

The later bundled check exposed the unassigned-Warrior fallback gap. The source
correction now gives all enabled Warriors a named target fallback: Protection
uses tank target and other implemented Warrior routes use general DPS target.
Melee DPS uses native melee reach for its range band. Existing controller combat,
command/selection precedence and distance leash remain. A pure route regression
was added; Windows and Linux worldserver/tests-common each built and passed all
171 tests. The completed live session did not include this correction.
