# ![logo](https://community.trinitycore.org/public/style_images/1_trinitycore.png) TrinityCore

## Experimental Cataclysm development fork

This fork develops optional Playerbots and Auction House Bot modules
for TrinityCore Cataclysm 4.3.4. It is work in progress, not a ready-to-run
playerbot dungeon server. Playerbots is disabled by default. A manually
configured low-level party has been tested locally with starter Warrior,
Mage, and Priest behavior; this does not establish a complete dungeon clear,
general class/spec support, or autonomous population. The latest Ragefire check
also exercised normal bot whispers and the Mage/Priest engine routes.
Managed roster/lifecycle, a Cata MultiBot bridge and an optional native character
factory are implemented in development. Their validation boundaries are recorded
in the [infrastructure acceptance checklist](doc/local/playerbots/PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md);
this is not a claim of autonomous population or full donor feature parity.
See the [local documentation index](doc/local/README.md),
[Playerbots roadmap](doc/local/playerbots/PLAYERBOTS_PORT_ROADMAP.md),
[implementation handoff](doc/local/playerbots/PLAYERBOTS_WORK_PACKETS.md), and
[AHBot development plan](doc/local/ahbot/AHBOT_DEV.md) for
the current scope and validation status.

This repository retains the history and GPL-2.0 license of the upstream
[Cataclysm Preservation Project TrinityCore](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore).
It contains server source, not a game client or game data.

Playerbots and AHBot live in separate source repositories and are not included
in a core-only checkout. The core builds without either module. Enabling them
requires matching checkouts at `modules/mod-playerbots` and
`modules/mod-ahbot`, respectively; arbitrary module revisions are not assumed
compatible. See the [module integration guide](modules/README.md) for the build
boundary. The modules are independently selectable with
`-DMODULE_MOD_PLAYERBOTS=ON|OFF` and `-DMODULE_MOD_AHBOT=ON|OFF`.

For the 2026-10-02 shared-gameplay-state candidate, use the matching module
revisions below. Windows passed 195 registered checks; the regenerated Linux
build ran 195 Catch cases, 194 passed and one failed as expected. Native
level-20 party fixture preparation and saved-data verification passed.
The integrated client transition check is deferred, so this candidate is not
yet a gameplay-accepted milestone. Linux realm runtime and full donor parity
remain unverified. AHBot implementation is unchanged by this Playerbots batch.
The earlier accepted [infrastructure milestone](doc/local/playerbots/PLAYERBOTS_INFRASTRUCTURE_MILESTONE.md)
retains its historical revisions and client lifecycle evidence.

| Module | Repository | Commit |
| --- | --- | --- |
| Playerbots | [iotadev/cata-playerbots](https://github.com/iotadev/cata-playerbots) | `e6591786a21e36bb5bdea55168bf63fafc095c38` |
| AHBot | [iotadev/cata-ahbot](https://github.com/iotadev/cata-ahbot) | `ac2064e91b02af6b345b492a3f3453614b0087ab` |

Clone each repository into the shown `modules/` directory and check out its
listed commit before configuring the build. These are source modules compiled
into this core, not runtime plug-ins. Neither module is required for a core-only
build. See [module integration](modules/README.md) for configuration details.

## Upstream build status

The badges below report the upstream project's branches, not CI results for
this development fork.


4.3.4 (master) |
:------------: |
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/The-Cataclysm-Preservation-Project/TrinityCore?branch=master&svg=true)](https://ci.appveyor.com/project/Ovahlord/trinitycore) |
[![master GCC Build status](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/actions/workflows/gcc-build.yml/badge.svg?branch=master&event=push)](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/actions?query=workflow%3AGCC+branch%3Amaster+event%3Apush) |
[![master clang Build status](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/actions/workflows/clang-build.yml/badge.svg?branch=master&event=push)](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/actions?query=workflow%3ACLANG+branch%3Amaster+event%3Apush) |

## Introduction

TrinityCore is a *MMORPG* Framework based mostly in C++.

It is derived from *MaNGOS*, the *Massive Network Game Object Server*, and is
based on the code of that project with extensive changes over time to optimize,
improve and cleanup the codebase at the same time as improving the in-game
mechanics and functionality.

It is completely open source; community involvement is highly encouraged.

For this fork's module integration and core changes, submit pull requests to
[iotadev/TrinityCore](https://github.com/iotadev/TrinityCore/pulls). Playerbots and
AHBot changes belong in their respective repositories linked above. The links
to TrinityCore sites below describe the upstream project.

For further information on the TrinityCore project, please visit our project
website at [TrinityCore.org](https://www.trinitycore.org).

## Install

Detailed installation guides are available in the [wiki](https://www.trinitycore.info/display/tc/Installation+Guide) for
Windows, Linux and Mac OSX.  
You can get database from  
https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases


## Reporting issues

Report Playerbots and AHBot problems in their respective module repositories
linked above. Include the core and module commit IDs, relevant configuration
with secrets removed, and steps to reproduce. The fork's issue tracker may not
be enabled; core fixes can be proposed through its pull requests.

Use the [upstream issue tracker](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/issues)
only for problems reproduced on unmodified upstream code. Keep credentials,
database dumps, client files, extracted game data, and raw private logs out of
reports and pull requests.

Please take the time to review existing issues before submitting your own to
prevent duplicates.

In addition, thoroughly read through the [issue tracker guide](https://www.trinitycore.org/f/topic/37-the-trinitycore-issuetracker-and-you/) to ensure
your report contains the required information. Incorrect or poorly formed
reports are wasteful and are subject to deletion.


## Submitting fixes

Fixes are submitted as pull requests via Github. For more information on how to
properly submit a pull request, read the [how-to: maintain a remote fork](https://www.trinitycore.org/f/topic/6037-howto-maintain-a-remote-fork-for-pull-requests-tortoisegit/).
NOTE: if a fix is valid also for 3.3.5a/master branches submit them also to [Github](https://github.com/TrinityCore/TrinityCore)


## Copyright

License: GPL 2.0

Read file [COPYING](COPYING)


## Authors &amp; Contributors

Read file [AUTHORS](AUTHORS)


## Links

[Site](https://www.trinitycore.org)

[Wiki](https://trinitycore.info)

[Documentation](https://www.trinitycore.net) (powered by Doxygen)

[Forums](https://www.trinitycore.org/f/)

[Discord](https://discord.gg/NevNbcagJX)
