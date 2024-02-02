local mod = Basement95MIX

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


--stat multipliers (they work but are a bit messy. update at your own risk)

local playerdamagemodifiers = {
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
    [PlayerType.PLAYER_BLUEBABY] = 1.05,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_KEEPER] = 1.5,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,

    [PlayerType.PLAYER_MAGDALENE_B] = 0.75,
    [PlayerType.PLAYER_CAIN_B] = 1.35,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_LAZARUS2_B] = 1.5,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
}

---@param player EntityPlayer
function mod:GetDamageMultiplier(player)
	local data = player:GetData()
	local effects = player:GetEffects()
    local type = player:GetPlayerType()
	local multi = 1.0

    if playerdamagemodifiers[type] ~= nil then
        multi = multi * playerdamagemodifiers[type]
    elseif type == PlayerType.PLAYER_EVE
    and effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) == 0 then
        multi = multi * 0.75
    end

	if effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MEGA_MUSH) > 0 then
		multi = multi * 4.0
	end

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EVES_MASCARA) > 0 then
		multi = multi * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_POLYPHEMUS) > 0 and
	   player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0
	then
		multi = multi * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SACRED_HEART) > 0 then
		multi = multi * 2.3
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ALMOND_MILK) > 0 then
		multi = multi * 0.3
	elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SOY_MILK) > 0 then
		multi = multi * 0.2
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IMMACULATE_HEART) > 0 then
		multi = multi * 1.2
	end

    if effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) > 0 then
		multi = multi * 2.0
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HAEMOLACRIA) > 0 then
		multi = multi * 1.5
	end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) > 0 then
		multi = multi * 0.8
	end

	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) > 0 or
	   player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) > 0 or
	   (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR) > 0 and
		effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) > 0)
	then
		multi = multi * 1.5
	end

    if REPENTOGON then
        multi = multi * player:GetD8DamageModifier()
        multi = multi * (1 + player:GetDeadEyeCharge() / 8)
    end

    mod:IsInHallowedCreep(player)
    mod:IsInHallowedGroundAura(player)
    if data.PeterModInStarAura and data.PeterModInStarAura > 0 then
        multi = multi * 1.8
    end
    if data.PeterModInHallowedCreep and data.PeterModInHallowedCreep > 0 then
        multi = multi * 1.2
    elseif data.PeterModInHallowedAura and data.PeterModInHallowedAura > 0 then
        multi = multi * 1.2
    end

	for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SUCCUBUS)) do
		if (player.Position - familiar.Position):Length() < 100 then
			multi = multi * 1.5
		end
	end

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.Damage / (multi * crown)) > 3.5 then
            multi = multi * crown
        end
    end

	return multi
end

---@param player EntityPlayer
function mod:GetTearMultiplier(player)
    local data = player:GetData()
    local multi = 1.0

    --Brimstone
    if player:HasWeaponType(2) then
        if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE) == 0 then
            multi = multi * 0.267
        else
            multi = multi * 0.33
        end
    end

    --Dr. Fetus
    if player:HasWeaponType(5) then
        multi = multi * 0.4
    end

    --Lung
    if player:HasWeaponType(7) then
        multi = multi * 0.23
    end

    --Tech X
    if player:HasWeaponType(9) then
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) > 0 then
            multi = multi * 0.32
        else
            multi = multi
        end
    end

    --Forgotten etc
    if player:HasWeaponType(10) then
      multi = multi * 0.5
    end

    --C section, Knife, Epic Fetus, Technology, Ludo and Sword doesn't change it?
    --Please report any unknown or forgotten synergy

    --Ipecac
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 then
        if not player:HasWeaponType(2) and
        not player:HasWeaponType(4) and
        not player:HasWeaponType(5) and
        not player:HasWeaponType(6) and
        not player:HasWeaponType(8) and
        not player:HasWeaponType(9) and
        not player:HasWeaponType(10) and
        not player:HasWeaponType(13) and
        not player:HasWeaponType(14) then
            multi = multi * 0.33
        end
    end

    --Almond/Soy Milk
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ALMOND_MILK) > 0 then
      multi = multi * 4
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SOY_MILK) > 0 then
      multi = multi * 5.5
    end

    if player:GetPlayerType() == PlayerType.PLAYER_EVE_B then
      multi = multi * 0.66
    end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EVES_MASCARA) > 0 then
      multi = multi * 0.66
    end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) > 0 then
      multi = multi * 0.66
    end

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE) > 0 and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
      multi = multi * 0.51
    elseif player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN) and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
      multi = multi * 0.51
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) > 0 and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 then
      multi = multi * 0.42
    elseif player:GetCollectibleNum(CollectibleType.COLLECTIBLE_POLYPHEMUS) > 0 and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) == 0 and
        not player:HasWeaponType(14) then
      multi = multi * 0.42
    end

    --Cards
    if player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_CHARIOT) then
      multi = multi * 4
    end

    --Misc
    if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT) > 0 and
        player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_DECAP_ATTACK) then
      multi = multi * 3
    end

    if REPENTOGON then
    local epiphora = player:GetEpiphoraCharge()
    if epiphora >= 270 then
        multi = multi * 2
    elseif epiphora >= 180 then
        multi = multi * (5/3)
    elseif epiphora >= 90 then
        multi = multi * (4/3)
    end

    multi = multi * player:GetD8FireDelayModifier()
    end

    mod:IsInHallowedCreep(player)
    mod:IsInHallowedGroundAura(player)

    if data.PeterModInStarAura and data.PeterModInStarAura > 0 then
        multi = multi * 2.5
    elseif data.PeterModInHallowedCreep and data.PeterModInHallowedCreep > 0 then
        multi = multi * 2.5
    elseif data.PeterModInHallowedAura and data.PeterModInHallowedAura > 0 then
        multi = multi * 2.5
    end

    return multi
