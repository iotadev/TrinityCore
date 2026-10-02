# Playerbots development handoff

Updated 2026-10-02. Read the [roadmap](PLAYERBOTS_PORT_ROADMAP.md) for priorities
and [development history](PLAYERBOTS_DEV.md) for dated evidence and superseded
work packets. Do not repeat accepted infrastructure work.

## Resume point

Close the shared-state gameplay milestone. Separate combat/noncombat/dead
strategy registrations share one context; transitions/control changes clear
pending actions. Native session ownership, resurrection and asynchronous
transfer remain unchanged.

Follow [state acceptance](PLAYERBOTS_STATE_MILESTONE.md) and use the
[repeatable fixture](PLAYERBOTS_PARTY_FIXTURE.md). Code, platform builds, native
fixture preparation, outgoing review and local candidate commits are complete.
Next, when the user is available, restart the saved baseline and run one
integrated transition/recovery/loot session. Record outcomes and promote or
correct the candidate. Do not rebuild unchanged code solely to resume testing.
Do not extend the milestone with an isolated Mage utility spell.

The native `fixture20` tool and `-RoleFixture -CheckRosterOnly` replay prepare
talents, equipment and consumables before the client session. Keep the feature
default-off and restricted to disposable configured slots; production character
progression remains separate donor-factory work. The user will test later, so
leave a saved/stopped baseline rather than an idle running realm.

Ready baseline/evidence: `build/playerbot-smoke-20261002-154407` (ignored).
All four native roles, equipped weapons/shield and carried food/water were
verified after logout, followed by clean shutdown. Final Windows suite passed
195 registered checks; regenerated Linux ran 195 Catch cases, 194 passed and
one failed as expected. Later client acceptance is still pending; local candidate
commits preserve this phase without claiming integrated gameplay success.

## Evidence boundaries

Published infrastructure pair: module `70014ce`, core `92f41cf`. The newer local
module candidate is `e659178`; its matching core pins it in README. Windows
passed 195 registered checks; regenerated Linux ran 195 Catch cases, 194 passed
and one failed as expected. Native fixture readiness/save/logout passed.
Integrated client acceptance and Linux gameplay remain untested.

The last client check established combat/healing/buffs/corpse opening and clean
shutdown. It lacked assigned roles and recovery items. Warrior late-pull/leash
observations remain evidence, not a universally fixed defect. New fallbacks and
advanced actions need integrated qualification, not separate spell sessions.

## Architecture constraints

- Keep native world/map/session ownership and command mailboxes. Mutate decision
  queues only on the map thread.
- Use explicit state registrations, as the donor does. Strategy type metadata
  is not an execution-state filter. Context objects can be shared without sharing
  pending queues; support healing belongs in both live states.
- Resolve live targets by GUID and retain owner/party/PvE/leash/security guards.
- Preserve native learned spells, cooldowns, talents, equipment, loot and DB
  transactions. Learning a stance alone does not assign a tank spec.
- Refresh upstream master and record immutable pins. The state audit refreshed
  master to `037c01418b5d01506917a3db9b44fd56ac5f965c`; its newer AI changes
  do not alter the separate-engine pattern. Existing action packets retain
  their actual older import pins.
- Keep features default-off and Linux server portability intact.
- Commit validated milestones using the publication identity. Do not infer
  client acceptance from a successful build or push automatically.

## After acceptance

Next is donor-aligned tank/healer coordination, recovery and one human-led
low-level dungeon. Autonomous population/questing remain the separate track.
Optional source archaeology can go directly to Nemotron with a pinned payload
and Sol audit; adding a local manager is unnecessary.
