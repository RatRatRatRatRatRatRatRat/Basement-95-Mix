local TRINKET_ID = Isaac.GetTrinketIdByName("Unnamed Reroll Trinket")

local function PostMorph(_, pickup, oldType, oldVariant, oldSubtype, _, _, ignoreModifiers)
    if not(
        not ignoreModifiers
        and oldType == EntityType.ENTITY_PICKUP
        and oldVariant == PickupVariant.PICKUP_COLLECTIBLE
        and oldSubtype ~= CollectibleType.COLLECTIBLE_NULL
        and PlayerManager.AnyoneHasTrinket(TRINKET_ID)
    ) then
        return
    end

    pickup:AddCollectibleCycle(oldSubtype)
end

DynamicCallbacks.RegisterDynamicCallbacksList(DynamicCallbacks.Enums.TriggerType.TRINKET, TRINKET_ID,
{
    {ModCallbacks.MC_POST_PICKUP_MORPH, PostMorph}
})