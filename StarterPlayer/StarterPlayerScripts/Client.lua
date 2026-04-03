-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local ClientModules = script.Parent:WaitForChild("ClientModules")

local DataService = require(ReplicatedStorage.DataService).client
local Keybind = require(ClientModules:WaitForChild("Keybind"))
local MovementController = require(ClientModules:WaitForChild("MovementController"))

local StandEvent = ReplicatedStorage.Remotes:WaitForChild("StandEvent")
local KeyEvent = ReplicatedStorage.Remotes:WaitForChild("KeyEvent")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local PlayerMovement = MovementController.new(character)

local standSummoned = false
local standDebounce = false

local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraModule = PlayerModule:WaitForChild("CameraModule")
local MouseLockController = CameraModule:WaitForChild("MouseLockController")
local BoundKeys = MouseLockController:WaitForChild("BoundKeys")
BoundKeys.Value = "LeftControl"

task.wait(1)

Keybind.RegisterHandler("PlayerBinds", "Run", function(plr, state)
	if state == "Begin" then
		PlayerMovement:SetSprintState(true)
	elseif state == "End" then
		PlayerMovement:SetSprintState(false)
	end
end)

Keybind.RegisterHandler("StandBinds", "StandSummon", function(plr, state)
	if state == "End" then return end

	local data = DataService:waitForData(plr)
	if not data then return end
	if not DataService:get({ "Stand" , "StandUser" }) then return end

	if standDebounce then return end
	standDebounce = true

	if not standSummoned then
		StandEvent:FireServer("Summon")
		standSummoned = true
	else
		StandEvent:FireServer("Unsummon")
		standSummoned = false
	end

	task.delay(0.5, function()
		standDebounce = false
	end)
end)

for i = 1, 5 do
	Keybind.RegisterHandler("StandBinds", "AbilitySlot".. i, function(plr, state)
		if state == "End" then return end

		local data = DataService:waitForData(plr)
		if not data then return end

		if not standSummoned then 
			return 
		end

		local abilityName = DataService:get({ "Stand" , "StandAbilities" , "AbilitySlot".. i })
		if abilityName and abilityName ~= "" then
			StandEvent:FireServer("UseAbility", i)
		end
	end)
end

for context, actions in pairs(DataService:get({ "Keybinds" })) do
	for actionName, key in pairs(actions) do
		DataService:getChangedSignal({ "Keybinds", context, actionName }):Connect(function(newKey)
			Keybind:changeBind(context, actionName, Enum.KeyCode[newKey])
		end)
	end
end

Keybind.EnableContext(player, "PlayerBinds")
Keybind.EnableContext(player, "StandBinds")