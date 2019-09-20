local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

-- The most important file there is.

-- To do: A bag slot visualizer (Yes, like FFXIV)
-- black square, 2x2 pixels inside, colored by what's in the slot if occupied, 0.3 opacity or something if it's an empty slot.
-- Highlight x cheapest items in bags. x should be optional

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local match = string.match
local tostring = tostring
local select = select
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local UseContainerItem = UseContainerItem
local GetItemInfo = GetItemInfo
local PickupMerchantItem = PickupMerchantItem
local GetFramerate = GetFramerate

--[[ This is currently just a test page to see how GUI controls work, and debug them.
GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow("Test")
	
	Left:CreateHeader(Language["Checkboxes"])
	Left:CreateSwitch("test-checkbox-1", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-checkbox-2", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-checkbox-3", false, "Checkbox Demo", "Show the textuals", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
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
end)
]]
GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Debug"])
	
	Left:CreateHeader(Language["UI Information"])
	Left:CreateDoubleLine(Language["UI Version"], vUI.UIVersion)
	Left:CreateDoubleLine(Language["Game Version"], vUI.GameVersion)
	Left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	Left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	Left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	Left:CreateDoubleLine(Language["Fullscreen"], vUI.IsFullScreen)
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

local AutoVendor = vUI:NewModule("Auto Vendor") -- Auto sell useless items

AutoVendor.Filter = {
	[6196] = true,
}

AutoVendor:SetScript("OnEvent", function(self, event)
	local Profit = 0
	local TotalCount = 0
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID and not self.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local SellPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				if ((SellPrice and (SellPrice > 0)) and Count) then
					TotalPrice = SellPrice * Count
				end
				
				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					UseContainerItem(Bag, Slot)
					PickupMerchantItem()
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end
	
	if (Profit > 0 and Settings["auto-vendor-report"]) then
		vUI:print(format(Language["You sold %d items for a total of %s"], TotalCount, GetCoinTextureString(Profit)))
	end
end)

function AutoVendor:Load()
	if Settings["auto-vendor-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
	end
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
				
				if (CoinString and Settings["auto-repair-report"]) then
					vUI:print(format(Language["Your equipment has been repaired for %s"], CoinString))
				end
			else
				local Required = Cost - Money
				
				CoinString = GetCoinTextureString(Required)
				
				if (CoinString and Settings["auto-repair-report"]) then
					vUI:print(format(Language["You require %s to repair"], CoinString))
				end
			end
		end
	end
end)

function AutoRepair:Load()
	if Settings["auto-repair-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
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

local UpdateAutoVendor = function(value)
	if value then
		AutoVendor:RegisterEvent("MERCHANT_SHOW")
	else
		AutoVendor:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateAutoRepair = function(value)
	if value then
		AutoRepair:RegisterEvent("MERCHANT_SHOW")
	else
		AutoRepair:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateBagLooting = function(value)
	SetInsertItemsLeftToRight(value)
end

local Taxi = vUI:NewModule("Taxi")

local TaxiOnEvent = function(self)
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

Taxi:RegisterEvent("PLAYER_ENTERING_WORLD")
Taxi:SetScript("OnEvent", function(self, event)
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
	TaxiFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	TaxiFrame:SetScript("OnEvent", TaxiOnEvent)
	
    if UnitOnTaxi("player") then
        TaxiFrame:Show()
    else
		TaxiFrame:Hide()
    end
	
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
	
	
end)

local BagSearch = vUI:NewModule("Bag Search")

local SearchOnTextChanged = function(self)
	local Text = self:GetText()
	
	if Text then
		SetItemSearch(Text)
	end
end

local SearchOnEnterPressed = function(self)
	self:ClearFocus()
	self:SetText("")
end

local SearchOnEditFocusLost = function(self)
	SetItemSearch("")
end

function BagSearch:Load()
	local Search = CreateFrame("EditBox", nil, ContainerFrame1, "InputBoxTemplate")
	Search:SetScaledPoint("TOPRIGHT", ContainerFrame1, -10, -24)
	Search:SetScaledSize(120, 30)
	Search:SetFrameLevel(ContainerFrame1:GetFrameLevel() + 10)
	Search:SetAutoFocus(false)
	Search:SetScript("OnTextChanged", SearchOnTextChanged)
	Search:SetScript("OnEnterPressed", SearchOnEnterPressed)
	Search:SetScript("OnEscapePressed", SearchOnEnterPressed)
	Search:SetScript("OnEditFocusLost", SearchOnEditFocusLost)
end

--[[local Icon = UIParent:CreateTexture(nil, "OVERLAY")
Icon:SetScaledSize(32, 32)
Icon:SetScaledPoint("CENTER")
Icon:SetTexture(Media:GetTexture("Warning"))
Icon:SetVertexColorHex("FFEB3B")]]

--[[ 

Delete cheapest item
clear item space when you need to
pop a dialog
--]]

local Delete = vUI:NewModule("Delete")

Delete.FilterIDs = {}
Delete.FilterClassIDs = {}

function Delete:UpdateFilterTradeskills(value)
	self.Filter[2901] = value -- Mining Pick
	self.Filter[5956] = value -- Blacksmith Hammer
	self.Filter[6219] = value -- Arclight Spanner
	self.Filter[6256] = value -- Fishing Pole
	self.Filter[7005] = value -- Skinning Knife
	
	self.Filter[6218] = value -- Runed Copper Rod
	self.Filter[7795] = value -- Runed Silver Rod
	self.Filter[13628] = value -- Runed Golden Rod
	self.Filter[13702] = value -- Runed Truesilver Rod
	self.Filter[20051] = value -- Runed Arcanite Rod
end

function Delete:UpdateFilterConsumable(value)
	self.FilterClassIDs[0] = value
end

function Delete:UpdateFilterContainer(value)
	self.FilterClassIDs[1] = value
end

function Delete:UpdateFilterWeapon(value)
	self.FilterClassIDs[2] = value
end

function Delete:UpdateFilterArmor(value)
	self.FilterClassIDs[4] = value
end

function Delete:UpdateFilterReagent(value)
	self.FilterClassIDs[5] = value
end

function Delete:UpdateFilterTradeskill(value)
	self.FilterClassIDs[7] = value
end

function Delete:EvaluateItem(link)
	local ItemType, ItemSubType, _, _, _, _, ClassID, SubClassID = select(6, GetItemInfo(link))
	local ID = match(link, ":(%w+)")
	
	if (self.FilterIDs[ID] or self.FilterClassIDs[ClassID]) then
		return
	end
	
	return true
end

function Delete:GetCheapestItem()
	local CheapestItem
	local CheapestValue
	local CheapestBag
	local CheapestSlot
	local CheapestCount
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID) then
				local SellPrice = select(11, GetItemInfo(Link))
				
				if (SellPrice and (SellPrice > 0) and self:EvaluateItem(Link)) then
					local Count = select(2, GetContainerItemInfo(Bag, Slot))
					
					if Count then
						SellPrice = SellPrice * Count
					end
					
					if ((not CheapestValue) or (SellPrice < CheapestValue)) then
						CheapestItem = Link
						CheapestValue = SellPrice
						CheapestCount = Count
						CheapestBag = Bag
						CheapestSlot = Slot
					end
				end
			end
		end
	end
	
	return CheapestItem, CheapestValue, CheapestCount, CheapestBag, CheapestSlot
