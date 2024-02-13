local ITEM_ID = Isaac.GetItemIdByName("Red Roulette")

local DAMAGE_MULTIPLIER = 0.15
local SHOT_COUNT = 6

---@param player EntityPlayer
local function EvaluateCache(_, player)
    local peffects = player:GetEffects()
    if not peffects:HasCollectibleEffect(ITEM_ID) then
        return end
    player.Damage = player.Damage * (1 + DAMAGE_MULTIPLIER*peffects:GetCollectibleEffectNum(ITEM_ID))
end
Basement95MIX:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache, CacheFlag.CACHE_DAMAGE)

---@param item integer
---@param rng RNG
---@param player EntityPlayer
local function UseItem(_, item, rng, player)
    local peffects = player:GetEffects()
    local seed = rng:GetSeed()
    if seed%SHOT_COUNT == peffects:GetCollectibleEffectNum(ITEM_ID)%SHOT_COUNT then
        player:AddBrokenHearts(4)
        player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        player:TakeDamage(0, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
        rng:Next()
        return
        {
            ShowAnim = true,
            Remove = true,
            Discharge = false,
        }
    end
    return
    {
        ShowAnim = true,
        Remove = false,
        Discharge = false,
    }
end
Basement95MIX:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, ITEM_ID)