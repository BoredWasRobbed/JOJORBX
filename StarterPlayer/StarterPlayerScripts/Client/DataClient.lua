-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataService = require(ReplicatedStorage.DataService).client
local Keybind = require(ReplicatedStorage.Modules.Keybind)

local player = Players.LocalPlayer

DataService:init()

local function loadKeybinds()
	local data = DataService:waitForData(player)
	if not data then return end
	
	for contextName, context in pairs(DataService:get("Keybinds")) do
		for actionName, action in pairs(context) do
			Keybind.newAction(player, Enum.KeyCode[action], actionName, contextName)
		end
	end
end

loadKeybinds()