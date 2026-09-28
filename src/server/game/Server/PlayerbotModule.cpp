/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#include "PlayerbotSessionHooks.h"
#include "PlayerbotModuleCommands.h"
#include "ModuleBuildConfig.h"
#include "World.h"

#ifndef TC_MODULE_PLAYERBOTS
std::unique_ptr<PlayerbotSessionHooks> CreatePlayerbotSessionHooks(WorldSession& /*session*/)
{
    return nullptr;
}

bool PlayerbotModuleSupportsClass(uint8 /*playerClass*/)
{
    return false;
}

void LoadPlayerbotModuleSettings(World& world, bool /*moduleConfigsValid*/)
{
    world.setBoolConfig(CONFIG_PLAYERBOTS_DEV_ENABLED, false);
    world.setBoolConfig(CONFIG_PLAYERBOTS_DEV_GREETING_ENABLED, false);
}

std::vector<ChatCommand> GetPlayerbotModuleCommands()
{
    return {};
}
#endif
