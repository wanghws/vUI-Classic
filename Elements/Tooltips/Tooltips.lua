local vUI, GUI, Language, Media, Settings = select(2, ...):get()

-- Super minimal, don't judge me. So much to do in this file, but I'm just laying out something basic here
local Tooltips = vUI:NewModule("Tooltips")

local select = select
local find = string.find

Tooltips.Handled = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	AutoCompleteBox,
	FriendsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	EmbeddedItemTooltip,
}

local UpdateFonts = function(self)
	for i = 1, self:GetNumRegions() do
		local Region = select(i, self:GetRegions())
		
		if (Region:GetObjectType() == "FontString" and not Region.Handled) then
			Region:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1, -1)
			Region.Handled = true
		end
	end
	
	-- What a pain in the ass
	for i = 1, self:GetNumChildren() do
		local Child = select(i, self:GetChildren())
		
		if (Child and Child.GetName and Child:GetName() ~= nil and find(Child:GetName(), "MoneyFrame")) then
			local Prefix = _G[Child:GetName() .. "PrefixText"]
			local Suffix = _G[Child:GetName() .. "SuffixText"]
			
			if (Prefix and not Prefix.Handled) then
				Prefix:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
				Prefix:SetShadowColor(0, 0, 0)
				Prefix:SetShadowOffset(1, -1)
				Prefix.SetFont = function() end
				Prefix.SetFontObject = function() end
				Prefix.Handled = true
			end
			
			if (Suffix and not Suffix.Handled) then
				Suffix:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
				Suffix:SetShadowColor(0, 0, 0)
				Suffix:SetShadowOffset(1, -1)
				Suffix.SetFont = function() end
				Suffix.SetFontObject = function() end
				Suffix.Handled = true
			end
		end
	end
	
	local MoneyFrame
	
	if self.numMoneyFrames then
		for i = 1, self.numMoneyFrames do
			MoneyFrame = _G[self:GetName() .. "MoneyFrame".. i]
			
			if (MoneyFrame and not MoneyFrame.Handled) then
				for j = 1, MoneyFrame:GetNumChildren() do
					local Region = select(j, MoneyFrame:GetChildren())
					
					if (Region and Region.GetName and Region:GetName()) then
						local Text = _G[Region:GetName() .. "Text"]
						
						if Text then
							Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
							Text:SetShadowColor(0, 0, 0)
							Text:SetShadowOffset(1, -1)
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
		UpdateFonts(self)
		
		return
	end
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropColorHex(Settings["ui-window-main-color"])
	
	self.OuterBG = CreateFrame("Frame", nil, self)
	self.OuterBG:SetScaledPoint("TOPLEFT", self, -3, 3)
	self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -3)
	self.OuterBG:SetBackdrop(vUI.BackdropAndBorder)
	self.OuterBG:SetBackdropBorderColor(0, 0, 0)
	self.OuterBG:SetFrameLevel(self:GetFrameLevel() - 1)
	self.OuterBG:SetFrameStrata("BACKGROUND")
	self.OuterBG:SetBackdropColorHex(Settings["ui-window-bg-color"])
	
	UpdateFonts(self)
end

local UnitPlayerControlled = UnitPlayerControlled
local UnitCanAttack = UnitCanAttack
local UnitIsPVP = UnitIsPVP
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local UnitExists = UnitExists
local UnitClass = UnitClass
local UnitRace = UnitRace
local find = string.find

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
		local Color = GetUnitColor(UnitID)
		
		if (Class == Name) then
			Class = ""
		end
		
		if Realm then
			GameTooltipTextLeft1:SetText(format("|cFF%s%s - %s|r", Color, Title, Realm))
		else
			GameTooltipTextLeft1:SetText(format("|cFF%s%s|r", Color, Title))
		end
		
		local Line
		
		for i = 1, self:NumLines() do
			Line = _G[self:GetName() .. "TextLeft" .. i]
			
			if Line and find(Line:GetText(), "^" .. LEVEL) then
				local LevelColor = vUI:UnitDifficultyColor(UnitID)
				
				if Race then
					Line:SetText(format("%s %s%s|r %s %s", LEVEL, LevelColor, Level, Race, Class))
				else
					Line:SetText(format("%s %s%s|r %s", LEVEL, LevelColor, Level, Class))
				end
				
				break
			end
		end
		
		if (UnitID ~= "player" and UnitExists(UnitID .. "target")) then
			local TargetColor = GetUnitColor(UnitID .. "target")
			
			self:AddLine(Language["|cFFFFFFFFTargeting: |cFF"] .. TargetColor .. UnitName(UnitID .. "target") .. "|r")
		end
		
		GameTooltipStatusBar:SetStatusBarColorHex(Color)
		
		if self.OuterBG then
			self.OuterBG:SetScaledPoint("TOPLEFT", self, -3, 3)
			self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self, 3, -15)
		end
	end
end

function Tooltips:AddHooks()
	for i = 1, #self.Handled do
		self.Handled[i]:HookScript("OnShow", SetStyle)
	end
	
	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
end

function Tooltips:StyleHealth()
	local HealthBar = GameTooltipStatusBar
	
	HealthBar:ClearAllPoints()
	HealthBar:SetScaledHeight(8)
	HealthBar:SetScaledPoint("TOPLEFT", HealthBar:GetParent(), "BOTTOMLEFT", 1, -3)
	HealthBar:SetScaledPoint("TOPRIGHT", HealthBar:GetParent(), "BOTTOMRIGHT", -1, -3)
	HealthBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	HealthBar.Backdrop = CreateFrame("Frame", nil, HealthBar)
	HealthBar.Backdrop:SetScaledPoint("TOPLEFT", HealthBar, -1, 1)
	HealthBar.Backdrop:SetScaledPoint("BOTTOMRIGHT", HealthBar, 1, -1)
	HealthBar.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	HealthBar.Backdrop:SetBackdropColor(0, 0, 0)
	HealthBar.Backdrop:SetBackdropBorderColor(0, 0, 0)
	HealthBar.Backdrop:SetFrameLevel(HealthBar:GetFrameLevel() - 1)
end

function Tooltips:Load()
	if (not Settings["tooltips-enable"]) then
		return
	end
	
	self:AddHooks()
	self:StyleHealth()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Tooltips"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("tooltips-enable", Settings["tooltips-enable"], Language["Enable Tooltips Module"], ""):RequiresReload(true)
end)