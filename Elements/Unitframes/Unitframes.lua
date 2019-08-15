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

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

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

Events["vUI-Status"] = "UNIT_HEALTH UNIT_CONNECTION"
Methods["vUI-Status"] = function(unit)
	if UnitIsDead(unit) then
		return Language["Dead"]
	elseif UnitIsGhost(unit) then
		return Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return Language["Offline"]
	end
end

Events["vUI-Health"] = "UNIT_HEALTH_FREQUENT"
Methods["vUI-Health"] = function(unit)
	return ShortValue(UnitHealth(unit))
end

Events["vUI-HealthLarge"] = "UNIT_HEALTH_FREQUENT"
Methods["vUI-HealthLarge"] = function(unit)
	return ShortValue(UnitHealth(unit))
end

Events["vUI-HealthPercent"] = "UNIT_HEALTH_FREQUENT"
Methods["vUI-HealthPercent"] = function(unit)
	return floor((UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
end

Events["vUI-PlayerInfo"] = "UNIT_HEALTH_FREQUENT"
Methods["vUI-PlayerInfo"] = function(unit)
	return ShortValue(UnitHealth(unit)) .. "/" .. ShortValue(UnitHealthMax(unit))
end

Events["vUI-TargetInfo"] = "UNIT_HEALTH_FREQUENT"
Methods["vUI-TargetInfo"] = function(unit)
	return ShortValue(UnitHealth(unit)) .. "/" .. ShortValue(UnitHealthMax(unit))
end

Events["vUI-Power"] = "UNIT_POWER_FREQUENT"
Methods["vUI-Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return ShortValue(UnitPower(unit))
	end
end

Events["vUI-Name4"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["vUI-Name4"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 4)
end

Events["vUI-Name5"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["vUI-Name5"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 5)
end

Events["vUI-Name8"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["vUI-Name8"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 8)
end

Events["vUI-Name15"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["vUI-Name15"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 18)
end

Events["vUI-Name20"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["vUI-Name20"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 20)
end

Events["vUI-ClassReaction"] = "UNIT_NAME_UPDATE"
Methods["vUI-ClassReaction"] = function(unit)
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
		
		self:Tag(TopLeft, "[vUI-Name15]")
	else
		Health.colorHealth = true
		
		self:Tag(TopLeft, "[vUI-ClassReaction][vUI-Name15]")
	end
	
	self:Tag(BottomRight, "[perhp]")
	self:Tag(TopRight, "[difficulty][level]")
	
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
	
	-- Tags
	self:Tag(PowerLeft, "[vUI-PlayerInfo]")
	self:Tag(PowerValue, "[vUI-Power]")
	
	if Settings["unitframes-player-show-name"] then
		if Settings["unitframes-player-cc-health"] then
			self:Tag(HealthLeft, "[vUI-Name15]")
		else
			self:Tag(HealthLeft, "[vUI-ClassReaction][vUI-Name15]")
		end
	end
	
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
	self.Castbar = CastBar
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
	
	local Name = Health:CreateFontString(nil, "OVERLAY")
	Name:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Name:SetScaledPoint("LEFT", Health, 3, 0)
	Name:SetJustifyH("LEFT")
	Name:SetShadowColor(0, 0, 0)
	Name:SetShadowOffset(1, -1)
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-target-cc-health"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(Name, "[vUI-Name15]")
	else
		Health.colorHealth = true
		
		self:Tag(Name, "[vUI-ClassReaction][vUI-Name15]")
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
	
	-- Combat
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
	-- Tags
	self:Tag(HealthValue, "[vUI-TargetInfo]")
	self:Tag(HealthPercent, "[vUI-HealthPercent]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.Name = Name
	self.Combat = Combat
	self.Castbar = CastBar
end

local Style = function(self, unit)
	if (unit == "player") then
		StylePlayer(self, unit)
	elseif (unit == "target") then
		StyleTarget(self, unit)
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
	
	if Settings["nameplates-enable"] then
		oUF:SpawnNamePlates(nil, nil, PlateCVars)
	end
	
	self:UnregisterEvent(event)
end)

local TogglePlayerName = function(value)
	if value then
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "[vUI-Name15]")
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
	
	Left:CreateFooter()
	Right:CreateFooter()
end)