-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataService = require(ReplicatedStorage.DataService).client
local Keybind = require(ReplicatedStorage.Modules.Keybind)
local MovementController = require(ReplicatedStorage:WaitForChild("Modules").MovementController)

local StandEvent = ReplicatedStorage.Remotes:WaitForChild("StandEvent")
local KeyEvent = ReplicatedStorage.Remotes:WaitForChild("KeyEvent")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local PlayerMovement = MovementController.new(character)

local standSummoned = false
local debounce = false

(script.Parent
	:WaitForChild("PlayerModule")
	:WaitForChild("CameraModule")
	:WaitForChild("MouseLockController")
	:WaitForChild("BoundKeys")
).Value = "LeftControl"

task.wait(1)

Keybind.RegisterHandler("PlayerBinds", "Run", function(player, state)
	if state == "Begin" then
		PlayerMovement:SetSprintState(true)
	elseif state == "End" then
		PlayerMovement:SetSprintState(false)
	end
end)

Keybind.RegisterHandler("StandBinds", "StandSummon", function(player, state)
	local data = DataService:waitForData(player)
	if not data then return end
	
	if state == "End" then return end
	if not DataService:get({ "Stand" , "StandUser" }) then return end
	
	if not standSummoned and not debounce then
		StandEvent:FireServer("Summon")
		standSummoned = true
		debounce = true

		task.wait(0.3)

		debounce = false
	elseif standSummoned and not debounce then
		StandEvent:FireServer("Unsummon")
		standSummoned = false
		debounce = true

		task.wait(0.3)

		debounce = false
	end
end)

for i = 1, 5 do
	Keybind.RegisterHandler("StandBinds", "AbilitySlot".. i, function(player, state)
		local data = DataService:waitForData(player)
		if not data then return end
		
		if state == "End" then return end

		print("Used ".. DataService:get({ "Stand" , "StandAbilities" , "AbilitySlot".. i }) ..".")
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