-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.DataService).server
local StandHandler = require(ReplicatedStorage.Modules.StandHandler)

local Ability = {}

Ability.RegisteredAbilities = {}

function Ability.RegisterAbility(abilityName: string, callback)
	Ability.RegisteredAbilities[abilityName] = callback
end

Ability.RegisterAbility("ORA!", function(character, standModel, player)
	local name = player and player.Name or character.Name
	print("ORA! " .. name)
end)

Ability.RegisterAbility("Crossfire Hurricane", function(character, standModel, player)
	local name = player and player.Name or character.Name
	print("Crossfire Hurricane " .. name)
end)

Ability.RegisterAbility("Time Stop", function(character, standModel, player)
	local name = player and player.Name or character.Name
	local StandEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StandEvent")
	
	if StandEvent then
		StandEvent:FireAllClients("TimeStopVFX", character.PrimaryPart.Position)
	end

	local frozenParts = {}
	local frozenAnimators = {}
	
	for _, obj in ipairs(workspace:GetDescendants()) do
		if not obj:IsDescendantOf(character) and not obj:IsDescendantOf(standModel) then
			if obj:IsA("BasePart") and not obj.Anchored then
				frozenParts[obj] = obj.Velocity
				obj.Anchored = true
				obj.Velocity = Vector3.new(0, 0, 0)
				obj.RotVelocity = Vector3.new(0, 0, 0)
			elseif obj:IsA("Animator") then
				table.insert(frozenAnimators, obj)
				for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
					track:AdjustSpeed(0)
				end
			end
		end
	end
	
	task.wait(5)
	
	if StandEvent then
		StandEvent:FireAllClients("TimeResumeVFX")
	end
	
	for part, vel in pairs(frozenParts) do
		if part and part.Parent then
			part.Anchored = false
			part.Velocity = vel
		end
	end
	
	for _, animator in ipairs(frozenAnimators) do
		if animator and animator.Parent then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:AdjustSpeed(1)
			end
		end
	end
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