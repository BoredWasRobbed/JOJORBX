-- @ScriptType: ModuleScript
local Blocking = {}
Blocking.__index = Blocking

function Blocking.new(machine)
	local self = setmetatable({}, Blocking)
	self.Name = "Blocking"
	self.Category = "Defense"
	self.Time = 0
	self.Machine = machine
	return self
end

function Blocking:CanEnter()
	return not self.Machine:HasState("Stunned") and not self.Machine:HasState("Attacking")
end

function Blocking:OnEnter()
	local humanoid = self.Machine.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.OldWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 4
	end
end

function Blocking:OnExit()
	local humanoid = self.Machine.Character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.WalkSpeed = self.OldWalkSpeed or 16
	end
end

return Blocking