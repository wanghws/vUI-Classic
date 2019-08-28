local _, ns = ...
local oUF = ns.oUF

local GetComboPoints = GetComboPoints

local Update = function(self, event, unit)
	if (unit ~= self.unit) then
		return
	end
	
	local element = self.ComboPoints
	
	if element.PreUpdate then
		element:PreUpdate()
	end
	
	local Points = GetComboPoints("player", "target")
	
	for i = 1, 5 do
		if (i > Points) then
			element[i]:SetAlpha(0.2)
		else
			element[i]:SetAlpha(1)
		end
	end
	
	if element.PostUpdate then
		return element:PostUpdate(Points)
	end
end

local Path = function(self, ...)
	return (self.ComboPoints.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local Enable = function(self)
	local element = self.ComboPoints
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path, true)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path, true)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path, true)
		
		for i = 1, 5 do
			if (element[i]:IsObjectType("Texture") and not element[i]:GetTexture()) then
				element[i]:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
			end
			
			element[i]:SetAlpha(0.2)
		end
		
		return true
	end
end

local Disable = function(self)
	local element = self.ComboPoints
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
	end
end

oUF:AddElement("ComboPoints", Path, Enable, Disable)