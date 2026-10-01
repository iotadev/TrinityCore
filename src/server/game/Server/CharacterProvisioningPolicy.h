/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information.
 * Released under GNU GPL v2 or any later version.
 */
#ifndef TRINITY_CHARACTER_PROVISIONING_POLICY_H
#define TRINITY_CHARACTER_PROVISIONING_POLICY_H

#include <cstddef>
#include <cstdint>

constexpr std::size_t MaxCharacterProvisioningContexts = 16;

inline bool CanBeginCharacterProvisioning(uint32_t accountId, bool hasSession,
    bool reserved, bool shuttingDown, std::size_t activeContexts)
{
    return accountId && !hasSession && !reserved && !shuttingDown &&
        activeContexts < MaxCharacterProvisioningContexts;
}

inline bool CharacterProvisioningAccountEligible(bool online, uint32_t security)
{
    // A trusted caller must additionally establish ownership. Do not adopt a
    // logged-in or privileged account merely because it appears in a config.
    return !online && security == 0;
}

#endif
