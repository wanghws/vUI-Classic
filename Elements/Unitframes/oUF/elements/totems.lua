--[[
# Element: Totem Indicator

Handles the updating and visibility of totems.

## Widget

Totems - A `table` to hold sub-widgets.

## Sub-Widgets

Totem - Any UI widget.

## Sub-Widget Options

.Icon     - A `Texture` representing the totem icon.
.Cooldown - A `Cooldown` representing the duration of the totem.

## Notes

OnEnter and OnLeave script handlers will be set to display a Tooltip if the `Totem` widget is mouse enabled.

## Examples

    local Totems = {}
    for index = 1, 5 do
        -- Position and size of the totem indicator
        local Totem = CreateFrame("Button", nil, self)
        Totem:SetSize(40, 40)
        Totem:SetPoint("TOPLEFT", self, "BOTTOMLEFT", index * Totem:GetWidth(), 0)

        local Icon = Totem:CreateTexture(nil, "OVERLAY")
        Icon:SetAllPoints()

        local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
        Cooldown:SetAllPoints()

        Totem.Icon = Icon
        Totem.Cooldown = Cooldown

        Totems[index] = Totem
    end

    -- Register with oUF
    self.Totems = Totems
--]]

local _, ns = ...
local oUF = ns.oUF

local GetTotemInfo = GetTotemInfo
local GetTime = GetTime

local UpdateTooltip = function(self)
	GameTooltip:SetTotem(self:GetID())
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
end

local OnLeave = function()
	GameTooltip:Hide()
end

local TotemOnUpdate = function(self, elapsed)
	self.ela = self.ela - elapsed
	
	self:SetValue(self.ela)
	
	if (self.ela <= 0) then
		self:SetScript("OnUpdate", nil)
	end
end

local UpdateTotem = function(self, event, slot)
	local element = self.Totems
	
	if element.PreUpdate then
		element:PreUpdate(slot)
	end
	
	local Exists, Name, Start, Duration, Icon = GetTotemInfo(slot)
	
	if (Exists and Duration > 0) then
		local Totem = element[slot]
		Totem.duration = Start + Duration - GetTime()
		Totem.ela = Totem.duration
		Totem:SetScript("OnUpdate", TotemOnUpdate)
		Totem:SetMinMaxValues(0, Totem.ela)
		Totem:SetValue(Totem.ela)
	end
	
	if element.PostUpdate then
		return element:PostUpdate(slot, Exists, Name, Start, Duration, Icon)
	end
end

local Path = function(self, ...)
	return (self.Totems.Override or UpdateTotem)(self, ...)
end

local Update = function(self, event)
	for i = 1, #self.Totems do
		Path(self, event, i)
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate")
end

local Enable = function(self)
	local element = self.Totems
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		for i = 1, #element do
			local Totem = element[i]
			
			Totem:SetID(i)
			Totem:SetMinMaxValues(0, 1)
			Totem:SetValue(0)
			
			if Totem:IsMouseEnabled() then
				Totem:SetScript("OnEnter", OnEnter)
				Totem:SetScript("OnLeave", OnLeave)
			end
		end
		
		self:RegisterEvent("PLAYER_TOTEM_UPDATE", Path, true)
		
		return true
	end
end

local Disable = function(self)
	local element = self.Totems
	
	if element then
		for i = 1, #element do
			element[i]:Hide()
		end
		
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Path)
	end
end

oUF:AddElement("Totems", Update, Enable, Disable)