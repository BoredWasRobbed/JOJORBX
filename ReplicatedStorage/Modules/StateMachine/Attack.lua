-- @ScriptType: ModuleScript
local Attack = {}
Attack.__index = Attack

function Attack.new(machine)
	local self = setmetatable({}, Attack)

	self.Name = "Attack"
	self.Category = "Action"
	self.Time = 0

	self.Machine = machine
	return self
end

function Attack:CanEnter()
	return not self.Machine:HasState("Stunned")
end

function Attack:OnEnter()
	print("Attack start")
end

function Attack:OnUpdate(dt)
	if self.Time > 0.5 then
		self.Machine:RemoveState("Action")
	end
end

return Attack