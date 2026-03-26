-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

local UIhandler = require(ReplicatedStorage.Modules:WaitForChild("UIHandler"))

local PlayerGui = Player:WaitForChild("PlayerGui")

UIhandler._init(PlayerGui)
UIhandler.UpdateText("Level", 15, "Level: %d")
--UIhandler.UpdateText("XP", 15)