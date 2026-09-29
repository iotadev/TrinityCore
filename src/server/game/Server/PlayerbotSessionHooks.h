/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_PLAYERBOT_SESSION_HOOKS_H
#define TRINITY_PLAYERBOT_SESSION_HOOKS_H

#include "Define.h"
#include <memory>

class World;
class WorldSession;

// WorldSession owns this object. Commands only post requests; map/world updates
// consume them in the same contexts used by the existing session implementation.
class PlayerbotSessionHooks
{
public:
    virtual ~PlayerbotSessionHooks() = default;
    virtual void RequestServerOriginFollow(uint32 guid) = 0;
    virtual void RequestServerOriginHold() = 0;
    virtual void RequestPartyControllerFollow(uint32 guid) = 0;
    virtual void RequestPartyControllerHold() = 0;
    virtual void RequestServerOriginAttack() = 0;
    virtual void RequestServerOriginCease() = 0;
    virtual void RequestServerOriginInstanceJoin(uint32 mapId) = 0;
    virtual uint32 GetFollowTargetGuidLow() const = 0;
    virtual uint32 GetPartyControllerGuidLow() const = 0;
    virtual bool IsAttacking() const = 0;
    virtual void UpdateMap(uint32 diff) = 0;
    virtual void UpdateWorld() = 0;
};

std::unique_ptr<PlayerbotSessionHooks> CreatePlayerbotSessionHooks(WorldSession& session);
bool PlayerbotModuleSupportsClass(uint8 playerClass);
void LoadPlayerbotModuleSettings(World& world, bool moduleConfigsValid);

#endif
