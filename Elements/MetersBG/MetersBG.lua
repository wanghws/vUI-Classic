local vUI, GUI, Language, Media, Settings = select(2, ...):get()

if (1 == 1) then
	return
end

local select = select
local tostring = tostring
local format = string.format
local sub = string.sub
local gsub = string.gsub
local match = string.match

local FRAME_WIDTH = 390
local FRAME_HEIGHT = 104
local BAR_HEIGHT = 22

local TabButtons = {}
local TabNames = {"General", "Whispers", "Loot", "Trade"}
local TabIDs = {1, 3, 4, 5}
local BUTTON_WIDTH = (FRAME_WIDTH / 4) + 1

local CreateMetersPanels = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	local MeterBGBottom = CreateFrame("Frame", "vUIMeterFrame", UIParent)
	MeterBGBottom:SetScaledSize(FRAME_WIDTH, 4)
	MeterBGBottom:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 13)
	MeterBGBottom:SetBackdrop(vUI.Backdrop)
	MeterBGBottom:SetBackdropColor(R, G, B)
	MeterBGBottom:SetBackdropBorderColor(0, 0, 0)
	MeterBGBottom:SetFrameStrata("LOW")
	
	local MeterBGLeft = CreateFrame("Frame", nil, UIParent)
	MeterBGLeft:SetScaledSize(4, 126)
	MeterBGLeft:SetScaledPoint("BOTTOMLEFT", MeterBGBottom, 0, 0)
	MeterBGLeft:SetBackdrop(vUI.Backdrop)
	MeterBGLeft:SetBackdropColor(R, G, B)
	MeterBGLeft:SetBackdropBorderColor(0, 0, 0)
	MeterBGLeft:SetFrameStrata("LOW")
	
	local MeterBGRight = CreateFrame("Frame", nil, UIParent)
	MeterBGRight:SetScaledSize(4, 126)
	MeterBGRight:SetScaledPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	MeterBGRight:SetBackdrop(vUI.Backdrop)
	MeterBGRight:SetBackdropColor(R, G, B)
	MeterBGRight:SetBackdropBorderColor(0, 0, 0)
	MeterBGRight:SetFrameStrata("LOW")
	
	local MeterBGTop = CreateFrame("Frame", nil, UIParent)
	MeterBGTop:SetScaledSize(FRAME_WIDTH, 22 + 4)
	MeterBGTop:SetScaledPoint("BOTTOMLEFT", MeterBGLeft, "TOPLEFT", 0, 0)
	MeterBGTop:SetBackdrop(vUI.Backdrop)
	MeterBGTop:SetBackdropColor(R, G, B)
	MeterBGTop:SetBackdropBorderColor(0, 0, 0)
	MeterBGTop:SetFrameStrata("LOW")
	
	local MeterBGMiddle = CreateFrame("Frame", nil, UIParent)
	MeterBGMiddle:SetScaledPoint("TOP", MeterBGTop, "BOTTOM", 0, 0)
	MeterBGMiddle:SetScaledPoint("BOTTOM", MeterBGBottom, "TOP", 0, 0)
	MeterBGMiddle:SetScaledWidth(4)
	MeterBGMiddle:SetBackdrop(vUI.Backdrop)
	MeterBGMiddle:SetBackdropColor(R, G, B)
	MeterBGMiddle:SetBackdropBorderColor(0, 0, 0)
	MeterBGMiddle:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", nil, ChatFrameBG)
	OuterOutline:SetScaledPoint("TOPLEFT", MeterBGTop, 0, 1)
	OuterOutline:SetScaledPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerLeftOutline = CreateFrame("Frame", nil, ChatFrameBG)
	InnerLeftOutline:SetScaledPoint("TOPLEFT", MeterBGLeft, "TOPRIGHT", -1, 1)
	InnerLeftOutline:SetScaledPoint("BOTTOMRIGHT", MeterBGMiddle, "BOTTOMLEFT", 1, -1)
	InnerLeftOutline:SetBackdrop(vUI.Outline)
	InnerLeftOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerRightOutline = CreateFrame("Frame", nil, ChatFrameBG)
	InnerRightOutline:SetScaledPoint("TOPRIGHT", MeterBGRight, "TOPLEFT", 1, 1)
	InnerRightOutline:SetScaledPoint("BOTTOMLEFT", MeterBGMiddle, "BOTTOMRIGHT", -1, -1)
	InnerRightOutline:SetBackdrop(vUI.Outline)
	InnerRightOutline:SetBackdropBorderColor(0, 0, 0)
	
	--[[local ChatFrameBG = CreateFrame("Frame", "vUIMeterFrame", UIParent)
	ChatFrameBG:SetScaledSize(FRAME_WIDTH, FRAME_HEIGHT + BAR_HEIGHT)
	ChatFrameBG:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 13)
	ChatFrameBG:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBG:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	ChatFrameBG:SetBackdropBorderColor(0, 0, 0)
	ChatFrameBG:SetFrameStrata("LOW")
	
	local LeftChatFrameTop = CreateFrame("Frame", "vUIMeterFrameTop", UIParent)
	LeftChatFrameTop:SetScaledSize(FRAME_WIDTH, BAR_HEIGHT)
	LeftChatFrameTop:SetScaledPoint("TOP", ChatFrameBG, 0, -2)
	LeftChatFrameTop:SetBackdrop(vUI.BackdropAndBorder)
	LeftChatFrameTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	LeftChatFrameTop:SetBackdropBorderColor(0, 0, 0)
	LeftChatFrameTop:SetFrameStrata("LOW")
	
	LeftChatFrameTop.Texture = LeftChatFrameTop:CreateTexture(nil, "OVERLAY")
	LeftChatFrameTop.Texture:SetScaledPoint("TOPLEFT", LeftChatFrameTop, 1, -1)
	LeftChatFrameTop.Texture:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, -1, 1)
	LeftChatFrameTop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	LeftChatFrameTop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- All this just to achieve an empty center :P
	local ChatFrameBGTop = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGTop:SetScaledPoint("TOPLEFT", LeftChatFrameTop, -3, 3)
	ChatFrameBGTop:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, 3, -3)
	ChatFrameBGTop:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGTop:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGTop:SetFrameStrata("LOW")
	
	local ChatFrameBGBottom = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGBottom:SetScaledPoint("TOPLEFT", ChatFrameBG, -3, 3)
	ChatFrameBGBottom:SetScaledPoint("BOTTOMRIGHT", ChatFrameBG, 3, -3)
	ChatFrameBGBottom:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGBottom:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGBottom:SetFrameStrata("LOW")
	
	local ChatFrameBGLeft = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGLeft:SetScaledWidth(4)
	ChatFrameBGLeft:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	ChatFrameBGLeft:SetScaledPoint("BOTTOMLEFT", ChatFrameBGBottom, "TOPLEFT", 0, 0)
	ChatFrameBGLeft:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGLeft:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGLeft:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGLeft:SetFrameStrata("LOW")
	
	local ChatFrameBGRight = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGRight:SetScaledWidth(4)
	ChatFrameBGRight:SetScaledPoint("TOPRIGHT", ChatFrameBGTop, 0, 0)
	ChatFrameBGRight:SetScaledPoint("BOTTOMRIGHT", ChatFrameBGBottom, 0, 0)
	ChatFrameBGRight:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGRight:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGRight:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGRight:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", nil, ChatFrameBG)
	OuterOutline:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	OuterOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBG, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerOutline = CreateFrame("Frame", nil, ChatFrameBG)
	InnerOutline:SetScaledPoint("TOPLEFT", ChatFrameBG, 0, 0)
	InnerOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBG, 0, 0)
	InnerOutline:SetBackdrop(vUI.Outline)
	InnerOutline:SetBackdropBorderColor(0, 0, 0)]]
end

local Frame = CreateFrame("Frame")

Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(self, event)
	CreateMetersPanels()
	
	self:UnregisterEvent(event)
end)