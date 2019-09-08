local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

-- The most important file there is.

-- Cinematic Mode with black lines on the top and bottom of the screen. Reposition the UI parent
-- Notification system with a bell icon under the minimap or something. This is just a small log where it shows things like version handshakes, update news etc

-- To do: A bag slot visualizer (Yes, like FFXIV)
-- black square, 2x2 pixels inside, colored by what's in the slot if occupied, 0.3 opacity or something if it's an empty slot.

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local tostring = tostring

local GetFramerate = GetFramerate

--[[ This is currently just a test page to see how GUI controls work, and debug them.
GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow("Test")
	
	Left:CreateHeader(Language["Checkboxes"])
	Left:CreateCheckbox("test-checkbox-1", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateCheckbox("test-checkbox-2", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateCheckbox("test-checkbox-3", false, "Checkbox Demo", "Show the textuals", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Right:CreateHeader(Language["Selections"])
	Right:CreateDropdown("test-dropdown-1", "Roboto", Media:GetFontList(), "Font Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Font")
	Right:CreateDropdown("test-dropdown-2", "Blank", Media:GetTextureList(), "Texture Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	Right:CreateDropdown("test-dropdown-3", "RenHorizonUp", Media:GetHighlightList(), "Highlight Menu Demo", "", function(v, id)vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	
	Right:CreateHeader(Language["Sliders"])
	Right:CreateSlider("test-slider-1", 3, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Right:CreateSlider("test-slider-2", 7, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " px")
	Right:CreateSlider("test-slider-3", 4, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " s")
	
	Right:CreateHeader(Language["Buttons"])
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-1") end)
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-2") end)
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI.Throttle:Create("test1", 10) if vUI.Throttle:IsThrottled("test1") then print('throttled:'..vUI:FormatTime(vUI.Throttle:GetRemaining("test1"))) else vUI.Throttle:Start("test1") print("starting") end end)
	
	Left:CreateHeader(Language["Switches"])
	Left:CreateSwitch("test-switch-1", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-switch-2", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-switch-3", false, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Left:CreateHeader(Language["Colors"])
	Left:CreateColorSelection("test-color-1", "B0BEC5", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateColorSelection("test-color-2", "607D8B", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateColorSelection("test-color-3", "263238", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Left:CreateHeader(Language["StatusBars"])
	
	local Bar = Left:CreateStatusBar(0, 0, 0, "Statusbar Demo", "", function(v)
		Framerate = floor(GetFramerate())
		
		return 0, 350, Framerate, Framerate
	end)
	
	Left:CreateStatusBar(5, 0, 10, "Statusbar Demo", "")
	Left:CreateStatusBar(75, 0, 100, "Statusbar Demo", "", nil, "%")
	
	Bar.Ela = 0
	Bar:SetScript("OnUpdate", function(self, ela)
		self.Ela = self.Ela + ela
		
		if (self.Ela >= 1) then
			local Min, Max, Value, Text = self.Hook()
			
			self:SetMinMaxValues(Min, Max)
			self.MiddleText:SetText(Text)
			
			self.Anim:SetChange(Value)
			self.Anim:Play()
			
			self.Ela = 0
		end
	end)
	
	Bar:GetScript("OnUpdate")(Bar, 1)
	
	Right:CreateHeader(Language["Lines"])
	Right:CreateLine("Test Line 1")
	Right:CreateLine("Test Line 2")
	Right:CreateLine("Test Line 3")
	
	Right:CreateHeader(Language["Double Lines"])
	Right:CreateDoubleLine("Left Line 1", "Right Line 1")
	Right:CreateDoubleLine("Left Line 2", "Right Line 2")
	Right:CreateDoubleLine("Left Line 3", "Right Line 3")
	
	Left:CreateHeader(Language["Inputs"])
	Left:CreateInput("test-input-1", vUI.UserName, "Test Input 1", nil, function(v) print(v) end)
	Left:CreateInput("test-input-2", vUI.UserName, "Test Input 2", nil, function(v) print(v) end)
	Left:CreateInput("test-input-3", vUI.UserName, "Test Input 3", nil, function(v) print(v) end)
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	-- Testing
	self:CreateWindow("Misc.")
	self:CreateWindow("Search")
end)
]]
GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Debug"])
	
	Left:CreateHeader(Language["UI Information"])
	Left:CreateDoubleLine(Language["UI Version"], vUI.UIVersion)
	Left:CreateDoubleLine(Language["Game Version"], vUI.GameVersion)
	Left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	Left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	--Left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	Left:CreateDoubleLine(Language["Profile"], Profiles:GetActiveProfileName())
	Left:CreateDoubleLine(Language["Style"], Settings["ui-style"])
	Left:CreateDoubleLine(Language["Locale"], vUI.UserLocale)
	--Left:CreateDoubleLine(Language["Language"], Settings["ui-language"])
	
	Right:CreateHeader(Language["User Information"])
	Right:CreateDoubleLine(Language["User"], vUI.UserName)
	Right:CreateDoubleLine(Language["Level"], UnitLevel("player"))
	Right:CreateDoubleLine(Language["Race"], vUI.UserRace)
	Right:CreateDoubleLine(Language["Class"], vUI.UserClassName)
	Right:CreateDoubleLine(Language["Realm"], vUI.UserRealm)
	Right:CreateDoubleLine(Language["Zone"], GetZoneText())
	Right:CreateDoubleLine(Language["Sub Zone"], GetMinimapZoneText())
	
	Left:CreateFooter()
	Right:CreateFooter()
end)

local UpdateZone = CreateFrame("Frame")
UpdateZone:RegisterEvent("ZONE_CHANGED")
UpdateZone:RegisterEvent("ZONE_CHANGED_INDOORS")
UpdateZone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
UpdateZone:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdateZone:SetScript("OnEvent", function(self)
	if GUI:IsShown() then
		GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
		GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
	end
end)

local Fonts = vUI:NewModule("Fonts")

function Fonts:Load()
	local WidgetFont = Media:GetFont(Settings["ui-widget-font"])

	UNIT_NAME_FONT = WidgetFont
	--NAMEPLATE_FONT = WidgetFont
	DAMAGE_TEXT_FONT = WidgetFont
	STANDARD_TEXT_FONT = WidgetFont
	
	AutoFollowStatusText:SetFontInfo(WidgetFont, 18)
end

local BagsFrame = vUI:NewModule("Bags Frame")
local Move = vUI:GetModule("Move")

BagsFrame.Objects = {
	CharacterBag3Slot,
	CharacterBag2Slot,
	CharacterBag1Slot,
	CharacterBag0Slot,
	MainMenuBarBackpackButton,
}

function BagsFrame:Load()
	local Panel = CreateFrame("Frame", "vUI Bags Window", UIParent)
	Panel:SetScaledSize(184, 40)
	Panel:SetScaledPoint("BOTTOMRIGHT", -10, 10)
	Panel:SetBackdrop(vUI.BackdropAndBorder)
	Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Panel:SetBackdropBorderColor(0, 0, 0)
	Panel:SetFrameStrata("LOW")
	Move:Add(Panel)
	
	local Object
	
	for i = 1, #self.Objects do
		Object = self.Objects[i]
		
		Object:SetParent(Panel)
		Object:ClearAllPoints()
		Object:SetScaledSize(32, 32)
		
		local Name = Object:GetName()
		local Normal = _G[Name .. "NormalTexture"]
		local Count = _G[Name .. "Count"]
		local Stock = _G[Name .. "Stock"]
		
		if Normal then
			Normal:SetTexture(nil)
		end
		
		if Count then
			Count:ClearAllPoints()
			Count:SetScaledPoint("BOTTOMRIGHT", 0, 2)
			Count:SetJustifyH("RIGHT")
			Count:SetFontInfo(Settings["ui-widget-font"], 12)
		end
		
		if Stock then
			Stock:ClearAllPoints()
			Stock:SetScaledPoint("TOPLEFT", 0, -2)
			Stock:SetJustifyH("LEFT")
			Stock:SetFontInfo(Settings["ui-widget-font"], 12)
		end
		
		if Object.icon then
			Object.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		
		Object.BG = Object:CreateTexture(nil, "BACKGROUND")
		Object.BG:SetScaledPoint("TOPLEFT", Object, -1, 1)
		Object.BG:SetScaledPoint("BOTTOMRIGHT", Object, 1, -1)
		Object.BG:SetColorTexture(0, 0, 0)
		
		local Checked = Object:CreateTexture(nil, "ARTWORK")
		Checked:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Checked:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Checked:SetColorTexture(0.1, 0.8, 0.1)
		Checked:SetAlpha(0.2)
		
		Object:SetCheckedTexture(Checked)
		
		local Highlight = Object:CreateTexture(nil, "ARTWORK")
		Highlight:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Highlight:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Highlight:SetColorTexture(1, 1, 1)
		Highlight:SetAlpha(0.2)
		
		Object:SetHighlightTexture(Highlight)
		
		local Pushed = Object:CreateTexture(nil, "ARTWORK", 7)
		Pushed:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Pushed:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Pushed:SetColorTexture(0.2, 0.9, 0.2)
		Pushed:SetAlpha(0.4)
		
		Object:SetPushedTexture(Pushed)
		
		if (i == 1) then
			Object:SetScaledPoint("LEFT", Panel, 4, 0)
		else
			Object:SetScaledPoint("LEFT", self.Objects[i-1], "RIGHT", 4, 0)
		end
	end
	
	if (not Settings["bags-frame-show"]) then
		Panel:Hide()
	end
	
	self.Panel = Panel
end

local MicroButtons = vUI:NewModule("Micro Buttons")

MicroButtons.Buttons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	WorldMapMicroButton,
	MainMenuMicroButton,
	HelpMicroButton,
}

function MicroButtons:Load()
	local Panel = CreateFrame("Frame", "vUI Micro Buttons", UIParent)
	Panel:SetScaledSize(232, 38)
	Panel:SetScaledPoint("BOTTOMRIGHT", BagsFrame.Panel, "BOTTOMLEFT", -2, 0)
	Panel:SetBackdrop(vUI.BackdropAndBorder)
	Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Panel:SetBackdropBorderColor(0, 0, 0)
	Panel:SetFrameStrata("LOW")
	Move:Add(Panel)
	
	local Button
	
	for i = 1, #self.Buttons do
		Button = self.Buttons[i]
		
		Button:SetParent(Panel)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOPLEFT", Panel, 0, 20)
		else
			Button:SetScaledPoint("LEFT", self.Buttons[i-1], "RIGHT", 0, 0)
		end
	end
	
	if (not Settings["micro-buttons-show"]) then
		Panel:Hide()
	end
	
	self.Panel = Panel
end

local AutoRepair = vUI:NewModule("Auto Repair") -- Check against the rep with the faction of the merchant, add option to repair if honored +

AutoRepair:SetScript("OnEvent", function(self, event)
	local Money = GetMoney()
	
	if CanMerchantRepair() then
		local Cost = GetRepairAllCost()
		local CoinString
		
		if (Cost > 0) then
			if (Money > Cost) then
				RepairAllItems()
				
				local CoinString = GetCoinTextureString(Cost)
				
				if CoinString then
					vUI:print(format(Language["Your equipment has been repaired for %s"], CoinString))
				end
			else
				local Required = Cost - Money
				
				CoinString = GetCoinTextureString(Required)
				
				if CoinString then
					vUI:print(format(Language["You require %s to repair"], CoinString))
				end
			end
		end
	end
end)

function AutoRepair:Load()
	if Settings["auto-repair-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
	else
		self:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateShowMicroButtons = function(value)
	if value then
		MicroButtons.Panel:Show()
	else
		MicroButtons.Panel:Hide()
	end
end

local UpdateShowBagsFrame = function(value)
	if value then
		BagsFrame.Panel:Show()
	else
		BagsFrame.Panel:Hide()
	end
end

local UpdateAutoRepair = function(value)
	if value then
		AutoRepair:RegisterEvent("MERCHANT_SHOW")
	else
		AutoRepair:UnregisterEvent("MERCHANT_SHOW")
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Misc."])
	
	Left:CreateHeader(Language["Miscellaneous Modules"])
	Left:CreateCheckbox("bags-frame-show", Settings["bags-frame-show"], Language["Enable Bags Frame"], "", UpdateShowBagsFrame)
	Left:CreateCheckbox("micro-buttons-show", Settings["micro-buttons-show"], Language["Enable Micro Buttons"], "", UpdateShowMicroButtons)
	Left:CreateCheckbox("auto-repair-enable", Settings["auto-repair-enable"], Language["Enable Auto Repair"], "", UpdateAutoRepair)
	
	Left:CreateFooter()
end)

local Taxi = vUI:NewModule("Taxi")

local OnEvent = function(self, event)
    if UnitOnTaxi("player") then
        self:Show()
    else
		self:Hide()
    end
end

local RequestLanding = function(self)
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
		self:Hide()
    end
end

local OnEnter = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-widget-font-color"])
	
	GameTooltip:SetOwner(Taxi.Frame, "ANCHOR_PRESERVE")
	GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, R, G, B)
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

function Taxi:Load()
	local TaxiFrame = CreateFrame("Frame", "vUI Taxi", UIParent)
	TaxiFrame:SetScaledSize(Settings["minimap-size"] + 8, 22)
	TaxiFrame:SetScaledPoint("TOP", _G["vUI Minimap"], "BOTTOM", 0, -2)
	TaxiFrame:SetBackdrop(vUI.BackdropAndBorder)
	TaxiFrame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	TaxiFrame:SetBackdropBorderColor(0, 0, 0)
	TaxiFrame:SetFrameStrata("HIGH")
	TaxiFrame:SetFrameLevel(10)
	TaxiFrame:SetScript("OnMouseUp", RequestLanding)
	TaxiFrame:SetScript("OnEnter", OnEnter)
	TaxiFrame:SetScript("OnLeave", OnLeave)
	TaxiFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TaxiFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	TaxiFrame:SetScript("OnEvent", OnEvent)
	TaxiFrame:Hide()
	
	TaxiFrame.Tex = TaxiFrame:CreateTexture(nil, "ARTWORK")
	TaxiFrame.Tex:SetPoint("TOPLEFT", TaxiFrame, 1, -1)
	TaxiFrame.Tex:SetPoint("BOTTOMRIGHT", TaxiFrame, -1, 1)
	TaxiFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	TaxiFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	TaxiFrame.Text = TaxiFrame:CreateFontString(nil, "OVERLAY", 7)
	TaxiFrame.Text:SetScaledPoint("CENTER", TaxiFrame, 0, -1)
	TaxiFrame.Text:SetFontInfo(Settings["ui-header-font"], 12)
	TaxiFrame.Text:SetScaledSize(TaxiFrame:GetWidth() - 12, 20)
	TaxiFrame.Text:SetText(Language["Land Early"])
	
	self.Frame = TaxiFrame
end