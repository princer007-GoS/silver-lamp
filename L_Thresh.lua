local Version = 0.01
local Patch = 9.24

if (myHero.charName ~= "Thresh") then 
    return
end

require('GamsteronPrediction')

local QData, EData, LastQTime

function OnLoad()
	QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 80, Range = 1000, Speed = 1900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}, UseBoundingRadius = true }
	EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 150, Range = 450, Speed = 1100, Collision = false}
	
	LoadMenu()
end

function LoadMenu()
    MM = MenuElement({type = MENU, id = "mm", name = "[L] Thresh"})

    MM:MenuElement({type = SPACE, name = "[L] Thresh - WIP"})
    MM:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    --MM.Combo:MenuElement({id = "Mode", name = "Mode", value = 1, drop = {"Hook anyone in range", "Hook by target selector priorities"}})
    MM.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
    MM.Combo:MenuElement({id = "QPredChance", name = "Hitchance", value = 2, drop = {"Normal", "High", "Immobile"}})
    --MM.Combo:MenuElement({type = SPACE, name = ""})
    --MM.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
    --MM.Combo:MenuElement({id = "WMode", name = "Mode", value = 2, drop = {"Always cast ASAP", "Save ally when low"}})
    MM.Combo:MenuElement({type = SPACE, name = ""})
    MM.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
    MM.Combo:MenuElement({id = "EMode", name = "Mode", value = 1, drop = {"Pull enemy closer", "Push enemy away", "Smart cast (WIP)"}})
    MM.Combo:MenuElement({type = SPACE, name = ""})
    MM.Combo:MenuElement({id = "UseR", name = "Use R", value = true})
    MM.Combo:MenuElement({id = "EnemiesToCastR", name = "Minimum enemies to cast", value = 2, min = 1, max = 5, step = 1})

    MM:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    MM.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})
    MM.Harass:MenuElement({id = "QPredChance", name = "Hitchance", value = 2, drop = {"Normal", "High", "Immobile"}})

    MM:MenuElement({type = SPACE})
    MM:MenuElement({name ="Patch : " , drop = {Patch}})
    MM:MenuElement({name ="Version " , drop = {Version}})

end

function OnDraw()
    if myHero.dead then return end

	Draw.Circle(myHero.pos, QData.Range, 0, Draw.Color(200, 255, 255, 255))
end

--TRASH

function OnTick()
    local target = _G.SDK.TargetSelector:GetTarget(QData.Range)
	
	if not _G.SDK.Orbwalker.AttackEnabled and Game.Timer() - LastQTime > 2.5 then _G.SDK.Orbwalker:SetAttack(true) end
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		Combo(target)
	end
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		Harass(target)
	end
	
	print(CountEnemyHeroInRange(425))
end

function Combo(target)
	--if(MM.Combo.Mode:Value() == 1) then end
	if(MM.Combo.UseQ:Value()) then CastQ(target, GetPredSetting(MM.Combo)) end
	--if(MM.Combo.UseW:Value()) then CastW() end
	if(MM.Combo.UseE:Value()) then CastE() end
	if(MM.Combo.UseR:Value()) then CastR() end
end

function Harass(target)
	CastQ(target, GetPredSetting(MM.Harass))
end

--CAST

function CastQ(target, predChance)
	if Game.CanUseSpell(_Q) ~= READY then return end
	if not IsSecondQ() then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= predChance then
			_G.SDK.Orbwalker:SetAttack(false)
			Control.CastSpell(HK_Q, pred.CastPosition)
			LastQTime = Game.Timer()
		end
	end 
	
	if IsSecondQ() and myHero:GetSpellData(_E).currentCd <= 0.4 and myHero:GetSpellData(_E).level > 0 then
		_G.SDK.Orbwalker:SetAttack(true)
		Control.CastSpell(HK_Q)
		CastW(true)
	end
end

function CastW(force)
	if Game.CanUseSpell(_W) ~= READY then return end

end

function CastE()
	if Game.CanUseSpell(_E) ~= READY then return end
    local target = _G.SDK.TargetSelector:GetTarget(EData.Range)
	if target == nil then return end
	
	local castDistance = -450
	if(MM.Combo.EMode:Value() == 2) then castDistance = 450 end
	
	Control.CastSpell(HK_E, Extended(myHero.pos, Normalized(target.pos, myHero.pos), castDistance))
end

function CastR()
	if Game.CanUseSpell(_R) ~= READY then return end
	if CountEnemyHeroInRange(450 - 35) >= MM.Combo.EnemiesToCastR:Value() then
		Control.CastSpell(HK_R)
	end
end

--MISC, MOVE TO THE CORE
 
function Normalized(p1, p2)
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
 
function Extended(vec, dir, range)
    if (dir == nil) then
        return vec
    end
    return {x = vec.x + dir.x * range, z = vec.z + dir.z * range}
end

function GetHeroes()
    local Heroes = {}
    for i = 1, Game.HeroCount() do
        table.insert(Heroes, Game.Hero(i))
    end
    return Heroes
end

function CountEnemyHeroInRange(range)
local enemyInRange = 0
        for i, hero in pairs(GetHeroes()) do
            if hero.isEnemy and not hero.dead and hero.pos:DistanceTo(myHero.pos) <= range then
                enemyInRange = enemyInRange + 1
            end
        end
return enemyInRange
end

function GetPredSetting(menu)
	return menu.QPredChance:Value()+1
end

function IsSecondQ()
	return myHero:GetSpellData(_Q).name == "ThreshQLeap"
end