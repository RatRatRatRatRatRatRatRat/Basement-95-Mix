local mod = Basement95MIX

local PLAYER_DRIFTER = Isaac.GetPlayerTypeByName("Drifter", false)

local DRIFTER_SPEED = 4
local DRIFTER_MOVESPEED = 3

local DRIFTER_ANGLE_CHANCE = 10

local col1 = Color(1,1,1,1)
col1:SetColorize(0,0,0,1)
col1:SetColorize(1,0,0,1)

local col2 = Color(1,1,1,1)
col2:SetColorize(0,0,0,1)
col2:SetColorize(0,1,0,1)

local col3 = Color(1,1,1,1)
col3:SetColorize(0,0,0,1)
col3:SetColorize(0,0,1,1)

local NUM_TO_COLOR = {
    [0]=Color(1,1,1,1),
    [1]=col1,
    [2]=col2,
    [3]=col3,
}

local function drifterUpdate(_, player)
    if(player:GetPlayerType()~=PLAYER_DRIFTER) then return end
    local data = mod:getDataTable(player)

    if(not data.DRIFTER_MOVEVEC) then data.DRIFTER_MOVEVEC = Vector(0,1) end
    if(not data.DRIFTER_MOVEINT) then data.DRIFTER_MOVEINT = 1 end

    local cId = player.ControllerIndex

    if(Input.IsActionPressed(ButtonAction.ACTION_LEFT, cId)) then data.DRIFTER_MOVEVEC = data.DRIFTER_MOVEVEC:Rotated(-DRIFTER_SPEED)
    elseif(Input.IsActionPressed(ButtonAction.ACTION_RIGHT, cId)) then data.DRIFTER_MOVEVEC = data.DRIFTER_MOVEVEC:Rotated(DRIFTER_SPEED) end
    if(Input.IsActionPressed(ButtonAction.ACTION_UP, cId)) then data.DRIFTER_MOVEINT = mod:lerp(data.DRIFTER_MOVEINT, 1.25, 0.25)
    elseif(Input.IsActionPressed(ButtonAction.ACTION_DOWN, cId)) then data.DRIFTER_MOVEINT = mod:lerp(data.DRIFTER_MOVEINT, 0.75, 0.25)
    else data.DRIFTER_MOVEINT = mod:lerp(data.DRIFTER_MOVEINT, 1, 0.25) end

    player.Velocity = mod:lerp(player.Velocity, data.DRIFTER_MOVEVEC*data.DRIFTER_MOVEINT*player.MoveSpeed*DRIFTER_MOVESPEED, 0.25)

    player.Color = NUM_TO_COLOR[mod:getPlayerNumFromPlayerEnt(player)] or Color(1,1,1,1)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, drifterUpdate)

local MOVEMENT_ACTIONS = {
    [ButtonAction.ACTION_LEFT] = true,
    [ButtonAction.ACTION_DOWN] = true,
    [ButtonAction.ACTION_UP] = true,
    [ButtonAction.ACTION_RIGHT] = true,
}

local function cancelMove(_, player, hook, action)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==PLAYER_DRIFTER)) then return end
    if(not (MOVEMENT_ACTIONS[action])) then return end
    
    if(hook==InputHook.GET_ACTION_VALUE) then return 0 end
    if(hook==InputHook.IS_ACTION_PRESSED) then return false end
    if(hook==InputHook.IS_ACTION_TRIGGERED) then return false end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, cancelMove)

---@param player EntityPlayer
local function drifterInit(_, player)
    if(player:GetPlayerType()==PLAYER_DRIFTER) then
        player:AddMaxHearts(6)
        player:AddHearts(6)
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, drifterInit)