local ScriptInfo = 
{
	Version = 0.20,
	Patch = 9.24,
	Release = "Beta",
}

local supportedChamps = 
{
	["Thresh"] = "",
	[""] = ""
}

if (supportedChamps[myHero.charName] == nil) then
    return
end

local downloadOccured = false

function OnLoad()
	CheckAndDownloadDependency('L_Core')
	CheckAndDownloadDependency(myHero.charName)
	
	downloadOccured = downloadOccured or require('L_Core')
	downloadOccured = downloadOccured or require(myHero.charName)
	
	LoadMenu()
end

function OnDraw()
	if downloadOccured then Draw:Text("[L] Oader downloaded updates. Please, press F6 twice to reload") end
end

function LoadMenu()
    LM = MenuElement({type = MENU, id = "LM", name = "[L] Oader"})

    LM:MenuElement({type = MENU, id = "Debug", name = "Debug"})
    LM.Debug:MenuElement({name = "Print debug data", value = false, toggle = true, callback = function(value) L_Core.DebugMode = value end})

	L_Core:AddMenuInfo(ScriptInfo, LM)
end

function CheckAndDownloadDependency(name)
	local file = COMMON_PATH .. name .. ".lua"
	if not FileExist(file) then
		print(name .. " installed")
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/" .. name .. ".lua", file, function() end)
		while not FileExist(file) do end
	end
	return true
end