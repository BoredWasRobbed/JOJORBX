-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DataService = require(ReplicatedStorage.DataService).server
local AnimationLoader = require(ReplicatedStorage:WaitForChild("Modules").AnimationLoader)
local Assets = require(ReplicatedStorage:WaitForChild("Modules").Assets)

local StandGeneration = require(script.StandGeneration)

local StandHandler = {}

StandHandler.StandGeneration = StandGeneration
StandHandler.playerStands = {}

function StandHandler.new(character: Model, standModel: Model)
	local self = setmetatable({}, {__index = StandHandler})

	self.Player = game.Players:GetPlayerFromCharacter(character) or nil
	self.Character = character
	self.StandModel = standModel

	return self
end

function StandHandler:Summon()
	local standModel = self.StandModel
	local Character = self.Character
	
	local cloneStand = standModel:Clone()

	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	local StandRoot = cloneStand.PrimaryPart

	StandRoot.CFrame = HumanoidRootPart.CFrame

	local weld = Instance.new("Weld")
	weld.Part0 = HumanoidRootPart
	weld.Part1 = StandRoot
	weld.C0 = CFrame.new(-0.5, 0, 1)
	weld.Name = "StandWeld"

	weld.Parent = cloneStand
	cloneStand.Parent = Character
	
	task.spawn(function()
		local summonAnim = AnimationLoader.PlayAnimation(Assets.StandAnimations.BasicStandSummon, cloneStand, true)
		
		task.wait(0.3)
		
		AnimationLoader.PlayAnimation(Assets.StandAnimations.BasicStandIdle, cloneStand, true)
	end)
end

function StandHandler:Unsummon()
	local function getStand(character: Model)
		for i, v in character:GetDescendants() do
			if v:GetAttribute("Stand") then
				return v
			end
		end
	end

	local character = self.Character
	local Stand = getStand(character)
	if not Stand then return end

	for i, v in Stand:GetDescendants() do
		if v:IsA("BasePart") or v:isA("Decal") then
			TweenService:Create(v, TweenInfo.new(.25), { Transparency = 1 }):Play()
		end
	end

	task.spawn(function()
		task.wait(0.25)
		
		Stand:Destroy()
	end)
end

function StandHandler:ConvertStandToData()
	if not self.Player then warn("Data can only be created from players.") return end
	
	local player = self.Player
	local Stand = StandHandler.playerStands[player].StandModel
	local data = DataService:waitForData(player)

	if data and Stand then
		local attributes = {"Name", "Head", "Body", "Palette", "Scale"}
		local standAbilities = {"AbilitySlot1", "AbilitySlot2", "AbilitySlot3", "AbilitySlot4", "AbilitySlot5"}
		
		for i, v in pairs(attributes) do
			if not Stand:GetAttribute(v) then warn("Stand does not have attribute: " .. v .. ".") continue end
			
			DataService:set(player, { "Stand" , "StandVisuals" , v }, Stand:GetAttribute(v))
		end
		
		for i, v in pairs(standAbilities) do
			if not Stand:GetAttribute(v) then warn("Stand does not have attribute: " .. v .. ".") continue end
			
			DataService:set(player, { "Stand" , "StandAbilities" , v }, Stand:GetAttribute(v))
		end
	end
end

return StandHandler
