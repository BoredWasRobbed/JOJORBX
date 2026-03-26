-- @ScriptType: ModuleScript
local Abilities = {
	Common = {
		["Crossfire Hurricane"] = {
			Description = "Fires a flaming ankh forward that explodes and spreads fire on contact.",
			AbilitySlot = 1
		},
	},
	Uncommon = {
		["Unravel Body/Ravel Up Body"] = {
			Description = "Unravel Body is what ability 2 is while you are in your humanoid mode. Ravel Up Body is what ability 2 is while you are in your unraveled mode.",
			AbilitySlot = 2
		},
		["Red Bind"] = {
			Description = "Creates harmless flames that stop all movement of the target if it lands.",
			AbilitySlot = 2
		},
	},
	Rare = {
		["Knife Throw"] = {
			Description = "The user hurls a barrage knife forward, inflicting a lot of bleed.",
			AbilitySlot = 3
		},
		["ORA!"] = {
			Description = "A single insanely powerful punch that sends a target flying and heavily blurs their screen for a moment.",
			AbilitySlot = 1
		}
	},
	Epic = {
		["Coin Toss"] = {
			Description = "Throw a coin and then detonate it.",
			AbilitySlot = 3
		},
		["Road Roller"] = {
			Description = "The user leaps up into the air, before plummeting down with a steam roller, smashing it down onto an area, hitting everyone in the radius.",
			AbilitySlot = 4
		}
	},
	Legendary = {
		["Time Stop"] = {
			Description = "Stops time for a few seconds",
			AbilitySlot = 5
		},
		["Time Skip"] = {
			Description = "Skips time for a few seconds",
			AbilitySlot = 5
		}
	},
	Mythical = {
		["Memory Disc"] = {
			Description = "Steals the memory of whoever is hit.",
			AbilitySlot = 4
		},
		["Stand Disc"] = {
			Description = "Steals the stand of whoever is hit.",
			AbilitySlot = 5
		}
	}
}

return Abilities
