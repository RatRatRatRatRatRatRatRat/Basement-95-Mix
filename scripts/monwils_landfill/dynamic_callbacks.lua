--This is still giga-WIP so if anything errors about it please lemme know.

local this = {}

local TriggerType = {
    CHARACTER = 1,
    PASSIVE_ITEM = 2,
    ACTIVE_ITEM = 3,
    TRINKET = 4,
}

this.Enums = {}
this.Enums.TriggerType = TriggerType

local triggers = {}

local mod = nil

local function AddDynamicCallbacks(callbackList)
    for _, dynamicCallback in ipairs(callbackList) do
        local modCallback, callbackFunction, param, priority = table.unpack(dynamicCallback)
        mod:AddPriorityCallback(modCallback, priority or 0, callbackFunction, param)
    end
end

local function RemoveDynamicCallbacks(callbackList)
    for _, dynamicCallback in ipairs(callbackList) do
        local modCallback, callbackFunction, param, priority = table.unpack(dynamicCallback)
        mod:RemoveCallback(modCallback, callbackFunction)
    end
end

function this.ActivateDynamicCallbacks(type, param)
    local callbackObject = triggers[type][param]
    if not callbackObject then
        return end
    if callbackObject.Initialised then
        return end
    callbackObject.Initialised = true
    if callbackObject.InitFunction then
        callbackObject.InitFunction()
    end
    AddDynamicCallbacks(callbackObject.CallbackList)
end

function this.DeactivateDynamicCallbacks(type, param)
    local callbackObject = triggers[type][param]
    if not callbackObject then
        return end
    if not callbackObject.Initialised then
        return end
    callbackObject.Initialised = false
    if callbackObject.UnloadFunction then
        callbackObject.UnloadFunction()
    end
    RemoveDynamicCallbacks(callbackObject.CallbackList)
end

local function RemoveAllCallbacks()
    for type, objects in pairs(triggers) do
        for param, object in pairs(objects) do
            this.DeactivateDynamicCallbacks(type, param)
        end
    end
end

function this:Init(inMod)
    assert(not mod, "Dynamic Callbacks error in Init: library was already initialised")
    assert(inMod, "Dynamic Callbacks error in Init: ModReference expected, got nil")
    mod = inMod

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, RemoveAllCallbacks)
    mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function (_, unloadedMod)
        if unloadedMod == mod then
            RemoveAllCallbacks()
        end
    end)

    mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, function (_, item)
        this.ActivateDynamicCallbacks(TriggerType.PASSIVE_ITEM, item)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, item)
        if not PlayerManager.AnyoneHasCollectible(item) then
            this.DeactivateDynamicCallbacks(TriggerType.PASSIVE_ITEM, item)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, function (_, _, trinket)
        this.ActivateDynamicCallbacks(TriggerType.TRINKET, trinket)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, function (_, _, trinket)
        if not PlayerManager.AnyoneHasTrinket(trinket) then
            this.DeactivateDynamicCallbacks(TriggerType.TRINKET, trinket)
        end
    end)

    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function ()
        for param, callbackList in pairs(triggers[TriggerType.PASSIVE_ITEM]) do
            RemoveDynamicCallbacks(callbackList)
        end
        for param, callbackList in pairs(triggers[TriggerType.TRINKET]) do
            RemoveDynamicCallbacks(callbackList)
        end
    end, CollectibleType.COLLECTIBLE_GENESIS)

    return this
end

function this.RegisterDynamicCallbacksList(type, param, callbackList, initFunction, unloadFunction)
    if not triggers[type] then
        triggers[type] = {}
    end
    assert(not triggers[type][param], "Readding callback of type " .. tostring(type) .. " with " .. tostring(param) .. " param")
    local newObject = {}
    newObject.Initialised = false
    newObject.CallbackList = callbackList
    newObject.InitFunction = initFunction
    newObject.UnloadFunction = unloadFunction
    triggers[type][param] = newObject
end

setmetatable(this, {__call = this.Init})

return this