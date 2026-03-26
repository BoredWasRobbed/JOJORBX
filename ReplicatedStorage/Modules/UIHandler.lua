-- @ScriptType: ModuleScript
local UIHandler = {}

local UIelements = {}

function UIHandler._init(PlayerGui: PlayerGui)
	local PlayerUI = PlayerGui:WaitForChild("PlayerUi")
	local LevelFrame = PlayerUI:WaitForChild("LevelBar")

	UIelements = {
		Level = LevelFrame:WaitForChild("LevelText"),	
	}
	
	print(UIelements)
end

function UIHandler.UpdateText(GuiName: string, Value: number, Format: string)
	local UI = UIelements[GuiName]
	
	if UI then
	UI.Text = Format:format(Value)
	else
		warn("Ui aint found big dawg")
	end
end
	


return UIHandler




