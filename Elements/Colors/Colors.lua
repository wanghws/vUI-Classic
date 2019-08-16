local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

local ClassColors = {}
local ReactionColors = {}
local ZoneColors = {}
local PowerColors = {}
local DebuffColors = {}
local HappinessColors = {}

function vUI:UpdateClassColors()
	--self.ClassColors["DEATHKNIGHT"] = {self:HexToRGB(Settings["color-death-knight"])}
	--self.ClassColors["DEMONHUNTER"] = {self:HexToRGB(Settings["color-demon-hunter"])}
	self.ClassColors["DRUID"] = {self:HexToRGB(Settings["color-druid"])}
	self.ClassColors["HUNTER"] = {self:HexToRGB(Settings["color-hunter"])}
	self.ClassColors["MAGE"] = {self:HexToRGB(Settings["color-mage"])}
	--self.ClassColors["MONK"] = {self:HexToRGB(Settings["color-monk"])}
	self.ClassColors["PALADIN"] = {self:HexToRGB(Settings["color-paladin"])}
	self.ClassColors["PRIEST"] = {self:HexToRGB(Settings["color-priest"])}
	self.ClassColors["ROGUE"] = {self:HexToRGB(Settings["color-rogue"])}
	self.ClassColors["SHAMAN"] = {self:HexToRGB(Settings["color-shaman"])}
	self.ClassColors["WARLOCK"] = {self:HexToRGB(Settings["color-warlock"])}
	self.ClassColors["WARRIOR"] = {self:HexToRGB(Settings["color-warrior"])}
end

function vUI:UpdateReactionColors()
	self.ReactionColors[1] = {self:HexToRGB(Settings["color-reaction-1"])}
	self.ReactionColors[2] = {self:HexToRGB(Settings["color-reaction-2"])}
	self.ReactionColors[3] = {self:HexToRGB(Settings["color-reaction-3"])}
	self.ReactionColors[4] = {self:HexToRGB(Settings["color-reaction-4"])}
	self.ReactionColors[5] = {self:HexToRGB(Settings["color-reaction-5"])}
	self.ReactionColors[6] = {self:HexToRGB(Settings["color-reaction-6"])}
	self.ReactionColors[7] = {self:HexToRGB(Settings["color-reaction-7"])}
	self.ReactionColors[8] = {self:HexToRGB(Settings["color-reaction-8"])}
end

function vUI:UpdateZoneColors()
	self.ZoneColors["sanctuary"] = {self:HexToRGB(Settings["color-sanctuary"])}
	self.ZoneColors["arena"] = {self:HexToRGB(Settings["color-arena"])}
	self.ZoneColors["hostile"] = {self:HexToRGB(Settings["color-hostile"])}
	self.ZoneColors["combat"] = {self:HexToRGB(Settings["color-combat"])}
	self.ZoneColors["friendly"] = {self:HexToRGB(Settings["color-friendly"])}
	self.ZoneColors["contested"] = {self:HexToRGB(Settings["color-contested"])}
	self.ZoneColors["other"] = {self:HexToRGB(Settings["color-other"])}
end

function vUI:UpdatePowerColors()
	PowerColors["MANA"] = {self:HexToRGB(Settings["color-mana"])}
	PowerColors["RAGE"] = {self:HexToRGB(Settings["color-rage"])}
	PowerColors["ENERGY"] = {self:HexToRGB(Settings["color-energy"])}
	PowerColors["COMBO_POINTS"] = {self:HexToRGB(Settings["color-combo-points"])}
	PowerColors["FOCUS"] = {self:HexToRGB(Settings["color-focus"])}
	--[[PowerColors["SOUL_SHARDS"] = {self:HexToRGB(Settings["color-soul-shards"])}
	PowerColors["INSANITY"] = {self:HexToRGB(Settings["color-insanity"])}
	PowerColors["FURY"] = {self:HexToRGB(Settings["color-fury"])}
	PowerColors["PAIN"] = {self:HexToRGB(Settings["color-pain"])}
	PowerColors["CHI"] = {self:HexToRGB(Settings["color-chi"])}
	PowerColors["MAELSTROM"] = {self:HexToRGB(Settings["color-maelstrom"])}
	PowerColors["ARCANE_CHARGES"] = {self:HexToRGB(Settings["color-arcane-charges"])}
	PowerColors["HOLY_POWER"] = {self:HexToRGB(Settings["color-holy-power"])}
	PowerColors["LUNAR_POWER"] = {self:HexToRGB(Settings["color-lunar-power"])}
	PowerColors["RUNIC_POWER"] = {self:HexToRGB(Settings["color-runic-power"])}
	PowerColors["RUNES"] = {self:HexToRGB(Settings["color-runes"])}
	PowerColors["FUEL"] = {self:HexToRGB(Settings["color-fuel"])}
	PowerColors["AMMO_SLOT"] = {self:HexToRGB(Settings["color-ammo-slot"])}]]
