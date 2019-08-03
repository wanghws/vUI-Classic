local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local type = type
local tonumber = tonumber
local match = string.match
local reverse = string.reverse
local format = format
local gsub = gsub
local floor = floor
local XP, MaxXP, Rested
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitLevel = UnitLevel
local GetXPExhaustion = GetXPExhaustion
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local ExperienceBar = CreateFrame("StatusBar", "vUIExperienceBar", UIParent)

local WidthWidget
local HeightWidget

local Comma = function(number)
	if (not number) then
		return
	end
	
	local Number = format("%.0f", floor(number + 0.5))
   	local Left, Number, Right = match(Number, "^([^%d]*%d)(%d+)(.-)$")
	
	return Left and Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) or number
end

local UpdateXP = function(self, first)
	if (UnitLevel("player") == MAX_PLAYER_LEVEL) then
		self:UnregisterAllEvents()
		self:SetScript("OnEnter", nil)
		self:SetScript("OnLeave", nil)
		self:SetScript("OnEvent", nil)
		self:Hide()
		
		return
	end
	
	Rested = GetXPExhaustion()
    XP = UnitXP("player")
    Max = UnitXPMax("player")
	
	self.Bar:SetMinMaxValues(0, Max)
	self.Bar.Rested:SetMinMaxValues(0, Max)
	
	if Rested then
		self.Bar.Rested:SetValue(XP + Rested)
		self.Progress:SetText(Comma(XP) .. " / " .. Comma(Max) .. " (+" .. Comma(Rested) .. ")")
	else
		self.Bar.Rested:SetValue(0)
		self.Progress:SetText(Comma(XP) .. " / " .. Comma(Max))
	end
	
	self.Percentage:SetText(floor((XP / Max * 100 + 0.05) * 10) / 10 .. "%")
	
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r %s", Settings["ui-header-font-color"], Language["Level"], UnitLevel("player")))
	self.HeaderBG:SetScaledWidth(self.HeaderBG.Text:GetWidth() + 14)
	
	if (XP > 0) and (self.Bar.Spark:GetAlpha() < 1) then
		self.Bar.Spark:SetAlpha(1)
	elseif (self.Bar.Spark:GetAlpha() > 0) then
		self.Bar.Spark:SetAlpha(0)
	end
	
	if Rested and (Rested > 0) and (self.Bar.Rested.Spark:GetAlpha() < 1) then
		self.Bar.Rested.Spark:SetAlpha(1)
	elseif (self.Bar.Rested.Spark:GetAlpha() > 0) then
		self.Bar.Rested.Spark:SetAlpha(0)
	end
	
	if Settings["experience-animate"] then
		if (not first) then
			self.Change:SetChange(XP)
			self.Change:Play()
			
			if ((XP > self.LastXP) and not self.Flash:IsPlaying()) then
				self.Flash:Play()
			end
		else
			self.Bar:SetValue(XP)
		end
	else
		self.Bar:SetValue(XP)
	end
	
	self.LastXP = XP
end

local UpdateDisplayLevel = function(value)
	if value then
		vUIExperienceBar.HeaderBG:Show()
		
		vUIExperienceBar.BarBG:ClearAllPoints()
		vUIExperienceBar.BarBG:SetScaledPoint("TOPLEFT", vUIExperienceBar.HeaderBG, "TOPRIGHT", 2, 0)
		vUIExperienceBar.BarBG:SetScaledPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
	else
		vUIExperienceBar.HeaderBG:Hide()
		
		vUIExperienceBar.BarBG:ClearAllPoints()
		vUIExperienceBar.BarBG:SetScaledPoint("TOPLEFT", vUIExperienceBar, 0, 0)
		vUIExperienceBar.BarBG:SetScaledPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
	end
end

local UpdateDisplayProgress = function(value)
	if (value and Settings["experience-progress-visibility"] ~= "MOUSEOVER") then
		vUIExperienceBar.Progress:Show()
	else
		vUIExperienceBar.Progress:Hide()
	end
end

local UpdateDisplayPercent = function(value)
	if (value and Settings["experience-percent-visibility"] ~= "MOUSEOVER") then
		vUIExperienceBar.Percentage:Show()
	else
		vUIExperienceBar.Percentage:Hide()
	end
