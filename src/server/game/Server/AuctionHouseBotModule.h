/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_AUCTION_HOUSE_BOT_MODULE_H
#define TRINITY_AUCTION_HOUSE_BOT_MODULE_H

#include "Define.h"

void InitializeAuctionHouseBotModule();
void UpdateAuctionHouseBotModule();
bool IsAuctionHouseBotCharacter(uint32 guidLow);

#endif
