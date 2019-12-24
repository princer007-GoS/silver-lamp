class 'L_Script'

local ScriptInfo = 
{
	Version = 0.74,
	Patch = 9.24,
	Release = "dBeta",
}

if (myHero.charName ~= "Thresh") then 
    return
end

local inited = false
local QData, WData, EData, QTarget

--Init

function LoadMenu()
    MM = MenuElement({type = MENU, id = "mm", name = "[L] Thresh"})

    MM:MenuElement({type = SPACE, name = "[L] Thresh - WIP"})
    MM:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    MM.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
    MM.Combo:MenuElement({id = "QPredChance", name = "Hitchance", value = 2, drop = {"Normal", "High", "Very high", "Try to dodge", "Immobile"}})
    MM.Combo:MenuElement({type = SPACE, name = ""})
    MM.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
    MM.Combo:MenuElement({id = "UseWAfter", name = "Cast W after second Q", value = true})
    MM.Combo:MenuElement({id = "WMode", name = "Mode", value = 2, drop = {"Always cast", "Save ally when low"}})
    MM.Combo:MenuElement({id = "WPrio", name = "Priority", value = 2, drop = {"MaxHP", "CurrentHP", "MostAD", "MostAP"}})
    MM.Combo:MenuElement({id = "WIgnoreSelf", name = "Don't cast on self", value = false})
    MM.Combo:MenuElement({type = SPACE})
    MM.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
    MM.Combo:MenuElement({id = "EMode", name = "Mode", value = 1, drop = {"Pull enemy closer", "Push enemy away", "Smart cast (WIP)"}})
    MM.Combo:MenuElement({type = SPACE})
    MM.Combo:MenuElement({id = "UseR", name = "Use R", value = true})
    MM.Combo:MenuElement({id = "EnemiesToCastR", name = "Minimum enemies to cast", value = 2, min = 1, max = 5, step = 1})

    MM:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    MM.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})
    MM.Harass:MenuElement({id = "QMode", name = "Mode", value = 1, drop = {"Hook when possible", "Only target selector priorities"}})
    MM.Harass:MenuElement({id = "QPredChance", name = "\"Hook when possible\" hitchance", value = 2, drop = {"Normal", "High", "Very high", "Try to dodge", "Immobile"}})
	
    MM:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
    MM.Drawings:MenuElement({id = "Q", name = "Draw Q range", value = true})
    MM.Drawings:MenuElement({id = "QTarget", name = "Draw Q target", value = true})
	L_Core:AddMenuInfo(ScriptInfo, MM)
end

function L_Script:Init()
	WData = {Range = 950, Radius = 150}
	
	QData = {type = L_Core.PredictionSpellType.Linear, delay = 0.5, radius = 75, range = 1000, speed = 1900, collision = {L_Core.PredictionCollisionType.Minion, L_Core.PredictionCollisionType.Windwall, L_Core.PredictionCollisionType.Hero}}
	EData = {type = L_Core.PredictionSpellType.Linear, delay = 0.25, radius = 150, range = 450, speed = 1100, collision = {}}
	
	LoadMenu()
	
	L_Core:LoadSubmodule("PremiumPrediction")
	
	inited = true
end

function L_Script:VersionCheck()
	return ScriptInfo.Version
end 

--TRASH

function OnTick()
    if myHero.dead or not inited then return end
	
    QTarget = _G.SDK.TargetSelector:GetTarget(QData.range)
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		Combo()
	end
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		Harass()
	end
end

function OnDraw()
    if myHero.dead or not inited then return end
	if MM.Drawings.Q:Value() then Draw.Circle(myHero.pos, QData.range, 0, L_Core.Colors["White"]) end
	if MM.Drawings.QTarget:Value() and QTarget then Draw.Circle(QTarget.pos, 100, 0, L_Core.Colors['Cyan']) end
end


function Combo()
	--if(MM.Combo.Mode:Value() == 1) then end
	if(MM.Combo.UseR:Value()) then CastR() end
	if(MM.Combo.UseW:Value()) then CastW() end
	if(MM.Combo.UseE:Value()) then CastE() end
	if(MM.Combo.UseQ:Value()) then CastQ() end
