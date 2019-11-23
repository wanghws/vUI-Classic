local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetPVPLifetimeStats = GetPVPLifetimeStats
local Label = "Kills"

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local Honorable, Dishonorable = GetPVPLifetimeStats()
	local Rank = UnitPVPRank("player")
	
	if (Rank > 0) then
		local Name, Number = GetPVPRankInfo(Rank, "player")
		
		GameTooltip:AddDoubleLine(Name, format(Language["Rank %s"], Number))
		GameTooltip:AddLine(" ")
	end
	
	GameTooltip:AddDoubleLine(Language["Honorable Kills"], Honorable)
	GameTooltip:AddDoubleLine(Language["Disonorable Kills"], Dishonorable)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("HonorFrame")
end

local Update = function(self)
	self.Text:SetFormattedText("%s: %s", Label, GetPVPLifetimeStats())
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_PVP_KILLS_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

DT:SetType("PVP", OnEnable, OnDisable, Update)