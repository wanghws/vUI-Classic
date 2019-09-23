local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Auras = vUI:NewModule("Auras")

Auras.AuraButton_Update = function(name, index)
	local Button = _G[name .. index]
	
	if ((not Button) or (Button and Button.Handled)) then
		return
	end
	
	--Button:SetScaledSize(30, 30)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColorHex("00000000")
	Button:SetBackdropBorderColorHex("000000")
	Button.duration:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	Button.count:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	
	local Icon = _G[name .. index .. "Icon"]
	
	if Icon then
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	Button.Handled = true
end

function Auras:Load()
	self:Hook("AuraButton_Update")
end