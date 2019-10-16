if (select(2, UnitClass("player")) ~= "ROGUE") or (select(2, UnitClass("player")) ~= "DRUID")then
	return
end

local _, ns = ...
local oUF = ns.oUF

local UnitPower = UnitPower
local GetTime = GetTime

local LastTick = GetTime()
local LastPower = 0

local OnUpdate = function(self, elapsed)
	local Power = UnitPower("player")
	local Time = GetTime()
	local Value = Time - LastTick
	
	if (Power > LastPower) or (Value >= 2) then
		LastTick = Time
	end
	
	self:SetValue(Value)
	
	LastPower = Power
end

local Path = function(self, ...)
	return (self.Tick.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local element = self.Tick
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		element:SetMinMaxValues(0, 2)
		element:SetScript("OnUpdate", OnUpdate)
		element:Show()
	end
end

local Disable = function(self)
	local element = self.Tick
	
	if element then
		element:Hide()
		element:SetScript("OnUpdate", nil)
	end
end

oUF:AddElement("Energy Tick", Path, Enable, Disable)