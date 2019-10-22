local _, ns = ...
local oUF = ns.oUF

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local OnUpdate = function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	
	self:SetValue(self.elapsed)
	
	if (self.elapsed >= 5) then
		self:Hide()
	end
end

local Update = function(self, event, unit)
	if (unit ~= self.unit) then
		return
	end
	
	local element = self.ManaTimer
	
	if element then
		local Type = UnitPowerType(self.unit)
		local Power = UnitPower(unit)
		
		if (Type ~= 0) or (Power == UnitPowerMax(unit)) or (Power >= element.LastPower) then
			return
		end
		
		element.elapsed = 0
		element.LastPower = Power
		element:Show()
		element:SetScript("OnUpdate", OnUpdate)
	end
end

local Path = function(self, ...)
	return (self.ManaTimer.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local element = self.ManaTimer
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		element.LastPower = UnitPower(self.unit)
		
		element:Hide()
		element:SetMinMaxValues(0, 5)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
	end
end

local Disable = function(self)
	local element = self.ManaTimer
	
	if element then
		element:Hide()
		element:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
	end
end

oUF:AddElement("ManaRegen", Path, Enable, Disable)