end

function vUI:UpdateDebuffColors()
	self.DebuffColors["Curse"] = {self:HexToRGB(Settings["color-curse"])}
	self.DebuffColors["Disease"] = {self:HexToRGB(Settings["color-disease"])}
	self.DebuffColors["Magic"] = {self:HexToRGB(Settings["color-magic"])}
	self.DebuffColors["Poison"] = {self:HexToRGB(Settings["color-poison"])}
	self.DebuffColors["none"] = {self:HexToRGB(Settings["color-none"])}
end

function vUI:UpdateHappinessColors()
	self.HappinessColors[1] = {self:HexToRGB(Settings["color-happiness-1"])}
	self.HappinessColors[2] = {self:HexToRGB(Settings["color-happiness-2"])}
	self.HappinessColors[3] = {self:HexToRGB(Settings["color-happiness-3"])}
end

vUI.ClassColors = ClassColors
vUI.ReactionColors = ReactionColors
vUI.ZoneColors = ZoneColors
vUI.PowerColors = PowerColors
vUI.DebuffColors = DebuffColors
vUI.HappinessColors = HappinessColors

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Colors"])
	
	Left:CreateHeader(Language["Class Colors"])
	--Left:CreateColorSelection("color-death-knight", Settings["color-death-knight"], Language["Death Knight"], "")
	--Left:CreateColorSelection("color-demon-hunter", Settings["color-demon-hunter"], Language["Demon Hunter"], "")
	Left:CreateColorSelection("color-druid", Settings["color-druid"], Language["Druid"], "")
	Left:CreateColorSelection("color-hunter", Settings["color-hunter"], Language["Hunter"], "")
	Left:CreateColorSelection("color-mage", Settings["color-mage"], Language["Mage"], "")
	--Left:CreateColorSelection("color-monk", Settings["color-monk"], Language["Monk"], "")
	Left:CreateColorSelection("color-paladin", Settings["color-paladin"], Language["Paladin"], "")
	Left:CreateColorSelection("color-priest", Settings["color-priest"], Language["Priest"], "")
	Left:CreateColorSelection("color-rogue", Settings["color-rogue"], Language["Rogue"], "")
	Left:CreateColorSelection("color-shaman", Settings["color-shaman"], Language["Shaman"], "")
	Left:CreateColorSelection("color-warlock", Settings["color-warlock"], Language["Warlock"], "")
	Left:CreateColorSelection("color-warrior", Settings["color-warrior"], Language["Warrior"], "")
	
	Right:CreateHeader(Language["Power Colors"])
	Right:CreateColorSelection("color-mana", Settings["color-mana"], Language["Mana"], "")
	Right:CreateColorSelection("color-rage", Settings["color-rage"], Language["Rage"], "")
	Right:CreateColorSelection("color-energy", Settings["color-energy"], Language["Energy"], "")
	Right:CreateColorSelection("color-combo-points", Settings["color-combo-points"], Language["Combo Points"], "")
	Right:CreateColorSelection("color-focus", Settings["color-focus"], Language["Focus"], "")
	--[[Left:CreateColorSelection("color-soul-shards", Settings["color-soul-shards"], Language["Soul Shards"], "")
	Left:CreateColorSelection("color-insanity", Settings["color-insanity"], Language["Insanity"], "")
	Left:CreateColorSelection("color-fury", Settings["color-fury"], Language["Fury"], "")
	Left:CreateColorSelection("color-pain", Settings["color-pain"], Language["Pain"], "")
	Left:CreateColorSelection("color-chi", Settings["color-chi"], Language["Chi"], "")
	Left:CreateColorSelection("color-maelstrom", Settings["color-maelstrom"], Language["Maelstrom"], "")
	Left:CreateColorSelection("color-arcane-charges", Settings["color-arcane-charges"], Language["Arcane Charges"], "")
	Left:CreateColorSelection("color-holy-power", Settings["color-holy-power"], Language["Holy Power"], "")
	Left:CreateColorSelection("color-lunar-power", Settings["color-lunar-power"], Language["Lunar Power"], "")
	Left:CreateColorSelection("color-runic-power", Settings["color-runic-power"], Language["Runic Power"], "")
	Left:CreateColorSelection("color-runes", Settings["color-runes"], Language["Runes"], "")
	Left:CreateColorSelection("color-fuel", Settings["color-fuel"], Language["Fuel"], "")
	Left:CreateColorSelection("color-ammo-slot", Settings["color-ammo-slot"], Language["Ammo Slot"], "")]]
	
	Left:CreateHeader(Language["Zone Colors"])
	Left:CreateColorSelection("color-sanctuary", Settings["color-sanctuary"], "Sanctuary", "")
	Left:CreateColorSelection("color-arena", Settings["color-arena"], "Arena", "")
	Left:CreateColorSelection("color-hostile", Settings["color-hostile"], "Hostile", "")
	Left:CreateColorSelection("color-combat", Settings["color-combat"], "Combat", "")
	Left:CreateColorSelection("color-contested", Settings["color-contested"], "Contested", "")
	Left:CreateColorSelection("color-friendly", Settings["color-friendly"], "Friendly", "")
	Left:CreateColorSelection("color-other", Settings["color-other"], "Other", "")
	
	Right:CreateHeader(Language["Reaction Colors"])
	Right:CreateColorSelection("color-reaction-1", Settings["color-reaction-1"], Language["Exceptionally Hostile"], "")
	Right:CreateColorSelection("color-reaction-2", Settings["color-reaction-2"], Language["Very Hostile"], "")
	Right:CreateColorSelection("color-reaction-3", Settings["color-reaction-3"], Language["Hostile"], "")
	Right:CreateColorSelection("color-reaction-4", Settings["color-reaction-4"], Language["Neutral"], "")
	Right:CreateColorSelection("color-reaction-5", Settings["color-reaction-5"], Language["Friendly"], "")
	Right:CreateColorSelection("color-reaction-6", Settings["color-reaction-6"], Language["Very Friendly"], "")
	Right:CreateColorSelection("color-reaction-7", Settings["color-reaction-7"], Language["Exceptionally Friendly"], "")
	Right:CreateColorSelection("color-reaction-8", Settings["color-reaction-8"], Language["Exalted"], "")
	
	Right:CreateHeader(Language["Debuff Colors"])
	Right:CreateColorSelection("color-curse", Settings["color-curse"], Language["Curse"], "")
	Right:CreateColorSelection("color-disease", Settings["color-disease"], Language["Disease"], "")
	Right:CreateColorSelection("color-magic", Settings["color-magic"], Language["Magic"], "")
	Right:CreateColorSelection("color-poison", Settings["color-poison"], Language["Poison"], "")
	Right:CreateColorSelection("color-none", Settings["color-none"], Language["None"], "")
	
	Left:CreateHeader(Language["Pet Happiness Colors"])
	Left:CreateColorSelection("color-happiness-1", Settings["color-happiness-1"], Language["Unhappy"], "")
	Left:CreateColorSelection("color-happiness-2", Settings["color-happiness-2"], Language["Content"], "")
	Left:CreateColorSelection("color-happiness-3", Settings["color-happiness-3"], Language["Happy"], "")
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	vUI:UpdateClassColors()
	vUI:UpdateReactionColors()
	vUI:UpdateZoneColors()
	vUI:UpdatePowerColors()
	vUI:UpdateDebuffColors()
	vUI:UpdateHappinessColors()
end)