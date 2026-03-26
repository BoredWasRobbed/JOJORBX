-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local DataService = require(ReplicatedStorage.DataService).client

local Keybind = {}

Keybind.PlayerKeybinds = {}
Keybind.ActionHandlers = {}

function Keybind.RegisterHandler(context: string, actionName: string, callback: (Player) -> ())
	if not Keybind.ActionHandlers[context] then
		Keybind.ActionHandlers[context] = {}
	end

	Keybind.ActionHandlers[context][actionName] = callback
end

function Keybind.newAction(player: Player, key: Enum.KeyCode, name: string, context: string)
	local self = setmetatable({}, {__index = Keybind})

	self.Player = player
	self.Key = key
	self.Context = context
	self.Name = name

	if not Keybind.PlayerKeybinds[player] then
		Keybind.PlayerKeybinds[player] = {}
	end

	if not Keybind.PlayerKeybinds[player][context] then
		Keybind.PlayerKeybinds[player][context] = {}
	end

	Keybind.PlayerKeybinds[player][context][name] = self

	return self
end

function Keybind.EnableContext(player: Player, context: string)
	local contexts = Keybind.PlayerKeybinds[player]
	if not contexts then return end

	local actions = contexts[context]
	if not actions then return end

	for actionName, action in pairs(actions) do
		ContextActionService:BindAction(
			actionName,
			function(_, inputState)
				local handler = Keybind.ActionHandlers[context] and Keybind.ActionHandlers[context][actionName]

				if not handler then return end

				if inputState == Enum.UserInputState.Begin then
					handler(player, "Begin")
				elseif inputState == Enum.UserInputState.End then
					handler(player, "End")
				end
			end,
			false,
			action.Key
		)
	end
end

function Keybind.DisableContext(player: Player, context: string)
	local contexts = Keybind.PlayerKeybinds[player]
	if not contexts then return end

	local actions = contexts[context]
	if not actions then return end

	for actionName, _ in pairs(actions) do
		ContextActionService:UnbindAction(actionName)
	end
end

function Keybind.changeBind(player: Player, context: string, actionName: string, key: Enum.KeyCode)
	local data = DataService:waitForData(player)
	if not data then return end
	
	local contexts = Keybind.PlayerKeybinds[player]
	if not contexts then return end

	local actions = contexts[context]
	if not actions then return end

	local actionObj = actions[actionName]
	if actionObj then
		ContextActionService:UnbindAction(actionName)

		actionObj.Key = key

		ContextActionService:BindAction(
			actionName,
			function(_, inputState)
				local handler = Keybind.ActionHandlers[context] and Keybind.ActionHandlers[context][actionName]
				if not handler then return end
				handler(player, inputState)
			end,
			false,
			key
		)
		
		DataService:set(player, { "Keybinds" , context , actionName }, tostring(key.Name))
	end
end

return Keybind