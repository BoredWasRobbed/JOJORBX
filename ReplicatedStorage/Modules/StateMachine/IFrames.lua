-- @ScriptType: ModuleScript
local IFrames = {}
IFrames.__index = IFrames

function IFrames.new(machine)
	local self = setmetatable({}, IFrames)

	self.Name = "IFrames"
	self.Category = "Invulnerability"
	self.Time = 0

	self.Machine = machine
	self.Duration = 0.5
	return self
end

function IFrames:OnEnter(duration: number)
	self.Duration = duration or 0.5
end

function IFrames:OnUpdate(dt)
	if self.Time >= self.Duration then
		self.Machine:RemoveState(self.Category)
	end
end

return IFrames