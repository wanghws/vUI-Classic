local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetPVPLifetimeStats = GetPVPLifetimeStats
local Label = KILLS

local OnEnter = function(self)
	self:SetTooltip()
	
	local Honorable, Dishonorable = GetPVPLifetimeStats()
	local Rank = UnitPVPRank("player")
	
	if (Rank > 0) then
		local Name, Number = GetPVPRankInfo(Rank, "player")
		
		GameTooltip:AddDoubleLine(Name, format("%s %s", RANK, Number))
		GameTooltip:AddLine(" ")
	end
	
	GameTooltip:AddDoubleLine(HONORABLE_KILLS, Honorable)
	GameTooltip:AddDoubleLine(DISHONORABLE_KILLS, Dishonorable)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("HonorFrame")
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], GetPVPLifetimeStats())
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

vUI:AddDataText("PVP", OnEnable, OnDisable, Update)