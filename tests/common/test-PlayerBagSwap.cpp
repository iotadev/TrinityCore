/* GPL v2 or later. Native storage exception is confined to exact swap facts. */
#include "../../src/server/game/Entities/Player/PlayerBagSwap.h"
#include <catch2/catch.hpp>
TEST_CASE("Populated bag storage exception requires every native swap fact", "[inventory][bags]")
{
    for (unsigned mask = 0; mask < 128; ++mask)
        REQUIRE(PlayerBagSwap::AllowsStorage(mask & 1, mask & 2, mask & 4, mask & 8,
            mask & 16, mask & 32, mask & 64) == (mask == 127));
}
