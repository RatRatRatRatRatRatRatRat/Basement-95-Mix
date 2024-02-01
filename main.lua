Basement95MIX = RegisterMod("Basement95Mix", 1)
local mod = Basement95MIX

local mod_files = {
    "scripts.custom_data",
    "scripts.helper",
    
    "scripts.rapture.players.drifter",
}
for _, path in ipairs(mod_files) do
    include(path)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)