end

function Delete:PrintCheapestItem()
	local Item, Value, Count = self:GetCheapestItem()
	
	if (Item and Value) then
		if (Count > 1) then
			vUI:print(format(Language["The cheapest vendorable item in your inventory is currently %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			vUI:print(format(Language["The cheapest vendorable item in your inventory is currently %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		vUI:print(Language["No valid items were found"])
	end
end

function Delete:DeleteCheapestItem()
	local Item, Value, Count, Bag, Slot = self:GetCheapestItem()
	
	if (Bag and Slot) then
		PickupContainerItem(Bag, Slot)
		DeleteCursorItem()
		
		if (Count > 1) then
			vUI:print(format(Language["Deleted %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			vUI:print(format(Language["Deleted %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		vUI:print(Language["No valid items were found"])
	end
end

local PrintCheapest = function()
	vUI:GetModule("Delete"):PrintCheapestItem()
end

local OnAccept = function(self)
	vUI:GetModule("Delete"):DeleteCheapestItem()
end

local DeleteCheapest = function()
	local Item, Value, Count = Delete:GetCheapestItem()
	
	if (Count > 1) then
		vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %sx%s?"], Item, Count), "Accept", OnAccept, "Cancel", nil)
	else
		vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %s?"], Item), "Accept", OnAccept, "Cancel", nil)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Misc."])
	
	Left:CreateHeader(Language["Miscellaneous Modules"])
	Left:CreateSwitch("bags-frame-show", Settings["bags-frame-show"], Language["Enable Bags Frame"], "Display the bag container frame", UpdateShowBagsFrame)
	Left:CreateSwitch("micro-buttons-show", Settings["micro-buttons-show"], Language["Enable Micro Buttons"], "Enable micro menu buttons", UpdateShowMicroButtons)
	Left:CreateSwitch("bags-loot-from-left", Settings["bags-loot-from-left"], Language["Loot Left To Right"], "When looting, new items will be|nplaced into the leftmost bag", UpdateBagLooting)
	
	Left:CreateHeader(Language["Inventory"])
	Left:CreateButton(Language["Search"], Language["Find Cheapest Item"], "Find the cheapest item|ncurrently in your inventory", PrintCheapest)
	Left:CreateButton(Language["Delete"], Language["Delete Cheapest Item"], "Delete the cheapest item|ncurrently in your inventory", DeleteCheapest)
	
	Right:CreateHeader(Language["Merchant"])
	Right:CreateSwitch("auto-repair-enable", Settings["auto-repair-enable"], Language["Auto Repair Equipment"], "Automatically repair damaged items|nwhen visiting a repair merchant", UpdateAutoRepair)
	Right:CreateSwitch("auto-repair-report", Settings["auto-repair-report"], Language["Auto Repair Report"], "Report the cost of automatic repairs into the chat")
	Right:CreateSwitch("auto-vendor-enable", Settings["auto-vendor-enable"], Language["Auto Vendor Greys"], "Automatically sell all |cFF9D9D9D[Poor]|r quality items", UpdateAutoVendor)
	Right:CreateSwitch("auto-vendor-report", Settings["auto-vendor-report"], Language["Auto Vendor Report"], "Report the profit of automatic vendoring into the chat")

	--Right:CreateHeader(Language["Announcements"])
	--Right:CreateSwitch("announcements-enable", Settings["announcements-enable"], Language["Enable Announcements"], "Announce actions to a specified channel")
	--Right:CreateDropdown("announcements-channel", Settings["announcements-channel"], {[Language["Group"]] = "GROUP", [Language["Say"]] = "SAY", [Language["Macro"]] = "MACRO", [Language["Self"]] = "SELF"}, Language["Set Channel"], "Set the channel to send announcements to")
	
	SetInsertItemsLeftToRight(Settings["bags-loot-from-left"])
	
	Left:CreateFooter()
	Right:CreateFooter()
end)