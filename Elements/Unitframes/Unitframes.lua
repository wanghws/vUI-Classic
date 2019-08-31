local addon, ns = ...
local vUI, GUI, Language, Media, Settings = ns:get()

local select = select
local format = string.format
local match = string.match
local floor = math.floor
local sub = string.sub
local find = string.find
local UnitName = UnitName
local UnitPower = UnitPower
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local DebuffTypeColor = DebuffTypeColor
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitReaction = UnitReaction
local GetPetHappiness = GetPetHappiness
local IsResting = IsResting
local GetQuestGreenRange = GetQuestGreenRange

local LCMH = LibStub("LibClassicMobHealth-1.0")

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

vUI.UnitFrames = {}

local HappinessLevels = {
	[1] = Language["Unhappy"],
	[2] = Language["Content"],
	[3] = Language["Happy"]
}

local Classes = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	["worldboss"] = Language["Boss"],
}

local ShortClasses = {
	["rare"] = Language[" R"],
	["elite"] = Language["+"],
	["rareelite"] = Language[" R+"],
	["worldboss"] = Language[" B"],
}

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

-- Tags
Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return Language["Dead"]
	elseif UnitIsGhost(unit) then
		return Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return Language["Offline"]
	end
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["Level"] = function(unit)
	return UnitLevel(unit)
end

