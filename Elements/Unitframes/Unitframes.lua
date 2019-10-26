local addon, ns = ...
local vUI, GUI, Language, Media, Settings = ns:get()

local unpack = unpack
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
local UnitAura = UnitAura
local GetTime = GetTime
local Huge = math.huge

local LCMH = LibStub("LibClassicMobHealth-1.0")
local LCD = LibStub("LibClassicDurations")

LCD:Register("vUI")

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods
local Name, Duration, Expiration, Caster, SpellID, _
local DurationNew, ExpirationNew, Enabled

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

local ComboPointsUpdateShapeshiftForm = function(self, form)
	local Parent = self:GetParent()
	
	Parent.Buffs:ClearAllPoints()
	
	if (form == 3) then
		Parent.Buffs:SetScaledPoint("BOTTOMLEFT", Parent, "TOPLEFT", 0, 2)
	else
		Parent.Buffs:SetScaledPoint("BOTTOMLEFT", Parent, "TOPLEFT", 0, 2)
	end
end

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela
	
	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())
		
		if (Now > 0 and Now ~= Huge) then
			self.Time:SetText(vUI:FormatTime(Now))
		else
			self:SetScript("OnUpdate", nil)
			--self.Time:Hide()
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

local NamePlateCallback = function(self) -- plate, event, unit
	if (not self) then
		return
	end
	
	if Settings["nameplates-display-debuffs"] then
		self:EnableElement("Auras")
	else
		self:DisableElement("Auras")
	end
	
	if self.Debuffs then
		self.Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	end
	
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	
	self.Health.colorTapping = Settings["nameplates-color-by-tapped"]
	self.Health.colorClass = Settings["nameplates-color-by-class"]
	self.Health.colorReaction = Settings["nameplates-color-by-reaction"]
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
	
	Health.Smooth = true
	Health.colorTapping = Settings["nameplates-color-by-tapped"]
	Health.colorDisconnected = true
	Health.colorClass = Settings["nameplates-color-by-class"]
	Health.colorReaction = Settings["nameplates-color-by-reaction"]
	Health.colorHealth = true
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(Settings["nameplates-width"], 26)
	Debuffs:SetScaledPoint("BOTTOM", Health, "TOP", 0, 18)
	Debuffs.size = 26
	Debuffs.spacing = 2
	Debuffs.num = 5
	Debuffs.numRow = 4
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	Debuffs.disableMouse = true
	
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
	self.Debuffs = Debuffs
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
	
	self.AuraParent = self
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(28)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	
	-- Mana regen
	if Settings["unitframes-show-mana-timer"] then
		local ManaTimer = CreateFrame("StatusBar", nil, Power)
		ManaTimer:SetAllPoints(Power)
		ManaTimer:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		ManaTimer:SetStatusBarColor(0, 0, 0, 0)
		ManaTimer:Hide()
		
		ManaTimer.Spark = ManaTimer:CreateTexture(nil, "ARTWORK")
		ManaTimer.Spark:SetScaledSize(3, 15)
		ManaTimer.Spark:SetScaledPoint("LEFT", ManaTimer:GetStatusBarTexture(), "RIGHT", -1, 0)
		ManaTimer.Spark:SetTexture(Media:GetTexture("Blank"))
		ManaTimer.Spark:SetVertexColor(1, 1, 1, 0.2)
		
		ManaTimer.Spark2 = ManaTimer:CreateTexture(nil, "ARTWORK")
		ManaTimer.Spark2:SetScaledSize(1, 15)
		ManaTimer.Spark2:SetScaledPoint("CENTER", ManaTimer.Spark, 0, 0)
		ManaTimer.Spark2:SetTexture(Media:GetTexture("Blank"))
		ManaTimer.Spark2:SetVertexColor(1, 1, 1, 0.8)
		
		self.ManaTimer = ManaTimer
	end
	
	-- Energy ticks
		if Settings["unitframes-show-energy-timer"] then
		local EnergyTick = CreateFrame("StatusBar", nil, Power)
		EnergyTick:SetAllPoints(Power)
		EnergyTick:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		EnergyTick:SetStatusBarColor(0, 0, 0, 0)
		EnergyTick:Hide()
		
		EnergyTick.Spark = EnergyTick:CreateTexture(nil, "ARTWORK")
		EnergyTick.Spark:SetScaledSize(3, 15)
		EnergyTick.Spark:SetScaledPoint("LEFT", EnergyTick:GetStatusBarTexture(), "RIGHT", -1, 0)
		EnergyTick.Spark:SetTexture(Media:GetTexture("Blank"))
		EnergyTick.Spark:SetVertexColor(1, 1, 1, 0.2)
		
		EnergyTick.Spark2 = EnergyTick:CreateTexture(nil, "ARTWORK")
		EnergyTick.Spark2:SetScaledSize(1, 15)
		EnergyTick.Spark2:SetScaledPoint("CENTER", EnergyTick.Spark, 0, 0)
		EnergyTick.Spark2:SetTexture(Media:GetTexture("Blank"))
		EnergyTick.Spark2:SetVertexColor(1, 1, 1, 0.8)
		
		self.EnergyTick = EnergyTick
	end
	
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
	
	--[[ Swing timer
	local swing = CreateFrame("Frame", nil, self)
	
	swing.Twohand = CreateFrame("Statusbar", nil, swing)
	swing.Twohand:SetPoint("TOPLEFT")
	swing.Twohand:SetPoint("BOTTOMRIGHT")
	swing.Twohand:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	swing.Twohand:SetStatusBarColor(0.8, 0.3, 0.3)
	swing.Twohand:SetFrameLevel(20)
	swing.Twohand:SetFrameStrata("LOW")
	swing.Twohand:Hide()
	
	swing.Twohand.Text = swing.Twohand:CreateFontString(nil, "OVERLAY")
	swing.Twohand.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	swing.Twohand.Text:SetScaledPoint("LEFT", swing.Twohand, 3, 0)
	swing.Twohand.Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	swing.Twohand.Text:SetJustifyH("LEFT")
	
	swing.Twohand.Background = swing.Twohand:CreateTexture(nil, "BACKGROUND")
    swing.Twohand.Background:SetScaledPoint("TOPLEFT", swing.Twohand, -1, 1)
    swing.Twohand.Background:SetScaledPoint("BOTTOMRIGHT", swing.Twohand, 1, -1)
    swing.Twohand.Background:SetTexture(Media:GetTexture("Blank"))
    swing.Twohand.Background:SetVertexColor(0, 0, 0)
	
	swing.Mainhand = CreateFrame("Statusbar", nil, swing)
	swing.Mainhand:SetPoint("BOTTOM", Castbar, 0, 0)
	swing.Mainhand:SetScaledSize(250, 16)
	swing.Mainhand:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	swing.Mainhand:SetStatusBarColor(0.8, 0.3, 0.3)
	swing.Mainhand:SetFrameLevel(20)
	swing.Mainhand:SetFrameStrata("LOW")
	swing.Mainhand:Hide()
	
	swing.Mainhand.Text = swing.Mainhand:CreateFontString(nil, "OVERLAY")
	swing.Mainhand.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	swing.Mainhand.Text:SetScaledPoint("LEFT", swing.Mainhand, 3, 0)
	swing.Mainhand.Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	swing.Mainhand.Text:SetJustifyH("LEFT")
	
	swing.Mainhand.Background = swing.Mainhand:CreateTexture(nil, "BACKGROUND")
    swing.Mainhand.Background:SetScaledPoint("TOPLEFT", swing.Mainhand, -1, 1)
    swing.Mainhand.Background:SetScaledPoint("BOTTOMRIGHT", swing.Mainhand, 1, -1)
    swing.Mainhand.Background:SetTexture(Media:GetTexture("Blank"))
    swing.Mainhand.Background:SetVertexColor(0, 0, 0)
	
	swing.Offhand = CreateFrame("Statusbar", nil, swing)
	swing.Offhand:SetPoint("BOTTOM", swing.Mainhand, "TOP", 0, 2)
	swing.Offhand:SetScaledSize(250, 16)
	swing.Offhand:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	swing.Offhand:SetStatusBarColor(0.8, 0.3, 0.3)
	swing.Offhand:SetFrameLevel(20)
	swing.Offhand:SetFrameStrata("LOW")
	swing.Offhand:Hide()
	
	swing.Offhand.Text = swing.Offhand:CreateFontString(nil, "OVERLAY")
	swing.Offhand.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	swing.Offhand.Text:SetScaledPoint("LEFT", swing.Offhand, 3, 0)
	swing.Offhand.Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	swing.Offhand.Text:SetJustifyH("LEFT")
	
	swing.Offhand.Background = swing.Offhand:CreateTexture(nil, "BACKGROUND")
    swing.Offhand.Background:SetScaledPoint("TOPLEFT", swing.Offhand, -1, 1)
    swing.Offhand.Background:SetScaledPoint("BOTTOMRIGHT", swing.Offhand, 1, -1)
    swing.Offhand.Background:SetTexture(Media:GetTexture("Blank"))
    swing.Offhand.Background:SetVertexColor(0, 0, 0)
	
	swing.hideOoc = true
	swing:SetAllPoints(Castbar)
	self.Swing = swing]]
	
	if (vUI.UserClass == "SHAMAN") then
		local Totems = CreateFrame("Frame", self:GetName() .. "Totems", self)
		Totems:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		Totems:SetScaledSize(238, 10)
		Totems:SetBackdrop(vUI.Backdrop)
		Totems:SetBackdropColor(0, 0, 0)
		Totems:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (238 / 4) - 1
		local Color
		
		for i = 1, 4 do
			Color = vUI.Totems[i]
			
			Totems[i] = CreateFrame("StatusBar", self:GetName() .. "Totems".. i, Totems)
			Totems[i]:SetScaledSize(Width, 8)
			Totems[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Totems[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			Totems[i]:SetMinMaxValues(0, 1)
			Totems[i]:SetValue(0)
			
			Totems[i].BG = Totems[i]:CreateTexture(nil, "BORDER")
			Totems[i].BG:SetScaledPoint("TOPLEFT", Totems[i], 0, 0)
			Totems[i].BG:SetScaledPoint("BOTTOMRIGHT", Totems[i], 0, 0)
			Totems[i].BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Totems[i].BG:SetVertexColor(Color[1], Color[2], Color[3])
			Totems[i].BG:SetAlpha(0.2)
			
			if (i == 1) then
				Totems[i]:SetScaledPoint("LEFT", Totems, 1, 0)
			else
				Totems[i]:SetScaledPoint("TOPLEFT", Totems[i-1], "TOPRIGHT", 1, 0)
				Totems[i]:SetScaledWidth(Width - 1)
			end
		end
		
		self.Totems = Totems
		self.AuraParent = Totems
	elseif (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
		local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self)
		ComboPoints:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		ComboPoints:SetScaledSize(238, 10)
		ComboPoints:SetBackdrop(vUI.Backdrop)
		ComboPoints:SetBackdropColor(0, 0, 0)
		ComboPoints:SetBackdropBorderColor(0, 0, 0)
		ComboPoints.UpdateShapeshiftForm = ComboPointsUpdateShapeshiftForm
		
		local Width = (238 / 5)
		local Color
		
		for i = 1, 5 do
			Color = vUI.ComboPoints[i]
			
			ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
			ComboPoints[i]:SetScaledSize(Width, 8)
			ComboPoints[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			ComboPoints[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			ComboPoints[i]:SetAlpha(0.2)
			
			if (i == 1) then
				ComboPoints[i]:SetScaledPoint("LEFT", ComboPoints, 1, 0)
			else
				ComboPoints[i]:SetScaledPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
				ComboPoints[i]:SetScaledWidth(Width - 2)
			end
		end
		
		self.ComboPoints = ComboPoints
		self.AuraParent = ComboPoints
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetScaledSize(238, 28)
	Buffs:SetScaledPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
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
	
	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetScaledSize(16, 16)
	Resurrect:SetScaledPoint("CENTER", Health, 0, 0)
	
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
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.RaidTargetIndicator = RaidTarget
	self.ResurrectIndicator = Resurrect
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	self.HealBar = HealBar
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	self.HealBar = HealBar
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	self.HealBar = HealBar
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	
	-- Debuffs
	if Settings["party-show-debuffs"] then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetScaledSize((31 * 5), 29)
		Debuffs:SetScaledPoint("LEFT", Health, "RIGHT", 2, 0)
		Debuffs.size = 29
		Debuffs.spacing = 2
		Debuffs.num = 5
		Debuffs.numRow = 1
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs.PostCreateIcon = PostCreateIcon
		Debuffs.PostUpdateIcon = PostUpdateIcon
		
		self.Debuffs = Debuffs
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
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetScaledSize(16, 16)
	Resurrect:SetScaledPoint("CENTER", Health, 0, 0)
	
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
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Leader = Leader
	self.ReadyCheck = ReadyCheck
	self.LeaderIndicator = Leader
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	self.HealBar = HealBar
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
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
	
	-- Resurrect
	local ResurrectIndicator = Health:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetScaledSize(16, 16)
	ResurrectIndicator:SetScaledPoint("CENTER", Health, 0, 0)
	
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
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Power = Power
	self.Power.bg = PowerBG
	self.ResurrectIndicator = ResurrectIndicator
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

local UpdateShowPlayerBuffs = function(value)
	if vUI.UnitFrames["player"] then
		if value then
			vUI.UnitFrames["player"]:EnableElement("Auras")
		else
			vUI.UnitFrames["player"]:DisableElement("Auras")
		end
	end
end

local UpdateShowManaTimer = function(value)
	if (not vUI.UnitFrames["player"]) then
		return
	end

	if value then
		vUI.UnitFrames["player"]:EnableElement("ManaRegen")
	else
		vUI.UnitFrames["player"]:DisableElement("ManaRegen")
	end
end

local UpdateShowEnergyTimer = function(value)
	if (not vUI.UnitFrames["player"]) then
		return
	end
	
	if value then
		vUI.UnitFrames["player"]:EnableElement("EnergyTick")
	else
		vUI.UnitFrames["player"]:DisableElement("EnergyTick")
	end
end

local NamePlateCVars = {
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
UF:RegisterEvent("PLAYER_ENTERING_WORLD")
UF:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
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
			oUF:SpawnNamePlates(nil, NamePlateCallback, NamePlateCVars)
		end
		
		if Settings["unitframes-enable-raid"] then
			local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			Hider:Hide()
			
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer:SetParent(Hider)
				
				--CompactRaidFrameManager:UnregisterAllEvents()
				--CompactRaidFrameManager:SetParent(Hider)
			end
		end
		
		Move:Add(Player)
		Move:Add(Target)
		Move:Add(TargetTarget)
		Move:Add(Pet)
		--Move:Add(Party)
		--Move:Add(PartyPet)
		--Move:Add(Raid)
		Move:Add(self.RaidAnchor)
	else
		UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
		--UpdateShowManaTimer(Settings["unitframes-show-mana-timer"])
		--UpdateShowEnergyTimer(Settings["unitframes-show-energy-timer"])
	end
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
	Left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the vUI unit frames module"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-party", Settings["unitframes-enable-party"], Language["Enable Party Frames"], Language["Enable the vUI party frames module"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-party-pets", Settings["unitframes-enable-party-pets"], Language["Enable Party Pet Frames"], Language["Enable the vUI party pet frames module"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-enable-raid", Settings["unitframes-enable-raid"], Language["Enable Raid Frames"], Language["Enable the vUI raid frames module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Settings"])
	Left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateShowPlayerBuffs)
	Left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will|nbe displayed on the target"], UpdateOnlyPlayerDebuffs)
	Left:CreateSwitch("unitframes-show-mana-timer", Settings["unitframes-show-mana-timer"], Language["Enable Mana Regen Timer"], Language["Display the time until your full mana|nregeneration is active"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("unitframes-show-energy-timer", Settings["unitframes-show-energy-timer"], Language["Enable Energy Timer"], Language["Display the time until your next energy|ntick on the power bar"], ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateSwitch("unitframes-class-color", Settings["unitframes-class-color"], Language["Use Class/Reaction Colors"], Language["Color unit frame health by class or reaction"], ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Party"])
	Right:CreateSwitch("party-show-debuffs", Settings["party-show-debuffs"], Language["Enable Debuffs"], "Enable to display debuffs on party members", ReloadUI):RequiresReload(true)
	
	--[[Left:CreateHeader(Language["Player"])
	Left:CreateSwitch("unitframes-player-show-name", Settings["unitframes-player-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Left:CreateSwitch("unitframes-player-cc-health", Settings["unitframes-player-cc-health"], Language["Dark Scheme"], "")
	
	Right:CreateHeader(Language["Target"])
	Right:CreateSwitch("unitframes-target-show-name", Settings["unitframes-target-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Right:CreateSwitch("unitframes-target-cc-health", Settings["unitframes-target-cc-health"], Language["Dark Scheme"], "")
	]]
end)

local NamePlatesUpdateEnableDebuffs = function(self)
	if Settings["nameplates-display-debuffs"] then
		self:EnableElement("Auras")
	else
		self:DisableElement("Auras")
	end
end

local NamePlatesUpdateShowPlayerDebuffs = function(self)
	if self.Debuffs then
		self.Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	end
end

local UpdateNamePlatesEnableDebuffs = function()
	oUF:RunForAllNamePlates(NamePlatesUpdateEnableDebuffs)
end

local UpdateNamePlatesShowPlayerDebuffs = function()
	oUF:RunForAllNamePlates(NamePlatesUpdateShowPlayerDebuffs)
end

local NamePlateSetWidth = function(self)
	self:SetWidth(Settings["nameplates-width"])
end

local UpdateNamePlatesWidth = function()
	oUF:RunForAllNamePlates(NamePlateSetWidth)
end

local NamePlateSetHeight = function(self)
	self:SetHeight(Settings["nameplates-height"])
end

local UpdateNamePlatesHeight = function()
	oUF:RunForAllNamePlates(NamePlateSetHeight)
end

local NamePlateSetHealthColor = function(self)
	self.Health.colorTapping = Settings["nameplates-color-by-tapped"]
	self.Health.colorClass = Settings["nameplates-color-by-class"]
	self.Health.colorReaction = Settings["nameplates-color-by-reaction"]
end

local UpdateNamePlateColors = function()
	oUF:RunForAllNamePlates(NamePlateSetHealthColor)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Name Plates"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates Module"], "Enable the vUI name plates module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Sizes"])
	Left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates", UpdateNamePlatesWidth)
	Left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates", UpdateNamePlatesHeight)
	
	Left:CreateHeader(Language["Debuffs"])
	Left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Name Plates Debuffs"], "Display your debuffs above enemy name plates", UpdateNamePlatesEnableDebuffs)
	Left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], "If enabled, only your own debuffs will be displayed", UpdateNamePlatesShowPlayerDebuffs)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateSwitch("nameplates-color-by-tapped", Settings["nameplates-color-by-tapped"], Language["Use Tapped Colors"], "Color name plate health if the unit is tapped by another player", UpdateNamePlateColors)
	Right:CreateSwitch("nameplates-color-by-class", Settings["nameplates-color-by-class"], Language["Use Class Colors"], "Color name plate health by class", UpdateNamePlateColors)
	Right:CreateSwitch("nameplates-color-by-reaction", Settings["nameplates-color-by-reaction"], Language["Use Reaction Colors"], "Color name plate health by unit reaction", UpdateNamePlateColors)
	
	Right:CreateHeader(Language["Information"])
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	--[[if (not Settings["nameplates-display-debuffs"]) then
		GUI:GetWidgetByWindow(Language["Name Plates"], "nameplates-only-player-debuffs"):Disable() -- Temporary
	end]]
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