local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

local ClassColors = {}

local Meta = getmetatable(CreateFrame("Frame"))

local UpdateClassColors = function()
	for _, obj in pairs(oUF.objects) do
		if obj.colors then
			for class, color in pairs(vUI.ClassColors) do
				obj.colors.class[class] = {color.r, color.g, color.b}
			end
		end
		
		Meta.__index.colors = vUI.ClassColors
		
		obj:UpdateAllElements("ForceUpdate")
	end
end

local UpdateDK = function(value)
	local R, G, B = vUI:HexToRGB(value)
	
	ClassColors["DEATHKNIGHT"] = {R, G, B}
	
	UpdateClassColors()
end

function vUI:UpdateClassColors()
	ClassColors["DEATHKNIGHT"] = {self:HexToRGB(Settings["color-death-knight"])}
	ClassColors["DEMONHUNTER"] = {self:HexToRGB(Settings["color-demon-hunter"])}
	ClassColors["DRUID"] = {self:HexToRGB(Settings["color-druid"])}
	ClassColors["HUNTER"] = {self:HexToRGB(Settings["color-hunter"])}
	ClassColors["MAGE"] = {self:HexToRGB(Settings["color-mage"])}
	ClassColors["MONK"] = {self:HexToRGB(Settings["color-monk"])}
	ClassColors["PALADIN"] = {self:HexToRGB(Settings["color-paladin"])}
	ClassColors["PRIEST"] = {self:HexToRGB(Settings["color-priest"])}
	ClassColors["ROGUE"] = {self:HexToRGB(Settings["color-rogue"])}
	ClassColors["SHAMAN"] = {self:HexToRGB(Settings["color-shaman"])}
	ClassColors["WARLOCK"] = {self:HexToRGB(Settings["color-warlock"])}
	ClassColors["WARRIOR"] = {self:HexToRGB(Settings["color-warrior"])}
end

vUI.ClassColors = ClassColors

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Colors"])
	
	Left:CreateHeader(Language["Class Colors"])
	Left:CreateColorSelection("color-death-knight", Settings["color-death-knight"], Language["Death Knight"], "", UpdateDK)
	Left:CreateColorSelection("color-demon-hunter", Settings["color-demon-hunter"], Language["Demon Hunter"], "")
	Left:CreateColorSelection("color-druid", Settings["color-druid"], Language["Druid"], "")
	Left:CreateColorSelection("color-hunter", Settings["color-hunter"], Language["Hunter"], "")
	Left:CreateColorSelection("color-mage", Settings["color-mage"], Language["Mage"], "")
	Left:CreateColorSelection("color-monk", Settings["color-monk"], Language["Monk"], "")
	Left:CreateColorSelection("color-paladin", Settings["color-paladin"], Language["Paladin"], "")
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
	
	vUI:UpdateClassColors()
end)