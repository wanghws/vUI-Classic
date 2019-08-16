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
local UnitReaction = UnitReaction
local GetPetHappiness = GetPetHappiness

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

vUI.UnitFrames = {}

local HappinessLevels = {Language["Unhappy"], Language["Content"], Language["Happy"]}

local ShortValue = function(n)
	if (n <= 999) then
		return n
	end
	
	if (n >= 1000000) then -- Is a million even a number anywhere in classic?
		return format("%.2fm", n / 1000000)
	elseif (n >= 1000) then
		return format("%dk", n / 1000)
	end
end

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

Events["Health"] = "UNIT_HEALTH_FREQUENT"
Methods["Health"] = function(unit)
	return ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthPercent"] = function(unit)
	return floor((UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT"
Methods["HealthColor"] = function(unit)
	return "|cFF"..vUI:RGBToHex(GetColor(UnitHealth(unit) / UnitHealthMax(unit), 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
end

Events["Power"] = "UNIT_POWER_FREQUENT"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return ShortValue(UnitPower(unit))
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
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

Events["Name15"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 18)
end

Events["Name20"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 20)
end

Events["ClassReaction"] = "UNIT_NAME_UPDATE"
Methods["ClassReaction"] = function(unit)
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
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	TopLeft:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	TopLeft:SetScaledPoint("LEFT", Health, "TOPLEFT", 4, 2)
	TopLeft:SetJustifyH("LEFT")
	TopLeft:SetShadowColor(0, 0, 0)
	TopLeft:SetShadowOffset(1, -1)
	
	local Top = Health:CreateFontString(nil, "OVERLAY")
	Top:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Top:SetScaledPoint("CENTER", Health, "TOP", 0, 2)
	Top:SetJustifyH("CENTER")
	Top:SetShadowColor(0, 0, 0)
	Top:SetShadowOffset(1, -1)
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	TopRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	TopRight:SetScaledPoint("RIGHT", Health, "TOPRIGHT", -4, 2)
	TopRight:SetJustifyH("RIGHT")
	TopRight:SetShadowColor(0, 0, 0)
	TopRight:SetShadowOffset(1, -1)
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	BottomRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	BottomRight:SetScaledPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -2)
	BottomRight:SetJustifyH("RIGHT")
	BottomRight:SetShadowColor(0, 0, 0)
	BottomRight:SetShadowOffset(1, -1)
	
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
	
	self.Health = Health
	self.TopLeft = TopLeft
	self.Top = Top
	self.TopRight = TopRight
	self.BottomRight = BottomRight
	self.Health.bg = HealthBG
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
	HealthLeft:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	HealthLeft:SetShadowColor(0, 0, 0)
	HealthLeft:SetShadowOffset(1, -1)
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	HealthRight:SetShadowColor(0, 0, 0)
	HealthRight:SetShadowOffset(1, -1)
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
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
	PowerRight:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	PowerRight:SetShadowColor(0, 0, 0)
	PowerRight:SetShadowOffset(1, -1)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	PowerLeft:SetShadowColor(0, 0, 0)
	PowerLeft:SetShadowOffset(1, -1)
	
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
    Castbar:SetScaledPoint("BOTTOM", UIParent, 0, 130)
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
	Time:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	Time:SetShadowColor(0, 0, 0)
	Time:SetShadowOffset(1, -1)
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	
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
		
		for index = 1, 5 do
			-- Position and size of the totem indicator
			local Totem = CreateFrame("Button", nil, self)
			Totem:SetSize(40, 40)
			Totem:SetPoint("TOPLEFT", self, "BOTTOMLEFT", index * Totem:GetWidth(), 0)
			
			local Icon = Totem:CreateTexture(nil, 'OVERLAY')
			Icon:SetAllPoints()
			
			local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
			Cooldown:SetAllPoints()
			
			Totem.Icon = Icon
			Totem.Cooldown = Cooldown
			
			Totems[index] = Totem
		end
		
		-- Register with oUF
		self.Totems = Totems
	end
	
	-- Tags
	self:Tag(PowerLeft, "[Health]")
	self:Tag(PowerValue, "[Power]")
	
	if Settings["unitframes-player-show-name"] then
		if Settings["unitframes-player-cc-health"] then
			self:Tag(HealthLeft, "[Name15]")
		else
			self:Tag(HealthLeft, "[Name15]")
		end
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
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
	
	local HealthValue = Health:CreateFontString(nil, "OVERLAY")
	HealthValue:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	HealthValue:SetScaledPoint("BOTTOMLEFT", self, 2, 2)
	HealthValue:SetJustifyH("LEFT")
	HealthValue:SetShadowColor(0, 0, 0)
	HealthValue:SetShadowOffset(1, -1)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	HealthLeft:SetShadowColor(0, 0, 0)
	HealthLeft:SetShadowOffset(1, -1)
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	HealthRight:SetShadowColor(0, 0, 0)
	HealthRight:SetShadowOffset(1, -1)
	
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
		
		self:Tag(HealthLeft, "[ClassReaction][Name15]")
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
	
	local PowerValue = Power:CreateFontString(nil, "OVERLAY")
	PowerValue:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	PowerValue:SetScaledPoint("RIGHT", Power, -1, 0)
	PowerValue:SetJustifyH("RIGHT")
	PowerValue:SetShadowColor(0, 0, 0)
	PowerValue:SetShadowOffset(1, -1)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	
	if Settings["unitframes-target-cc-health"] then
		Power.colorPower = true
	else
		Power.colorClass = true
	end
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetScaledSize(250, 20)
    Castbar:SetScaledPoint("BOTTOM", UIParent, 0, 156)
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
	Time:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	Time:SetShadowColor(0, 0, 0)
	Time:SetShadowOffset(1, -1)
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	
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
	
    -- Register it with oUF
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
	self:Tag(HealthValue, "[Health]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Combat = Combat
	self.Castbar = Castbar
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
	HealthLeft:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	HealthLeft:SetShadowColor(0, 0, 0)
	HealthLeft:SetShadowOffset(1, -1)
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	HealthRight:SetShadowColor(0, 0, 0)
	HealthRight:SetShadowOffset(1, -1)
	
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
		
		self:Tag(HealthLeft, "[ClassReaction][Name10]")
		--self:Tag(HealthLeft, "[Name10]")
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
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
	HealthLeft:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	HealthLeft:SetShadowColor(0, 0, 0)
	HealthLeft:SetShadowOffset(1, -1)
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	HealthRight:SetShadowColor(0, 0, 0)
	HealthRight:SetShadowOffset(1, -1)
	
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
	
	self:Tag(HealthLeft, "[HappinessColor][Name10]")
	
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
    -- important, strongly recommend to set these to 1
    nameplateGlobalScale = 1,
    NamePlateHorizontalScale = 1,
    NamePlateVerticalScale = 1,
    -- optional, you may use any values
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

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], ""):RequiresReload(true)
	
	Left:CreateHeader(Language["Player"])
	Left:CreateCheckbox("unitframes-player-show-name", Settings["unitframes-player-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Left:CreateCheckbox("unitframes-player-cc-health", Settings["unitframes-player-cc-health"], Language["Dark Scheme"], "")
	
	Right:CreateHeader(Language["Target"])
	Right:CreateCheckbox("unitframes-target-show-name", Settings["unitframes-target-show-name"], Language["Enable Name"], "", TogglePlayerName)
	Right:CreateCheckbox("unitframes-target-cc-health", Settings["unitframes-target-cc-health"], Language["Dark Scheme"], "")
	
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