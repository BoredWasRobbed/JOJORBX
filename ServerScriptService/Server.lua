-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local DataService = require(ReplicatedStorage.DataService).server
local StandHandler = require(ReplicatedStorage.Modules.StandHandler)
local Keybind = require(ReplicatedStorage.Modules.Keybind)
local Ability = require(ReplicatedStorage.Modules.Ability)

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

Players.PlayerRemoving:Connect(function(player)
	StandHandler.playerStands[player] = nil
end)

local StandEventActions = {
	["Summon"] = function(player)
		local stand = StandHandler.playerStands[player]
		if stand then stand:Summon() end
	end,

	["Unsummon"] = function(player)
		local stand = StandHandler.playerStands[player]
		if stand then stand:Unsummon() end
	end,

	["Arrow"] = function(player)
		if not DataService:get(player, { "Stand", "StandUser" }) then
			DataService:set(player, { "Stand", "StandUser" }, true)
		end
	end,

	["RemoveStand"] = function(player)
		DataService:set(player, { "Stand", "StandUser" }, false)
	end,

	["Validate"] = function(player)
		return DataService:get(player, { "Stand", "StandUser" })
	end,

	["UseAbility"] = function(player, slotNumber)
		if typeof(slotNumber) ~= "number" then return end
		Ability.ExecuteAbility(player, slotNumber)
	end
}

StandEvent.OnServerEvent:Connect(function(player, action, ...)
	local actionFunction = StandEventActions[action]
	if actionFunction then
		local success, err = pcall(actionFunction, player, ...)
		if not success then
			warn("Action '" .. tostring(action) .. "': " .. tostring(err))
		end
	end
end)

KeyEvent.OnServerEvent:Connect(function(player, action, context, actionName, newKey)
	local data = DataService:waitForData(player)
	if not data then return end

	if action == "ChangeBind" then
		if typeof(context) == "string" and typeof(actionName) == "string" and typeof(newKey) == "string" then
			DataService:set(player, { "Keybinds", context, actionName }, newKey)
		end
	end
end)