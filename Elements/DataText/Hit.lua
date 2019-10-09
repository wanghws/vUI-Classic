local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetHitModifier = GetHitModifier
local GetSpellHitModifier = GetSpellHitModifier

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Hit = GetHitModifier()
	local Spell = GetSpellHitModifier()
	
	if (Spell > Hit) then
		Rating = Spell
	else
		Rating = Hit
	end
	
	self.Text:SetFormattedText("%s: %s", Language["Hit"], Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Hit", OnEnable, OnDisable, Update)