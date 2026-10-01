/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_PLAYERBOT_ADDON_BRIDGE_H
#define TRINITY_PLAYERBOT_ADDON_BRIDGE_H

#include <string>

class Player;

// Called on the world thread only, after native addon throttling and routing
// checks. true consumes the message; module-off builds leave routing unchanged.
bool HandlePlayerbotAddonMessage(Player& sender, std::string const& prefix, std::string const& message);

#endif
