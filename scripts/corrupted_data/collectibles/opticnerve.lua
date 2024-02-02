local mod = Basement95MIX
local COLLECTIBLE_OPTIC_NERVE = Isaac.GetItemIdByName("Optic Nerve")
local FAMILIAR_OPTIC_NERVE = Isaac.GetEntityVariantByName("Optic Nerve")
local OPTIC_NERVE_SPEED = 1
local LASER_DAMAGE = 1
local LASER_COLOR = Color(1, 0.4, 0.4)

---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
    local count = player:GetCollectibleNum(COLLECTIBLE_OPTIC_NERVE) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    player:CheckFamiliar(FAMILIAR_OPTIC_NERVE, count, RNG())
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    local player = familiar.Player
    local data = familiar:GetData()
    familiar:MoveDiagonally(OPTIC_NERVE_SPEED)

    data.eyelaser = data.eyelaser or Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.ELECTRIC, 0, player.Position + Vector(0,-10), Vector.Zero, player):ToLaser()
    local laser = data.eyelaser

    if laser then
        local damage = LASER_DAMAGE
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS, false) then
            damage = damage * 2
        end
        laser.CollisionDamage = damage

        local startposition = player.Position + Vector(0, -12)
        local endposition = familiar.Position + Vector(0, -24) 
        laser.Velocity = (startposition - laser.Position)
        laser.Angle = (endposition - startposition):GetAngleDegrees()
        laser.MaxDistance = math.max(1, endposition:Distance(startposition) - 10)

        laser.Timeout = 0
        laser.DepthOffset = -400

        laser:SetColor(LASER_COLOR, -1, 1)
    end
end, FAMILIAR_OPTIC_NERVE)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    for _, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FAMILIAR_OPTIC_NERVE)) do
        local data = familiar:GetData()
        if data.eyelaser then
            data.eyelaser:Remove()
        end
        data.eyelaser = nil
    end
end)