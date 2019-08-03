local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Colors"])
	
	Left:CreateHeader(Language["Class Colors"])
	Left:CreateColorSelection("color-death-knight", Settings["color-death-knight"], Language["Death Knight"], "")
	Left:CreateColorSelection("color-demon-hunter", Settings["color-demon-hunter"], Language["Demon Hunter"], "")
	Left:CreateColorSelection("color-druid", Settings["color-druid"], Language["Druid"], "")
	Left:CreateColorSelection("color-hunter", Settings["color-hunter"], Language["Hunter"], "")
	Left:CreateColorSelection("color-mage", Settings["color-mage"], Language["Mage"], "")
	Left:CreateColorSelection("color-monk", Settings["color-monk"], Language["Monk"], "")
	Left:CreateColorSelection("color-priest", Settings["color-priest"], Language["Priest"], "")
	Left:CreateColorSelection("color-rogue", Settings["color-rogue"], Language["Rogue"], "")
	Left:CreateColorSelection("color-shaman", Settings["color-shaman"], Language["Shaman"], "")
	Left:CreateColorSelection("color-warlock", Settings["color-warlock"], Language["Warlock"], "")
	Left:CreateColorSelection("color-warrior", Settings["color-warrior"], Language["Warrior"], "")
	
	Right:CreateHeader(Language["Zone Colors"])
	Right:CreateColorSelection("color-sanctuary", Settings["color-sanctuary"], "Sanctuary", "")
	Right:CreateColorSelection("color-arena", Settings["color-arena"], "Arena", "")
	Right:CreateColorSelection("color-hostile", Settings["color-hostile"], "Hostile", "")
	Right:CreateColorSelection("color-combat", Settings["color-combat"], "Combat", "")
	Right:CreateColorSelection("color-contested", Settings["color-contested"], "Contested", "")
	Right:CreateColorSelection("color-friendly", Settings["color-friendly"], "Friendly", "")
	Right:CreateColorSelection("color-other", Settings["color-other"], "Other", "")
	
	Left:CreateFooter()
	Right:CreateFooter()
end)