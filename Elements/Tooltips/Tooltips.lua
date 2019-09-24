local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Tooltips = vUI:NewModule("Tooltips")
local LCMH = LibStub("LibClassicMobHealth-1.0")
local MyGuild

local select = select
local find = string.find
local match = string.match
local floor = floor
local format = format
local UnitPlayerControlled = UnitPlayerControlled
local UnitCanAttack = UnitCanAttack
local UnitIsPVP = UnitIsPVP
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local UnitExists = UnitExists
local UnitClass = UnitClass
local GetGuildInfo = GetGuildInfo
local UnitRace = UnitRace
local UnitName = UnitName
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClassification = UnitClassification
local GetPetHappiness = GetPetHappiness
local GetMouseFocus = GetMouseFocus
local GetItemInfo = GetItemInfo
local GetCoinTextureString = GetCoinTextureString

Tooltips.Handled = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	--AutoCompleteBox,
	FriendsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	EmbeddedItemTooltip,
}

Tooltips.Classifications = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	["worldboss"] = Language["Boss"],
}

Tooltips.HappinessLevels = {
	[1] = Language["Unhappy"],
	[2] = Language["Content"],
	[3] = Language["Happy"]
}

local UpdateFonts = function(self)
	for i = 1, self:GetNumRegions() do
		local Region = select(i, self:GetRegions())
		
		if (Region:GetObjectType() == "FontString" and not Region.Handled) then
			Region:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
			Region.Handled = true
		end
	end
	
	for i = 1, self:GetNumChildren() do
		local Child = select(i, self:GetChildren())
		
		if (Child and Child.GetName and Child:GetName() ~= nil and find(Child:GetName(), "MoneyFrame")) then
			local Prefix = _G[Child:GetName() .. "PrefixText"]
			local Suffix = _G[Child:GetName() .. "SuffixText"]
			
			if (Prefix and not Prefix.Handled) then
				Prefix:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
				Prefix.SetFont = function() end
				Prefix.SetFontObject = function() end
				Prefix.Handled = true
			end
			
			if (Suffix and not Suffix.Handled) then
				Suffix:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
				Suffix.SetFont = function() end
				Suffix.SetFontObject = function() end
				Suffix.Handled = true
			end
		end
	end
	
	if self.numMoneyFrames then
		local MoneyFrame
		
		for i = 1, self.numMoneyFrames do
			MoneyFrame = _G[self:GetName() .. "MoneyFrame" .. i]
			
			if (MoneyFrame and not MoneyFrame.Handled) then
				for j = 1, MoneyFrame:GetNumChildren() do
					local Region = select(j, MoneyFrame:GetChildren())
					
					if (Region and Region.GetName and Region:GetName()) then
						local Text = _G[Region:GetName() .. "Text"]
						
						if Text then
							Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
							Text.SetFont = function() end
							Text.SetFontObject = function() end
						end
					end
				end
				
				MoneyFrame.Handled = true
			end
		end
	end
end

local SetStyle = function(self)
	if self.Styled then
	--	self.Backdrop:SetVertexColorHex(Settings["ui-window-main-color"])
		
		if (self.GetUnit and self:GetUnit()) then
			self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -22)
		else
			self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -3)
		end
		
		UpdateFonts(self)
		
		return
	end
	
	self:SetBackdrop(nil) -- To stop blue tooltips
	self:SetFrameLevel(10)
	self.SetFrameLevel = function() end
	
	self.Backdrop = CreateFrame("Frame", nil, self)
	self.Backdrop:SetAllPoints(self)
	self.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	self.Backdrop:SetBackdropBorderColor(0, 0, 0)
	self.Backdrop:SetBackdropColorHex(Settings["ui-window-main-color"])
	self.Backdrop:SetFrameStrata("TOOLTIP")
	self.Backdrop:SetFrameLevel(2)
	
	self.OuterBG = CreateFrame("Frame", nil, self)
	self.OuterBG:SetScaledPoint("TOPLEFT", self, -3, 3)
	self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -3)
	self.OuterBG:SetBackdrop(vUI.BackdropAndBorder)
	self.OuterBG:SetBackdropBorderColor(0, 0, 0)
	self.OuterBG:SetFrameStrata("TOOLTIP")
	self.OuterBG:SetFrameLevel(1)
	self.OuterBG:SetBackdropColorHex(Settings["ui-window-bg-color"])
	
	if (self == AutoCompleteBox) then
		for i = 1, AUTOCOMPLETE_MAX_BUTTONS do
			local Text = _G["AutoCompleteButton" .. i .. "Text"]
			
			Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
		end
		
		AutoCompleteInstructions:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
		
		AutoCompleteBox.Backdrop:SetFrameStrata("DIALOG")
		AutoCompleteBox.OuterBG:SetFrameStrata("DIALOG")
	end
	
	UpdateFonts(self)
	
	self.SetBackdrop = function() end
	
	self.Styled = true
