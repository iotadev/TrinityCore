/* GPL v2 or later. Copied diagnostics only; no native objects or mutation authority. */
#ifndef TRINITY_PLAYERBOT_ACTION_HISTORY_H
#define TRINITY_PLAYERBOT_ACTION_HISTORY_H
#include "Define.h"
#include <optional>
#include <string>
#include <vector>
struct PlayerbotActionEvent
{
    uint64 Sequence = 0, FirstSequence = 0;
    uint32 FirstAgeMs = 0, LastAgeMs = 0, Repeats = 1;
    std::string Engine, Action, Kind, Reason;
    bool ExecuteCalled = false;
    std::optional<bool> ActionReturn, EngineResult;
};
struct PlayerbotActionHistory
{
    bool Available = false;
    uint64 Epoch = 0, LastSequence = 0, Overwritten = 0, Expired = 0, Suppressed = 0;
    std::vector<PlayerbotActionEvent> Events;
};
#endif
