local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

local ClassColors = {}
local ReactionColors = {}
local ZoneColors = {}

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
	self.ClassColors["DEATHKNIGHT"] = {self:HexToRGB(Settings["color-death-knight"])}
	self.ClassColors["DEMONHUNTER"] = {self:HexToRGB(Settings["color-demon-hunter"])}
	self.ClassColors["DRUID"] = {self:HexToRGB(Settings["color-druid"])}
	self.ClassColors["HUNTER"] = {self:HexToRGB(Settings["color-hunter"])}
	self.ClassColors["MAGE"] = {self:HexToRGB(Settings["color-mage"])}
	self.ClassColors["MONK"] = {self:HexToRGB(Settings["color-monk"])}
	self.ClassColors["PALADIN"] = {self:HexToRGB(Settings["color-paladin"])}
	self.ClassColors["PRIEST"] = {self:HexToRGB(Settings["color-priest"])}
	self.ClassColors["ROGUE"] = {self:HexToRGB(Settings["color-rogue"])}
	self.ClassColors["SHAMAN"] = {self:HexToRGB(Settings["color-shaman"])}
	self.ClassColors["WARLOCK"] = {self:HexToRGB(Settings["color-warlock"])}
	self.ClassColors["WARRIOR"] = {self:HexToRGB(Settings["color-warrior"])}
end

function vUI:UpdateReactionColors()
	self.ReactionColors[1] = {self:HexToRGB(Settings["reaction-1"])}
	self.ReactionColors[2] = {self:HexToRGB(Settings["reaction-2"])}
	self.ReactionColors[3] = {self:HexToRGB(Settings["reaction-3"])}
	self.ReactionColors[4] = {self:HexToRGB(Settings["reaction-4"])}
	self.ReactionColors[5] = {self:HexToRGB(Settings["reaction-5"])}
	self.ReactionColors[6] = {self:HexToRGB(Settings["reaction-6"])}
	self.ReactionColors[7] = {self:HexToRGB(Settings["reaction-7"])}
	self.ReactionColors[8] = {self:HexToRGB(Settings["reaction-8"])}
end

function vUI:UpdateZoneColors()
	ZoneColors["sanctuary"] = {self:HexToRGB(Settings["color-sanctuary"])}
	ZoneColors["arena"] = {self:HexToRGB(Settings["color-arena"])}
	ZoneColors["hostile"] = {self:HexToRGB(Settings["color-hostile"])}
	ZoneColors["combat"] = {self:HexToRGB(Settings["color-combat"])}
	ZoneColors["friendly"] = {self:HexToRGB(Settings["color-friendly"])}
	ZoneColors["contested"] = {self:HexToRGB(Settings["color-contested"])}
	ZoneColors["other"] = {self:HexToRGB(Settings["color-other"])}
end

vUI.ClassColors = ClassColors
vUI.ReactionColors = ReactionColors
vUI.ZoneColors = ZoneColors

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
	
	Right:CreateHeader(Language["Reaction Colors"])
	Right:CreateColorSelection("reaction-1", Settings["reaction-1"], Language["Exceptionally Hostile"], "")
	Right:CreateColorSelection("reaction-2", Settings["reaction-2"], Language["Very Hostile"], "")
	Right:CreateColorSelection("reaction-3", Settings["reaction-3"], Language["Hostile"], "")
	Right:CreateColorSelection("reaction-4", Settings["reaction-4"], Language["Neutral"], "")
	Right:CreateColorSelection("reaction-5", Settings["reaction-5"], Language["Friendly"], "")
	Right:CreateColorSelection("reaction-6", Settings["reaction-6"], Language["Very Friendly"], "")
	Right:CreateColorSelection("reaction-7", Settings["reaction-7"], Language["Exceptionally Friendly"], "")
	Right:CreateColorSelection("reaction-8", Settings["reaction-8"], Language["Exalted"], "")
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	vUI:UpdateClassColors()
	vUI:UpdateReactionColors()
	vUI:UpdateZoneColors()
end)