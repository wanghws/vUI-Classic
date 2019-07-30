local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Colors"])
	
	Left:CreateHeader(Language["Class Colors"])
	Left:CreateColorSelection("cc-death-knight", Settings["cc-death-knight"], "Death Knight", "")
	Left:CreateColorSelection("cc-demon-hunter", Settings["cc-demon-hunter"], "Demon Hunter", "")
	Left:CreateColorSelection("cc-druid", Settings["cc-druid"], "Druid", "")
	Left:CreateColorSelection("cc-hunter", Settings["cc-hunter"], "Hunter", "")
	Left:CreateColorSelection("cc-mage", Settings["cc-mage"], "Mage", "")
	Left:CreateColorSelection("cc-monk", Settings["cc-monk"], "Monk", "")
	Left:CreateColorSelection("cc-priest", Settings["cc-priest"], "Priest", "")
	Left:CreateColorSelection("cc-rogue", Settings["cc-rogue"], "Rogue", "")
	Left:CreateColorSelection("cc-shaman", Settings["cc-shaman"], "Shaman", "")
	Left:CreateColorSelection("cc-warlock", Settings["cc-warlock"], "Warlock", "")
	Left:CreateColorSelection("cc-warrior", Settings["cc-warrior"], "Warrior", "")
	
	Left:CreateFooter()
	Right:CreateFooter()
end)