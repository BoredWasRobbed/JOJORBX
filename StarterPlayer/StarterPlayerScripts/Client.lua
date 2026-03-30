-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local DataService = require(ReplicatedStorage.DataService).client
local Keybind = require(ReplicatedStorage.Modules.Keybind)

local MovementController = require(ReplicatedStorage:WaitForChild("Modules").MovementController)

local StandEvent = ReplicatedStorage.Remotes:WaitForChild("StandEvent")
local KeyEvent = ReplicatedStorage.Remotes:WaitForChild("KeyEvent")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local PlayerMovement = MovementController.new(character)

local standSummoned = false
local standDebounce = false

local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraModule = PlayerModule:WaitForChild("CameraModule")
local MouseLockController = CameraModule:WaitForChild("MouseLockController")
local BoundKeys = MouseLockController:WaitForChild("BoundKeys")
BoundKeys.Value = "LeftControl"

task.wait(1)

Keybind.RegisterHandler("PlayerBinds", "Run", function(plr, state)
	if state == "Begin" then
		PlayerMovement:SetSprintState(true)
	elseif state == "End" then
		PlayerMovement:SetSprintState(false)
	end
end)

Keybind.RegisterHandler("StandBinds", "StandSummon", function(plr, state)
	if state == "End" then return end

	local data = DataService:waitForData(plr)
	if not data then return end
	if not DataService:get({ "Stand" , "StandUser" }) then return end

	if standDebounce then return end
	standDebounce = true

	if not standSummoned then
		StandEvent:FireServer("Summon")
		standSummoned = true
	else
		StandEvent:FireServer("Unsummon")
		standSummoned = false
	end

	task.delay(0.5, function()
		standDebounce = false
	end)
end)

for i = 1, 5 do
	Keybind.RegisterHandler("StandBinds", "AbilitySlot".. i, function(plr, state)
		if state == "End" then return end

		local data = DataService:waitForData(plr)
		if not data then return end

		if not standSummoned then 
			return 
		end

		local abilityName = DataService:get({ "Stand" , "StandAbilities" , "AbilitySlot".. i })
		if abilityName and abilityName ~= "" then
			StandEvent:FireServer("UseAbility", i)
		end
	end)
end

for context, actions in pairs(DataService:get({ "Keybinds" })) do
	for actionName, key in pairs(actions) do
		DataService:getChangedSignal({ "Keybinds", context, actionName }):Connect(function(newKey)
			Keybind:changeBind(context, actionName, Enum.KeyCode[newKey])
		end)
	end
end

Keybind.EnableContext(player, "PlayerBinds")
Keybind.EnableContext(player, "StandBinds")

StandEvent.OnClientEvent:Connect(function(action, position)
	if action == "TimeStopVFX" then
		local sphere = Instance.new("Part")
		sphere.Shape = Enum.PartType.Ball
		sphere.CastShadow = false
		sphere.Material = Enum.Material.ForceField
		sphere.Color = Color3.fromRGB(200, 200, 255)
		sphere.Size = Vector3.new(1, 1, 1)
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Position = position
		sphere.Parent = workspace
		
		local sphereTween = TweenService:Create(sphere, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = Vector3.new(1000, 1000, 1000),
			Transparency = 1
		})
		sphereTween:Play()
		Debris:AddItem(sphere, 2)
		
		local cc = game.Lighting:FindFirstChild("TimeStopCC") or Instance.new("ColorCorrectionEffect")
		cc.Name = "TimeStopCC"
		cc.Parent = game.Lighting
		
		local flashTween = TweenService:Create(cc, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Brightness = 0.5,
			Contrast = -1,
			TintColor = Color3.fromRGB(150, 150, 255)
		})
		flashTween:Play()

		flashTween.Completed:Wait()

		local settleTween = TweenService:Create(cc, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Brightness = -0.1,
			Contrast = 0.2,
			Saturation = -1,
			TintColor = Color3.fromRGB(200, 200, 255)
		})
		settleTween:Play()
	elseif action == "TimeResumeVFX" then
		local cc = game.Lighting:FindFirstChild("TimeStopCC")
		if cc then
			local endTween = TweenService:Create(cc, TweenInfo.new(0.5), {
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			})
			endTween:Play()
			
			endTween.Completed:Connect(function()
				cc:Destroy()
			end)
		end
	end
end)