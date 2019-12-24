class 'L_Core'

local ScriptInfo = 
{
	Version = 0.24,
	Patch = 9.24,
	Release = "dAlpha",
}

DebugMode = false

L_Core.Colors = 
{
	['Red'] = Draw.Color(200, 200, 0, 0),
	['Yellow'] = Draw.Color(200, 200, 200, 0),
	['Green'] = Draw.Color(200, 0, 200, 0),
	['Blue'] = Draw.Color(200, 0, 0, 200),
	['Cyan'] = Draw.Color(200, 0, 200, 200),
	['White'] = Draw.Color(200, 255, 255, 255),
}

L_Core.OrderMode = { 
	None = 0,
	MaxHP = 1,
	CurrentHP = 2,
	MostAD = 3,
	MostAP = 4
}

L_Core.Team = { 
	Any = 0,
	Ally = 1,
	Enemy = 2
}

L_Core.PredictionSpellType = 
{
	Linear = "linear",
	Cone = "conic",
	Circular = "circular",
}
    
L_Core.PredictionCollisionType =  
{
	Minion = "minion",
	Hero = "hero",
	Windwall = "windwall",
}
    
L_Core.PredictionMenuHitchance =  
{
	0.2,
	0.3,
	0.5,
	0.75,
	1
}

local OrderModeSortPicker =
{
	function (a, b) return false end,
	function (a, b) return a.maxHealth > b.maxHealth end,
	function (a, b) return a.health > b.health end,
	function (a, b) return a.totalDamage > b.totalDamage end,
	function (a, b) return a.ap > b.ap end,
}

function L_Core:VersionCheck()
	return ScriptInfo.Version
end

function L_Core:CanCast(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

function L_Core:AddMenuInfo(source, menu)
    menu:MenuElement({type = SPACE})
    menu:MenuElement({name ="Patch" , drop = {source.Patch}})
    menu:MenuElement({name ="Version" , drop = {source.Version}})
    menu:MenuElement({name ="Release" , drop = {source.Release}})
end

-- MTG

function L_Core:GetHeroes(team, aliveOnly, orderMode, ignoreSelf)
	if team == nil then team = L_Core.Team.Any end
	if aliveOnly == nil then aliveOnly = false end
	if orderMode == nil then orderMode = L_Core.OrderMode.None end
	if ignoreSelf == nil then ignoreSelf = false end
	
    local heroes = {}
    for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if TeamCheck(hero, team)
				and AliveCondition(aliveOnly, hero.alive)
				and IgnoreCondition(ignoreSelf, hero.isMe)
				then
			table.insert(heroes, hero)
		end
    end
	
    return L_Core:OrderHeroes(orderMode, heroes)
end

function TeamCheck(hero, team)
	local enemyCheck = team == L_Core.Team.Enemy and hero.isEnemy
	local allyCheck = team == L_Core.Team.Ally and hero.isAlly
	return team == L_Core.Team.Any or enemyCheck or allyCheck
end

function AliveCondition(aliveOnly, alive)
	return not aliveOnly or alive
end

function IgnoreCondition(ignoreSelf, isMe)
	return not ignoreSelf or not isMe
end

function L_Core:GetHeroesInRange(range, team, aliveOnly, orderMode, ignoreSelf)
	if range == 0 then return {} end
	
    local heroes = L_Core:GetHeroes(team, aliveOnly, orderMode, ignoreSelf)
	local filteredByRange = {}
    for _, hero in pairs(heroes) do
		if hero.pos:DistanceTo(myHero.pos) <= range then
			table.insert(filteredByRange, hero)
		end
	end
	
	return filteredByRange
end

-- team: true - enemies, false - allies
function L_Core:CountHeroesInRange(range, team, aliveOnly, ignoreSelf)	
	local heroes = L_Core:GetHeroesInRange(range, team, aliveOnly, ignoreSelf)
	return #heroes
end

function L_Core:OrderHeroes(orderMode, heroes)
	if orderMode ~= L_Core.OrderMode.None then
		table.sort(heroes, OrderModeSortPicker[orderMode])
	end
	
	return heroes
end

function L_Core:ReverseTable(tbl)
	local ret = {}
    for i, val in ipairs(tbl) do
		ret[#tbl - i+1] = val
	end
	
	return ret
end

function L_Core:RemoveSelfFromTable(tbl)
	local ret = {}
    for i, val in ipairs(tbl) do
		ret[#tbl - i+1] = val
	end
	
	return ret
end

-- Math

function L_Core:Normalized(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    local length = math.sqrt(dx * dx + dz * dz)
    local sol = nil
    if (length > 0) then
        local inv = 1.0 / length
        sol = {x = (dx * inv), z = (dz * inv)}
    end
    return sol
end
 
function L_Core:Extended(vec, dir, range)
    if (dir == nil) then
        return vec
    end
    return {x = vec.x + dir.x * range, z = vec.z + dir.z * range}
end

-- Debug

function L_Core:Print(str)
	if(L_Core.DebugMode) then print(str) end
end