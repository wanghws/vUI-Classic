local _, ns = ...
local oUF = ns.oUF

-- If drinking, add a 1s tick

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local Update

local OnUpdate = function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	
	self:SetValue(self.elapsed)
	
	if (self.elapsed >= self.max) then
		self.LastPower = UnitPower("player")
		self:Hide()
		
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
	end
end

Update = function(self, event, unit)
	if (unit ~= self.unit) then
		return
	end
	
	local element = self.ManaTimer
	
	if element then
		local Type = UnitPowerType(self.unit)
		local Power = UnitPower(unit)
		
		if (Type ~= 0) or (Power == UnitPowerMax(unit)) then
			return
		end
		
		if (element.LastPower > Power) then -- Cast
			element.elapsed = 0
			element.max = 5
			element:SetMinMaxValues(0, element.max)
			element:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
			element:Show()
			element:SetScript("OnUpdate", OnUpdate)
		elseif (Power > element.LastPower) then -- Tick
			element.elapsed = 0
			element.max = 2
			element:SetMinMaxValues(0, element.max)
			element:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
			element:Show()
			element:SetScript("OnUpdate", OnUpdate)
		end
		
		element.LastPower = Power
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
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
	end
end

local Disable = function(self)
	local element = self.ManaTimer
	
	if element then
		element:Hide()
		element:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
	end
end

oUF:AddElement("ManaRegen", Path, Enable, Disable)