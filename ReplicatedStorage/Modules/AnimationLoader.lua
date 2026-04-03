-- @ScriptType: ModuleScript
local AnimationLoader = {}

local trackCache = setmetatable({}, {__mode = "k"})

local function getAnimator(model: Model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid:FindFirstChildOfClass("Animator")
			or Instance.new("Animator", humanoid)
	end

	local controller = model:FindFirstChildOfClass("AnimationController")
	if controller then
		return controller:FindFirstChildOfClass("Animator")
			or Instance.new("Animator", controller)
	end

	return nil
end

function AnimationLoader.PlayAnimation(animation: any, character: Model, stopAllCurrentAnimations: boolean)
	local animator = getAnimator(character)

	if not animator then
		warn("AnimationLoader: No Humanoid or AnimationController found in " .. character.Name)
		return
	end

	local animationObject: Animation

	if typeof(animation) == "string" then
		animationObject = Instance.new("Animation")
		animationObject.AnimationId = animation
	elseif typeof(animation) == "Instance" and animation:IsA("Animation") then
		animationObject = animation
	else
		warn("AnimationLoader: Invalid animation provided. Got: " .. typeof(animation))
		return nil
	end

	local animId = animationObject.AnimationId

	if not trackCache[character] then
		trackCache[character] = {}
	end

	local track = trackCache[character][animId]

	if not track then
		local success, result = pcall(function()
			return animator:LoadAnimation(animationObject)
		end)

		if success then
			track = result
			trackCache[character][animId] = track
		else
			warn("AnimationLoader: Failed to load animation: " .. tostring(result))
			return nil
		end
	end

	if track.IsPlaying then
		return track
	end

	if stopAllCurrentAnimations then
		for _, playingTrack in ipairs(animator:GetPlayingAnimationTracks()) do
			playingTrack:Stop(0.1)
		end
	end

	track:Play(0.1)

	return track
end

function AnimationLoader.WaitForAnimation(track: AnimationTrack)
	if not track then return end

	if not track.IsPlaying then
		return
	end

	track.Stopped:Wait()
end

return AnimationLoader