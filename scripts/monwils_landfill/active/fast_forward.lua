local ITEM_ID = Isaac.GetItemIdByName("Fast Forward")

local skipCallback = false

---@param player EntityPlayer
local function PostPeffectUpdate(_, player)
    local effects = player:GetEffects()
    if skipCallback or
    not effects:HasCollectibleEffect(ITEM_ID) then
        return end

    skipCallback = true
    for i = 1, effects:GetCollectibleEffectNum(ITEM_ID) do
        player:Update()
    end
    skipCallback = false
end
Basement95MIX:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPeffectUpdate)

local function FamiliarUpdate(_, familiar)
    local effects = familiar.Player:GetEffects()
    if skipCallback or
    not effects:HasCollectibleEffect(ITEM_ID) then
        return end

    skipCallback = true
    for i = 1, effects:GetCollectibleEffectNum(ITEM_ID) do
        familiar:Update()
    end
    skipCallback = false
end
Basement95MIX:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FamiliarUpdate)

local function UseItem()
    return true
end
Basement95MIX:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, ITEM_ID)