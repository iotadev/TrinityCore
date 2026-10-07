/* GPL v2 or later. Copied native roll facts; no Group, Roll or Item pointers. */
#ifndef TRINITY_PLAYERBOT_LOOT_ROLL_IDENTITY_H
#define TRINITY_PLAYERBOT_LOOT_ROLL_IDENTITY_H
#include "Define.h"
struct PlayerbotLootRoll
{
    uint64 Group = 0, Roll = 0;
    uint32 Entry = 0, Property = 0, SuffixFactor = 0, Map = 0, Instance = 0;
    uint8 PropertyType = 0, Count = 0, Slot = 0, Mask = 0;
    bool Matches(PlayerbotLootRoll const& other) const
    {
        return Group == other.Group && Roll == other.Roll && Entry == other.Entry &&
            Property == other.Property && PropertyType == other.PropertyType &&
            SuffixFactor == other.SuffixFactor && Map == other.Map && Instance == other.Instance &&
            Count == other.Count && Slot == other.Slot;
    }
    static bool Admits(bool pending, uint8 mask, uint8 choice)
    { return pending && choice < 4 && (mask & (uint8(1) << choice)); }
};
#endif
