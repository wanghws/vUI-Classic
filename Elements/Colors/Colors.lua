local AddonName, Namespace = ...
local vUI, GUI, Language, Media, Settings, Defaults, Profiles = Namespace:get()
local oUF = Namespace.oUF

vUI.ClassColors = {}
vUI.ReactionColors = {}
vUI.ZoneColors = {}
vUI.PowerColors = {}
vUI.DebuffColors = {}
vUI.HappinessColors = {}
vUI.ClassificationColors = {}
vUI.ComboPoints = {}

function vUI:UpdateComboColors()
	self.ComboPoints[1] = {self:HexToRGB(Settings["color-combo-1"])}
	self.ComboPoints[2] = {self:HexToRGB(Settings["color-combo-2"])}
	self.ComboPoints[3] = {self:HexToRGB(Settings["color-combo-3"])}
	self.ComboPoints[4] = {self:HexToRGB(Settings["color-combo-4"])}
	self.ComboPoints[5] = {self:HexToRGB(Settings["color-combo-5"])}
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
	self.PowerColors["MANA"] = {self:HexToRGB(Settings["color-mana"])}
	self.PowerColors["RAGE"] = {self:HexToRGB(Settings["color-rage"])}
	self.PowerColors["ENERGY"] = {self:HexToRGB(Settings["color-energy"])}
	self.PowerColors["COMBO_POINTS"] = {self:HexToRGB(Settings["color-combo-points"])}
	self.PowerColors["FOCUS"] = {self:HexToRGB(Settings["color-focus"])}
	self.PowerColors["SOUL_SHARDS"] = {self:HexToRGB(Settings["color-soul-shards"])}
	self.PowerColors["INSANITY"] = {self:HexToRGB(Settings["color-insanity"])}
	self.PowerColors["FURY"] = {self:HexToRGB(Settings["color-fury"])}
	self.PowerColors["PAIN"] = {self:HexToRGB(Settings["color-pain"])}
	self.PowerColors["CHI"] = {self:HexToRGB(Settings["color-chi"])}
	self.PowerColors["MAELSTROM"] = {self:HexToRGB(Settings["color-maelstrom"])}
	self.PowerColors["ARCANE_CHARGES"] = {self:HexToRGB(Settings["color-arcane-charges"])}
	self.PowerColors["HOLY_POWER"] = {self:HexToRGB(Settings["color-holy-power"])}
	self.PowerColors["LUNAR_POWER"] = {self:HexToRGB(Settings["color-lunar-power"])}
	self.PowerColors["RUNIC_POWER"] = {self:HexToRGB(Settings["color-runic-power"])}
	self.PowerColors["RUNES"] = {self:HexToRGB(Settings["color-runes"])}
	self.PowerColors["FUEL"] = {self:HexToRGB(Settings["color-fuel"])}
	self.PowerColors["AMMO_SLOT"] = {self:HexToRGB(Settings["color-ammo-slot"])}
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

function vUI:UpdateClassificationColors()
	self.ClassificationColors["trivial"] = {self:HexToRGB(Settings["color-trivial"])}
	self.ClassificationColors["standard"] = {self:HexToRGB(Settings["color-standard"])}
	self.ClassificationColors["difficult"] = {self:HexToRGB(Settings["color-difficult"])}
	self.ClassificationColors["verydifficult"] = {self:HexToRGB(Settings["color-verydifficult"])}
	self.ClassificationColors["impossible"] = {self:HexToRGB(Settings["color-impossible"])}
