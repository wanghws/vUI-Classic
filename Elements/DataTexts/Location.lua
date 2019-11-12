local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local Color = vUI.ZoneColors[GetZonePVPInfo() or "other"]
	
	self.Text:SetText(GetMinimapZoneText())
	self.Text:SetTextColor(Color[1], Color[2], Color[3])
end

local OnEnable = function(self)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
	self.Text:SetTextColor(1, 1, 1)
end

DT:SetType("Location", OnEnable, OnDisable, Update)