local vUI, GUI, Language, Media, Settings = select(2, ...):get()

MainMenuBar.Show = function() end
MainMenuBar:Hide()

if (1 == 1) then
	return
end

local BUTTON_SIZE = 34
local SPACING = 2

local BOTTOM_WIDTH = ((BUTTON_SIZE * 12) + (SPACING * 13))
local BOTTOM_HEIGHT = ((BUTTON_SIZE * 2) + (SPACING * 3))

local SIDE_WIDTH = ((BUTTON_SIZE * 3) + (SPACING * 4))
local SIDE_HEIGHT = ((BUTTON_SIZE * 12) + (SPACING * 13))

local ActionBars = CreateFrame("Frame")

local CreateBarPanels = function()
	local BottomPanel = CreateFrame("Frame", "vUIBottomActionBarsPanel", UIParent, "SecureHandlerStateTemplate")
	BottomPanel:SetScaledSize(BOTTOM_WIDTH, BOTTOM_HEIGHT)
	BottomPanel:SetScaledPoint("BOTTOM", UIParent, 0, 12)
	BottomPanel:SetBackdrop(vUI.BackdropAndBorder)
	BottomPanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	BottomPanel:SetBackdropBorderColor(0, 0, 0)
	BottomPanel:SetFrameStrata("LOW")
	
	local SidePanel = CreateFrame("Frame", "vUISideActionBarsPanel", UIParent, "SecureHandlerStateTemplate")
	SidePanel:SetScaledSize(SIDE_WIDTH, SIDE_HEIGHT)
	SidePanel:SetScaledPoint("RIGHT", UIParent, -12, 0)
	SidePanel:SetBackdrop(vUI.BackdropAndBorder)
	SidePanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	SidePanel:SetBackdropBorderColor(0, 0, 0)
	SidePanel:SetFrameStrata("LOW")
end

ActionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBars:SetScript("OnEvent", function(self, event)
	CreateBarPanels()
	
	self:UnregisterEvent(event)
end)