end

local UpdateBarWidth = function(value)
	if (Settings["experience-position"] ~= "CHATFRAME") then
		vUIExperienceBar:SetScaledWidth(value)
	end
end

local UpdateBarHeight = function(value)
	if (Settings["experience-position"] ~= "CHATFRAME") then
		vUIExperienceBar:SetScaledHeight(value)
		vUIExperienceBar.HeaderBG:SetScaledHeight(value)
		vUIExperienceBar.Bar.Spark:SetScaledHeight(value)
	end
end

local UpdateBarPosition = function(value)
	ExperienceBar:ClearAllPoints()
	
	if (value == "TOP") then
		ExperienceBar.BGAll:Show()
		ExperienceBar:SetScaledSize(Settings["experience-width"], Settings["experience-height"])
		ExperienceBar:SetScaledPoint("TOP", UIParent, 0, -13)
		ExperienceBar.HeaderBG:SetScaledHeight(Settings["experience-height"])
		ExperienceBar.Bar.Spark:SetScaledHeight(Settings["experience-height"])
		
		vUIChatFrameBottom:Show()
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
		end
		
		if (WidthWidget and WidthWidget.Disabled) then
			WidthWidget:Enable()
		end
		
		if (HeightWidget and HeightWidget.Disabled) then
			HeightWidget:Enable()
		end
	elseif (value == "CHATFRAME") then
		vUIChatFrameBottom:Hide()
		
		local Height = vUIChatFrameBottom:GetHeight()
		
		ExperienceBar.BGAll:Hide()
		ExperienceBar:SetScaledSize(vUIChatFrameBottom:GetWidth(), Height)
		ExperienceBar:SetScaledPoint("CENTER", vUIChatFrameBottom, 0, 0)
		
		ExperienceBar.HeaderBG:SetScaledHeight(Height)
		ExperienceBar.Bar.Spark:SetScaledHeight(Height)
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
		end
		
		if (WidthWidget and not WidthWidget.Disabled) then
			WidthWidget:Disable()
		end
		
		if (HeightWidget and not HeightWidget.Disabled) then
			HeightWidget:Disable()
		end
	elseif (value == "CLASSIC") then
		vUIChatFrameBottom:Show()
		
		ExperienceBar.BGAll:Show()
		ExperienceBar:SetScaledHeight(Settings["experience-height"])
		ExperienceBar:SetScaledPoint("BOTTOM", UIParent, 0, 13)
		ExperienceBar.HeaderBG:SetScaledHeight(Settings["experience-height"])
		ExperienceBar.Bar.Spark:SetScaledHeight(Settings["experience-height"])
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", ExperienceBar, "TOP", 0, 5)
			
			ExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - 6)
		end
		
		if (WidthWidget and not WidthWidget.Disabled) then
			WidthWidget:Disable()
		end
		
		if (HeightWidget and HeightWidget.Disabled) then
			HeightWidget:Enable()
		end
	end
end

local OnEnter = function(self)
	if (Settings["experience-display-progress"] and Settings["experience-progress-visibility"] == "MOUSEOVER") then
		if (not self.Progress:IsShown()) then
			self.Progress:Show()
		end
	end
	
	if (Settings["experience-display-percent"] and Settings["experience-percent-visibility"] == "MOUSEOVER") then
		if (not self.Percentage:IsShown()) then
			self.Percentage:Show()
		end
	end
end

local OnLeave = function(self)
	if (Settings["experience-display-progress"] and Settings["experience-progress-visibility"] == "MOUSEOVER") then
		if self.Progress:IsShown() then
			self.Progress:Hide()
		end
	end
	
	if (Settings["experience-display-percent"] and Settings["experience-percent-visibility"] == "MOUSEOVER") then
		if self.Percentage:IsShown() then
			self.Percentage:Hide()
		end
	end
end

local UpdateProgressVisibility = function(value)
	if (value == "MOUSEOVER") then
		ExperienceBar.Progress:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-progress"]) then
		ExperienceBar.Progress:Show()
	end
end

