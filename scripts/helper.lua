local mod = Isaac95Mod

function mod:unlock(unlock, force)
    local pgd = Isaac.GetPersistentGameData()
    if(not force) then
        if(not Game():AchievementUnlocksDisallowed()) then
            if(not pgd:Unlocked(unlock)) then
                pgd:TryUnlock(unlock)
            end
        end
    else
        pgd:TryUnlock(unlock)
    end
end

function mod:cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key]={}
            for key2, val2 in pairs(mod:cloneTable(val)) do
                tClone[key][key2]=val2
            end
        else
            tClone[key]=val
        end
    end
    return tClone
end
function mod:cloneTableWithoutDeleteing(table1, table2)
    for key, val in pairs(table2) do
        if(type(val)=="table") then
            table1[key] = {}
            mod:cloneTableWithoutDeleteing(table1[key], table2[key])
        else
            table1[key]=val
        end
    end
end

---@param v Vector
function mod:vectorToVectorTable(v)
    return
    {
        X = v.X,
        Y = v.Y,
        IsVectorTable = true,
    }
end
---@param t table
function mod:vectorTableToVector(t)
    return Vector(t.X, t.Y)
end

---@param c Color
function mod:colorToColorTable(c)
    return
    {
        R = c.R,
        G = c.G,
        B = c.B,
        A = c.A,
        RO = c.RO,
        GO = c.GO,
        BO = c.BO,
        IsColorTable = true,
    }
end
---@param t table
function mod:colorTableToColor(t)
    return Color(t.R, t.G, t.B, t.A, t.RO, t.GO, t.BO)
end

---@param val number Value to clamp
---@param upper number Upper bound of the range
---@param lower number Lower bound of the range
---@return number clampedVal The clamped value
---Clamps a given value into a range
function mod:clamp(val, upper, lower)
    return math.min(upper, math.max(val, lower))
end

function mod:lerp(a, b, f)
    return a*(1-f)+b*f
end

---@param t table The table to count
---@return number count The number of elements in the table
---Counts the number of elements in a table
function mod:countElements(t)
    local count = 0
    for _, _ in pairs(t) do count = count+1 end

    return count
end

---@param player EntityPlayer
---@return number num
function mod:getPlayerNumFromPlayerEnt(player)
    for i=0, Game():GetNumPlayers()-1 do
        if(GetPtrHash(player)==GetPtrHash(Isaac.GetPlayer(i))) then return i end
    end
    return 0
end

function mod:getScreenCenter()
    return (Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286))/2
end
function mod:getScreenBottomRight()
    return Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286)
end

function mod:addCustomStrawman(playerType, cIndex)
    playerType=playerType or 0
    cIndex=cIndex or 0
    local LastPlayerIndex=Game():GetNumPlayers()-1
    if LastPlayerIndex>=63 then return nil else
        Isaac.ExecuteCommand('addplayer '..playerType..' '..cIndex)
        local strawman=Isaac.GetPlayer(LastPlayerIndex+1)
        strawman.Parent=Isaac.GetPlayer(0)
        Game():GetHUD():AssignPlayerHUDs()
        return strawman
    end
end

---true players just means they're not strawman-like characters
function mod:isTruePlayer(player)
    return (player.Parent==nil)
end

function mod:getNumberOfTruePlayers()
    local c = 0
    for _, player in ipairs(Isaac.FindByType(1)) do
        if(mod:isTruePlayer(player)) then c=c+1 end
    end
    return c
end

function mod:getTruePlayers()
    local idx = 0
    local p = {}
    for i=0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(i)
        if(mod:isTruePlayer(player)) then
            p[idx] = player
            idx=idx+1
        end
    end

    return p
end

