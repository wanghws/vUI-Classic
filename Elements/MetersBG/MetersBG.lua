local vUI, GUI, Language, Media, Settings = select(2, ...):get()

if (1 == 1) then
--	return
end

local FRAME_WIDTH = 390
local FRAME_HEIGHT = 104
local BAR_HEIGHT = 22

local CreateMetersPanels = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	local MeterBGBottom = CreateFrame("Frame", nil, UIParent)
	MeterBGBottom:SetScaledSize(FRAME_WIDTH, 4)
	MeterBGBottom:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 13)
	MeterBGBottom:SetBackdrop(vUI.Backdrop)
	MeterBGBottom:SetBackdropColorHex(Settings["ui-window-bg-color"])
	MeterBGBottom:SetBackdropBorderColor(0, 0, 0)
	MeterBGBottom:SetFrameStrata("LOW")
	
	local MeterBGLeft = CreateFrame("Frame", nil, UIParent)
	MeterBGLeft:SetScaledSize(4, 126)
	MeterBGLeft:SetScaledPoint("BOTTOMLEFT", MeterBGBottom, 0, 0)
	MeterBGLeft:SetBackdrop(vUI.Backdrop)
	MeterBGLeft:SetBackdropColorHex(Settings["ui-window-bg-color"])
	MeterBGLeft:SetBackdropBorderColor(0, 0, 0)
	MeterBGLeft:SetFrameStrata("LOW")
	
	local MeterBGRight = CreateFrame("Frame", nil, UIParent)
	MeterBGRight:SetScaledSize(4, 126)
	MeterBGRight:SetScaledPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	MeterBGRight:SetBackdrop(vUI.Backdrop)
	MeterBGRight:SetBackdropColorHex(Settings["ui-window-bg-color"])
	MeterBGRight:SetBackdropBorderColor(0, 0, 0)
	MeterBGRight:SetFrameStrata("LOW")
	
	local MeterBGTop = CreateFrame("Frame", nil, UIParent)
	MeterBGTop:SetScaledSize(FRAME_WIDTH, 22 + 4)
	MeterBGTop:SetScaledPoint("BOTTOMLEFT", MeterBGLeft, "TOPLEFT", 0, 0)
	MeterBGTop:SetBackdrop(vUI.Backdrop)
	MeterBGTop:SetBackdropColorHex(Settings["ui-window-bg-color"])
	MeterBGTop:SetBackdropBorderColor(0, 0, 0)
	MeterBGTop:SetFrameStrata("LOW")
	
	local MeterBG = CreateFrame("Frame", nil, UIParent)
	MeterBG:SetScaledPoint("BOTTOMLEFT", MeterBGLeft, 0, 0)
	MeterBG:SetScaledPoint("TOPRIGHT", MeterBGTop, 0, 0)
	MeterBG:SetBackdrop(vUI.BackdropAndBorder)
	MeterBG:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	MeterBG:SetBackdropBorderColor(0, 0, 0)
	MeterBG:SetFrameStrata("BACKGROUND")
	
	local TopLeft = CreateFrame("Frame", nil, UIParent)
	TopLeft:SetScaledSize((FRAME_WIDTH / 2) - 4, 21)
	TopLeft:SetScaledPoint("TOPLEFT", MeterBGTop, 3, -2)
	TopLeft:SetBackdrop(vUI.BackdropAndBorder)
	TopLeft:SetBackdropColorHex(Settings["ui-window-bg-color"])
	TopLeft:SetBackdropBorderColor(0, 0, 0)
	TopLeft:SetFrameStrata("LOW")
	
	TopLeft.Texture = TopLeft:CreateTexture(nil, "OVERLAY")
	TopLeft.Texture:SetScaledPoint("TOPLEFT", TopLeft, 1, -1)
	TopLeft.Texture:SetScaledPoint("BOTTOMRIGHT", TopLeft, -1, 1)
	TopLeft.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	TopLeft.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	local TopRight = CreateFrame("Frame", nil, UIParent)
	TopRight:SetScaledSize((FRAME_WIDTH / 2) - 4, 21)
	TopRight:SetScaledPoint("TOPRIGHT", MeterBGTop, -3, -2)
	TopRight:SetBackdrop(vUI.BackdropAndBorder)
	TopRight:SetBackdropColorHex(Settings["ui-window-bg-color"])
	TopRight:SetBackdropBorderColor(0, 0, 0)
	TopRight:SetFrameStrata("LOW")
	
	TopRight.Texture = TopRight:CreateTexture(nil, "OVERLAY")
	TopRight.Texture:SetScaledPoint("TOPLEFT", TopRight, 1, -1)
	TopRight.Texture:SetScaledPoint("BOTTOMRIGHT", TopRight, -1, 1)
	TopRight.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	TopRight.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))	
	
	local MeterBGMiddle = CreateFrame("Frame", nil, UIParent)
	MeterBGMiddle:SetScaledPoint("TOP", MeterBGTop, "BOTTOM", 0, 0)
	MeterBGMiddle:SetScaledPoint("BOTTOM", MeterBGBottom, "TOP", 0, 0)
	MeterBGMiddle:SetScaledWidth(4)
	MeterBGMiddle:SetBackdrop(vUI.Backdrop)
	MeterBGMiddle:SetBackdropColorHex(Settings["ui-window-bg-color"])
	MeterBGMiddle:SetBackdropBorderColor(0, 0, 0)
	MeterBGMiddle:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", "vUIMetersFrame", MeterBGBottom)
	OuterOutline:SetScaledPoint("TOPLEFT", MeterBGTop, 0, 1)
	OuterOutline:SetScaledPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerLeftOutline = CreateFrame("Frame", nil, MeterBGBottom)
	InnerLeftOutline:SetScaledPoint("TOPLEFT", MeterBGLeft, "TOPRIGHT", -1, 1)
	InnerLeftOutline:SetScaledPoint("BOTTOMRIGHT", MeterBGMiddle, "BOTTOMLEFT", 1, -1)
	InnerLeftOutline:SetBackdrop(vUI.Outline)
	InnerLeftOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerRightOutline = CreateFrame("Frame", nil, MeterBGBottom)
	InnerRightOutline:SetScaledPoint("TOPRIGHT", MeterBGRight, "TOPLEFT", 1, 1)
	InnerRightOutline:SetScaledPoint("BOTTOMLEFT", MeterBGMiddle, "BOTTOMRIGHT", -1, -1)
	InnerRightOutline:SetBackdrop(vUI.Outline)
	InnerRightOutline:SetBackdropBorderColor(0, 0, 0)
end

local Frame = CreateFrame("Frame")

Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(self, event)
	CreateMetersPanels()
	
	self:UnregisterEvent(event)
end)