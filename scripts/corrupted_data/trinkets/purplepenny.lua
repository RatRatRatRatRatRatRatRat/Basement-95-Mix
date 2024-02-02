local mod = Basement95MIX
local TRINKET_PURPLE_PENNY = Isaac.GetItemIdByName("Purple Penny")

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    if PlayerManager.AnyoneHasTrinket(TRINKET_PURPLE_PENNY) then
        local rng = RNG()
        local seed = Game():GetRoom():GetDecorationSeed()
        rng:SetSeed(seed, 32)
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsEnemy() and not entity:IsBoss() then
                local entity = entity:ToNPC()
                if not entity:IsChampion() and EntityConfig.GetEntity(entity.Type):CanBeChampion() and rng:RandomFloat() < 0.1 then
                    entity:MakeChampion(entity.InitSeed)
                end
            end
        end
    end
end)

---@param npc EntityNPC
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
    if PlayerManager.AnyoneHasTrinket(TRINKET_PURPLE_PENNY) and npc:IsChampion() then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, npc.Position, Vector.Zero, npc)
    end
end)