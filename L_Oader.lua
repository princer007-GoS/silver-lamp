local ScriptInfo = 
{
	Version = 0.20,
	Patch = 9.24,
	Release = "Beta",
}

local supportedChamps = 
{
	["Thresh"] = "L_Thresh",
	[""] = ""
}

local bundlePath = COMMON_PATH .. "L_Bundle/"

if (supportedChamps[myHero.charName] == nil) then
    return
end

local downloadOccured = false, scriptsLoaded = false

function OnLoad()
	local champScript = supportedChamps[myHero.charName]
	local downloadStatus = false
	
	--DownloadCommon('L_Versions')
	downloadOccured = downloadStatus or CheckAndDownloadDependency('L_Core')
	downloadOccured = downloadStatus or CheckAndDownloadDependency(champScript)
	
	LoadMenu()
	
	if LM.onDemand then LoadSubmodules() end
end

function OnDraw()
	if downloadOccured then Draw.Text("[L] Oader downloaded updates. Please, press F6 twice to reload", 17, 450, 550) end
end

function LoadMenu()
    LM = MenuElement({type = MENU, id = "LM", name = "[L] Oader"})
	
    LM:MenuElement({id = 'onDemand', name = "Inject scripts automatically", tooltip = "If this option is disabled L Modules won't load on the game start", value = true, toggle = true)
    LM:MenuElement({name = "Inject L Bundle", tooltip = "Click this to load L Modules into GoS manually", callback = function(value) LoadSubmodules() end)

    LM:MenuElement({type = SPACE})
    LM:MenuElement({type = MENU, id = "Debug", name = "Debug"})
    LM.Debug:MenuElement({name = "Print debug data", value = false, toggle = true, callback = function(value) L_Core.DebugMode = value end})

	L_Core:AddMenuInfo(ScriptInfo, LM)
end

function LoadSubmodules()
	if scriptsLoaded then print("L Submodules are already loaded") return end

	require('L_Core')
	require(champScript)
	
	scriptsLoaded = true
end

function CheckUpdates(name)
	
end

function CheckAndDownloadDependency(name)
	local file = bundlePath .. name .. ".lua"
	if not FileExist(file) then
		DownloadCommon(name, file)
		print(name .. " installed")
		return true
	end
	--if 
	return false
end

function DownloadCommon(name, path)
		if path == nil then path = bundlePath .. name .. ".lua" end
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/" .. name .. ".lua", path, function() end)
		while not FileExist(path) do  end
end