local Basement95MIXData = {}

function Basement95MIX:getDataTable(entity)
    if(not Basement95MIXData[GetPtrHash(entity)]) then Basement95MIXData[GetPtrHash(entity)]={} end

    return Basement95MIXData[GetPtrHash(entity)]
end

function Basement95MIX:getData(entity, key)
    if(not Basement95MIXData[GetPtrHash(entity)]) then Basement95MIXData[GetPtrHash(entity)]={} end

    return Basement95MIXData[GetPtrHash(entity)][key]
end

function Basement95MIX:setData(entity, key, val)
    local exists = true
    if(not Basement95MIXData[GetPtrHash(entity)]) then
        Basement95MIXData[GetPtrHash(entity)]={}
        exists=false
    end

    Basement95MIXData[GetPtrHash(entity)][key]=val

    return exists
end

Basement95MIX:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE+1,
    function(_, entity)
        Basement95MIXData[GetPtrHash(entity)] = nil
    end
)

Basement95MIX:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE+1,
    function()
        Basement95MIXData = {}
    end
)