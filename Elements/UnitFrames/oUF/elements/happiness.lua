--[[
# Element: Pet Happiness

Toggles the visibility of an indicator based on the pet happiness level.

## Widget

PetHappiness - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local PetHappiness = self:CreateTexture(nil, 'OVERLAY')
    PetHappiness:SetSize(16, 16)
    PetHappiness:SetPoint('TOP', self)

    -- Register it with oUF
    self.PetHappiness = PetHappiness
--]]

local _, ns = ...
local oUF = ns.oUF

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness

local Update = function(self, event)
	local element = self.PetHappiness

	--[[ Callback: PetHappiness:PreUpdate()
	Called before the element has been updated.

	* self - the PetHappiness element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local Happiness = GetPetHappiness()
	local HasUI, IsHunter = HasPetUI()
	
	if (Happiness and IsHunter) then
		if (Happiness == 1) then
			element:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		elseif (Happiness == 2) then
			element:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		else
			element:SetTexCoord(0, 0.1875, 0, 0.359375)
		end
		
		element:Show()
	else
		element:Hide()
	end
	
	--[[ Callback: PetHappiness:PostUpdate(inCombat)
	Called after the element has been updated.
	
	* self     - the PetHappiness element
	* Happiness - indicates the pets happiness level (number)
 	--]]
	if element.PostUpdate then
		return element:PostUpdate(Happiness)
	end
end

local Path = function(self, ...)
	--[[ Override: PetHappiness.Override(self, event)
	Used to completely override the internal update function.
	
	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.PetHappiness.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local Enable = function(self, unit)
	if (unit ~= "pet") then
		return
	end
	
	local element = self.PetHappiness
	
	if (not element) then
		return
	end
	
	element.__owner = self
	element.ForceUpdate = ForceUpdate
	
	self:RegisterEvent("UNIT_HAPPINESS", Path, true)
	
	if (element:IsObjectType("Texture") and not element:GetTexture()) then
		element:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	end
	
	return true
end

local function Disable(self)
	local element = self.PetHappiness
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("UNIT_HAPPINESS", Path)
	end
end

oUF:AddElement("Happiness", Path, Enable, Disable)