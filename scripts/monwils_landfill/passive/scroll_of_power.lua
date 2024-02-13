local ITEM_ID = Isaac.GetItemIdByName("Scroll of Power")

local DAMAGE_MULTIPLIER = 1.15

local function PreTakeDamage(_, target, damage)
    print("ouch")
    if not PlayerManager.AnyoneHasCollectible(ITEM_ID) or not target:ToNPC() then
        return end
    local scrollCount = PlayerManager.GetNumCollectibles(ITEM_ID)
    local multiplier = DAMAGE_MULTIPLIER ^ scrollCount
    return {Damage = damage*multiplier}
end

DynamicCallbacks.RegisterDynamicCallbacksList(DynamicCallbacks.Enums.TriggerType.PASSIVE_ITEM, ITEM_ID,
{
    {ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDamage}
})