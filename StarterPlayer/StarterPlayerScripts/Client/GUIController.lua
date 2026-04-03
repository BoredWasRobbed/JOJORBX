-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

local ClientModules = script.Parent.Parent:WaitForChild("ClientModules")

local UIHandler = require(ClientModules:WaitForChild("UIHandler"))

local PlayerGui = player:WaitForChild("PlayerGui")

UIHandler._init(PlayerGui)
UIHandler.UpdateText("Level", 15, "Level: %d")
--UIhandler.UpdateText("XP", 15)