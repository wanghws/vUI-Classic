local addon, ns = ...
local vUI, GUI, Language, Media, Settings = ns:get()

local select = select
local format = string.format
local match = string.match
local floor = math.floor
local sub = string.sub
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

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

vUI.UnitFrames = {}

local HappinessLevels = {Language["Unhappy"], Language["Content"], Language["Happy"]}

local Classes = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	["worldboss"] = Language["Boss"],
	["minus"] = Language["Affix"],
}

local ShortClasses = {
	["rare"] = Language["R"],
	["elite"] = Language["+"],
	["rareelite"] = Language["R+"],
	["worldboss"] = Language["B"],
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
	return floor((UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthPercent"] = function(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return 0
	else
		return floor(UnitHealth(unit) / Max * 100 + 0.5)
	end
end

Events["HealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION "
Methods["HealthValues"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFD64545" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFBBBBBB" .. Language["Offline"] .. "|r"
	end
	
	return vUI:ShortValue(UnitHealth(unit)) .. " / " .. vUI:ShortValue(UnitHealthMax(unit))
end

Events["ColoredHealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION "
Methods["ColoredHealthValues"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"]
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return "|cFFBBBBBB" .. Language["Offline"]
	end
	
	return "|cFF" .. vUI:RGBToHex(GetColor(UnitHealth(unit) / UnitHealthMax(unit), 0.905, 0.298, 0.235, 0.18, 0.8, 0.443)) .. vUI:ShortValue(UnitHealth(unit)) .. " |cFFFEFEFE/|cFF2DCC70 " .. vUI:ShortValue(UnitHealthMax(unit))
end

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthColor"] = function(unit)
	return "|cFF" .. vUI:RGBToHex(GetColor(UnitHealth(unit) / UnitHealthMax(unit), 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
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
	
	return sub(Name, 1, 4)
end

Events["Name5"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 5)
end

Events["Name8"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 8)
end

Events["Name10"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 10)
end

Events["Name14"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 14)
end

Events["Name15"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 15)
end

Events["Name20"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 20)
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

Events["PetColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP" -- UNIT_HAPPINESS
Methods["PetColor"] = function(unit)
	if (vUI.UserClass == "HUNTER") then
		return Methods["HappinessColor"](unit)
	else
		return Methods["Reaction"](unit)
	end
end

-- Temporary so I can code on retail
if vUI:IsClassic() then
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
else
	Methods["PetHappiness"] = function() end
	Methods["HappinessColor"] = function() end
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
	
    local LeaderIndicator = Health:CreateTexture(nil, "OVERLAY")
    LeaderIndicator:SetSize(16, 16)
    LeaderIndicator:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    LeaderIndicator:SetTexture(Media:GetTexture("Leader"))
    LeaderIndicator:SetVertexColorHex("FFEB3B")
    LeaderIndicator:Hide()
	
	--[[local RaidTargetIndicator = Health:CreateTexture(nil, "OVERLAY")
	RaidTargetIndicator:SetScaledSize(16, 16)
	RaidTargetIndicator:SetScaledPoint("CENTER", Health, "TOP")]]
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
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
	--self.RaidTargetIndicator = RaidTargetIndicator
	self.LeaderIndicator = LeaderIndicator
	
	self:UpdateTags()
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
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetScaledPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.cd:SetScaledPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	
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
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(HealthLeft, "[Name15]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[NameColor][Name15]")
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
	self.RaidTargetIndicator = RaidTargetIndicator
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
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	self:Tag(HealthLeft, "[PetColor][Name10]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
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

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(self, event)
	if (not Settings["unitframes-enable"]) then
		return
	end
	
	local Player = oUF:Spawn("player")
	Player:SetScaledSize(230, 46)
	Player:SetScaledPoint("RIGHT", UIParent, "CENTER", -68, -304)
	
	local Target = oUF:Spawn("target")
	Target:SetScaledSize(230, 46)
	Target:SetScaledPoint("LEFT", UIParent, "CENTER", 68, -304)
	
	local TargetTarget = oUF:Spawn("targettarget")
	TargetTarget:SetScaledSize(110, 26)
	TargetTarget:SetScaledPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -3)
	
	local Pet = oUF:Spawn("pet")
	Pet:SetScaledSize(110, 26)
	Pet:SetScaledPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -3)
	
	vUI.UnitFrames["player"] = Player
	vUI.UnitFrames["target"] = Target
	vUI.UnitFrames["targettarget"] = TargetTarget
	vUI.UnitFrames["pet"] = Pet
	
	if Settings["nameplates-enable"] then
		oUF:SpawnNamePlates(nil, nil, PlateCVars)
	end
	
	self:UnregisterEvent(event)
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
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	Left:CreateFooter()
	Right:CreateFooter()
end)