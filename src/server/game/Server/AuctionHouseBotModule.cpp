/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#include "AuctionHouseBotModule.h"
#include "ModuleBuildConfig.h"

#ifndef TC_MODULE_AHBOT
void InitializeAuctionHouseBotModule() { }
void UpdateAuctionHouseBotModule() { }
bool IsAuctionHouseBotCharacter(uint32 /*guidLow*/) { return false; }
#endif
