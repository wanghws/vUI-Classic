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
local LCD = LibStub("LibClassicDurations")

LCD:Register("vUI")

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
Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return Language["Dead"]
	elseif UnitIsGhost(unit) then
		return Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return Language["Offline"]
	end
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Level"] = function(unit)
	local Level = UnitLevel(unit)
	
	if (Level == -1) then
		return "??"
	else
		return Level
	end
end

Events["LevelPlus"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
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

Events["Classification"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Classification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if Classes[Class] then
		return Classes[Class]
	end
end

Events["ShortClassification"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["ShortClassification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Plus"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Plus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Resting"] = "PLAYER_UPDATE_RESTING PLAYER_ENTERING_WORLD"
Methods["Resting"] = function(unit)
	if (unit == "player" and IsResting()) then
		return "zZz"
	end
end

Events["Health"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Health"] = function(unit)
	return vUI:ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["HealthPercent"] = function(unit)
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
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

Events["HealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION PLAYER_ENTERING_WORLD"
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

Events["PartyInfo"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION UNIT_FLAGS PLAYER_ENTERING_WORLD"
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

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["HealthColor"] = function(unit)
	local Current, Max, Found = LCMH:GetUnitHealth(unit)
	
	if (not Found) then
		Current = UnitHealth(unit)
		Max = UnitHealthMax(unit)
	end
	
	if (Current and Max > 0) then
		return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
	else
		return "|cFF" .. vUI:RGBToHex(0.18, 0.8, 0.443)
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return vUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerValues"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerValues"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)
	
	if (Max ~= 0) then
		return Current .. " / " .. Max
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["PowerColor"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerColor"] = function(unit)
	
end

Events["Name4"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name4"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 4)
	end
end

Events["Name5"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 5)
	end
end

Events["Name8"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 8)
	end
end

Events["Name10"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 10)
	end
end

Events["Name14"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 14)
	end
end

Events["Name15"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 15)
	end
end

Events["Name20"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 20)
	end
end

Events["Name30"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name30"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 30)
	end
end

Events["NameColor"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
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

Events["Reaction"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = vUI.ReactionColors[Reaction]
		
		if Color then
			return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["LevelColor"] = function(unit)
	return vUI:UnitDifficultyColor(unit)
end

Events["PetColor"] = "UNIT_HAPPINESS UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD UNIT_PET" -- UNIT_HAPPINESS
Methods["PetColor"] = function(unit)
	if (vUI.UserClass == "HUNTER") then
		return Methods["HappinessColor"](unit)
	else
		return Methods["Reaction"](unit)
	end
end

Events["PetHappiness"] = "UNIT_HAPPINESS PLAYER_ENTERING_WORLD UNIT_PET"
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

local Name, Duration, Expiration, Caster, SpellID, _
local DurationNew, ExpirationNew, Enabled
local UnitAura = UnitAura
local GetTime = GetTime

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela
	
	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())
		
		if (Now > 0) then
			self.Time:SetText(vUI:FormatTime(Now))
		else
			self:SetScript("OnUpdate", nil)
		end
		
		if (Now <= 0) then
			self:SetScript("OnUpdate", nil)
			self.Time:Hide()
		end
		
		self.ela = 0
	end
end

local PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
	local Name, _, _, _, Duration, Expiration, Caster, _, _, SpellID = UnitAura(unit, index, button.filter)
	local DurationNew, ExpirationNew = LCD:GetAuraDurationByUnit(unit, SpellID, Caster, Name)
	
	if (Duration == 0 and DurationNew) then
		Duration = DurationNew
		Expiration = ExpirationNew
	end
	
	button.Duration = Duration
	button.Expiration = Expiration
	
	if button.cd then
		if (Duration and Duration > 0) then
			button.cd:SetCooldown(Expiration - Duration, Duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end
	
	if (vUI.DebuffColors[debuffType] and button.filter == "HARMFUL") then
		button:SetBackdropColor(unpack(vUI.DebuffColors[debuffType]))
	else
		button:SetBackdropColor(unpack(vUI.DebuffColors["none"]))
	end
	
	if (Expiration and Expiration ~= 0) then
		button:SetScript("OnUpdate", AuraOnUpdate)
		button.Time:Show()
	else
		button.Time:Hide()
	end
end

local PostCreateIcon = function(unit, button)
	button:SetBackdrop(vUI.Backdrop)
	button:SetBackdropColor(0, 0, 0)
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetScaledPoint("TOPLEFT", button, 1, -1)
	button.cd:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	
	button.icon:SetScaledPoint("TOPLEFT", 1, -1)
	button.icon:SetScaledPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetScaledPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	button.Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	button.Time:SetScaledPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.overlay:SetParent(button.overlayFrame)
	button.count:SetParent(button.overlayFrame)
	button.Time:SetParent(button.overlayFrame)
	
	button.ela = 0
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
	Health:EnableMouse(false)
	
	local HealthBG = Health:CreateTexture(nil, "BACKGROUND")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("LEFT", Health, "RIGHT", 5, 0)
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	TopLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	TopLeft:SetScaledPoint("LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local Top = Health:CreateFontString(nil, "OVERLAY")
	Top:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Top:SetScaledPoint("CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	TopRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	TopRight:SetScaledPoint("RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	BottomRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	BottomRight:SetScaledPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	BottomLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	BottomLeft:SetScaledPoint("LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["nameplates-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
	else
		Health.colorHealth = true
	end
	
	-- Debuffs
	if Settings["nameplates-display-debuffs"] then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetScaledSize(Settings["nameplates-width"], 26)
		Debuffs:SetScaledPoint("BOTTOM", Health, "TOP", 0, 18)
		Debuffs.size = 26
		Debuffs.spacing = 2
		Debuffs.num = 5
		Debuffs.numRow = 4
		Debuffs.numDebuffs = 16
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs.PostCreateIcon = PostCreateIcon
		Debuffs.PostUpdateIcon = PostUpdateIcon
		Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
		Debuffs.disableMouse = true
		
		self.Debuffs = Debuffs
	end
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetScaledSize(Settings["nameplates-width"] - 2, 12)
	Castbar:SetScaledPoint("TOP", Health, "BOTTOM", 0, -4)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Time:SetScaledPoint("RIGHT", Castbar, "BOTTOMRIGHT", -4, -3)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetScaledPoint("LEFT", Castbar, "BOTTOMLEFT", 4, -3)
	Text:SetScaledWidth(Settings["nameplates-width"] / 2 + 4)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(Settings["nameplates-height"] + 12 + 2, Settings["nameplates-height"] + 12 + 2)
    Icon:SetScaledPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	
	self:Tag(TopLeft, Settings["nameplates-topleft-text"])
	self:Tag(TopRight, Settings["nameplates-topright-text"])
	self:Tag(BottomRight, Settings["nameplates-bottomright-text"])
	self:Tag(BottomLeft, Settings["nameplates-bottomleft-text"])
	
	self.Health = Health
	self.TopLeft = TopLeft
	self.Top = Top
	self.TopRight = TopRight
	self.BottomRight = BottomRight
	self.Health.bg = HealthBG
	self.Castbar = Castbar
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
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
	
	if Settings["unitframes-class-color"] then
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
	PowerRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetScaledSize(238, 28)
	Buffs:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 16
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(238, 28)
	Debuffs:SetScaledWidth(238)
	--Debuffs:SetScaledPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	Debuffs:SetScaledPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Casting Bar", self)
    Castbar:SetScaledSize(250, 22)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(22, 22)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
	SafeZone:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
	
    -- Register it with oUF
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.SafeZone = SafeZone
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	
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
		self:Tag(HealthLeft, "[Name15]")
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[PowerValues]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.RaidTargetIndicator = RaidTarget
	self.LeaderIndicator = Leader
	
	--self:UpdateTags()
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
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
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus]|r [Name30]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus] [NameColor][Name30]")
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
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	PowerRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
	else
		Power.colorClass = true
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetScaledSize(238, 28)
	Buffs:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 16
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(238, 28)
	Debuffs:SetScaledWidth(238)
	--Debuffs:SetScaledPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	Debuffs:SetScaledPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Target Casting Bar", self)
    Castbar:SetScaledSize(250, 22)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(22, 22)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	
	-- Tags
	self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[PowerValues]")
	
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
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
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
		Health.colorClassPet = true
		
		self:Tag(HealthLeft, "[Name10]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[NameColor][Name10]")
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		self:Tag(HealthLeft, "[Name10]")
	else
		Health.colorHealth = true
		self:Tag(HealthLeft, "[PetColor][Name10]")
	end
	
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(6)
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
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
	
	if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[LevelColor][Level]|r [Name10]")
	else
		self:Tag(HealthLeft, "[LevelColor][Level] [NameColor][Name10]")
	end
	
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Health.colorClass = true
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	-- Tags
	if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[LevelColor][Level]|r [Name10]")
	else
		self:Tag(HealthLeft, "[LevelColor][Level] [Reaction][Name10]")
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
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(23)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorClass = true
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(2)
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-color"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-color"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
	-- Tags
	if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[Name5]")
	else
		self:Tag(HealthLeft, "[NameColor][Name5]")
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
	self.Power = Power
	self.Power.bg = PowerBG
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
	elseif (find(unit, "raid") and Settings["unitframes-enable-raid"]) then
		StyleRaid(self, unit)
	elseif (find(unit, "partypet") and Settings["unitframes-enable-party"] and Settings["unitframes-enable-party-pets"]) then
		StylePartyPet(self, unit)
	elseif (find(unit, "party") and not find(unit, "pet") and Settings["unitframes-enable-party"]) then
		StyleParty(self, unit)
	elseif (match(unit, "nameplate") and Settings["nameplates-enable"]) then
		StyleNamePlate(self, unit)
	end
end

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

oUF:RegisterStyle("vUI", Style)

UF:RegisterEvent("PLAYER_LOGIN")
UF:SetScript("OnEvent", function(self, event)
	if (not Settings["unitframes-enable"]) then
		return
	end
	
	local Player = oUF:Spawn("player", "vUI Player")
	Player:SetScaledSize(238, 46)
	Player:SetScaledPoint("RIGHT", UIParent, "CENTER", -68, -304)
	
	local Target = oUF:Spawn("target", "vUI Target")
	Target:SetScaledSize(238, 46)
	Target:SetScaledPoint("LEFT", UIParent, "CENTER", 68, -304)
	
	local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
	TargetTarget:SetScaledSize(110, 26)
	TargetTarget:SetScaledPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -3)
	
	local Pet = oUF:Spawn("pet", "vUI Pet")
	Pet:SetScaledSize(110, 26)
	Pet:SetScaledPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -3)
	
	local Party = oUF:SpawnHeader("vUI Party", nil, "party,solo",
		"initial-width", 160,
		"initial-height", 38,
		"showSolo", false,
		"showPlayer", true,
		"showParty", true,
		"showRaid", false,
		"xoffset", 2,
		"yOffset", -2,
		"oUF-initialConfigFunction", [[
			local Header = self:GetParent()
			
			self:SetWidth(Header:GetAttribute("initial-width"))
			self:SetHeight(Header:GetAttribute("initial-height"))
		]]
	)
	
	local PartyPet = oUF:SpawnHeader("vUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
		"initial-width", 160,
		"initial-height", 22,
		"showSolo", false,
		"showPlayer", true,
		"showParty", true,
		"showRaid", false,
		"xoffset", 2,
		"yOffset", -2,
		"oUF-initialConfigFunction", [[
			local Header = self:GetParent()
			
			self:SetWidth(Header:GetAttribute("initial-width"))
			self:SetHeight(Header:GetAttribute("initial-height"))
		]]
	)
	
	local Raid = oUF:SpawnHeader("vUI Raid", nil, "raid,solo",
		"initial-width", 90,
		"initial-height", 28,
		"showSolo", false,
		"showPlayer", true,
		"showParty", false,
		"showRaid", true,
		"xoffset", 2,
		"yOffset", -2,
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", ceil(40 / 10),
		"unitsPerColumn", 10,
		"columnSpacing", 2,
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", [[
			local Header = self:GetParent()
			
			self:SetWidth(Header:GetAttribute("initial-width"))
			self:SetHeight(Header:GetAttribute("initial-height"))
		]]
	)
	
	Player.Castbar:SetScaledPoint("BOTTOM", vUIBottomActionBarsPanel, "TOP", 0, 5)
	Target.Castbar:SetScaledPoint("BOTTOM", Player.Castbar, "TOP", 0, 4)
	
	Move:Add(Player.Castbar, 2)
	Move:Add(Target.Castbar, 2)
	
	self.RaidAnchor = CreateFrame("Frame", "vUI Raid Anchor", UIParent)
	self.RaidAnchor:SetScaledSize((4 * 90 + 4 * 2), (28 * 10) + (2 * (10 - 1)))
	self.RaidAnchor:SetScaledPoint("TOPLEFT", UIParent, 10, -10)
	
	Party:SetScaledPoint("LEFT", UIParent, 10, 0)
	PartyPet:SetScaledPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, -2)
	Raid:SetScaledPoint("TOPLEFT", self.RaidAnchor, 0, 0)
	
	vUI.UnitFrames["player"] = Player
	vUI.UnitFrames["target"] = Target
	vUI.UnitFrames["targettarget"] = TargetTarget
	vUI.UnitFrames["pet"] = Pet
	
	if Settings["nameplates-enable"] then
		oUF:SpawnNamePlates(nil, nil, PlateCVars)
	end
	
	if Settings["unitframes-enable-raid"] then
		local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		Hider:Hide()
		
		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:SetParent(Hider)
		
		--CompactRaidFrameManager:UnregisterAllEvents()
		--CompactRaidFrameManager:SetParent(Hider)
	end
	
	Move:Add(Player)
	Move:Add(Target)
	Move:Add(TargetTarget)
	Move:Add(Pet)
	--Move:Add(Party)
	--Move:Add(PartyPet)
	--Move:Add(Raid)
	Move:Add(self.RaidAnchor)
end)

local TogglePlayerName = function(value)
	if value then
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "[Name15]")
		oUF_vUIPlayer:UpdateTags()
	else
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "")
		oUF_vUIPlayer:UpdateTags()
	end
end

local UpdateOnlyPlayerDebuffs = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Debuffs.onlyShowPlayer = value
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], "Enable the vUI unit frames module", ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-party", Settings["unitframes-enable-party"], Language["Enable Party Frames"], "Enable the vUI party frames module", ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-party-pets", Settings["unitframes-enable-party-pets"], Language["Enable Party Pet Frames"], "Enable the vUI party pet frames module", ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-raid", Settings["unitframes-enable-raid"], Language["Enable Raid Frames"], "Enable the vUI raid frames module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Settings"])
	Left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], "If enabled, only your own debuffs will be displayed", UpdateOnlyPlayerDebuffs)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateSwitch("unitframes-class-color", Settings["unitframes-class-color"], Language["Use Class/Reaction Colors"], "Color unit frame health by class or reaction", ReloadUI):RequiresReload(true)
	
	--[[Left:CreateHeader(Language["Player"])
	Left:CreateSwitch("unitframes-player-show-name", Settings["unitframes-player-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Left:CreateSwitch("unitframes-player-cc-health", Settings["unitframes-player-cc-health"], Language["Dark Scheme"], "")
	
	Right:CreateHeader(Language["Target"])
	Right:CreateSwitch("unitframes-target-show-name", Settings["unitframes-target-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Right:CreateSwitch("unitframes-target-cc-health", Settings["unitframes-target-cc-health"], Language["Dark Scheme"], "")
	]]
	Left:CreateFooter()
	Right:CreateFooter()
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Name Plates"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates Module"], "Enable the vUI name plates module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Debuffs"])
	Left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Name Plates Debuffs"], "Display your debuffs above enemy name plates", ReloadUI):RequiresReload(true)
	Left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], "If enabled, only your own debuffs will be displayed", ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateSwitch("nameplates-class-color", Settings["nameplates-class-color"], Language["Use Class/Reaction Colors"], "Color name plate health by class or reaction", ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Sizes"])
	Right:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates")
	Right:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates")
	
	Right:CreateHeader(Language["Information"])
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "").Box:Save()
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "").Box:Save()
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "").Box:Save()
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "").Box:Save()
	
	Left:CreateFooter()
	Right:CreateFooter()
end)

--[[ /run FakeGroup()
FakeGroup = function()
	local Header = _G["vUI Raid"]
	
	if Header then
		if (Header:GetAttribute("startingIndex") ~= -39) then
			Header:SetAttribute("startingIndex", -39)
		end
		
		for i = 1, select("#", Header:GetChildren()) do
			local Frame = select(i, Header:GetChildren())
			
			Frame.unit = "player"
			UnregisterUnitWatch(Frame)
			RegisterUnitWatch(Frame, true)
			Frame:Show()
		end
	end
end]]