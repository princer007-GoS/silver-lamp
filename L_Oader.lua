local ScriptInfo = 
{
	Version = 0.30,
	Patch = 9.24,
	Release = "Beta",
}

local supportedChamps = 
{
	["Thresh"] = "L_Thresh",
	[""] = ""
}
if (supportedChamps[myHero.charName] == nil) then
    return
end

local _Versions = 'L_Versions'
local _Core = 'L_Core'
local _Oader = 'L_Oader'

local bundleDir = "L_Bundle/"
local bundlePath = COMMON_PATH .. bundleDir

local downloadOccured, scriptsLoaded = false

function OnLoad()
	DownloadCommon(_Versions)
	LoadSubmodule(_Versions)
	
	if CheckForLoaderUpdates() then return end
	
	CheckAndDownloadDependency(_Core)
	CheckAndDownloadDependency(supportedChamps[myHero.charName])
	
	LoadSubmodule(_Core)
	function L_Core:LoadSubmodule(name) LoadSubmodule(name) end
	
	LoadMenu()
	
	if LM.autoInject then LoadChampionSubmodule() end
end

function OnDraw()
	if downloadOccured then Draw.Text("[L] Oader downloaded updates. Please, press F6 twice to reload", 18, 450, 550) end
end

function LoadMenu()
    LM = MenuElement({type = MENU, id = "LM", name = "[L] Oader"})
	
    LM:MenuElement({id = 'autoInject', name = "Inject scripts automatically", tooltip = "If this option is disabled L Modules won't load on the game start", value = true, toggle = true})
    LM:MenuElement({name = "Inject L Bundle", tooltip = "Click this to load L Modules into GoS manually", callback = function(value) LoadChampionSubmodule() end})

    LM:MenuElement({type = SPACE})
    LM:MenuElement({type = MENU, id = "Debug", name = "Debug"})
    LM.Debug:MenuElement({name = "Print debug data", value = false, toggle = true, callback = function(value) L_Core.DebugMode = value end})

	L_Core:AddMenuInfo(ScriptInfo, LM)
end

--Loader

function LoadChampionSubmodule()
	if scriptsLoaded then print("L Submodules are already loaded") return end
	
	LoadSubmodule(supportedChamps[myHero.charName])

	scriptsLoaded = true
end

function LoadSubmodule(name)
	require(bundleDir..name)
end

--Updates

function CheckUpdates(name)
	
end

function CheckAndDownloadDependency(name)
	local file = bundlePath .. name .. ".lua"
	if not FileExist(file) then
		DownloadCommon(name, file)
		print(name .. " installed")
		return false
	end
	--if 
	return false
end

function DownloadCommon(name, path)
		if path == nil then path = bundlePath .. name .. ".lua" end
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/".. bundleDir .. name .. ".lua", path, function() end)
		while not FileExist(path) do  end
end

function CheckForLoaderUpdates()
		if L_Versions[_Oader] == ScriptInfo.Version then return false end
		
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/" .. _Oader .. ".lua", _Oader .. ".lua", function() downloadOccured = true end)
		while not FileExist(path) do end
		
		return true
end
