local ITEM_ID = Isaac.GetItemIdByName("Black-Eyed Pea")

local BASE_RADIUS = 85
local GIGANTE_RADIUS = BASE_RADIUS*2 --I have no clue if that's the correct formula.
local WEAKNESS_DURATION = 600
local WEAKNESS_DURATION_SECOND_HAND = WEAKNESS_DURATION*2
local FART_COLOUR = Color(1,0,1, 1, 0,0,0)

local game = Game()

---@param player EntityPlayer
local function UseItem(_, _, _, player)
    local radius = BASE_RADIUS
    if player:HasTrinket(TrinketType.TRINKET_GIGANTE_BEAN) then
        radius = GIGANTE_RADIUS
    end
    game:Fart(player.Position, radius, player, 1, 0, FART_COLOUR)

    local playerRef = EntityRef(player)
    local duration = WEAKNESS_DURATION
    if player:HasTrinket(TrinketType.TRINKET_SECOND_HAND) then
        duration = WEAKNESS_DURATION_SECOND_HAND
    end
    for _, entity in ipairs(Isaac.FindInRadius(player.Position, radius, EntityPartition.ENEMY)) do
        if entity:IsActiveEnemy(false)
        and entity:IsVulnerableEnemy()
        and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            entity:AddWeakness(playerRef, duration)
        end
    end
end
Basement95MIX:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, ITEM_ID)