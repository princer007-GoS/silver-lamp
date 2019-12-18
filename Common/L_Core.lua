class 'L_AIO'

	function L:CanCast(spell)
		return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
	end
	
	function L:LoadDependency(name)
		local file = COMMON_PATH .. name .. ".lua"
		if not FileExist(file) then
			print(name .. " installed")
			DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/" .. name .. ".lua", file, function() end)
			while not FileExist(file) do end
		end
		return true
	end