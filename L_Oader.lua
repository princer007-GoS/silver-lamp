local ScriptInfo = 
{
	Version = 1.03,
	Patch = 9.24,
	Release = "Stable",
}

local _Versions = 'L_Versions'
local _Core = 'L_Core'
local _Oader = 'L_Oader'
local _Prediction = 'GamsteronPrediction'

local bundleDir = "L_Bundle\\"
local bundlePath = COMMON_PATH .. bundleDir

local downloadOccured, scriptsLoaded, failedToLoad
local scriptFile

function OnLoad()
	if not FolderExists(bundlePath) then
		failedToLoad = true
		return
	end

	--Loading versions
	DownloadCommon(_Versions)
	LoadSubmodule(_Versions)
	
	scriptFile = L_SupportedChamps[myHero.charName]
	
	if (scriptFile == nil) then return end

	--Checking Loader updates
	if CheckForLoaderUpdates() then return end
	
	--Downloading dependencies
	CheckAndDownloadDependency(_Core)
	CheckAndDownloadDependency(_Prediction)
	CheckAndDownloadDependency(scriptFile)
	
	LoadSubmodule(_Core)
	
	CheckUpdates(_Core, L_Core:VersionCheck())
	
	function L_Core:LoadSubmodule(name) LoadSubmodule(name) end
	
	LoadMenu()
	
	--Autoinject
	if LM.autoInject:Value() then
		LoadChampionSubmodule()
	end
end

function OnDraw()
	if downloadOccured then Draw.Text("[L] Oader downloaded updates. Please, press F6 twice to reload", 18, 450, 550) end
	if failedToLoad then Draw.Text("[L] Oader failed to load. L_Bundle directory doesn't exist", 18, 450, 550) end
	if failedToLoad then Draw.Text("Please, check the script topic for resolving this issue", 18, 450, 570) end
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

function FolderExists(strFolderName)
	local fileHandle, strError = io.open(strFolderName.."\\*.*","r")
	if fileHandle ~= nil then
		io.close(fileHandle)
		return true
	else
		if string.match(strError,"No such file or directory") then
			return false
		else
			return true
		end
	end
end

--Loader

function LoadChampionSubmodule()
	if scriptsLoaded then print("L Submodules are already loaded") return end
	
	LoadSubmodule(scriptFile)
	if not CheckUpdates(scriptFile, L_Script:VersionCheck()) 
	then 
		LoadSubmodule(scriptFile)
	end
	L_Script:Init()
	
	scriptsLoaded = true
end

function LoadSubmodule(name)
	require(bundleDir..name)
end

--Updates

function CheckUpdates(name, version)
	if L_Versions[name] == nil or L_Versions[name] <= version then return true end
	DownloadCommon(name)
		print(name .. " updated")
	downloadOccured = true
end

function CheckAndDownloadDependency(name)
	local file = bundlePath .. name .. ".lua"
	if not FileExist(file) then
		DownloadCommon(name, file)
		print(name .. " installed")
	end
end

function DownloadCommon(name, path)
		if path == nil then path = bundlePath .. name .. ".lua" end
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/".. bundleDir .. name .. ".lua", path, function() end)
		while not FileExist(path) do  end
end

function CheckForLoaderUpdates()
		if L_Versions[_Oader] <= ScriptInfo.Version then return false end
		
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/" .. _Oader .. ".lua", _Oader .. ".lua", function() downloadOccured = true end)
		while not FileExist(path) do end
		
		return true
end