end

---@param player EntityPlayer
function mod:GetRangeMultiplier(player)
    local multi = 1

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_NUMBER_ONE) > 0 then
        multi = multi * 0.8
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CRICKETS_BODY) > 0 then
        multi = multi * 0.8
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 then
        multi = multi * 0.8 ---i have no idea what the multiplier is
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MY_REFLECTION) > 0 then
        multi = multi * 2
    end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HAEMOLACRIA) > 0 then
        multi = multi * 0.8
    end

    if REPENTOGON then
        multi = multi * player:GetD8RangeModifier()
    end

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.TearRange / (40 * multi * crown)) > 6.5 then
            multi = multi * crown
        end
    end

    return multi
end

---@param player EntityPlayer
function mod:GetSpeedMultiplier(player)
    local multi = 1

    if REPENTOGON then
        multi = multi * player:GetD8SpeedModifier()
    end

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.MoveSpeed / (multi * crown)) > 1 then
            multi = multi * crown
        end
    end

    return multi
end

---@param player EntityPlayer
function mod:ReturnShotSpeedMultiplier(player)
    local multi = 1

    local crown = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)
    if crown > 0 then
        if (player.ShotSpeed / (multi * crown)) > 1 then
            multi = multi * crown
        end
    end

    return multi
end


---@param player EntityPlayer
function mod:IsInHallowedGroundAura(player)
    local data = player:GetData()
    local hallowedaura = 0
    local staraura = 0
    data.PeterModInHallowedAura = data.PeterModInHallowedAura or 0
    data.PeterModInStarAura = data.PeterModInHallowedAura or 0

    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
        if effect.Parent
        and (effect.Parent.Type == EntityType.ENTITY_POOP
        or effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.DIP) then
            local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 70 / 2) + player.Size
            if player.Position:Distance(effect.Position) < scale then
                hallowedaura = hallowedaura + 1
            end
        elseif effect.Parent
        and effect.Parent.Type == EntityType.ENTITY_FAMILIAR
        and effect.Parent.Variant == FamiliarVariant.STAR_OF_BETHLEHEM then
            local scale = 70 + player.Size
            if player.Position:Distance(effect.Position) < scale then
                staraura = staraura + 1
            end
        end
    end

    if hallowedaura ~= data.PeterModInHallowedAura then
        data.PeterModInHallowedAura = hallowedaura
    end
    if staraura ~= data.PeterModInStarAura then
        data.PeterModInStarAura = staraura
    end
end

---@param player EntityPlayer
function mod:IsInHallowedCreep(player)
    local data = player:GetData()
    local auranum = 0
    data.PeterModInHallowedCreep = data.PeterModInHallowedCreep or 0

    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP)) do
        effect = effect:ToEffect()
        local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 36 / 2)
        if effect.State == 64 and player.Position:Distance(effect.Position) <= scale then
            auranum = auranum + 1
        end
    end

    if auranum ~= data.PeterModInHallowedCreep then
        data.PeterModInHallowedCreep = auranum
    end
end