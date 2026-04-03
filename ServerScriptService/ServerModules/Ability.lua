-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = script.Parent

local DataService = require(ReplicatedStorage.DataService).server
local StandHandler = require(ServerModules.StandHandler)

local Ability = {}

Ability.RegisteredAbilities = {}

function Ability.RegisterAbility(abilityName: string, callback)
	Ability.RegisteredAbilities[abilityName] = callback
end

Ability.RegisterAbility("ORA!", function(character, standModel, player)
	local activeStand = StandHandler.playerStands[player]
	if not activeStand then return end

	activeStand:TweenPosition(CFrame.new(0, 0, -3), 0.2)

	task.wait(0.2)
	
	activeStand:TweenPosition(CFrame.new(-1.5, 1.5, 2.5), 0.4)
end)

Ability.RegisterAbility("Time Stop", function(character, standModel, player)
	local name = player and player.Name or character.Name
	local activeStand = StandHandler.playerStands[player]
	print("Time Stop " .. name)
end)

function Ability.ExecuteForCharacter(character: Model, abilityName: string, standModel: Model, player: Player?)
	local abilityFunction = Ability.RegisteredAbilities[abilityName]
	if abilityFunction then
		abilityFunction(character, standModel, player)
	end
end

function Ability.ExecuteAbility(player: Player, slotNumber: number)
	local data = DataService:waitForData(player)
	if not data then return end

	if not DataService:get(player, { "Stand", "StandUser" }) then return end

	local activeStand = StandHandler.playerStands[player]
	if not activeStand then return end

	local abilityName = DataService:get(player, { "Stand", "StandAbilities", "AbilitySlot" .. slotNumber })
	if not abilityName or abilityName == "" then return end

	local character = player.Character
	if not character or not character:FindFirstChild("Humanoid") then return end

	Ability.ExecuteForCharacter(character, abilityName, activeStand.StandModel, player)
end

return Ability