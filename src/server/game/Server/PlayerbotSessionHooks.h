/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_PLAYERBOT_SESSION_HOOKS_H
#define TRINITY_PLAYERBOT_SESSION_HOOKS_H

#include "Define.h"
#include "PlayerbotStrategyBinding.h"
#include <memory>
#include <string>
#include <vector>

class World;
class WorldSession;

// Immutable map-published read model. Contains no native objects or engine pointers.
struct PlayerbotStrategySnapshot
{
    uint32 Bot = 0, Controller = 0, Created = 0;
    std::vector<std::string> Combat, NonCombat;
};

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
    virtual bool RequestPlayerbotRange(uint32 requesterGuidLow, std::string const& param) = 0;
    virtual bool RequestPlayerbotStrategy(uint32 requesterGuidLow, std::string const& command,
        std::string const& token, std::string const& target, uint64 batch, PlayerbotStrategyBinding const& binding) = 0;
    virtual bool RequestPlayerbotRebuff(uint32 requesterGuidLow) = 0;
    virtual bool RequestPlayerbotStay(uint32 requesterGuidLow) = 0;
    virtual void RequestPlayerbotReadyCheck(uint64 group, uint64 check, uint32 initiator, uint32 created) = 0;
    virtual uint32 GetFollowTargetGuidLow() const = 0;
    virtual uint32 GetPartyControllerGuidLow() const = 0;
    virtual bool IsAttacking() const = 0;
    virtual uint32 GetStrategyRoleMask() const = 0;
    virtual std::shared_ptr<PlayerbotStrategySnapshot const> GetStrategySnapshot() const = 0;
    virtual void UpdateMap(uint32 diff) = 0;
    virtual void UpdateWorld() = 0;
};

std::unique_ptr<PlayerbotSessionHooks> CreatePlayerbotSessionHooks(WorldSession& session);
bool PlayerbotModuleSupportsClass(uint8 playerClass);
void LoadPlayerbotModuleSettings(World& world, bool moduleConfigsValid);

#endif
