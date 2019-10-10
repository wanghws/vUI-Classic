local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Base, Casting = GetManaRegen()
	local Regen
	
	if InCombatLockdown() then
		Regen = Casting * 5
	else
		Regen = Base * 5
	end
	
	self.Text:SetFormattedText("%s: %.2f", Language["Regen"], Regen)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", Update)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:UnregisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Regen", OnEnable, OnDisable, Update)