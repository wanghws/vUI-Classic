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
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

local ShortValue = function(n)
	if (n <= 999) then
		return n
	end
	
	if (n >= 1000000) then
		return format("%.2fm", n / 1000000)
	elseif (n >= 1000) then
		return format("%dk", n / 1000)
	end
end

local ShortValueLarge = function(n)
	if (n <= 999) then
		return n
	end
	
	if (n > 1000000000) then
		return format("%.2fb", n / 1000000000)
	elseif (n >= 1000000) then
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
	return ShortValueLarge(UnitHealth(unit))
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
	return ShortValueLarge(UnitHealth(unit)) .. "/" .. ShortValueLarge(UnitHealthMax(unit))
end

Events["vUI-Power"] = "UNIT_POWER_FREQUENT"
Methods["vUI-Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return ShortValue(UnitPower(unit))
	end
end

Events["vUI-Name4"] = "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE"
Methods["vUI-Name4"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 4)
end

Events["vUI-Name5"] = "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE"
Methods["vUI-Name5"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 5)
end

Events["vUI-Name8"] = "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE"
Methods["vUI-Name8"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 8)
end

Events["vUI-Name15"] = "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE"
Methods["vUI-Name15"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 18)
end

Events["vUI-Name20"] = "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE"
Methods["vUI-Name20"] = function(unit)
	local Name = UnitName(unit)
	
	return sub(Name, 1, 20)
end

local StyleNamePlate = function(self, unit)
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self:SetPoint("CENTER", 0, 0)
	self:SetScale(Settings["ui-scale"] / 100)
	
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
	
	local Name = Health:CreateFontString(nil, "OVERLAY")
	Name:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Name:SetScaledPoint("CENTER", Health, "TOP", 0, 2)
	Name:SetJustifyH("CENTER")
	Name:SetShadowColor(0, 0, 0)
	Name:SetShadowOffset(1, -1)
	
	local HealthValue = Health:CreateFontString(nil, "OVERLAY")
	HealthValue:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	HealthValue:SetScaledPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -2)
	HealthValue:SetJustifyH("RIGHT")
	HealthValue:SetShadowColor(0, 0, 0)
	HealthValue:SetShadowOffset(1, -1)
	
	Health.colorHealth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true
	
	self:Tag(Name, "[vUI-Name20]")
	self:Tag(HealthValue, "[vUI-HealthPercent]")
	
	self.Health = Health
	self.Name = Name
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
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(14)
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
	Power.colorPower = true
	
	local HealthValue = Health:CreateFontString(nil, "OVERLAY")
	HealthValue:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	HealthValue:SetScaledPoint("BOTTOMLEFT", self, 2, 2)
	HealthValue:SetJustifyH("LEFT")
	HealthValue:SetShadowColor(0, 0, 0)
	HealthValue:SetShadowOffset(1, -1)
	
	-- Heal Prediction
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local AbsorbsSpark = AbsorbsBar:CreateTexture(nil, "OVERLAY")
	AbsorbsSpark:SetScaledSize(1, 28)
	AbsorbsSpark:SetScaledPoint("LEFT", AbsorbsBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	AbsorbsSpark:SetTexture(Media:GetTexture("Blank"))
	AbsorbsSpark:SetVertexColor(0, 0, 0)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealSpark = HealBar:CreateTexture(nil, "OVERLAY")
	HealSpark:SetScaledSize(1, 28)
	HealSpark:SetScaledPoint("LEFT", HealBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	HealSpark:SetTexture(Media:GetTexture("Blank"))
	HealSpark:SetVertexColor(0, 0, 0)
	
	-- Tags
	self:Tag(HealthValue, "[vUI-PlayerInfo]")
	self:Tag(PowerValue, "[vUI-Power]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.Combat = Combat
	self.Castbar = CastBar
	self.HealBar = HealBar
	self.AbsorbsBar = AbsorbsBar
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
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorReaction = true
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(14)
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
	Power.colorPower = true
	
	-- Combat
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
	-- Heal	Prediction
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local AbsorbsSpark = AbsorbsBar:CreateTexture(nil, "OVERLAY")
	AbsorbsSpark:SetScaledSize(1, 28)
	AbsorbsSpark:SetScaledPoint("LEFT", AbsorbsBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	AbsorbsSpark:SetTexture(Media:GetTexture("Blank"))
	AbsorbsSpark:SetVertexColor(0, 0, 0)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealSpark = HealBar:CreateTexture(nil, "OVERLAY")
	HealSpark:SetScaledSize(1, 28)
	HealSpark:SetScaledPoint("LEFT", HealBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	HealSpark:SetTexture(Media:GetTexture("Blank"))
	HealSpark:SetVertexColor(0, 0, 0)
	
	-- Tags
	self:Tag(HealthValue, "[vUI-TargetInfo]")
	self:Tag(HealthPercent, "[vUI-HealthPercent]")
	self:Tag(Name, "[vUI-Name15]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.Name = Name
	self.Combat = Combat
	self.Castbar = CastBar
	self.HealBar = HealBar
	self.AbsorbsBar = AbsorbsBar
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
	Player:SetScaledSize(230, 45)
	Player:SetScaledPoint("RIGHT", UIParent, "CENTER", -67, -304)
	
	local Target = oUF:Spawn("target")
	Target:SetSize(230, 45)
	Target:SetPoint("LEFT", UIParent, "CENTER", 67, -304)
	
	if Settings["nameplates-enable"] then
		oUF:SpawnNamePlates(nil, nil, PlateCVars)
	end
	
	self:UnregisterEvent(event)
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], ""):RequiresReload(true)
	
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