end

function Harass()
	if IsSecondQ() or not MM.Harass.UseQ:Value() then return end
	
	if MM.Harass.QMode:Value() == 1 then
		CastAnyQ()
	end
	
	if MM.Harass.QMode:Value() == 2 then
		CastQ()
	end
end

--CAST
function CastAnyQ()
	if Game.CanUseSpell(_Q) ~= READY then return end
	local enemies = L_Core:GetHeroesInRange(QData.range, L_Core.Team.Enemy, true, L_Core.OrderMode.CurrentHP, true)
	
    for _, enemy in pairs(enemies) do
		local predprem = _G.PremiumPrediction:GetPrediction(myHero, enemy, QData)
		if predprem.HitChance >= L_Core.PredictionMenuHitchance[MM.Harass.QPredChance:Value()] then
			InitiateQCast(predprem.PredPos)
		end
	end
end

function CastQ()
	if Game.CanUseSpell(_Q) ~= READY then return end
	local isSecondQActive = IsSecondQ()
	
	if not isSecondQActive then
		FirstQCast()
	end 
	
	if isSecondQActive and 
			myHero:GetSpellData(_E).currentCd <= 0.4 and 
			myHero:GetSpellData(_E).level > 0 then
		SecondQCast()
	end
end

function FirstQCast()
	if QTarget == nil then return end
	local predprem = _G.PremiumPrediction:GetPrediction(myHero, QTarget, QData)
	if predprem.HitChance >= L_Core.PredictionMenuHitchance[MM.Combo.QPredChance:Value()] then
		InitiateQCast(predprem.PredPos)
	end
end

function InitiateQCast(pos)
		_G.SDK.Orbwalker:SetAttack(false)
		Control.CastSpell(HK_Q, pos)
        DelayAction(function() _G.SDK.Orbwalker:SetAttack(true) end, 2)
end

function SecondQCast()
	_G.SDK.Orbwalker:SetAttack(true)
	if MM.Combo.UseWAfter:Value() then CastW(true) end
	Control.CastSpell(HK_Q)
end

function CastW(force)
	if Game.CanUseSpell(_W) ~= READY then return end
	local hpPerc = 0.35
	local sortOrder = MM.Combo.WPrio:Value()
	local wMode = MM.Combo.WMode:Value()
	
	if wMode == 1 then hpPerc = 1 end
	if wMode == 2 then sortOrder = L_Core.OrderMode.CurrentHP end
	
	local allies = L_Core:GetHeroesInRange(WData.Range + 250, L_Core.Team.Ally, true, sortOrder, MM.Combo.WIgnoreSelf:Value() or force)
	
	if #allies == 0 then return end
	if wMode == 2 then allies = L_Core:ReverseTable(allies) end
	
	if allies[1].health / allies[1].maxHealth <= hpPerc or force then
		local pos = allies[1].pos
		local dist = pos:DistanceTo(myHero.pos)
		
		if allies[1].isMe then pos = { x = 0, y = 0, z = 0} end
		_G.SDK.Orbwalker:SetMovement(false)
		Control.CastSpell(HK_W, L_Core:Extended(myHero.pos, L_Core:Normalized(pos, myHero.pos), dist-120))
        DelayAction(function() _G.SDK.Orbwalker:SetMovement(true) end, 1)
	end
end

function CastE()
	if Game.CanUseSpell(_E) ~= READY then return end
    local target = _G.SDK.TargetSelector:GetTarget(EData.range)
	if target == nil then return end
	
	local castDistance = -450
	if(MM.Combo.EMode:Value() == 2) then castDistance = 450 end
	
	Control.CastSpell(HK_E, L_Core:Extended(myHero.pos, L_Core:Normalized(target.pos, myHero.pos), castDistance))
end

function CastR()
	if Game.CanUseSpell(_R) ~= READY then return end
	if L_Core:CountHeroesInRange(450 - 40, L_Core.Team.Enemy, true) >= MM.Combo.EnemiesToCastR:Value() then
		Control.CastSpell(HK_R)
	end
end

--Misc

function IsSecondQ()
	return myHero:GetSpellData(_Q).name == "ThreshQLeap"
end