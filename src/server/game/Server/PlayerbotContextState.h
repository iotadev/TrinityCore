/* GPL v2 or later. See the TrinityCore AUTHORS file. */
#ifndef TRINITY_PLAYERBOT_CONTEXT_STATE_H
#define TRINITY_PLAYERBOT_CONTEXT_STATE_H
#include "Define.h"
#include "PlayerbotActionHistory.h"
#include <string>
#include <vector>

// A copied read result. Only request this from the player's map update context.
struct PlayerbotContextState
{
    bool Available = false, Staying = false;
    std::string EngineState, LastExecutedAction;
    uint32 QueuedCount = 0;
    std::vector<std::string> CombatStrategies, NonCombatStrategies;
    PlayerbotActionHistory ActionHistory;
};
#endif
