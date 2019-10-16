local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing

local HealingLabel = Language["Spell Healing"]
local SpellLabel = Language["Spell Damage"]

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Label
	
	local Spell = GetSpellBonusDamage(7)
	local Healing = GetSpellBonusHealing()
	
	if (Spell > 0 or Healing > 0) then
		if (Healing > Spell) then
			Rating = Healing
			Label = HealingLabel
		else
			Rating = Spell
			Label = SpellLabel
		end
	end
	
	self.Text:SetFormattedText("%s: %s", Label, Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", Update)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:UnregisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:SetType("Spell Power", OnEnable, OnDisable, Update)