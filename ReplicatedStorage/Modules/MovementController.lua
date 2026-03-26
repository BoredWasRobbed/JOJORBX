-- @ScriptType: ModuleScript
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local AnimationLoader = require(Modules.AnimationLoader)
local Assets = require(Modules.Assets)

local MovementController = {}
MovementController.__index = MovementController

function MovementController.new(character: Model)
	local self = setmetatable({}, MovementController)

	self.Character = character
	self.Humanoid = character:WaitForChild("Humanoid")
	self.RootPart = character:WaitForChild("HumanoidRootPart")

	self.LastDirection = "Idle"
	self.LastIsSprinting = false
	self.IsHoldingSprintKey = false

	self.WalkSpeed = 16
	self.SprintSpeed = 24

	self.Connection = RunService.Heartbeat:Connect(function()
		if not self.Character or not self.Character.Parent then 
			self:Destroy()
			return 
		end

		self:UpdateAnimations()
	end)

	return self
end

function MovementController:GetMovementDirection()
	local moveDirection = self.Humanoid.MoveDirection

	if moveDirection.Magnitude <= 0.01 then
		return "Idle"
	end

	local localDir = self.RootPart.CFrame:VectorToObjectSpace(moveDirection)
	local directionString = ""
	local threshold = 0.1

	if localDir.Z < -threshold then
		directionString = directionString .. "Forward "
	elseif localDir.Z > threshold then
		directionString = directionString .. "Backward "
	end

	if localDir.X > threshold then
		directionString = directionString .. "Right"
	elseif localDir.X < -threshold then
		directionString = directionString .. "Left"
	end

	directionString = directionString:match("^%s*(.-)%s*$")

	if directionString == "" then
		return "Unknown"
	end

	return directionString
end

function MovementController:UpdateAnimations()
	local currentDirection = self:GetMovementDirection()

	local isMovingBackward = currentDirection:match("Backward")
	local canSprint = self.IsHoldingSprintKey and not isMovingBackward and currentDirection ~= "Idle"

	if canSprint then
		self.Humanoid.WalkSpeed = self.SprintSpeed
	else
		self.Humanoid.WalkSpeed = self.WalkSpeed
	end

	local isSprinting = (self.Humanoid.WalkSpeed == self.SprintSpeed) and (currentDirection ~= "Idle")

	if currentDirection == self.LastDirection and isSprinting == self.LastIsSprinting then 
		return 
	end

	if currentDirection == "Idle" then
		AnimationLoader.PlayAnimation(Assets.PlayerAnimations.Idle, self.Character, true)
	elseif isSprinting then
		AnimationLoader.PlayAnimation(Assets.PlayerAnimations.Sprint, self.Character, true)
	else
		if currentDirection:match("Forward") then
			AnimationLoader.PlayAnimation(Assets.PlayerAnimations.WalkForward, self.Character, true)
		elseif currentDirection:match("Left") then
			AnimationLoader.PlayAnimation(Assets.PlayerAnimations.WalkLeft, self.Character, true)
		elseif currentDirection:match("Right") then
			AnimationLoader.PlayAnimation(Assets.PlayerAnimations.WalkRight, self.Character, true)
		elseif currentDirection:match("Backward") then
			AnimationLoader.PlayAnimation(Assets.PlayerAnimations.WalkBackward, self.Character, true)
		end
	end

	self.LastDirection = currentDirection
	self.LastIsSprinting = isSprinting
end

function MovementController:SetSprintState(isSprinting: boolean)
	self.IsHoldingSprintKey = isSprinting
end

function MovementController:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	self.Character = nil
	self.Humanoid = nil
	self.RootPart = nil
end

return MovementController