---@param f Font
---@param str string
---@param maxlength number
function mod:separateStringIntoLines(f, str, maxlength)
    local fStrings = {}
    local splitStrings = {}

    for s in str:gmatch("([^ ]+)") do
        splitStrings[#splitStrings+1] = s
    end

    local st = ""

    for _, s in ipairs(splitStrings) do
        if(f:GetStringWidth(st.." "..s)>maxlength) then
            fStrings[#fStrings+1] = st
            st=s
        else
            st=st.." "..s
        end
    end

    fStrings[#fStrings+1] = st

    return fStrings
end

---@param pos Vector
function mod:closestPlayer(pos)
	local entities = Isaac.FindByType(1)
	local closestEnt = Isaac.GetPlayer()
	local closestDist = 2^32
	for i = 1, #entities do
		if not entities[i]:IsDead() then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]:ToPlayer()
			end
		end
	end
	return closestEnt
end

function mod:toTps(n)
    return 30/(n+1)
end
function mod:toFireDelay(n)
    return (30/n)-1
end
function mod:getTps(player)
    return 30/(player.MaxFireDelay+1)
end

function mod:addTps(player, n)
    return (30/(30/(player.MaxFireDelay+1)+n))-1
end

function mod:renderingAboveWater()
    return Game():GetRoom():GetRenderMode()==RenderMode.RENDER_NORMAL or Game():GetRoom():GetRenderMode()==RenderMode.RENDER_WATER_ABOVE
end

function mod:getKeyFromVal(table, val)
    for key, v in pairs(table) do
        if(v==val) then return key end
    end
    return nil
end

function mod:setBaited(e, s, d)
    e:AddBaited(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_BAITED)
    e:SetBaitedCountdown(d)
end
function mod:getBaitedFrames(e) return e:GetBaitedCountdown() end
function mod:setBleeding(e, s, d)
    e:AddBleeding(EntityRef(s), 1)
    e:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    e:SetBleedingCountdown(d)
end
function mod:getBleedingFrames(e) return e:GetBaitedCountdown() end
function mod:setBrimstoneMark(e, s, d)
    e:AddBrimstoneMark(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
    e:SetBrimstoneMarkCountdown(d)
end
function mod:getBrimstoneMarkFrames(e) return e:GetBaitedCountdown() end
function mod:setBurn(e, s, d, dmg)
    e:AddBurn(EntityRef(s),1, dmg)
    e:AddEntityFlags(EntityFlag.FLAG_BURN)
    e:SetBurnCountdown(d)
end
function mod:getBurnFrames(e) return e:GetBleedingCountdown() end
function mod:setCharmed(e, s, d)
    e:AddCharmed(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_CHARM)
    e:SetCharmedCountdown(d)
end
function mod:getCharmedFrames(e) return e:GetCharmedCountdown() end
function mod:setConfusion(e, s, d, ignoreBoss)
    e:AddConfusion(EntityRef(s),1,ignoreBoss or false)
    e:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
    e:SetConfusionCountdown(d)
end
function mod:getConfusionFrames(e) return e:GetConfusionCountdown() end
function mod:setFear(e, s, d)
    e:AddFear(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_FEAR)
    e:SetFearCountdown(d)
end
function mod:getFearFrames(e) return e:GetFearCountdown() end
function mod:setFreeze(e, s, d)
    e:AddFreeze(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_FREEZE)
    e:SetFreezeCountdown(d)
end
function mod:getFreezeFrames(e) return e:GetFreezeCountdown() end
function mod:setIce(e, s, d)
    e:AddIce(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_ICE)
    e:SetIceCountdown(d)
end
function mod:getIceFrames(e) return e:GetIceCountdown() end
function mod:setKnockback(e, s, d, direction, takeImpact)
    e:AddKnockback(s,direction,1,takeImpact)
    e:SetKnockbackCountdown(d)
end
function mod:getKnockbackFrames(e) return e:GetKnockbackCountdown() end
function mod:setMagnetized(e, s, d)
    e:AddMagnetized(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
    e:SetMagnetizedCountdown(d)
end
function mod:getMagnetizedFrames(e) return e:GetMagnetizedCountdown() end
function mod:setMidasFreeze(e, s, d)
    e:AddMidasFreeze(EntityRef(s),d-e:GetMidasFreezeCountdown())
end
function mod:getMidasFreezeFrames(e) return e:GetMidasFreezeCountdown() end
function mod:setPoison(e, s, d, dmg)
    e:AddPoison(EntityRef(s), 1, dmg)
    e:AddEntityFlags(EntityFlag.FLAG_POISON)
    e:SetPoisonCountdown(d)
end
function mod:getPoisonFrames(e) return e:GetPoisonCountdown() end
function mod:setShrink(e, s, d)
    e:AddShrink(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_SHRINK)
    e:SetShrinkCountdown(d)
end
function mod:getShrinkFrames(e) return e:GetShrinkCountdown() end
function mod:setSlowing(e, s, d, val, color)
    e:AddSlowing(EntityRef(s), 1, val, color)
    e:SetSlowingCountdown(d)
end
function mod:getSlowingFrames(e) return e:GetSlowingCountdown() end
function mod:setWeakness(e, s, d)
    e:AddWeakness(EntityRef(s), 1)
    e:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
    e:SetWeaknessCountdown(d)
end
function mod:getWeaknessFrames(e) return e:GetWeaknessCountdown() end

function mod:getHeartHudPosition(playerNum)
    if(playerNum==0) then
        return Vector(41,5)+Vector(20,12)*Options.HUDOffset
    elseif(playerNum==1) then
        return Vector(-118+Isaac.GetScreenWidth(), 5)+Vector(-24,12)*Options.HUDOffset
    elseif(playerNum==2) then
        return Vector(51,-34+Isaac.GetScreenHeight())+Vector(22,-6)*Options.HUDOffset
    elseif(playerNum==3) then
        return Vector(-118+Isaac.GetScreenWidth(),-34+Isaac.GetScreenHeight())+Vector(-24,-6)*Options.HUDOffset
    end
    return Vector(-100,-100)
end

---@param entity Entity
function mod:isValidEnemy(entity)
    return (entity:IsEnemy() and entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
end

function mod:closestEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if mod:isValidEnemy(entities[i]) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end
	return closestEnt
end

function mod:closestVisibleEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if(mod:isValidEnemy(entities[i]) and Game():GetRoom():CheckLine(pos, entities[i].Position, 1)) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end
	return closestEnt
end