end

local GetUnitColor = function(unit)
	local Color
	
	if UnitIsPlayer(unit) then
		local Class = select(2, UnitClass(unit))
		
		if Class then
			Color = vUI.ClassColors[Class]
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			Color = vUI.ReactionColors[Reaction]
		end
	end
	
	if Color then
		return vUI:RGBToHex(Color[1], Color[2], Color[3])
	else
		return "FFFFFF"
	end
end

local OnTooltipSetUnit = function(self)
	local Unit, UnitID = self:GetUnit()
	
	if UnitID then
		local Class = UnitClass(UnitID)
		
		if (not Class) then
			return
		end
		
		local Name, Realm = UnitName(UnitID)
		local Race = UnitRace(UnitID)
		local Level = UnitLevel(UnitID)
		local Title = UnitPVPName(UnitID)
		local Guild, Rank = GetGuildInfo(UnitID)
		local Color = GetUnitColor(UnitID)
		local Flag = ""
		local Line
		
		if (Class == Name) then
			Class = ""
		end
		
		if (Level == -1) then
			Level = "??"
		end
		
		if UnitIsAFK(UnitID) then
			Flag = "|cFFFDD835" .. CHAT_FLAG_AFK .. "|r "
		elseif UnitIsDND(UnitID) then 
			Flag = "|cFFF44336" .. CHAT_FLAG_DND .. "|r "
		end
		
		if Guild then
			if (Guild == MyGuild) then
				Guild = format("|cFF5DADE2<%s>|r", Guild)
			else
				Guild = format("|cFF66BB6A<%s>|r", Guild)
			end
		else
			Guild = ""
		end
		
		if Realm then
			GameTooltipTextLeft1:SetText(format("%s|cFF%s%s %s %s|r", Flag, Color, (Title or Name), Realm, Guild))
		else
			GameTooltipTextLeft1:SetText(format("%s|cFF%s%s %s|r", Flag, Color, (Title or Name), Guild))
		end
		
		for i = 2, self:NumLines() do
			Line = _G["GameTooltipTextLeft" .. i]
			
			if (Line and Line.GetText and find(Line:GetText(), "^" .. LEVEL)) then
				local LevelColor = vUI:UnitDifficultyColor(UnitID)
				
				if Race then
					Line:SetText(format("%s %s%s|r %s %s", LEVEL, LevelColor, Level, Race, Class))
				else
					Line:SetText(format("%s %s%s|r %s", LEVEL, LevelColor, Level, Class))
				end
			elseif (Line and find(Line:GetText(), PVP)) then
				Line:SetText(format("|cFFEE4D4D%s|r", PVP))
			end
		end
		
		if (UnitID ~= "player" and UnitExists(UnitID .. "target")) then
			local TargetColor = GetUnitColor(UnitID .. "target")
			
			self:AddLine(Language["Targeting: |cFF"] .. TargetColor .. UnitName(UnitID .. "target") .. "|r", 1, 1, 1)
		end
		
		if (vUI.UserClass == "HUNTER" and UnitID == "pet") then
			local Happiness = GetPetHappiness()
			
			if Happiness then
				local Color = vUI.HappinessColors[Happiness]
				
				if Color then
					self:AddDoubleLine(Language["Happiness:"], format("|cFF%s%s|r", vUI:RGBToHex(Color[1], Color[2], Color[3]), Tooltips.HappinessLevels[Happiness]))
				end
			end
		end
		
		--GameTooltipStatusBar:OldSetStatusBarColor(vUI:HexToRGB(Color))
		--GameTooltipStatusBar.BG:SetVertexColorHex(Color)
		
		if self.OuterBG then
			self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -22)
		end
	end
