local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTime_GetGameTime = GameTime_GetGameTime
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local format = format
local select = select
local floor = floor

local Frame = CreateFrame("Frame", "vUI Minimap", UIParent)

local ZoneUpdate = function(self)
	local Zone = GetMinimapZoneText()
	local PVPType = GetZonePVPInfo()
	local Color = vUI.ZoneColors[PVPType or "other"]
	
	self.Text:SetText(Zone)
	self.Text:SetTextColor(Color[1], Color[2], Color[3])
end

local CreateMinimap = function()
	Frame:SetScaledSize(Settings["minimap-size"] + 8, (22 + 8 + Settings["minimap-size"]))
	Frame:SetScaledPoint("TOPRIGHT", UIParent, -12, -12)
	Frame:SetBackdrop(vUI.BackdropAndBorder)
	Frame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame.Ela = 0
	
	vUI:GetModule("Move"):Add(Frame)
	
	local ZoneFrame = CreateFrame("Frame", "vUIZoneFrame", Frame)
	ZoneFrame:SetScaledHeight(20)
	ZoneFrame:SetScaledPoint("TOPLEFT", Frame, 3, -3)
	ZoneFrame:SetScaledPoint("TOPRIGHT", Frame, -3, -3)
	ZoneFrame:SetBackdrop(vUI.BackdropAndBorder)
	ZoneFrame:SetBackdropColor(0, 0, 0, 0)
	ZoneFrame:SetBackdropBorderColor(0, 0, 0)
	ZoneFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ZoneFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	ZoneFrame:RegisterEvent("ZONE_CHANGED")
	ZoneFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	ZoneFrame:SetScript("OnEvent", ZoneUpdate)
	ZoneFrame:SetScript("OnEnter", ZoneFrameOnEnter)
	ZoneFrame:SetScript("OnLeave", ZoneFrameOnLeave)
	
	ZoneFrame.Tex = ZoneFrame:CreateTexture(nil, "ARTWORK")
	ZoneFrame.Tex:SetPoint("TOPLEFT", ZoneFrame, 1, -1)
	ZoneFrame.Tex:SetPoint("BOTTOMRIGHT", ZoneFrame, -1, 1)
	ZoneFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ZoneFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ZoneFrame.Text = ZoneFrame:CreateFontString(nil, "OVERLAY", 7)
	ZoneFrame.Text:SetScaledPoint("CENTER", ZoneFrame, 0, -1)
	ZoneFrame.Text:SetFontInfo(Settings["ui-header-font"], 12)
	ZoneFrame.Text:SetScaledSize(ZoneFrame:GetWidth() - 12, 20)
	
	Frame.Stats = CreateFrame("Frame", nil, Minimap)
	Frame.Stats:SetAllPoints(ZoneFrame)
	Frame.Stats:SetScript("OnEnter", StatsOnEnter)
	Frame.Stats:SetScript("OnLeave", StatsOnLeave)
	Frame.Stats:SetScript("OnMouseUp", StatsOnMouseUp)
	
	ZoneUpdate(ZoneFrame)
end

local OnMouseWheel = function(self, delta)
	if (delta > 0) then
		MinimapZoomIn:Click()
	elseif (delta < 0) then
		MinimapZoomOut:Click()
	end
end

local Kill = function(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	if (object.GetScript and object:GetScript("OnUpdate")) then
		object:SetScript("OnUpdate", nil)
	end
	
	object.Show = function() end
	object:Hide()
end

function GetMinimapShape()
	return "SQUARE"
end

local UpdateMinimapSize = function(value)
	Minimap:SetScaledSize(value, value)
	vUIMinimap:SetScaledSize((value + 8), (22 + 8 + value))
	
	Minimap:SetZoom(Minimap:GetZoom() + 1)
	Minimap:SetZoom(Minimap:GetZoom() - 1)
	Minimap:UpdateBlips()
end

local OnEvent = function(self, event)
	if (not Settings["minimap-enable"]) then
		self:UnregisterEvent(event)
		
		return
	end
	
	CreateMinimap()
	
	Minimap:SetMaskTexture(Media:GetTexture("Blank"))
	
	Minimap:SetParent(self)
	Minimap:ClearAllPoints()
	Minimap:SetScaledPoint("TOP", vUIZoneFrame, "BOTTOM", 0, -3)
	Minimap:SetScaledSize(Settings["minimap-size"], Settings["minimap-size"])
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	
	Minimap.BG = Minimap:CreateTexture(nil, "BACKGROUND")
	Minimap.BG:SetTexture(Media:GetTexture("Blank"))
	Minimap.BG:SetVertexColor(0, 0, 0)
	Minimap.BG:SetScaledPoint("TOPLEFT", Minimap, -1, 1)
	Minimap.BG:SetScaledPoint("BOTTOMRIGHT", Minimap, 1, -1)
	
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetScaledPoint("TOPRIGHT", -4, 12)
	
	MiniMapMailIcon:SetScaledSize(32, 32)
	MiniMapMailIcon:SetTexture(Media:GetTexture("vUI Mail 2"))
	MiniMapMailIcon:SetVertexColorHex(Settings["ui-widget-bright-color"])
	--MiniMapMailIcon:SetVertexColorHex("EEEEEE")
	
	MinimapNorthTag:SetTexture(nil)
	
	if MiniMapTrackingFrame then
		MiniMapTrackingFrame:ClearAllPoints()
		MiniMapTrackingFrame:SetScaledSize(24, 24)
		MiniMapTrackingFrame:SetScaledPoint("TOPLEFT", Minimap, 1, -1)
		MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
	end
	
	if MiniMapTrackingBorder then
		MiniMapTrackingBorder:Hide()
	end
	
	if MiniMapTrackingIcon then
		MiniMapTrackingIcon:SetScaledSize(18, 18)
		MiniMapTrackingIcon:ClearAllPoints()
		MiniMapTrackingIcon:SetScaledPoint("TOPLEFT", MiniMapTrackingFrame, 1, -1)
		MiniMapTrackingIcon:SetScaledPoint("BOTTOMRIGHT", MiniMapTrackingFrame, -1, 1)
	--	MiniMapTrackingIcon:SetTexCoords(0.1, 0.9, 0.1, 0.9)
	end
	
	Kill(MinimapCluster)
	Kill(MinimapBorder)
	Kill(MinimapBorderTop)
	Kill(MinimapZoomIn)
	Kill(MinimapZoomOut)
	Kill(MinimapNorthTag)
	Kill(GameTimeFrame)
	Kill(MiniMapWorldMapButton)
	Kill(MiniMapMailBorder)
	Kill(TimeManagerClockButton)
	
	self:UnregisterEvent(event)
end

Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", OnEvent)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Minimap"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("minimap-enable", Settings["minimap-enable"], Language["Enable Minimap Module"], "bloop."):RequiresReload(true)
	
	Right:CreateHeader(Language["Size"])
	Right:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, "Minimap Size", "doesn't matter", UpdateMinimapSize)
	
	Left:CreateFooter()
	Right:CreateFooter()
end)