-- @ScriptType: ModuleScript
local StateMachine = {}
StateMachine.__index = StateMachine

export type State = {
	Name: string,
	Category: string,
	Time: number,

	Machine: any,

	OnEnter: ((self: State) -> nil)?,
	OnExit: ((self: State) -> nil)?,
	OnUpdate: ((self: State, dt: number) -> nil)?,
	OnRenderStepped: ((self: State, dt: number) -> nil)?,
	OnEvent: ((self: State, event: string, data: any?) -> nil)?,
	CanEnter: ((self: State) -> boolean)?
}

function StateMachine._init()
	for i, v in pairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			StateMachine[v.Name] = require(v)
		end
	end
end

function StateMachine.new(character: Model)
	local self = setmetatable({}, StateMachine)

	self.Character = character

	self.States = {}
	self.ActiveStates = {}

	return self
end

function StateMachine:RegisterState(stateModule)
	local state = stateModule.new(self)
	self.States[state.Name] = state
end

function StateMachine:GetState(category: string)
	return self.ActiveStates[category]
end

function StateMachine:HasState(name: string)
	for _, state in pairs(self.ActiveStates) do
		if state.Name == name then
			return true
		end
	end
	return false
end

function StateMachine:ChangeState(name: string)
	local newState = self.States[name]
	if not newState then
		warn("State not found:", name)
		return
	end

	if newState.CanEnter and not newState:CanEnter() then
		return
	end

	local category = newState.Category
	local currentState = self.ActiveStates[category]

	if currentState and currentState.OnExit then
		currentState:OnExit()
	end

	newState.Time = 0

	self.ActiveStates[category] = newState

	if newState.OnEnter then
		newState:OnEnter()
	end
end

function StateMachine:RemoveState(category: string)
	local state = self.ActiveStates[category]
	if not state then return end

	if state.OnExit then
		state:OnExit()
	end

	self.ActiveStates[category] = nil
end

function StateMachine:Update(dt: number)
	for _, state in pairs(self.ActiveStates) do
		state.Time += dt

		if state.OnUpdate then
			state:OnUpdate(dt)
		end
	end
end

function StateMachine:RenderStepped(dt: number)
	for _, state in pairs(self.ActiveStates) do
		if state.OnRenderStepped then
			state:OnRenderStepped(dt)
		end
	end
end

function StateMachine:SendEvent(event: string, data: any?)
	for _, state in pairs(self.ActiveStates) do
		if state.OnEvent then
			state:OnEvent(event, data)
		end
	end
end

return StateMachine