end

local OnTooltipSetItem = function(self)
	if (not Settings["tooltips-show-sell-value"]) then
		return
	end
	
	if (MerchantFrame and MerchantFrame:IsShown()) then
		return
	end
	
	local Link = select(2, self:GetItem())
	
	if (not Link) then
		return
	end
	
	local VendorPrice = select(11, GetItemInfo(Link))
	
	if VendorPrice then
		local Count = 1
		local MouseFocus = GetMouseFocus()
		
		if (MouseFocus and MouseFocus.count) then
			Count = MouseFocus.count
		end
		
		if (Count and type(Count) == "number") then
			local CopperValue = VendorPrice * Count
			
			if (CopperValue > 0) then
				local CoinString = GetCoinTextureString(CopperValue)
				
				if CoinString then
					self:AddLine(CoinString, 1, 1, 1)
				end
			end
		end
	end
	
	if Settings["tooltips-show-id"] then
		local ID = match(Link, ":(%w+)")
		
		self:AddLine(" ")
		self:AddDoubleLine(Language["Item ID:"], ID, 1, 1, 1, 1, 1, 1)
	end
end

local OnItemRefTooltipSetItem = function(self)
	local Item, Link = select(2, self:GetItem())
	
	if (not Link) then
		return
	end
	
	if Settings["tooltips-show-sell-value"] then
		local SellValue = select(11, GetItemInfo(Link))
		
		if (not SellValue) then
			return
		end
		
		local CoinString = GetCoinTextureString(SellValue)
		
		if CoinString then
			self:AddLine(CoinString, 1, 1, 1)
		end
	end
	
	if Settings["tooltips-show-id"] then
		local ID = match(Link, ":(%w+)")
		
		self:AddLine(" ")
		self:AddDoubleLine(Language["Item ID:"], ID, 1, 1, 1, 1, 1, 1)
	end
end

local OnTooltipSetSpell = function(self)
	if (not Settings["tooltips-show-id"]) then
		return
	end
	
	local ID = select(2, self:GetSpell())
	
	self:AddLine(" ")
	self:AddDoubleLine(Language["Spell ID:"], ID, 1, 1, 1, 1, 1, 1)
end

local SetTooltipDefaultAnchor = function(self, parent)
	if Settings["tooltips-on-cursor"] then
		self:SetOwner(parent, "ANCHOR_CURSOR", 0, 8)
		
		return
	end
	
	local Unit, UnitID = self:GetUnit()
	
	if (not UnitID) then
		local MouseFocus = GetMouseFocus()
		
		if MouseFocus and MouseFocus:GetAttribute("unit") then
			UnitID = MouseFocus:GetAttribute("unit")
		end
	end
	
	if (not UnitID and UnitExists("mouseover")) then
		UnitID = "mouseover"
	end
	
	self:ClearAllPoints()
	
	if UnitID then
		if vUIMetersFrame then
			self:SetScaledPoint("BOTTOMLEFT", vUIMetersFrame, "TOPLEFT", 3, 24)
		else
			self:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 120)
		end
	else
		if vUIMetersFrame then
			self:SetScaledPoint("BOTTOMLEFT", vUIMetersFrame, "TOPLEFT", 3, 5)
		else
			self:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 101)
		end
	end
end