end

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
	Right:CreateColorSelection("color-focus", Settings["color-focus"], Language["Focus"], "")
	--[[Right:CreateColorSelection("color-combo-points", Settings["color-combo-points"], Language["Combo Points"], "")
	Right:CreateColorSelection("color-soul-shards", Settings["color-soul-shards"], Language["Soul Shards"], "")
	Right:CreateColorSelection("color-insanity", Settings["color-insanity"], Language["Insanity"], "")
	Right:CreateColorSelection("color-fury", Settings["color-fury"], Language["Fury"], "")
	Right:CreateColorSelection("color-pain", Settings["color-pain"], Language["Pain"], "")
	Right:CreateColorSelection("color-chi", Settings["color-chi"], Language["Chi"], "")
	Right:CreateColorSelection("color-maelstrom", Settings["color-maelstrom"], Language["Maelstrom"], "")
	Right:CreateColorSelection("color-arcane-charges", Settings["color-arcane-charges"], Language["Arcane Charges"], "")
	Right:CreateColorSelection("color-holy-power", Settings["color-holy-power"], Language["Holy Power"], "")
	Right:CreateColorSelection("color-lunar-power", Settings["color-lunar-power"], Language["Lunar Power"], "")
	Right:CreateColorSelection("color-runic-power", Settings["color-runic-power"], Language["Runic Power"], "")
	Right:CreateColorSelection("color-runes", Settings["color-runes"], Language["Runes"], "")
	Right:CreateColorSelection("color-fuel", Settings["color-fuel"], Language["Fuel"], "")
	Right:CreateColorSelection("color-ammo-slot", Settings["color-ammo-slot"], Language["Ammo Slot"], "")]]
	
	Left:CreateHeader(Language["Zone Colors"])
	Left:CreateColorSelection("color-sanctuary", Settings["color-sanctuary"], "Sanctuary", "")
	Left:CreateColorSelection("color-arena", Settings["color-arena"], "Arena", "")
	Left:CreateColorSelection("color-hostile", Settings["color-hostile"], "Hostile", "")
	Left:CreateColorSelection("color-combat", Settings["color-combat"], "Combat", "")
	Left:CreateColorSelection("color-contested", Settings["color-contested"], "Contested", "")
	Left:CreateColorSelection("color-friendly", Settings["color-friendly"], "Friendly", "")
	Left:CreateColorSelection("color-other", Settings["color-other"], "Other", "")
	
	Right:CreateHeader(Language["Reaction Colors"])
	Right:CreateColorSelection("color-reaction-8", Settings["color-reaction-8"], Language["Exalted"], "")
	Right:CreateColorSelection("color-reaction-7", Settings["color-reaction-7"], Language["Revered"], "")
	Right:CreateColorSelection("color-reaction-6", Settings["color-reaction-6"], Language["Honored"], "")
	Right:CreateColorSelection("color-reaction-5", Settings["color-reaction-5"], Language["Friendly"], "")
	Right:CreateColorSelection("color-reaction-4", Settings["color-reaction-4"], Language["Neutral"], "")
	Right:CreateColorSelection("color-reaction-3", Settings["color-reaction-3"], Language["Unfriendly"], "")
	Right:CreateColorSelection("color-reaction-2", Settings["color-reaction-2"], Language["Hostile"], "")
	Right:CreateColorSelection("color-reaction-1", Settings["color-reaction-1"], Language["Hated"], "")
	
	Right:CreateHeader(Language["Debuff Colors"])
	Right:CreateColorSelection("color-curse", Settings["color-curse"], Language["Curse"], "")
	Right:CreateColorSelection("color-disease", Settings["color-disease"], Language["Disease"], "")
	Right:CreateColorSelection("color-magic", Settings["color-magic"], Language["Magic"], "")
	Right:CreateColorSelection("color-poison", Settings["color-poison"], Language["Poison"], "")
	Right:CreateColorSelection("color-none", Settings["color-none"], Language["None"], "")
	
	Right:CreateHeader(Language["Pet Happiness Colors"])
	Right:CreateColorSelection("color-happiness-3", Settings["color-happiness-3"], Language["Happy"], "")
	Right:CreateColorSelection("color-happiness-2", Settings["color-happiness-2"], Language["Content"], "")
	Right:CreateColorSelection("color-happiness-1", Settings["color-happiness-1"], Language["Unhappy"], "")
	
	Left:CreateHeader(Language["Difficulty Colors"])
	Left:CreateColorSelection("color-trivial", Settings["color-trivial"], Language["Very Easy"], "")
	Left:CreateColorSelection("color-standard", Settings["color-standard"], Language["Easy"], "")
	Left:CreateColorSelection("color-difficult", Settings["color-difficult"], Language["Medium"], "")
	Left:CreateColorSelection("color-verydifficult", Settings["color-verydifficult"], Language["Hard"], "")
	Left:CreateColorSelection("color-impossible", Settings["color-impossible"], Language["Very Hard"], "")
	
	Left:CreateHeader(Language["Combo Points Colors"])
	Left:CreateColorSelection("color-combo-1", Settings["color-combo-1"], Language["Combo Point 1"], "")
	Left:CreateColorSelection("color-combo-2", Settings["color-combo-2"], Language["Combo Point 2"], "")
	Left:CreateColorSelection("color-combo-3", Settings["color-combo-3"], Language["Combo Point 3"], "")
	Left:CreateColorSelection("color-combo-4", Settings["color-combo-4"], Language["Combo Point 4"], "")
	Left:CreateColorSelection("color-combo-5", Settings["color-combo-5"], Language["Combo Point 5"], "")
	
	Right:CreateHeader(Language["Misc Colors"])
	Right:CreateColorSelection("color-tapped", Settings["color-tapped"], Language["Tagged"], "")
	Right:CreateColorSelection("color-disconnected", Settings["color-disconnected"], Language["Disconnected"], "")
	
	Right:CreateHeader(Language["Casting"])
	Right:CreateColorSelection("color-casting-start", Settings["color-casting-start"], Language["Casting"], "")
	Right:CreateColorSelection("color-casting-stopped", Settings["color-casting-stopped"], Language["Stopped"], "")
	Right:CreateColorSelection("color-casting-interrupted", Settings["color-casting-interrupted"], Language["Interrupted"], "")
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	vUI:UpdateClassColors()
	vUI:UpdateReactionColors()
	vUI:UpdateZoneColors()
	vUI:UpdatePowerColors()
	vUI:UpdateComboColors()
	vUI:UpdateDebuffColors()
	vUI:UpdateHappinessColors()
	vUI:UpdateClassificationColors()
end)