local UpdatePercentVisibility = function(value)
	if (value == "MOUSEOVER") then
		ExperienceBar.Percentage:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-percent"]) then
		ExperienceBar.Percentage:Show()
	end
end

ExperienceBar["PLAYER_LEVEL_UP"] = UpdateXP
ExperienceBar["PLAYER_XP_UPDATE"] = UpdateXP
ExperienceBar["PLAYER_UPDATE_RESTING"] = UpdateXP
ExperienceBar["UPDATE_EXHAUSTION"] = UpdateXP

ExperienceBar["PLAYER_ENTERING_WORLD"] = function(self)
	if (not Settings["experience-enable"]) then
		self:UnregisterAllEvents()
		
		return
	end
	
	self:SetFrameStrata("MEDIUM")
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self.LastXP = 0
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	self.HeaderBG:SetScaledHeight(Settings["experience-height"])
	self.HeaderBG:SetScaledPoint("LEFT", self, 0, 0)
	self.HeaderBG:SetBackdrop(vUI.BackdropAndBorder)
	self.HeaderBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.HeaderBG:SetBackdropBorderColor(0, 0, 0)
	self.HeaderBG:SetFrameStrata("MEDIUM")
	
	self.HeaderBG.Texture = self.HeaderBG:CreateTexture(nil, "OVERLAY")
	self.HeaderBG.Texture:SetScaledPoint("TOPLEFT", self.HeaderBG, 1, -1)
	self.HeaderBG.Texture:SetScaledPoint("BOTTOMRIGHT", self.HeaderBG, -1, 1)
	self.HeaderBG.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.HeaderBG.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.HeaderBG.Text = self.HeaderBG:CreateFontString(nil, "OVERLAY")
	self.HeaderBG.Text:SetScaledPoint("CENTER", self.HeaderBG, 0, 0)
	self.HeaderBG.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	self.HeaderBG.Text:SetJustifyH("CENTER")
	self.HeaderBG.Text:SetShadowColor(0, 0, 0)
	self.HeaderBG.Text:SetShadowOffset(1, -1)
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r", Settings["ui-widget-color"], Language["Level"]))
	
	self.BarBG = CreateFrame("Frame", nil, self)
	self.BarBG:SetScaledPoint("TOPLEFT", self.HeaderBG, "TOPRIGHT", 2, 0)
	self.BarBG:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	self.BarBG:SetFrameStrata("MEDIUM")
	
	self.Texture = self.BarBG:CreateTexture(nil, "OVERLAY")
	self.Texture:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Texture:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BGAll = CreateFrame("Frame", nil, self)
	self.BGAll:SetScaledPoint("TOPLEFT", self.HeaderBG, -3, 3)
	self.BGAll:SetScaledPoint("BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	--local R, G, B = vUI:HexToRGB("1AE045")
	local R, G, B = vUI:HexToRGB(Settings["ui-widget-color"])
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetStatusBarColor(R, G, B)
	self.Bar:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameStrata("MEDIUM")
	self.Bar:SetFrameLevel(6)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "ARTWORK")
	self.Bar.Spark:SetScaledSize(1, Settings["experience-height"])
	self.Bar.Spark:SetScaledPoint("LEFT", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Spark:SetTexture(Media:GetTexture("Blank"))
	self.Bar.Spark:SetVertexColor(0, 0, 0)
	
	self.Shine = self.Bar:CreateTexture(nil, "ARTWORK")
	self.Shine:SetAllPoints(self.Bar:GetStatusBarTexture())
	self.Shine:SetTexture(Media:GetTexture("pHishTex12"))
	self.Shine:SetVertexColor(1, 1, 1)
	self.Shine:SetAlpha(0)
	self.Shine:SetDrawLayer("ARTWORK", 7)
	
	self.Change = CreateAnimationGroup(self.Bar):CreateAnimation("Progress")
	self.Change:SetOrder(1)
	self.Change:SetEasing("in")
	self.Change:SetDuration(0.3)
	
	self.Flash = CreateAnimationGroup(self.Shine)
	
	self.Flash.In = self.Flash:CreateAnimation("Fade")
	self.Flash.In:SetOrder(1)
	self.Flash.In:SetEasing("in")
	self.Flash.In:SetDuration(0.3)
	self.Flash.In:SetChange(0.3)
	
	self.Flash.Out = self.Flash:CreateAnimation("Fade")
	self.Flash.Out:SetOrder(2)
	self.Flash.Out:SetEasing("out")
	self.Flash.Out:SetDuration(0.5)
	self.Flash.Out:SetChange(0)
	
	--local RR, RG, RB = vUI:HexToRGB("00B4FF")
	
	self.Bar.Rested = CreateFrame("StatusBar", nil, self.Bar)
	self.Bar.Rested:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.Rested:SetFrameLevel(5)
	self.Bar.Rested:SetAllPoints(self.Bar)
	self.Bar.Rested:SetStatusBarColor(R, G, B)
	self.Bar.Rested:SetFrameStrata("MEDIUM")
	self.Bar.Rested:SetAlpha(0.5)
	
	self.Bar.Rested.Spark = self.Bar.Rested:CreateTexture(nil, "ARTWORK")
	self.Bar.Rested.Spark:SetScaledSize(1, Settings["experience-height"])
	self.Bar.Rested.Spark:SetScaledPoint("LEFT", self.Bar.Rested:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Rested.Spark:SetTexture(Media:GetTexture("Blank"))
	self.Bar.Rested.Spark:SetVertexColor(0, 0, 0)
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetScaledPoint("LEFT", self.Bar, 5, 0)
	self.Progress:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	self.Progress:SetJustifyH("LEFT")
	self.Progress:SetShadowColor(0, 0, 0)
	self.Progress:SetShadowOffset(1, -1)
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetScaledPoint("RIGHT", self.Bar, -5, 0)
	self.Percentage:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	self.Percentage:SetJustifyH("RIGHT")
	self.Percentage:SetShadowColor(0, 0, 0)
	self.Percentage:SetShadowOffset(1, -1)
	
	-- Add fade to self.Percentage
	
	UpdateDisplayLevel(Settings["experience-display-level"])
	UpdateDisplayProgress(Settings["experience-display-progress"])
	UpdateDisplayPercent(Settings["experience-display-percent"])
	UpdateBarPosition(Settings["experience-position"])
	UpdateProgressVisibility(Settings["experience-progress-visibility"])
	UpdatePercentVisibility(Settings["experience-percent-visibility"])
	UpdateXP(self, true)
end

ExperienceBar:RegisterEvent("PLAYER_LEVEL_UP")
ExperienceBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ExperienceBar:RegisterEvent("PLAYER_XP_UPDATE")
ExperienceBar:RegisterEvent("PLAYER_UPDATE_RESTING")
ExperienceBar:RegisterEvent("UPDATE_EXHAUSTION")
ExperienceBar:SetScript("OnEvent", function(self, event)
	if self[event] then
		self[event](self)
	end
end)

local HasPrinted = false
local DevTools = "|Hcommand:/reload|h|cFF%s[Reload UI]|r|h |Hcommand:/eventtrace|h|cFF%s[Event Trace]|r|h |Hplayer:%s|h|cFF%s[Whisper Self]|r|h |Hcommand:/framestack|h|cFF%s[Frame Stack]|r|h"

local UpdateDisplayDevTools = function()
	if (not HasPrinted) then
		local Color = Settings["ui-widget-color"]
		local Name = UnitName("player")
		
		print(format(DevTools, Color, Color, Name, Color, Color))
		
		HasPrinted = true
	end
end

local Languages = {
	["English"] = "enUS",
	--[[["German"] = "deDE",
	["Spanish (Spain)"] = "esES",
	["Spanish (Mexico)"] = "esMX",
	["French"] = "frFR",
	["Italian"] = "itIT",
	["Korean"] = "koKR",
	["Portuguese (Brazil)"] = "ptBR",
	["Russian"] = "ruRU",
	["Chinese (Simplified)"] = "zhCN",
	["Chinese (Traditional)"] = "zhTW",]]
}

local UpdateUIScale = function(value)
	value = value / 100
	
	SetCVar("uiScale", value)
end

local GetDiscordLink = function()
	if (not vUI.Throttle:Exists("get-discord-link")) then
		vUI.Throttle:Create("get-discord-link", 10)
	end
	
	if (not vUI.Throttle:IsThrottled("get-discord-link")) then
		print("https://discord.gg/SmT6Yk")
		
		vUI.Throttle:Start("get-discord-link")
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Experience"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("experience-enable", true, Language["Enable Experience Module"], ""):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateCheckbox("experience-display-level", Settings["experience-display-level"], Language["Display Level"], "", UpdateDisplayLevel)
	Left:CreateCheckbox("experience-display-progress", Settings["experience-display-progress"], Language["Display Progress Text"], "", UpdateDisplayProgress)
	Left:CreateCheckbox("experience-display-percent", Settings["experience-display-percent"], Language["Display Percent Text"], "", UpdateDisplayPercent)
	Left:CreateCheckbox("experience-animate", Settings["experience-animate"], Language["Animate Experience Changes"], "")
	
	Right:CreateHeader(Language["Size"])
	WidthWidget = Right:CreateSlider("experience-width", Settings["experience-width"], 240, 400, 10, Language["Bar Width"], "", UpdateBarWidth)
	HeightWidget = Right:CreateSlider("experience-height", Settings["experience-height"], 6, 30, 1, Language["Bar Height"], "", UpdateBarHeight)
	
	Right:CreateHeader(Language["Positioning"])
	Right:CreateDropdown("experience-position", Settings["experience-position"], {[Language["Top"]] = "TOP", [Language["Chat Frame"]] = "CHATFRAME", [Language["Classic"]] = "CLASSIC"}, Language["Set Position"], "", UpdateBarPosition)
	
	Right:CreateHeader(Language["Visibility"])
	
	Right:CreateDropdown("experience-progress-visibility", Settings["experience-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], "", UpdateProgressVisibility)
	Right:CreateDropdown("experience-percent-visibility", Settings["experience-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], "", UpdatePercentVisibility)
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	-- TEMPORARY -- Debug/Test
	local GeneralLeft, GeneralRight = self:CreateWindow(Language["General"])
	
	GeneralLeft:CreateHeader(Language["Welcome"])
	GeneralLeft:CreateCheckbox("ui-display-welcome", Settings["ui-display-welcome"], Language["Display Welcome Message"], "")
	GeneralLeft:CreateCheckbox("ui-display-whats-new", Settings["ui-display-whats-new"], Language[ [[Display "What's New" Pop-ups]] ], "")
	GeneralLeft:CreateCheckbox("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Tools"], "", UpdateDisplayDevTools)
	
	GeneralLeft:CreateHeader("Discord")
	GeneralLeft:CreateButton("Get Link", "Join Discord", "", GetDiscordLink)
	
	GeneralRight:CreateHeader(Language["Language"])
	GeneralRight:CreateDropdown("ui-language", vUI.UserLocale, Languages, Language["UI Language"], "", ReloadUI):RequiresReload(true)
	GeneralRight:CreateButton(Language["Contribute"], Language["Help Localize"], Language["Contribute"], function() vUI:print("put something here. print a link, or pop up a window or something.") end)
	
	GeneralRight:CreateHeader(Language["Scale"])
	GeneralRight:CreateSlider("ui-scale", Settings["ui-scale"], 64, 100, 1, "Set UI Scale", "", UpdateUIScale, nil, "%")
	
	GeneralLeft:CreateFooter()
	GeneralRight:CreateFooter()
	
	if Settings["ui-display-welcome"] then
		local Color1 = Settings["ui-widget-color"]
		local Color2 = Settings["ui-header-font-color"]
		
		print(format(Language["Welcome to |cFF%svUI|r version |cFF%s%s|r."], Color1, Color2, vUI.Version))
		print(format(Language["Type |cFF%s/vui|r to access the console for settings, or click |cFF%s|Hcommand:/vui|h[here]|h|r."], Color1, Color1))
		
		-- May as well put this here for now too.
		if Settings["ui-display-dev-tools"] then
			local Name = UnitName("player")
			
			print(format(DevTools, Color1, Color1, Name, Color1, Color1))
			
			HasPrinted = true
		end
	end
end)