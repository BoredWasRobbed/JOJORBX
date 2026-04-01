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

	self.ActiveStand = nil
	self.StandWeld = nil
	self.PositionTween = nil

	return self
end

function StandHandler:Summon()
	local Character = self.Player and self.Player.Character or self.Character
	if not Character or not Character.Parent then return end

	self.Character = Character

	if self.ActiveStand then
		self:Unsummon()
	end

	local standModel = self.StandModel
	if not standModel then return end

	local cloneStand = standModel:Clone()
	cloneStand:SetAttribute("Stand", true)

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
	end
	if not HumanoidRootPart then return end

	local StandRoot = cloneStand.PrimaryPart
	if not StandRoot then
		warn("StandModel does not have a PrimaryPart assigned! Stand cannot be summoned.")
		return
	end

	StandRoot.CFrame = HumanoidRootPart.CFrame

	local weld = Instance.new("Weld")
	weld.Part0 = HumanoidRootPart
	weld.Part1 = StandRoot
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Name = "StandWeld"

	weld.Parent = cloneStand
	cloneStand.Parent = Character

	self.ActiveStand = cloneStand
	self.StandWeld = weld
	
	for i, v in cloneStand:GetDescendants() do
		if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
			
			TweenService:Create(v, TweenInfo.new(.25), { Transparency = 0 }):Play()
		end
	end 

	task.spawn(function()
		local summonAnim = AnimationLoader.PlayAnimation(Assets.StandAnimations.BasicStandSummon, cloneStand, true)
		self:TweenPosition(CFrame.new(-1.5, 1.5, 2.5), 0.25)

		task.wait(0.25)

		AnimationLoader.PlayAnimation(Assets.StandAnimations.BasicStandIdle, cloneStand, true)
	end)
end

function StandHandler:Unsummon()
	local Stand = self.ActiveStand
	if not Stand then return end

	if self.PositionTween then
		self.PositionTween:Cancel()
		self.PositionTween = nil
	end
	
	if self.TValue then
		self.TValue:Destroy()
		self.TValue = nil
	end

	for i, v in Stand:GetDescendants() do
		if v:IsA("BasePart") or v:IsA("Decal") then
			TweenService:Create(v, TweenInfo.new(.25), { Transparency = 1 }):Play()
		end
	end

	self.ActiveStand = nil
	self.StandWeld = nil

	task.spawn(function()
		task.wait(0.25)
		if Stand then
			Stand:Destroy()
		end
	end)
end

function StandHandler:TweenPosition(targetOffset: CFrame, duration: number, arcAmount: number?, controlOffset: CFrame?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?)
	local weld = self.StandWeld
	if not weld then return end

	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	arcAmount = arcAmount or 3

	if self.PositionTween then
		self.PositionTween:Cancel()
		if self.TValue then self.TValue:Destroy() end
	end

	local tValue = Instance.new("NumberValue")
	tValue.Value = 0
	self.TValue = tValue

	local startC0 = weld.C0

	if not controlOffset then
		local midPoint = startC0.Position:Lerp(targetOffset.Position, 0.5)
		local dir = (targetOffset.Position - startC0.Position)

		if dir.Magnitude < 0.001 then
			dir = Vector3.new(0, 0, -1)
		else
			dir = dir.Unit
		end

		local side = Vector3.new(0, 1, 0):Cross(dir).Unit
		if side.Magnitude < 0.001 then side = Vector3.new(1, 0, 0) end

		controlOffset = CFrame.new(midPoint + (side * arcAmount))
	end

	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = TweenService:Create(tValue, tweenInfo, {Value = 1})
	self.PositionTween = tween

	local connection
	connection = tValue:GetPropertyChangedSignal("Value"):Connect(function()
		local t = tValue.Value

		local p0 = startC0.Position
		local p1 = controlOffset.Position
		local p2 = targetOffset.Position
		local pos = (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2

		local rot = startC0:Lerp(targetOffset, t).Rotation

		weld.C0 = CFrame.new(pos) * rot
	end)

	tween.Completed:Connect(function()
		if connection then connection:Disconnect() end
		if tValue then tValue:Destroy() end
		self.PositionTween = nil
	end)

	tween:Play()
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