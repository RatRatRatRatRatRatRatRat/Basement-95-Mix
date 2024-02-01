local Basement95MIX = {}

function Isaac95Mod:getDataTable(entity)
    if(not Basement95MIX[GetPtrHash(entity)]) then Basement95MIX[GetPtrHash(entity)]={} end

    return Basement95MIX[GetPtrHash(entity)]
end

function Isaac95Mod:getData(entity, key)
    if(not Basement95MIX[GetPtrHash(entity)]) then Basement95MIX[GetPtrHash(entity)]={} end

    return Basement95MIX[GetPtrHash(entity)][key]
end

function Isaac95Mod:setData(entity, key, val)
    local exists = true
    if(not Basement95MIX[GetPtrHash(entity)]) then
        Basement95MIX[GetPtrHash(entity)]={}
        exists=false
    end

    Basement95MIX[GetPtrHash(entity)][key]=val

    return exists
end

Isaac95Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE+1,
    function(_, entity)
        Basement95MIX[GetPtrHash(entity)] = nil
    end
)

Isaac95Mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE+1,
    function()
        Basement95MIX = {}
    end
)