local ITEM_ID = Isaac.GetItemIdByName("</3")

---@param firstTime boolean
---@param player EntityPlayer
local function PostAddCollectible(_, _, _, firstTime, _, _, player)
    if firstTime then
        player:AddBrokenHearts(1)
    end
end
Basement95MIX:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PostAddCollectible, ITEM_ID)