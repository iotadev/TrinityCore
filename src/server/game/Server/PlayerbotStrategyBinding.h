/* GPL v2 or later. Copied Playerbots strategy request identity; no native pointers. */
#ifndef TRINITY_PLAYERBOT_STRATEGY_BINDING_H
#define TRINITY_PLAYERBOT_STRATEGY_BINDING_H
#include <cstdint>
#include <memory>
#include <string>

struct PlayerbotStrategyBinding
{
    std::uint32_t Account = 0;
    std::uint64_t Group = 0;
    std::string Scope;
    std::weak_ptr<void const> Session, Lease;
    bool Valid() const
    {
        return Account && !Session.expired() && !Lease.expired() &&
            ((Scope == "ALL" && !Group) ||
                ((Scope == "GROUP" || Scope == "PARTY" || Scope == "RAID") && Group));
    }
    bool SessionMatches(std::uint32_t account, std::shared_ptr<void const> const& session) const
    { auto expected = Session.lock(); return expected && account == Account && expected == session; }
    bool GroupMatches(std::uint64_t requesterGroup, std::uint64_t botGroup, bool raid) const
    {
        return Scope == "ALL" || (Group && requesterGroup == Group && botGroup == Group &&
            (Scope == "GROUP" || Scope == "PARTY" || (Scope == "RAID" && raid)));
    }
};
#endif