Tooltips.GameTooltip_SetDefaultAnchor = function(self, parent)
	if Settings["tooltips-on-cursor"] then
		self:SetOwner(parent, "ANCHOR_CURSOR", 0, 8)
		
		return
	end
	
	local Unit, UnitID = self:GetUnit()
	
	if (not UnitID) then
		local MouseFocus = GetMouseFocus()
		
		if MouseFocus and MouseFocus:GetAttribute("unit") then
			UnitID = MouseFocus:GetAttribute("unit")
		end
	end
	
	if (not UnitID and UnitExists("mouseover")) then
		UnitID = "mouseover"
	end
	
	self:ClearAllPoints()
	
	if UnitID then
		if vUIMetersFrame then
			self:SetScaledPoint("BOTTOMLEFT", vUIMetersFrame, "TOPLEFT", 3, 24)
		else
			self:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 120)
		end
	else
		if vUIMetersFrame then
			self:SetScaledPoint("BOTTOMLEFT", vUIMetersFrame, "TOPLEFT", 3, 5)
		else
			self:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 101)
		end
	end
end

function Tooltips:AddHooks()
	for i = 1, #self.Handled do
		self.Handled[i]:HookScript("OnShow", SetStyle)
	end
	
	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
	GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
	ItemRefTooltip:HookScript("OnTooltipSetItem", OnItemRefTooltipSetItem)
	
	self:Hook("GameTooltip_SetDefaultAnchor")
	
--	hooksecurefunc("GameTooltip_SetDefaultAnchor", SetTooltipDefaultAnchor)
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local OnValueChanged = function(self)
	local Unit = select(2, self:GetParent():GetUnit())
	
	if (not Unit) then
		return
	end
	
	local Current, Max, Found = LCMH:GetUnitHealth(Unit)
	
	if (not Found) then
		Current = self:GetValue()
		Max = select(2, self:GetMinMaxValues())
	end
	
	local Color = vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
	
	if Unit then
		if UnitIsDead(Unit) then
			self.HealthValue:SetText("|cFFD64545" .. Language["Dead"] .. "|r")
		elseif UnitIsGhost(Unit) then
			self.HealthValue:SetText("|cFFEEEEEE" .. Language["Ghost"] .. "|r")
		else
			self.HealthValue:SetText(format("|cFF%s%s|r / |cFF2DCC70%s|r", Color, vUI:ShortValue(Current), vUI:ShortValue(Max)))
		end
		
		self.HealthPercent:SetText(format("|cFF%s%s|r", Color, floor(Current / Max * 100 + 0.5)))
	else
		self.HealthValue:SetText(format("|cFF%s%s|r / |cFF2DCC70%s|r", Color, vUI:ShortValue(Current), vUI:ShortValue(Max)))
		self.HealthPercent:SetText(format("|cFF%s%s|r", Color, floor(Current / Max * 100 + 0.5)))
	end
end

function Tooltips:StyleStatusBar()
	local HealthBar = GameTooltipStatusBar
	
	HealthBar:ClearAllPoints()
	HealthBar:SetScaledHeight(15)
	HealthBar:SetScaledPoint("TOPLEFT", HealthBar:GetParent(), "BOTTOMLEFT", 1, -3)
	HealthBar:SetScaledPoint("TOPRIGHT", HealthBar:GetParent(), "BOTTOMRIGHT", -1, -3)
	HealthBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBar:SetStatusBarColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	HealthBar.BG = HealthBar:CreateTexture(nil, "ARTWORK")
	HealthBar.BG:SetScaledPoint("TOPLEFT", HealthBar, 0, 0)
	HealthBar.BG:SetScaledPoint("BOTTOMRIGHT", HealthBar, 0, 0)
	HealthBar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBar.BG:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	HealthBar.BG:SetAlpha(0.2)
	
	HealthBar.Backdrop = CreateFrame("Frame", nil, HealthBar)
	HealthBar.Backdrop:SetScaledPoint("TOPLEFT", HealthBar, -1, 1)
	HealthBar.Backdrop:SetScaledPoint("BOTTOMRIGHT", HealthBar, 1, -1)
	HealthBar.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	HealthBar.Backdrop:SetBackdropColor(0, 0, 0)
	HealthBar.Backdrop:SetBackdropBorderColor(0, 0, 0)
	HealthBar.Backdrop:SetFrameLevel(HealthBar:GetFrameLevel() - 1)
	
	HealthBar.HealthValue = HealthBar:CreateFontString(nil, "OVERLAY")
	HealthBar.HealthValue:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthBar.HealthValue:SetScaledPoint("LEFT", HealthBar, 3, 0)
	HealthBar.HealthValue:SetJustifyH("LEFT")
	
	HealthBar.HealthPercent = HealthBar:CreateFontString(nil, "OVERLAY")
	HealthBar.HealthPercent:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthBar.HealthPercent:SetScaledPoint("RIGHT", HealthBar, -3, 0)
	HealthBar.HealthPercent:SetJustifyH("RIGHT")
	
	HealthBar:HookScript("OnValueChanged", OnValueChanged)
	HealthBar:HookScript("OnShow", OnValueChanged)
	
	HealthBar.OldSetStatusBarColor = HealthBar.SetStatusBarColor
	HealthBar.SetStatusBarColor = function() end
