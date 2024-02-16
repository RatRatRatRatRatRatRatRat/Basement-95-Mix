local ITEM_ID = Isaac.GetItemIdByName("Glitched Miner")

local errorOreOutcomes = {
    {100,
    ---@param rock GridEntityRock
    ---@param rng RNG
    function (rock, rng)
        Isaac.Spawn(
            EntityType.ENTITY_BOMB,
            BombVariant.BOMB_TROLL,
            BombSubType.BOMB_TROLL,
            rock.Position,
            rng:RandomVector()*15,
            nil
        )
    end},
    {100,
    ---@param rock GridEntityRock
    ---@param rng RNG
    function (rock, rng)
        for i = 1, 3 do
            local soul = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.HUNGRY_SOUL,
                0,
                rock.Position + rng:RandomVector()*6,
                Vector.Zero,
                PlayerManager.FirstCollectibleOwner(ITEM_ID)
            ):ToEffect()
            soul:SetTimeout(150)
        end
    end},
    {1,
    ---@param rock GridEntityRock
    ---@param rng RNG
    function (rock, rng)
        local deli = Isaac.Spawn(
            EntityType.ENTITY_DELIRIUM,
            0,
            0,
            rock.Position,
            Vector.Zero,
            nil
        )
        deli.MaxHitPoints = 20
        deli.HitPoints = 20
    end},
    {5,
    ---@param rock GridEntityRock
    ---@param rng RNG
    function (rock, rng)
        local item = ProceduralItemManager.CreateProceduralItem(rng:GetSeed(), 1)
        Isaac.Spawn(
            EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            item,
            rock.Position,
            Vector.Zero,
            nil
        )
    end},
}

local picker = WeightedOutcomePicker()

for index, outcome in ipairs(errorOreOutcomes) do
    picker:AddOutcomeWeight(index, outcome[1])
end

---@param rock GridEntityRock
local function IsErrore(rock)
    return rock.Desc.SpawnSeed%5 == 0
end

---@param rock GridEntityRock
---@param type GridEntityType
---@param immediate boolean
local function PostRockDestroy(_, rock, type, immediate)
    if not
        (PlayerManager.AnyoneHasCollectible(ITEM_ID)
        and IsErrore(rock))
    then
        return
    end
    local rng = RNG()
    rng:SetSeed(rock.Desc.SpawnSeed)
    local outcomeNum = picker:PickOutcome(rng)
    errorOreOutcomes[outcomeNum][2](rock, rng)
end

---@param rock GridEntityRock
local function PostRockRender(_, rock)
    if not
        (rock.State == 1
        and PlayerManager.AnyoneHasCollectible(ITEM_ID)
        and IsErrore(rock))
    then
        return
    end
    local pos = Isaac.WorldToScreen(rock.Position)
    Isaac.RenderText("errore", pos.X, pos.Y, 1,1,1,1)
end

DynamicCallbacks.RegisterDynamicCallbacksList(DynamicCallbacks.Enums.TriggerType.PASSIVE_ITEM, ITEM_ID,
{
    {ModCallbacks.MC_POST_GRID_ROCK_DESTROY, PostRockDestroy, GridEntityType.GRID_ROCK},
    {ModCallbacks.MC_POST_GRID_ENTITY_ROCK_RENDER, PostRockRender, GridEntityType.GRID_ROCK}
})