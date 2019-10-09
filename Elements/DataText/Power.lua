local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local UnitAttackPower = UnitAttackPower
local UnitRangedAttackPower = UnitRangedAttackPower
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Label
	
	local AttackBase, AttackPositiveBuffs, AttackNegativeBuffs = UnitAttackPower("player")
	local Attack =  AttackBase + AttackPositiveBuffs + AttackNegativeBuffs
	
	local RangedBase, RangedPositiveBuffs, RangedNegativeBuffs = UnitRangedAttackPower("player")
	local Ranged = RangedBase + RangedPositiveBuffs + RangedNegativeBuffs
	
	local Spell = GetSpellBonusDamage(7)
	local Healing = GetSpellBonusHealing()
	
	if (vUI.UserClass == "HUNTER") then
		Rating = Ranged
		Label = Language["Ranged"]
	elseif (Healing > Spell) then
		Rating = Healing
		Label = Language["Healing"]
	elseif (Spell > Attack) then
		Rating = Spell
		Label = Language["Spell"]
	else
		Rating = Attack
		Label = Language["Power"]
	end
	
	self.Text:SetFormattedText("%s: %s", Label, Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_ATTACK_POWER")
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
	self:RegisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", Update)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:UnregisterEvent("UNIT_ATTACK_POWER")
	self:UnregisterEvent("UNIT_RANGED_ATTACK_POWER")
	self:UnregisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Power", OnEnable, OnDisable, Update)