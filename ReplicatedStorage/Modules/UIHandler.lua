-- @ScriptType: ModuleScript
local UIHandler = {}

local UIElements = {}

function UIHandler._init(PlayerGui: PlayerGui)
	local PlayerUI = PlayerGui:WaitForChild("PlayerUi")
	local LevelFrame = PlayerUI:WaitForChild("LevelBar")

	UIElements = {
		Level = LevelFrame:WaitForChild("LevelText"),	
	}
	
	print(UIElements)
end

function UIHandler.UpdateText(GuiName: string, Value: number, Format: string)
	local UI = UIElements[GuiName]
	
	if UI then
		UI.Text = Format:format(Value)
	else
		warn("Ui aint found big dawg")
	end
end

return UIHandler