Events["LevelPlus"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["LevelPlus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if (Class == "worldboss") then
		return "Boss"
	else
		local Plus = Methods["Plus"](unit)
		local Level = Methods["Level"](unit)
		
		if Plus then
			return Level .. Plus
		else
			return Level
		end
	end
end

Events["Classification"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["Classification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if Classes[Class] then
		return Classes[Class]
	end
end

Events["ShortClassification"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["ShortClassification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Plus"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["Plus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Resting"] = "PLAYER_UPDATE_RESTING"
Methods["Resting"] = function(unit)
	if (unit == "player" and IsResting()) then
		return "zZz"
	end
end

Events["Health"] = "UNIT_HEALTH_FREQUENT"
Methods["Health"] = function(unit)
	return vUI:ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthPercent"] = function(unit)
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthPercent"] = function(unit)
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	if (Max == 0) then
		return 0
	else
		return floor(Current / Max * 100 + 0.5)
	end
end

Events["HealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION "
Methods["HealthValues"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFD64545" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	end
	
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
end

Events["ColoredHealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION "
Methods["ColoredHealthValues"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"]
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"]
	end
	
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.18, 0.8, 0.443)) .. vUI:ShortValue(Current) .. " |cFFFEFEFE/|cFF2DCC70 " .. vUI:ShortValue(Max)
end

Events["PartyInfo"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION UNIT_FLAGS"
Methods["PartyInfo"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"]
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"]
	end
	
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	local Color = Methods["HealthColor"](unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	if (Max == 0) then
		return Color .. "0|r"
	else
		return Color .. floor(Current / Max * 100 + 0.5) .. "|r"
	end
end

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthColor"] = function(unit)
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	if (Current and Max) then
		return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return vUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["PowerColor"] = "UNIT_POWER_FREQUENT"
Methods["PowerColor"] = function(unit)
	
end

Events["Name4"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name4"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 4)
	end
end

Events["Name5"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 5)
	end
end

Events["Name8"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 8)
	end
end

Events["Name10"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 10)
	end
end

Events["Name14"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 14)
	end
end

Events["Name15"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 15)
	end
end

Events["Name20"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 20)
	end
end

Events["NameColor"] = "UNIT_NAME_UPDATE"
Methods["NameColor"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		
		if Class then
			local Color = vUI.ClassColors[Class]
			
			if Color then
				return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			local Color = vUI.ReactionColors[Reaction]
			
			if Color then
				return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

Events["Reaction"] = "UNIT_NAME_UPDATE"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = vUI.ReactionColors[Reaction]
		
		if Color then
			return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["LevelColor"] = function(unit)
	return vUI:UnitDifficultyColor(unit)
end

Events["PetColor"] = "UNIT_HAPPINESS UNIT_LEVEL PLAYER_LEVEL_UP" -- UNIT_HAPPINESS
Methods["PetColor"] = function(unit)
	if (vUI.UserClass == "HUNTER") then
		return Methods["HappinessColor"](unit)
	else
		return Methods["Reaction"](unit)
	end
end

Events["PetHappiness"] = "UNIT_HAPPINESS PLAYER_ENTERING_WORLD"
Methods["PetHappiness"] = function(unit)
	if (unit == "pet") then
		local Happiness = GetPetHappiness()
		
		if Happiness then
			return HappinessLevels[Happiness]
		end
	end
end

Events["HappinessColor"] = "UNIT_HAPPINESS PLAYER_ENTERING_WORLD"
Methods["HappinessColor"] = function(unit)
	if (unit == "pet") then
		local Happiness = GetPetHappiness()
		
		if Happiness then
			local Color = vUI.HappinessColors[Happiness]
			
			if Color then
				return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

local StyleNamePlate = function(self, unit)
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self:SetPoint("CENTER", 0, 0)
	self:SetScale(Settings["ui-scale"])
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = Health:CreateTexture(nil, "BACKGROUND")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("RIGHT", Health, "LEFT", -5, 0)
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	TopLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	TopLeft:SetScaledPoint("LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local Top = Health:CreateFontString(nil, "OVERLAY")
	Top:SetFontInfo(Settings["ui-widget-font"], 12)
	Top:SetScaledPoint("CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	TopRight:SetFontInfo(Settings["ui-widget-font"], 12)
	TopRight:SetScaledPoint("RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	BottomRight:SetFontInfo(Settings["ui-widget-font"], 12)
	BottomRight:SetScaledPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	BottomLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	BottomLeft:SetScaledPoint("LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["nameplates-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(TopLeft, "[Name15]")
	else
		Health.colorHealth = true
		
		self:Tag(TopLeft, Settings["nameplates-topleft-text"])
	end
	
	self:Tag(TopRight, Settings["nameplates-topright-text"])
	self:Tag(BottomRight, Settings["nameplates-bottomright-text"])
	self:Tag(BottomLeft, Settings["nameplates-bottomleft-text"])
	
	self.Health = Health
	self.TopLeft = TopLeft
	self.Top = Top
	self.TopRight = TopRight
	self.BottomRight = BottomRight
	self.Health.bg = HealthBG
	self.RaidTargetIndicator = RaidTargetIndicator
end

local StylePlayer = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(28)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Media:GetTexture("Leader"))
    Leader:SetVertexColorHex("FFEB3B")
    Leader:Hide()
	
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetScaledPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-player-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(15)
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	PowerRight:SetFontInfo(Settings["ui-widget-font"], 12)
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.Smooth = true
	
	if Settings["unitframes-player-cc-health"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetScaledSize(250, 20)
    Castbar:SetScaledPoint("BOTTOM", UIParent, 0, Settings["unitframes-player-castbar-y"])
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
    Castbar:SetStatusBarColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
    CastbarBG:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], 12)
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], 12)
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(20, 20)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -3, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    -- Add Shield
    local Shield = Castbar:CreateTexture(nil, "OVERLAY")
    Shield:SetScaledSize(20, 20)
    Shield:SetScaledPoint("CENTER", Castbar)
	
    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
	SafeZone:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
	
    -- Register it with oUF
    --Castbar.bg = Background
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.Shield = Shield
    Castbar.SafeZone = SafeZone
    Castbar.showTradeSkills = true
	
	if (vUI.UserClass == "SHAMAN") then
		local Totems = {}
		
		for i = 1, 5 do
			local Totem = CreateFrame("Button", nil, self)
			Totem:SetSize(32, 32)
			Totem:SetPoint("TOPLEFT", self, "BOTTOMLEFT", i * Totem:GetWidth(), 0)
			
			local Icon = Totem:CreateTexture(nil, "OVERLAY")
			Icon:SetAllPoints()
			Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			
			local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
			Cooldown:SetAllPoints()
			
			Totem.Icon = Icon
			Totem.Cooldown = Cooldown
			
			Totems[i] = Totem
		end
		
		self.Totems = Totems
	elseif (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
		local ComboPoints = CreateFrame("Frame", nil, self)
		ComboPoints:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		ComboPoints:SetScaledSize(230, 10)
		ComboPoints:SetBackdrop(vUI.Backdrop)
		ComboPoints:SetBackdropColor(0, 0, 0)
		ComboPoints:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (230 / 5) - 2
		local Color
		
		for i = 1, 5 do
			Color = vUI.ComboPoints[i]
			
			ComboPoints[i] = CreateFrame("StatusBar", nil, ComboPoints)
			ComboPoints[i]:SetScaledSize(Width + 1, 8)
			ComboPoints[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			ComboPoints[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			ComboPoints[i]:SetAlpha(0.2)
			
			if (i == 1) then
				ComboPoints[i]:SetScaledPoint("LEFT", ComboPoints, 1, 0)
				ComboPoints[i]:SetScaledWidth(Width)
			else
				ComboPoints[i]:SetScaledPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
			end
		end
		
		self.ComboPoints = ComboPoints
	end
	
	-- Tags
	if Settings["unitframes-player-show-name"] then
		if Settings["unitframes-player-cc-health"] then
			self:Tag(HealthLeft, "[Name15]")
		else
			self:Tag(HealthLeft, "[Name15]")
		end
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[Power]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.Combat = Combat
	self.Castbar = Castbar
	--self.RaidTargetIndicator = RaidTarget
	self.LeaderIndicator = Leader
	
	--self:UpdateTags()
end

local PostCreateIcon = function(unit, button)
	button:SetBackdrop(vUI.Backdrop)
	button:SetBackdropColor(0, 0, 0)
	button:SetFrameLevel(6)
	
	--[[button.remaining = button:CreateFontString(nil, "OVERLAY")
	button.remaining:SetFont(Font, 12, "OUTLINE")
	button.remaining:SetScaledPoint("TOPLEFT", 2, -1)
	button.remaining:SetJustifyH("LEFT")
	]]
	--button.cd.noOCC = true
	--button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetScaledPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.cd:SetScaledPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	--button.cd:SetHideCountdownNumbers(true)
	
	button.icon:SetScaledPoint("TOPLEFT", 1, -1)
	button.icon:SetScaledPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetScaledPoint("BOTTOMRIGHT", 2, 2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFontInfo(Settings["ui-widget-font"], 12)
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.overlay:SetParent(button.overlayFrame)
	button.count:SetParent(button.overlayFrame)
	--button.remaining:SetParent(button.overlayFrame)
end

local StyleTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(28)
	Health:SetFrameLevel(5)
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus] [NameColor][Name15]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus] [NameColor][Name15]")
		--self:Tag(HealthLeft, "[Name15]")
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(15)
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	PowerRight:SetFontInfo(Settings["ui-widget-font"], 12)
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	if Settings["unitframes-target-cc-health"] then
		Power.colorPower = true
	else
		Power.colorClass = true
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	
	Buffs:SetScaledSize(230, 30)
	Buffs:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
	Buffs.size = 30
	Buffs.num = 8
	Buffs.spacing = -1
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-y"] = "UP"
	Buffs["growth-x"] = "RIGHT"
	Buffs.PostCreateIcon = PostCreateIcon
	--Buffs.PostUpdateIcon = vUI_UF.PostUpdateAura
	
	Debuffs:SetScaledSize(230, 30)
	Debuffs:SetScaledPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 29)
	Debuffs.size = 30
	Debuffs.num = 8
	Debuffs.spacing = -1
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-y"] = "UP"
	Debuffs["growth-x"] = "LEFT"
	Debuffs.PostCreateIcon = PostCreateIcon
	--Debuffs.PostUpdateIcon = vUI_UF.PostUpdateAura
	Debuffs.onlyShowPlayer = true
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetScaledSize(250, 20)
    Castbar:SetScaledPoint("BOTTOM", UIParent, 0, Settings["unitframes-target-castbar-y"])
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
    Castbar:SetStatusBarColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
    CastbarBG:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], 12)
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], 12)
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(20, 20)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -3, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    --[[ Add Shield
    local Shield = Castbar:CreateTexture(nil, "OVERLAY")
    Shield:SetScaledSize(20, 20)
    Shield:SetScaledPoint("CENTER", Castbar)]]
	
    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
	SafeZone:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
	
    --Castbar.bg = Background
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
	--Castbar.Shield = Shield
    Castbar.SafeZone = SafeZone
    Castbar.showTradeSkills = true
	
	-- Combat
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
	-- Tags
	self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[Power]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.Combat = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	self.RaidTargetIndicator = RaidTarget
end

local StyleTargetTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
		Health.colorClassPet = true
		
		self:Tag(HealthLeft, "[Name10]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[NameColor][Name10]")
		--self:Tag(HealthLeft, "[Name10]")
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.RaidTargetIndicator = RaidTargetIndicator
end

local StylePet = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	self:Tag(HealthLeft, "[PetColor][Name10]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
end

local StyleParty = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(29)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = false
	Health.colorHealth = true
	Health.Smooth = true
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(6)
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-color"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-color"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorClass = true
	
	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetScaledPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Media:GetTexture("Leader"))
    Leader:SetVertexColorHex("FFEB3B")
    Leader:Hide()
	
	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, 'OVERLAY')
    ReadyCheck:SetScaledSize(16, 16)
    ReadyCheck:SetScaledPoint("CENTER", Health, 0, 0)
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	-- Tags
	self:Tag(HealthLeft, "[LevelColor][Level] [NameColor][Name10]")
	self:Tag(HealthRight, "[PartyInfo]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Leader = Leader
	self.ReadyCheck = ReadyCheck
	self.LeaderIndicator = Leader
	self.ReadyCheckIndicator = ReadyCheck
	self.RaidTargetIndicator = RaidTarget
end

local StylePartyPet = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = false
	Health.colorHealth = true
	Health.Smooth = true
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	-- Tags
	self:Tag(HealthLeft, "[LevelColor][Level] [NameColor][Name10]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.RaidTargetIndicator = RaidTarget
end

local StyleRaid = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	self:Tag(HealthLeft, "[NameColor][Name5]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
end

local PartyAttributes = function()
	return
	"vUI Party", nil, "custom [@raid6,exists] hide;show",
	"initial-width", vUI.GetScale(160),
	"initial-height", vUI.GetScale(38),
	"showParty", true,
	"showRaid", false,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", vUI.GetScale(2),
	"yOffset", vUI.GetScale(-2),
	"point", "TOP",
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", "GROUP",
	"maxColumns", 8,
	"unitsPerColumn", 5,
	"columnSpacing", vUI.GetScale(3),
	"columnAnchorPoint", "TOP",
	"oUF-initialConfigFunction", [[
		local Header = self:GetParent()
		
		self:SetWidth(Header:GetAttribute("initial-width"))
		self:SetHeight(Header:GetAttribute("initial-height"))
	]]
end

local PartyPetAttributes = function()
	return
	"vUI Party Pets", "SecureGroupPetHeaderTemplate", "custom [@raid6,exists] hide;show",
	"initial-width", vUI.GetScale(160),
	"initial-height", vUI.GetScale(22),
	"showParty", true,
	"showRaid", false,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", vUI.GetScale(2),
	"yOffset", vUI.GetScale(-2),
	"point", "TOP",
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", "GROUP",
	"maxColumns", 8,
	"unitsPerColumn", 5,
	"columnSpacing", vUI.GetScale(3),
	"columnAnchorPoint", "TOP",
	"oUF-initialConfigFunction", [[
		local Header = self:GetParent()
		
		self:SetWidth(Header:GetAttribute("initial-width"))
		self:SetHeight(Header:GetAttribute("initial-height"))
	]]
end

local RaidAttributes = function()
	return
	"vUI Raid", nil, "custom [@raid6,exists] show;hide",
	"initial-width", vUI.GetScale(76),
	"initial-height", vUI.GetScale(22),
	"showParty", false,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", vUI.GetScale(3),
	"yOffset", vUI.GetScale(-3),
	"point", "LEFT",
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", "GROUP",
	"maxColumns", 8,
	"unitsPerColumn", 5,
	"columnSpacing", vUI.GetScale(3),
	"columnAnchorPoint", "TOP",
	"oUF-initialConfigFunction", [[
		local Header = self:GetParent()
		
		self:SetWidth(Header:GetAttribute("initial-width"))
		self:SetHeight(Header:GetAttribute("initial-height"))
	]]
end

local Style = function(self, unit)
	if (unit == "player") then
		StylePlayer(self, unit)
	elseif (unit == "target") then
		StyleTarget(self, unit)
	elseif (unit == "targettarget") then
		StyleTargetTarget(self, unit)
	elseif (unit == "pet") then
		StylePet(self, unit)
	elseif find(unit, "partypet") then
		StylePartyPet(self, unit)
	elseif find(unit, "party") then
		StyleParty(self, unit)
	elseif find(unit, "raid") then
		StyleRaid(self, unit)
	elseif (match(unit, "nameplate") and Settings["nameplates-enable"]) then
		StyleNamePlate(self, unit)
	end
end

oUF:RegisterStyle("vUI", Style)

local PlateCVars = {
    nameplateGlobalScale = 1,
    NamePlateHorizontalScale = 1,
    NamePlateVerticalScale = 1,
    nameplateLargerScale = 1,
    nameplateMaxScale = 1,
    nameplateMinScale = 1,
    nameplateSelectedScale = 1,
    nameplateSelfScale = 1,
}

local Move = vUI:GetModule("Move")

local UF = vUI:NewModule("Unit Frames")

function UF:Load()
	if (not Settings["unitframes-enable"]) then
		return
	end
	
	local Player = oUF:Spawn("player", "vUI Player")
	Player:SetScaledSize(230, 46)
	Player:SetScaledPoint("RIGHT", UIParent, "CENTER", -68, -304)
	
	local Target = oUF:Spawn("target", "vUI Target")
	Target:SetScaledSize(230, 46)
	Target:SetScaledPoint("LEFT", UIParent, "CENTER", 68, -304)
	
	local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
	TargetTarget:SetScaledSize(110, 26)
	TargetTarget:SetScaledPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -3)
	
	local Pet = oUF:Spawn("pet", "vUI Pet")
	Pet:SetScaledSize(110, 26)
	Pet:SetScaledPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -3)
	
	Player:UpdateAllElements("ForceUpdate")
	Target:UpdateAllElements("ForceUpdate")
	TargetTarget:UpdateAllElements("ForceUpdate")
	Pet:UpdateAllElements("ForceUpdate")
	
	vUI.UnitFrames["player"] = Player
	vUI.UnitFrames["target"] = Target
	vUI.UnitFrames["targettarget"] = TargetTarget
	vUI.UnitFrames["pet"] = Pet
	
	if Settings["nameplates-enable"] then
		oUF:SpawnNamePlates(nil, nil, PlateCVars)
	end
	
	local Party = oUF:SpawnHeader(PartyAttributes())
	Party:SetScaledPoint("LEFT", UIParent, 10, 0)
	
	local PartyPet = oUF:SpawnHeader(PartyPetAttributes())
	PartyPet:SetScaledPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, -2)
	
	local Raid = oUF:SpawnHeader(RaidAttributes())
	Raid:SetScaledPoint("TOPLEFT", UIParent, 10, -10)
	
	Move:Add(Player)
	Move:Add(Target)
	Move:Add(TargetTarget)
	Move:Add(Pet)
	Move:Add(Party)
	Move:Add(PartyPet)
	Move:Add(Raid)
end

local TogglePlayerName = function(value)
	if value then
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "[Name15]")
		oUF_vUIPlayer:UpdateTags()
	else
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "")
		oUF_vUIPlayer:UpdateTags()
	end
end

local UpdatePlayerCastBarY = function(value)
	oUF_vUIPlayer.Castbar:SetScaledPoint("BOTTOM", UIParent, 0, value)
end

local UpdateTargetCastBarY = function(value)
	oUF_vUITarget.Castbar:SetScaledPoint("BOTTOM", UIParent, 0, value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], ""):RequiresReload(true)
	
	Left:CreateHeader(Language["Cast Bars"])
	Left:CreateSlider("unitframes-player-castbar-y", Settings["unitframes-player-castbar-y"], 40, 400, 1, Language["Player Cast Bar Y-Offset"], "", UpdatePlayerCastBarY)
	Left:CreateSlider("unitframes-target-castbar-y", Settings["unitframes-target-castbar-y"], 40, 400, 1, Language["Target Cast Bar Y-Offset"], "", UpdateTargetCastBarY)
	
	--[[Left:CreateHeader(Language["Player"])
	Left:CreateCheckbox("unitframes-player-show-name", Settings["unitframes-player-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Left:CreateCheckbox("unitframes-player-cc-health", Settings["unitframes-player-cc-health"], Language["Dark Scheme"], "")
	
	Right:CreateHeader(Language["Target"])
	Right:CreateCheckbox("unitframes-target-show-name", Settings["unitframes-target-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Right:CreateCheckbox("unitframes-target-cc-health", Settings["unitframes-target-cc-health"], Language["Dark Scheme"], "")
	]]
	Left:CreateFooter()
	Right:CreateFooter()
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Name Plates"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates Module"], ""):RequiresReload(true)
	
	Right:CreateHeader(Language["Sizes"])
	Right:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "")
	Right:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "")
	
	Right:CreateHeader(Language["Information"])
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "").Box:Save()
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "").Box:Save()
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "").Box:Save()
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "").Box:Save()
	
	Left:CreateFooter()
	Right:CreateFooter()
end)