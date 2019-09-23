local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Auras = vUI:NewModule("Auras")

local Name, Texture, Count, DebuffType
local UnitAura = UnitAura
local unpack = unpack

local SkinAura = function(button, name, index)
	button:SetBackdrop(vUI.BackdropAndBorder)
	button:SetBackdropColorHex("00000000")
	button:SetBackdropBorderColorHex("000000")
	
	button.duration:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	button.duration:ClearAllPoints()
	button.duration:SetScaledPoint("TOP", button, "BOTTOM", 0, -4)
	button.count:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	
	local Icon = _G[name .. index .. "Icon"]
	local Border = _G[name .. index .. "Border"]
	
	if Icon then
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if Border then
		Border:SetTexture(nil)
	end
	
	button.Handled = true
end

Auras.AuraButton_Update = function(name, index)
	local Button = _G[name .. index]
	
	if (not Button) then
		return
	end
	
	if (not Button.Handled) then
		SkinAura(Button, name, index)
	end
	
	Name, Texture, Count, DebuffType = UnitAura("player", index, name == "BuffButton" and "HELPFUL" or "HARMFUL")
	
	if (Name and DebuffType) then
		Button:SetBackdropBorderColor(unpack(vUI.DebuffColors[DebuffType]))
	end
end

function Auras:Load()
	self:Hook("AuraButton_Update")
end