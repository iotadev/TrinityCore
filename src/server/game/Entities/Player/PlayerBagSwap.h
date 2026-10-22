/* GPL v2 or later. Native swap-scoped nonempty bag storage admission.
 * AzerothCore comparison/provenance is recorded in the Playerbots port notes. */
#ifndef PLAYER_BAG_SWAP_H
#define PLAYER_BAG_SWAP_H
namespace PlayerBagSwap
{
inline bool AllowsStorage(bool nativeSwap, bool swapping, bool carriedBag,
    bool backpackPosition, bool ownedSource, bool ownedTarget, bool emptyTargetBag)
{
    return nativeSwap && swapping && carriedBag && backpackPosition &&
        ownedSource && ownedTarget && emptyTargetBag;
}
}
#endif
