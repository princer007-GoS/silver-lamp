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

if (supportedChamps[myHero.charName] == nil) then
    return
end

local downloadOccured = false
local downloadingUpdates = true
local progress = 0

function OnLoad()
	local champScript = supportedChamps[myHero.charName]
	local downloadStatus = false
	
	DownloadCommon('L_Versions')
	progress = 10
	downloadStatus = downloadStatus or CheckAndDownloadDependency('L_Core')
	progress = 30
	downloadStatus = downloadStatus or CheckAndDownloadDependency(champScript)
	progress = 90
	
	require('L_Core')
	require(champScript)
	
	print(_G['L_Core'])
	
	downloadOccured = downloadStatus
	downloadingUpdates = false
	LoadMenu()
end

function OnDraw()
	if downloadOccured then Draw.Text("[L] Oader downloaded updates. Please, press F6 twice to reload", 17, 450, 550) end
	if downloadingUpdates then Draw.Text("[L] Oader is loading update: " .. progress .. "%", 17, 400, 500) end
end

function LoadMenu()
    LM = MenuElement({type = MENU, id = "LM", name = "[L] Oader"})

    LM:MenuElement({type = MENU, id = "Debug", name = "Debug"})
    LM.Debug:MenuElement({name = "Print debug data", value = false, toggle = true, callback = function(value) L_Core.DebugMode = value end})

	L_Core:AddMenuInfo(ScriptInfo, LM)
end

function CheckUpdates(name)
	
end

function CheckAndDownloadDependency(name)
	local file = COMMON_PATH .. name .. ".lua"
	if not FileExist(file) then
		DownloadCommon(name, file)
		print(name .. " installed")
		return true
	end
	--if 
	return false
end

function DownloadCommon(name, path)
		if path == nil then path = COMMON_PATH .. name .. ".lua" end
		DownloadFileAsync("https://raw.githubusercontent.com/princer007-GoS/silver-lamp/master/Common/" .. name .. ".lua", path, function() end)
		while not FileExist(path) do end
end