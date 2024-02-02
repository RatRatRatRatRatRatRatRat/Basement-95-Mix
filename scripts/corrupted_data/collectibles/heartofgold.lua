local mod = Basement95MIX
local COLLECTIBLE_HEART_OF_GOLD = Isaac.GetItemIdByName("Heart of Gold")

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
    local count = player:GetCollectibleNum(COLLECTIBLE_HEART_OF_GOLD)
    if count > 0 then
        if Game():IsGreedMode() then
            local dmg = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.GREED_DONATION_MACHINE_COUNTER) * (mod:GetDamageMultiplier(player) / 300)
            player.Damage = player.Damage + dmg
        else
            local dmg = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.DONATE_MACHINE_COUNTER) * (mod:GetDamageMultiplier(player) / 300)
            player.Damage = player.Damage + dmg        
        end
    end
end, CacheFlag.CACHE_DAMAGE)

local function donationMachineInteraction(_, _, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(COLLECTIBLE_HEART_OF_GOLD) then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, donationMachineInteraction, SlotVariant.DONATION_MACHINE)
mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, donationMachineInteraction, SlotVariant.GREED_DONATION_MACHINE)