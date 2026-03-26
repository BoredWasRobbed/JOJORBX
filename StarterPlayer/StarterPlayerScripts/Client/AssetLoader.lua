-- @ScriptType: LocalScript
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = require(Modules:WaitForChild("Assets"))

local assetsToLoad = {}

for animName, animId in pairs(Assets.PlayerAnimations) do
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	anim.Name = animName
	table.insert(assetsToLoad, anim)
end

for animName, animId in pairs(Assets.StandAnimations) do
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	anim.Name = animName
	table.insert(assetsToLoad, anim)
end

for soundName, soundId in pairs(Assets.Sounds) do
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Name = soundName
	table.insert(assetsToLoad, sound)
end

local success, errorMessage = pcall(function()
	ContentProvider:PreloadAsync(assetsToLoad)
end)

--if success then
--	print("Successfully preloaded all assets!")
--else
--	warn("Failed to preload some assets: " .. tostring(errorMessage))
--end