end

local ItemRefCloseOnEnter = function(self)
	self.Cross:SetVertexColorHex("C0392B")
end

local ItemRefCloseOnLeave = function(self)
	self.Cross:SetVertexColorHex("EEEEEE")
end

local ItemRefCloseOnMouseUp = function(self)
	self.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ItemRefTooltip:Hide()
end

local ItemRefCloseOnMouseDown = function(self)
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

function Tooltips:SkinItemRef()
	ItemRefCloseButton:Hide()
	
	-- Close button
	CloseButton = CreateFrame("Frame", nil, ItemRefTooltip)
	CloseButton:SetScaledSize(20, 20)
	CloseButton:SetScaledPoint("TOPRIGHT", ItemRefTooltip, -3, -3)
	CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	CloseButton:SetBackdropColor(0, 0, 0, 0)
	CloseButton:SetBackdropBorderColor(0, 0, 0)
	CloseButton:SetScript("OnEnter", ItemRefCloseOnEnter)
	CloseButton:SetScript("OnLeave", ItemRefCloseOnLeave)
	CloseButton:SetScript("OnMouseUp", ItemRefCloseOnMouseUp)
	CloseButton:SetScript("OnMouseDown", ItemRefCloseOnMouseDown)
	
	CloseButton.Texture = CloseButton:CreateTexture(nil, "ARTWORK")
	CloseButton.Texture:SetScaledPoint("TOPLEFT", CloseButton, 1, -1)
	CloseButton.Texture:SetScaledPoint("BOTTOMRIGHT", CloseButton, -1, 1)
	CloseButton.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	CloseButton.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	CloseButton.Cross = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Cross:SetPoint("CENTER", CloseButton, 0, 0)
	CloseButton.Cross:SetScaledSize(16, 16)
	CloseButton.Cross:SetTexture(Media:GetTexture("vUI Close"))
	CloseButton.Cross:SetVertexColorHex("EEEEEE")
	
	ItemRefTooltip.CloseButton = CloseButton
end

function Tooltips:Load()
	if (not Settings["tooltips-enable"]) then
		return
	end
	
	self:AddHooks()
	self:StyleStatusBar()
	self:SkinItemRef()
	
	if IsInGuild() then
		MyGuild = GetGuildInfo("player")
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Tooltips"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("tooltips-enable", Settings["tooltips-enable"], Language["Enable Tooltips Module"], ""):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSwitch("tooltips-on-cursor", Settings["tooltips-on-cursor"], Language["Tooltip On Cursor"], "Anchor the tooltip to the mouse cursor")
	Left:CreateSwitch("tooltips-show-sell-value", Settings["tooltips-show-sell-value"], Language["Display Item Sell Value"], "")
	Left:CreateSwitch("tooltips-show-id", Settings["tooltips-show-id"], Language["Display ID's"], "Dislay item and spell ID's in the tooltip")
	
	Left:CreateFooter()
end)