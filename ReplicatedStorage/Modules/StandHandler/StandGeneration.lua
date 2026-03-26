-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.DataService).server

local StandParts = ReplicatedStorage.Models.Stands
local StandHeads = StandParts.StandHeads
local StandBodies = StandParts.StandBodies

local Palettes = require(script:FindFirstChild("Palettes"))
local Names = require(script:FindFirstChild("Names"))
local Abilities = require(script:FindFirstChild("Abilities"))

local StandGeneration = {}

StandGeneration.Palettes = Palettes
StandGeneration.Names = Names
StandGeneration.Abilities = Abilities

local function randomBody(): Model
	local Bodies = StandBodies:GetChildren()
	local randomBody = Bodies[math.random(1, #Bodies)]:Clone()

	return randomBody
end

local function randomHead(): Model
	local Heads = StandHeads:GetChildren()
	local randomHead = Heads[math.random(1, #Heads)]:Clone()

	return randomHead
end

local function randomPalette(): {}
	local keys = {}

	for name in pairs(Palettes) do
		table.insert(keys, name)
	end

	local randomKey = keys[math.random(1, #keys)]

	return Palettes[randomKey], randomKey
end

local function randomName(): string
	local randomName = Names[math.random(1, #Names)]

	return randomName
end

local function randomAbilities(): {}
	local abilities = {
		AbilitySlot1 = {},
		AbilitySlot2 = {},
		AbilitySlot3 = {},
		AbilitySlot4 = {},
		AbilitySlot5 = {}
	}

	local allAbilitiesBySlot = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {}
	}

	for rarity, list in pairs(Abilities) do
		for name, abilityData in pairs(list) do
			abilityData.Name = name
			abilityData.Rarity = rarity
			table.insert(allAbilitiesBySlot[abilityData.AbilitySlot], abilityData)
		end
	end

	local thresholds = {
		Common = 554,
		Uncommon = 260,
		Rare = 130,
		Epic = 50,
		Legendary = 5,
		Mythical = 1,
	}

	for slot = 1, 5 do
		local slotAbilities = allAbilitiesBySlot[slot]
		if #slotAbilities > 0 then
			local chosenAbility
			repeat
				local number = math.random(1, 1000)
				local rarity
				local roll = number
				for r, chance in pairs(thresholds) do
					if roll <= chance then
						rarity = r
						break
					else
						roll -= chance
					end
				end
				local candidates = {}
				for _, ability in ipairs(slotAbilities) do
					if ability.Rarity == rarity then
						table.insert(candidates, ability)
					end
				end
				if #candidates > 0 then
					chosenAbility = candidates[math.random(1, #candidates)]
				end
			until chosenAbility
			table.insert(abilities["AbilitySlot"..slot], chosenAbility)
		end
	end

	return abilities
end

local function constructStand(standData: {})
	local head = standData.Head
	local body = standData.Body
	local palette = standData.Palette
	local name = standData.Name
	local scale = standData.Scale
	local abilities = standData.StandAbilities
	local stand = standData.Stand
	
	if not head or not body or not palette or not name or not scale then
		if name then
			warn("Stand data is missing or nil for " .. name .. ".")
			return
		end
		
		warn("Stand data is missing required fields.")
		return
	end
	
	head.PrimaryPart.Parent = stand
	for _, v in ipairs(body:GetChildren()) do
		v.Parent = stand
	end

	for _, v in ipairs(stand:GetDescendants()) do
		if v:GetAttribute("Palette") then
			v.Color = palette[v:GetAttribute("Palette")]
		end
	end
	
	local StandHRP = stand:WaitForChild("HumanoidRootPart")
	local StandTorso = stand:WaitForChild("Torso")
	local StandHead = stand:WaitForChild("Head")

	local neck = Instance.new("Weld")
	neck.Part0 = StandTorso
	neck.Part1 = StandHead
	neck.C0 = CFrame.new(0, 1, 0)
	neck.C1 = CFrame.new(0, -0.5, 0)
	neck.Parent = StandTorso
	neck.Name = "Neck"

	local RootHip = StandHRP:FindFirstChild("Root Hip")
	if RootHip then
		RootHip.Part1 = StandTorso
	end
	
	stand:ScaleTo(scale)
	stand.Name = name

	return stand
end

function StandGeneration.randomCustomStand()
	local Stand = StandParts.Base:Clone()
	local Body = randomBody()
	local Head = randomHead()
	local Palette, PaletteName = randomPalette()
	local Name = randomName()
	local Scale = math.random(80, 120) / 100
	local StandAbilities = randomAbilities()
	
	Stand:SetAttribute("Name", Name)
	Stand:SetAttribute("Head", Head.Name)
	Stand:SetAttribute("Body", Body.Name)
	Stand:SetAttribute("Palette", PaletteName)
	Stand:SetAttribute("Scale", Scale)
	
	for i = 1, 5 do
		Stand:SetAttribute("AbilitySlot".. i, StandAbilities["AbilitySlot".. i][1].Name)
	end

	local StandData = {
		Head = Head, 
		Body = Body, 
		Palette = Palette, 
		Name = Name, 
		Scale = Scale, 
		StandAbilities = StandAbilities,
		Stand = Stand
	}

	return constructStand(StandData)
end

function StandGeneration.convertDataToStand(player: Player)
	local data = DataService:waitForData(player)

	if data then
		local Stand = StandParts.Base:Clone()

		local Head = StandHeads:FindFirstChild(DataService:get(player, { "Stand" , "StandVisuals" , "Head" })):Clone()
		local Body = StandBodies:FindFirstChild(DataService:get(player, { "Stand" , "StandVisuals" , "Body" })):Clone()
		local Palette = Palettes[DataService:get(player, { "Stand" , "StandVisuals" , "Palette" })]
		local PaletteName = DataService:get(player, { "Stand" , "StandVisuals" , "Palette" })
		local Name = DataService:get(player, { "Stand" , "StandVisuals" , "Name" })
		local Scale = DataService:get(player, { "Stand" , "StandVisuals" , "Scale" })
		local StandAbilities = DataService:get(player, { "Stand" , "StandAbilities" })
		
		Stand:SetAttribute("Name", Name)
		Stand:SetAttribute("Head", Head.Name)
		Stand:SetAttribute("Body", Body.Name)
		Stand:SetAttribute("Palette", PaletteName)
		Stand:SetAttribute("Scale", Scale)
		
		for i = 1, 5 do
			Stand:SetAttribute("AbilitySlot".. i, StandAbilities["AbilitySlot".. i])
		end
		
		local StandData = {
			Head = Head, 
			Body = Body, 
			Palette = Palette, 
			Name = Name, 
			Scale = Scale, 
			Stand = Stand
		}

		return constructStand(StandData)
	end
end

return StandGeneration