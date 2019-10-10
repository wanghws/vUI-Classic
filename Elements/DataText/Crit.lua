local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Crit
	local Spell = GetSpellCritChance()
	local Melee = GetCritChance()
	
	if (vUI.UserClass == "HUNTER") then
		Crit = GetRangedCritChance()
	elseif (Spell > Melee) then
		Crit = Spell
	else
		Crit = Melee
	end
	
	self.Text:SetFormattedText("%s: %.2f%%", Language["Crit"], Crit)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Crit", OnEnable, OnDisable, Update)