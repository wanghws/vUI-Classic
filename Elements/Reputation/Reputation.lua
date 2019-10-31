local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Reputation = vUI:NewModule("Reputation")

local format = format
local floor = floor
local GetWatchedFactionInfo = GetWatchedFactionInfo

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function Reputation:CreateBar()
	if (not Settings["reputation-enable"]) then
		self:UnregisterAllEvents()
		
		return
	end
	
	self:SetScaledSize(Settings["reputation-width"], Settings["reputation-height"])
	self:SetScaledPoint("TOP", UIParent, 0, -13)
	self:SetFrameStrata("HIGH")
	
	self.Fade = CreateAnimationGroup(self)
	
	self.FadeIn = self.Fade:CreateAnimation("Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.15)
	self.FadeIn:SetChange(1)
	
	self.FadeOut = self.Fade:CreateAnimation("Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.15)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.BarBG = CreateFrame("Frame", nil, self)
	self.BarBG:SetScaledPoint("TOPLEFT", self, 0, 0)
	self.BarBG:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColorHex(Settings["ui-window-main-color"])
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Texture = self.BarBG:CreateTexture(nil, "ARTWORK")
	self.Texture:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Texture:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColorHex(Settings["ui-window-main-color"])
	
	self.BGAll = CreateFrame("Frame", nil, self)
	self.BGAll:SetScaledPoint("TOPLEFT", self.BarBG, -3, 3)
	self.BGAll:SetScaledPoint("BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColorHex(Settings["ui-window-bg-color"])
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColorHex(Settings["ui-window-main-color"])
	self.Bar.BG:SetAlpha(0.2)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "OVERLAY")
	self.Bar.Spark:SetDrawLayer("OVERLAY", 7)
	self.Bar.Spark:SetScaledSize(1, Settings["reputation-height"])
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
	self.Change:SetEasing("inout")
	self.Change:SetDuration(0.3)
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetScaledPoint("LEFT", self.Bar, 5, 0)
	self.Progress:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetScaledPoint("RIGHT", self.Bar, -5, 0)
	self.Percentage:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
end

function Reputation:OnEvent()
	local Name, Standing, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if Name then
		Max = Max - Min
		Value = Value - Min
		
		self.Bar:SetMinMaxValues(0, Max)
		self.Bar:SetStatusBarColorHex(Settings["color-reaction-" .. Standing])
		
		self.Progress:SetText(format("%s: %s / %s", Name, vUI:Comma(Value), vUI:Comma(Max)))
		self.Percentage:SetText(floor((Value / Max * 100 + 0.05) * 10) / 10 .. "%")
		
		self.Change:SetChange(Value)
		self.Change:Play()
		
		if (not self:IsShown()) then
			self:Show()
			self.FadeIn:Play()
		end
	elseif self:IsShown() then
		self.FadeOut:Play()
	end
end

function Reputation:Load()
	self:CreateBar()
	self:OnEvent()
	
	self:RegisterEvent("UPDATE_FACTION")
	self:SetScript("OnEvent", self.OnEvent)
end