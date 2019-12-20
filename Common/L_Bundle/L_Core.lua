class 'L_Core'

local ScriptInfo = 
{
	Version = 0.02,
	Patch = 9.24,
	Release = "dAlpha",
}

DebugMode = false

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

-- Gathering

function L_Core:GetHeroes()
    local Heroes = {}
    for i = 1, Game.HeroCount() do
        table.insert(Heroes, Game.Hero(i))
    end
    return Heroes
end

-- team: true - enemies, false - allies
function L_Core:CountHeroesInRange(range, team)
	if team == nil then team = false end
	local enemyInRange = 0
    for i, hero in pairs(L_Core:GetHeroes()) do
		if hero.isEnemy == team and not hero.dead and not hero.isMe and hero.pos:DistanceTo(myHero.pos) <= range then
			enemyInRange = enemyInRange + 1
		end
    end
	return enemyInRange
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