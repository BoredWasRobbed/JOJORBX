-- @ScriptType: ModuleScript
local Stunned = {}
Stunned.__index = Stunned

function Stunned.new(machine)
	local self = setmetatable({}, Stunned)

	self.Name = "Stunned"
	self.Category = "Status"
	self.Time = 0

	self.Machine = machine
	self.Duration = 1
	return self
end

function Stunned:OnEnter(duration: number)
	self.Duration = duration or 1

	local humanoid = self.Machine.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.OldWalkSpeed = humanoid.WalkSpeed
		self.OldJumpPower = humanoid.JumpPower

		humanoid.WalkSpeed = 2
		humanoid.JumpPower = 0
	end
end

function Stunned:OnUpdate(dt)
	if self.Time >= self.Duration then
		self.Machine:RemoveState(self.Category)
	end
end

function Stunned:OnExit()
	local humanoid = self.Machine.Character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.WalkSpeed = self.OldWalkSpeed or 16
		humanoid.JumpPower = self.OldJumpPower or 50
	end
end

return Stunned