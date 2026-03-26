-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataService = require(ReplicatedStorage.DataService).server
local StandHandler = require(ReplicatedStorage.Modules.StandHandler)
local Keybind = require(ReplicatedStorage.Modules.Keybind)

local StandEvent = ReplicatedStorage.Remotes:WaitForChild("StandEvent")
local KeyEvent = ReplicatedStorage.Remotes:WaitForChild("KeyEvent")

local function createPlayerStand(player, character, isDataStand)
	local standModel
	
	if isDataStand then
		standModel = StandHandler.StandGeneration.convertDataToStand(player)
	else
		standModel = StandHandler.StandGeneration.randomCustomStand()
	end
	
	local stand = StandHandler.new(character, standModel)
	StandHandler.playerStands[player] = stand
	stand:ConvertStandToData()
end

local function removePlayerStand(player)
	local stand = StandHandler.playerStands[player]
	if stand then
		stand:Unsummon()
		StandHandler.playerStands[player] = nil
	end
end

Players.PlayerAdded:Connect(function(player)
	local data = DataService:waitForData(player)
	local character = player.Character or player.CharacterAdded:Wait()

	DataService:getChangedSignal(player, { "Stand", "StandUser" }):Connect(function(value)
		if value then
			if not StandHandler.playerStands[player] then
				createPlayerStand(player, character)
			end
		else
			removePlayerStand(player)
		end
	end)

	if DataService:get(player, { "Stand", "StandUser" }) and not StandHandler.playerStands[player] then
		createPlayerStand(player, character, true)
	end
end)

StandEvent.OnServerEvent:Connect(function(player, action)
	local stand = StandHandler.playerStands[player]

	if action == "Summon" and stand then
		stand:Summon()
	elseif action == "Unsummon" and stand then
		stand:Unsummon()
	elseif action == "Arrow" then
		DataService:set(player, { "Stand", "StandUser" }, true)
	elseif action == "RemoveStand" then
		DataService:set(player, { "Stand", "StandUser" }, false)
	elseif action == "Validate" then
		return DataService:get(player, { "Stand", "StandUser" })
	end
end)

KeyEvent.OnServerEvent:Connect(function(player, action)
	local data = DataService:waitForData(player)
	if not data then return end

	if action == "ChangeBind" then
		DataService:set(player, { "Keybinds", "StandBinds", "StandSummon" }, "V")
	end
end)