-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.DataService).server

local DataTemplate = {
	-- Data --
	Race = "Human",
	Level = 1,
	XP = 0,
	Karma = 0,
	
	Keybinds = {
		PlayerBinds = {
			Run = "LeftShift",
		},
		StandBinds = {
			StandSummon = "Q",
			AbilitySlot1 = "Z",
			AbilitySlot2 = "X",
			AbilitySlot3 = "C",
			AbilitySlot4 = "V",
			AbilitySlot5 = "B",
		},
	},
	
	Stand = {
		StandUser = false,
		Canon = false,
		StandMastery = 0,
		Requiem = false,
		HeavenAscended = false,
		ActStand = false,
		ActStage = 0,

		StandPassives = {},
		StandAbilities = {
			AbilitySlot1 = "",
			AbilitySlot2 = "",
			AbilitySlot3 = "",
			AbilitySlot4 = "",
			AbilitySlot5 = ""
		},
		
		StandStats = {
			DestructivePower = 1,
			Precision = 1,	
			Stamina = 1,
			Range = 1,
			Developmentalpotential = 1,
		},

		StandVisuals = {
			Name = "",
			Head = "",
			Body = "",
			Palette = {},
			Scale = 1,
			SummonVisualEffect = "",
			SummonAudioEffect = "",
			Accessory = "",
			StandPose = "",
			StandIdle = "",
			RushSound = "",
			SummonAnimation = "",
		},	
	},
	
	-- Metadata --
	FirstJoin = true,
}

DataService:init({
	template = DataTemplate,
	useMock = false,
	resetData = false
})

game.Players.PlayerAdded:Connect(function(player)
	--local data = DataService:waitForData(player)
	
	--print(data)
end)