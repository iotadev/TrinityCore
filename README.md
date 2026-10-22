# ![logo](https://community.trinitycore.org/public/style_images/1_trinitycore.png) TrinityCore

## Experimental Cataclysm development fork

TrinityCore Cataclysm 4.3.4 with optional
[Playerbots](https://github.com/iotadev/cata-playerbots) and
[Auction House Bot](https://github.com/iotadev/cata-ahbot) modules.
Playerbots aims to port AzerothCore's existing bot behavior to Cata while
preserving native server ownership. It is disabled by default and remains alpha.

A human-led Warrior/Mage/Priest party has been exercised outdoors and in Ragefire.
Managed bot lifecycle, a MultiBot compatibility bridge, explicit gear/quest
controls and selected-NPC maintenance are implemented. Rogue/Hunter starter
routes and native Hunter pet control are available behind separate gates but
have not had a live combat check. Full dungeon clears, complete class/spec
coverage and autonomous populations remain unverified.

See the [Playerbots overview](https://github.com/iotadev/cata-playerbots),
[roadmap](doc/local/playerbots/PLAYERBOTS_PORT_ROADMAP.md) and
[development handoff](doc/local/playerbots/PLAYERBOTS_WORK_PACKETS.md).
The [documentation index](doc/local/README.md) retains detailed validation and
history. AHBot scope is described in its repository and
[development plan](doc/local/ahbot/AHBOT_DEV.md).

### Matching source modules

A core-only checkout contains neither module and can build without them.
Clone compatible module sources into the directories below before configuring.
These are statically compiled source modules, not runtime plug-ins or drop-in
AzerothCore modules.

| Directory | Repository | Matching revision (October 22 documentation refresh) |
| --- | --- | --- |
| modules/mod-playerbots | [iotadev/cata-playerbots](https://github.com/iotadev/cata-playerbots) | `1661edaf711ef175cd96a80630bb7738b6a54f18` |
| modules/mod-ahbot | [iotadev/cata-ahbot](https://github.com/iotadev/cata-ahbot) | `ac2064e91b02af6b345b492a3f3453614b0087ab` |

Check out the listed module revisions for this milestone. The
[module integration guide](modules/README.md) explains independent build switches
and configuration placement. AHBot implementation is unchanged by this milestone.
The optional context exporter/query application is a separate project and is
not required to run either module.

### Validation scope

October 13 source passed Windows and Linux worldserver/tests-common builds with
all three installed optional modules enabled: **476/476 tests** on each platform.
Windows with all three disabled passed **20/20**. Linux realm runtime is
unverified. Later helper/documentation cleanup and an include-only no-PCH
correction are not a new full native build qualification.
The [milestone record](https://github.com/iotadev/cata-playerbots/blob/main/PORTING.md)
distinguishes builds, observed gameplay and pending checks.

This repository retains the history and GPL license of the upstream
[Cataclysm Preservation Project TrinityCore](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore).
It contains server source, not a game client or game data.

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
