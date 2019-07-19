local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local type = type
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local match = string.match
local upper = string.upper
local lower = string.lower
local sub = string.sub
local floor = math.floor

GUI.Widgets = {}

--[[
	
	Thoughts:
	
	- Test different resolutions and find the pixel perfect scale for each. Then either set or suggest the scale
	
	- Debug window of the GUI. With info like ui scale, resolution, windowed, language, etc etc
	
	- Add Window.IgnoreScroll = true to stop a side of the window from scrolling. 
	
	To do:
	- Make GUI:NewWindow() return 2 values, both widget anchors. These can have the :CreateWidget methods so that you don't call Left/Right in each widget init
	
	- widgets:
	Input (longer editbox that accepts text input, as well as dropping spells/actions/items into it)
	
	- I can likely do 2 lined widgets by just creating 2 anchors and inserting them so that the scroll system still handles them just fine.
	
	Input label blah blah
	[      editbox on line below      ]
	
	- Widget methods
	
	widget:SetWarning(true) -- to determine if the widget should pop up a warning before proceeding
	widget:RequiresReload(true) -- to determine if the widget should pop up a warning before proceeding
	widget:Disable()
	widget:Enable()
--]]

-- Constants
local GUI_WIDTH = 710
local GUI_HEIGHT = 406
local SPACING = 3

local HEADER_WIDTH = GUI_WIDTH - (SPACING * 2)
local HEADER_HEIGHT = 22
local HEADER_SPACING = 5

local BUTTON_LIST_WIDTH = 126
local BUTTON_LIST_HEIGHT = (GUI_HEIGHT - HEADER_HEIGHT - (SPACING * 2) - 2)

local PARENT_WIDTH = GUI_WIDTH - BUTTON_LIST_WIDTH - ((SPACING * 2) + 2)
local PARENT_HEIGHT = (GUI_HEIGHT - HEADER_HEIGHT - (SPACING * 2) - 2)

local GROUP_HEIGHT = 80
local GROUP_WIDTH = 270
local GROUP_WIDGETHEIGHT = GROUP_HEIGHT - HEADER_HEIGHT + 1

local MENU_BUTTON_WIDTH = BUTTON_LIST_WIDTH - (SPACING * 2)
local MENU_BUTTON_HEIGHT = 20

local MAX_WIDGETS_SHOWN = 16

local WIDGET_HEIGHT = 20

local LABEL_SPACING = 3

local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local LAST_ACTIVE_DROPDOWN

local Ignore = {
	["ui-profile"] = true,
}

-- Functions
local SetVariable = function(id, value)
	if Ignore[id] then
		return
	end
	
	if vUIData["ui-profile"] then
		if (value ~= Defaults[id]) then -- Only saving a value if it's different than default
			vUIProfiles[vUIData["ui-profile"]][id] = value
		else
			vUIProfiles[vUIData["ui-profile"]][id] = nil
		end
	end
	
	Settings[id] = value
end

local HexToRGB = function(hex)
    return tonumber("0x"..sub(hex, 1, 2)) / 255, tonumber("0x"..sub(hex, 3, 4)) / 255, tonumber("0x"..sub(hex, 5, 6)) / 255
end

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)
	
	return floor(num * Mult + 0.5) / Mult
end

local TrimHex = function(s)
	local Subbed = match(s, "|c%x%x%x%x%x%x%x%x(.-)|r")
	
	return Subbed or s
end

local GetOrderedIndex = function(t)
    local OrderedIndex = {}
	
    for Key in pairs(t) do
        tinsert(OrderedIndex, Key)
    end
	
	tsort(OrderedIndex, function(a, b)
		return TrimHex(a) < TrimHex(b)
	end)
	
    return OrderedIndex
end

local OrderedNext = function(t, state)
	local OrderedIndex = GetOrderedIndex(t)
	local Key
	
    if (state == nil) then
        Key = OrderedIndex[1]
		
        return Key, t[Key]
    end
	
    for i = 1, #OrderedIndex do
        if (OrderedIndex[i] == state) then
            Key = OrderedIndex[i + 1]
        end
    end
	
    if Key then
        return Key, t[Key]
    end
	
    return
end

local PairsByKeys = function(t)
    return OrderedNext, t, nil
end

-- Widgets

-- Header
GUI.Widgets.CreateHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	-- Header
	local Header = CreateFrame("Frame", nil, Anchor)
	Header:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Header:SetScaledPoint("CENTER", Anchor, 0, 0)
	Header:SetBackdrop(vUI.BackdropAndBorder)
	Header:SetBackdropColor(HexToRGB(Settings["ui-header-texture-color"]))
	Header:SetBackdropBorderColor(0, 0, 0)
	
	Header.NewTexture = Header:CreateTexture(nil, "OVERLAY")
	Header.NewTexture:SetScaledPoint("TOPLEFT", Header, 1, -1)
	Header.NewTexture:SetScaledPoint("BOTTOMRIGHT", Header, -1, 1)
	Header.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Header.NewTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetScaledPoint("LEFT", Header, HEADER_SPACING, 0)
	Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 14)
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetShadowColor(0, 0, 0)
	Header.Text:SetShadowOffset(1, -1)
	Header.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Header
end

-- Button
local BUTTON_WIDTH = 130

local ButtonOnMouseUp = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.Hook then
		self.Hook()
	end
end

local ButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local ButtonWidgetOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	self.MiddleText:SetTextColor(HexToRGB(Settings["ui-widget-color"]))
end

local ButtonWidgetOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	self.MiddleText:SetTextColor(1, 1, 1)
end

GUI.Widgets.CreateButton = function(self, value, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	
	local Button = CreateFrame("Frame", nil, Anchor)
	Button:SetScaledSize(BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColor(0.17, 0.17, 0.17)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnMouseUp", ButtonOnMouseUp)
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnEnter", ButtonWidgetOnEnter)
	Button:SetScript("OnLeave", ButtonWidgetOnLeave)
	Button.Hook = hook
	Button.Tooltip = tooltip
	
	Button.Texture = Button:CreateTexture(nil, "BORDER")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetScaledPoint("CENTER", Button, "CENTER", 0, 0)
	Button.MiddleText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetShadowColor(0, 0, 0)
	Button.MiddleText:SetShadowOffset(1, -1)
	Button.MiddleText:SetText(value)
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetShadowColor(0, 0, 0)
	Button.Text:SetShadowOffset(1, -1)
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Button
end

-- StatusBar
local STATUSBAR_WIDTH = 100

GUI.Widgets.CreateStatusBar = function(self, value, minvalue, maxvalue, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	
	local Backdrop = CreateFrame("Frame", nil, Anchor)
	Backdrop:SetScaledSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Backdrop:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Backdrop:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Backdrop:SetBackdropBorderColor(0, 0, 0)
	Backdrop.Value = value
	--Backdrop.Hook = hook
	
	Backdrop.BG = Backdrop:CreateTexture(nil, "ARTWORK")
	Backdrop.BG:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Backdrop.BG:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Backdrop.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Backdrop.BG:SetVertexColor(HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Bar = CreateFrame("StatusBar", nil, Backdrop)
	Bar:SetScaledSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Bar:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Bar:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Bar:SetBackdrop(vUI.BackdropAndBorder)
	Bar:SetBackdropColor(0, 0, 0, 0)
	Bar:SetBackdropBorderColor(0, 0, 0, 0)
	Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Bar:SetStatusBarColor(HexToRGB(Settings["ui-widget-color"]))
	Bar:SetMinMaxValues(minvalue, maxvalue)
	Bar:SetValue(value)
	Bar.Hook = hook
	Bar.Tooltip = tooltip
	
	Bar.Anim = CreateAnimationGroup(Bar):CreateAnimation("progress")
	Bar.Anim:SetEasing("in")
	Bar.Anim:SetDuration(0.15)
	
	Bar.Spark = Bar:CreateTexture(nil, "ARTWORK")
	Bar.Spark:SetScaledSize(1, WIDGET_HEIGHT - 2)
	Bar.Spark:SetScaledPoint("LEFT", Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	Bar.Spark:SetTexture(Media:GetTexture("Blank"))
	Bar.Spark:SetVertexColor(0, 0, 0)
	
	Bar.MiddleText = Bar:CreateFontString(nil, "ARTWORK")
	Bar.MiddleText:SetScaledPoint("CENTER", Bar, "CENTER", 0, 0)
	Bar.MiddleText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Bar.MiddleText:SetJustifyH("CENTER")
	Bar.MiddleText:SetShadowColor(0, 0, 0)
	Bar.MiddleText:SetShadowOffset(1, -1)
	Bar.MiddleText:SetText(value)
	
	Bar.Text = Bar:CreateFontString(nil, "OVERLAY")
	Bar.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Bar.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Bar.Text:SetJustifyH("LEFT")
	Bar.Text:SetShadowColor(0, 0, 0)
	Bar.Text:SetShadowOffset(1, -1)
	Bar.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Bar
end

-- Checkbox
local CHECKBOX_WIDTH = 20

local CheckboxOnMouseUp = function(self)
	if self.Value then
		self.FadeOut:Play()
		self.Value = false
	else
		self.FadeIn:Play()
		self.Value = true
	end
	
	SetVariable(self.ID, self.Value)
	
	if self.Hook then
		self.Hook(self.Value, self.ID)
	end
end

local CheckboxOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local CheckboxOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

GUI.Widgets.CreateCheckbox = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	
	local Checkbox = CreateFrame("Frame", nil, Anchor)
	Checkbox:SetScaledSize(CHECKBOX_WIDTH, WIDGET_HEIGHT)
	Checkbox:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Checkbox:SetBackdrop(vUI.BackdropAndBorder)
	Checkbox:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Checkbox:SetBackdropBorderColor(0, 0, 0)
	Checkbox:SetScript("OnMouseUp", CheckboxOnMouseUp)
	Checkbox:SetScript("OnEnter", CheckboxOnEnter)
	Checkbox:SetScript("OnLeave", CheckboxOnLeave)
	Checkbox.Value = value
	Checkbox.Hook = hook
	Checkbox.Tooltip = tooltip
	Checkbox.ID = id
	
	Checkbox.BG = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.BG:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.BG:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.BG:SetVertexColor(HexToRGB(Settings["ui-widget-bg-color"]))
	
	Checkbox.Highlight = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Highlight:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Highlight:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Highlight:SetTexture(Media:GetTexture("Blank"))
	Checkbox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Checkbox.Highlight:SetAlpha(0)
	
	Checkbox.Texture = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.Texture:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Texture:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	Checkbox.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Checkbox.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Checkbox.Hover = Checkbox:CreateTexture(nil, "HIGHLIGHT")
	Checkbox.Hover:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Hover:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Hover:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	Checkbox.Hover:SetTexture(Media:GetTexture("RenHorizonUp"))
	Checkbox.Hover:SetAlpha(0)
	
	Checkbox.Fade = CreateAnimationGroup(Checkbox.Texture)
	
	Checkbox.FadeIn = Checkbox.Fade:CreateAnimation("Fade")
	Checkbox.FadeIn:SetEasing("in")
	Checkbox.FadeIn:SetDuration(0.15)
	Checkbox.FadeIn:SetChange(1)
	
	Checkbox.FadeOut = Checkbox.Fade:CreateAnimation("Fade")
	Checkbox.FadeOut:SetEasing("out")
	Checkbox.FadeOut:SetDuration(0.15)
	Checkbox.FadeOut:SetChange(0)
	
	if Checkbox.Value then
		Checkbox.Texture:SetAlpha(1)
	else
		Checkbox.Texture:SetAlpha(0)
	end
	
	tinsert(self.Widgets, Anchor)
	
	return Checkbox
end

-- Switch
local SWITCH_WIDTH = 50

local SwitchOnMouseUp = function(self)
	if self.Move:IsPlaying() then
		return
	end
	
	self.Thumb:ClearAllPoints()
	
	if self.Value then
		self.Thumb:SetScaledPoint("RIGHT", self, 0, 0)
		self.Move:SetOffset(-30, 0)
		self.Value = false
	else
		self.Thumb:SetScaledPoint("LEFT", self, 0, 0)
		self.Move:SetOffset(30, 0)
		self.Value = true
	end
	
	self.Move:Play()
	
	SetVariable(self.ID, self.Value)
	
	if self.Hook then
		self.Hook(self.Value, self.ID)
	end
end

local SwitchOnMouseWheel = function(self, delta)
	local CurrentValue = self.Value
	local NewValue
	
	if (delta < 0) then
		NewValue = false
	else
		NewValue = true
	end
	
	if (CurrentValue ~= NewValue) then
		SwitchOnMouseUp(self) -- This is already set up to handle everything, so just pass it along
	end
end

local SwitchOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local SwitchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

GUI.Widgets.CreateSwitch = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	
	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:SetScaledSize(SWITCH_WIDTH, WIDGET_HEIGHT)
	Switch:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Switch:SetBackdrop(vUI.BackdropAndBorder)
	Switch:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Switch:SetBackdropBorderColor(0, 0, 0)
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch:SetScript("OnMouseWheel", SwitchOnMouseWheel)
	Switch:SetScript("OnEnter", SwitchOnEnter)
	Switch:SetScript("OnLeave", SwitchOnLeave)
	Switch.Value = value
	Switch.Hook = hook
	Switch.Tooltip = tooltip
	Switch.ID = id
	
	Switch.BG = Switch:CreateTexture(nil, "ARTWORK")
	Switch.BG:SetScaledPoint("TOPLEFT", Switch, 1, -1)
	Switch.BG:SetScaledPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.BG:SetVertexColor(HexToRGB(Settings["ui-widget-bg-color"]))
	
	Switch.Thumb = CreateFrame("Frame", nil, Switch)
	Switch.Thumb:SetScaledSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Switch.Thumb:SetBackdrop(vUI.BackdropAndBorder)
	Switch.Thumb:SetBackdropBorderColor(0, 0, 0)
	Switch.Thumb:SetBackdropColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Switch.ThumbTexture = Switch.Thumb:CreateTexture(nil, "ARTWORK")
	Switch.ThumbTexture:SetScaledSize(WIDGET_HEIGHT - 2, WIDGET_HEIGHT - 2)
	Switch.ThumbTexture:SetScaledPoint("TOPLEFT", Switch.Thumb, 1, -1)
	Switch.ThumbTexture:SetScaledPoint("BOTTOMRIGHT", Switch.Thumb, -1, 1) -- the slider blur
	Switch.ThumbTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.ThumbTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Switch.Flavor = Switch:CreateTexture(nil, "ARTWORK")
	Switch.Flavor:SetScaledPoint("TOPLEFT", Switch, "TOPLEFT", 1, -1)
	Switch.Flavor:SetScaledPoint("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.Flavor:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.Flavor:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	Switch.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Switch.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Switch.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Switch.Text:SetJustifyH("LEFT")
	Switch.Text:SetShadowColor(0, 0, 0)
	Switch.Text:SetShadowOffset(1, -1)
	Switch.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Switch.Highlight = Switch:CreateTexture(nil, "HIGHLIGHT")
	Switch.Highlight:SetScaledPoint("TOPLEFT", Switch, 1, -1)
	Switch.Highlight:SetScaledPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.Highlight:SetTexture(Media:GetTexture("Blank"))
	Switch.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Switch.Highlight:SetAlpha(0)
	
	Switch.Move = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Move:SetEasing("in")
	Switch.Move:SetDuration(0.1)
	
	if Switch.Value then
		Switch.Thumb:SetScaledPoint("RIGHT", Switch, 0, 0)
	else
		Switch.Thumb:SetScaledPoint("LEFT", Switch, 0, 0)
	end
	
	tinsert(self.Widgets, Anchor)
	
	return Switch
end

-- Dropdown
local DROPDOWN_WIDTH = 130
local DROPDOWN_HEIGHT = 20
local DROPDOWN_FADE_DELAY = 3 -- To be implemented
local DROPDOWN_MAX_SHOWN = 8

local SetArrowUp = function(button)
	button.ArrowTop.Anim:SetChange(2)
	button.ArrowBottom.Anim:SetChange(6)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
end

local SetArrowDown = function(button)
	button.ArrowTop.Anim:SetChange(6)
	button.ArrowBottom.Anim:SetChange(2)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
end

local CloseLastDropdown = function(compare)
	if (LAST_ACTIVE_DROPDOWN and LAST_ACTIVE_DROPDOWN.Menu:IsShown() and (LAST_ACTIVE_DROPDOWN ~= compare)) then
		if (not LAST_ACTIVE_DROPDOWN.Menu.FadeOut:IsPlaying()) then
			LAST_ACTIVE_DROPDOWN.Menu.FadeOut:Play()
			SetArrowDown(LAST_ACTIVE_DROPDOWN)
		end
	end
end

local DropdownButtonOnMouseUp = function(self)
	if self.ArrowBottom.Anim:IsPlaying() then
		return
	end
	
	self.Parent.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.Menu:IsVisible() then
		self.Menu.FadeOut:Play()
		SetArrowDown(self)
	else
		for i = 1, #self.Menu do
			if self.Parent.CustomType then
				if (self.Menu[i].Key == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			else
				if (self.Menu[i].Value == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			end
		end
		
		CloseLastDropdown(self)
		self.Menu:Show()
		self.Menu.FadeIn:Play()
		SetArrowUp(self)
	end
	
	LAST_ACTIVE_DROPDOWN = self
end

local DropdownButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Parent.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)
	
	self.Highlight:SetAlpha(0)
	
	if self.GrandParent.CustomType then
		SetVariable(self.ID, self.Key)
		
		self.GrandParent.Value = self.Key
		
		if self.GrandParent.Hook then
			self.GrandParent.Hook(self.Key, self.ID)
		end
	else
		SetVariable(self.ID, self.Value)
		
		self.GrandParent.Value = self.Value
		
		if self.GrandParent.Hook then
			self.GrandParent.Hook(self.Value, self.ID)
		end
	end
	
	if (self.GrandParent.CustomType == "Texture") then
		self.GrandParent.Texture:SetTexture(Media:GetTexture(self.Key))
	elseif (self.GrandParent.CustomType == "Font") then
		self.GrandParent.Current:SetFont(Media:GetFont(self.Key), 12)
	end
	
	self.GrandParent.Current:SetText(self.Key)
end

local DropdownOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local DropdownOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ScrollMenu = function(self)
	local First = false
	
	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + DROPDOWN_MAX_SHOWN - 1) then
			if (not First) then
				self[i]:SetScaledPoint("TOPLEFT", self, 0, 0)
				First = true
			else
				self[i]:SetScaledPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end
			
			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SetDropdownOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self - (DROPDOWN_MAX_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local DropdownOnMouseWheel = function(self, delta)
	self:SetDropdownOffsetByDelta(delta)
	self:ScrollMenu()
	self.ScrollBar:SetValue(self.Offset)
end

local SetDropdownOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self - DROPDOWN_MAX_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:ScrollMenu()
end

local DropdownScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value
	
	Parent:ScrollMenu()
end

local DropdownScrollBarOnMouseWheel = function(self, delta)
	DropdownOnMouseWheel(self:GetParent(), delta)
end

local AddDropdownScrollBar = function(self)
	local MaxValue = (#self - (DROPDOWN_MAX_SHOWN - 1))
	local ScrollWidth = (WIDGET_HEIGHT / 2)
	
	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetScaledPoint("TOPLEFT", self, "TOPRIGHT", 2, 0)
	ScrollBar:SetScaledPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0)
	ScrollBar:SetScaledWidth(ScrollWidth)
	ScrollBar:SetThumbTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)
	
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetScaledSize(ScrollWidth, WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetScaledPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetScaledPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetScaledPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Progress:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)
	
	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetDropdownOffset(1)
	
	ScrollBar:Show()
	
	for i = 1, #self do
		self[i]:SetScaledWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	end
	
	self:SetScaledWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	self:SetScaledHeight(((WIDGET_HEIGHT - 1) * DROPDOWN_MAX_SHOWN) + 1)
end

GUI.Widgets.CreateDropdown = function(self, id, value, values, label, tooltip, hook, custom)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	
	local Dropdown = CreateFrame("Frame", nil, Anchor)
	Dropdown:SetScaledSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Dropdown:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown:SetBackdropColor(0.6, 0.6, 0.6)
	Dropdown:SetBackdropBorderColor(0, 0, 0)
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 1)
	Dropdown.Values = values
	Dropdown.Value = value
	Dropdown.Hook = hook
	Dropdown.Tooltip = tooltip
	Dropdown.CustomType = custom
	
	Dropdown.Texture = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Texture:SetScaledPoint("TOPLEFT", Dropdown, 1, -1)
	Dropdown.Texture:SetScaledPoint("BOTTOMRIGHT", Dropdown, -1, 1)
	Dropdown.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:SetScaledPoint("LEFT", Dropdown, HEADER_SPACING, 0)
	Dropdown.Current:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Dropdown.Current:SetJustifyH("LEFT")
	Dropdown.Current:SetScaledWidth(DROPDOWN_WIDTH - 4)
	Dropdown.Current:SetShadowColor(0, 0, 0)
	Dropdown.Current:SetShadowOffset(1, -1)
	
	Dropdown.Button = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Button:SetScaledSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown.Button:SetScaledPoint("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Button:SetBackdropColor(0, 0, 0, 0)
	Dropdown.Button:SetBackdropBorderColor(0, 0, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	Dropdown.Button:SetScript("OnEnter", DropdownOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownOnLeave)
	
	Dropdown.Button.Highlight = Dropdown.Button:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.Highlight:SetScaledPoint("TOPLEFT", Dropdown.Button, 1, -1)
	Dropdown.Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Dropdown.Button, -1, 1)
	Dropdown.Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Dropdown.Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Dropdown.Button.Highlight:SetAlpha(0)
	
	Dropdown.Text = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Dropdown.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Dropdown.Text:SetJustifyH("LEFT")
	Dropdown.Text:SetScaledWidth(DROPDOWN_WIDTH - 4)
	Dropdown.Text:SetShadowColor(0, 0, 0)
	Dropdown.Text:SetShadowOffset(1, -1)
	Dropdown.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:SetScaledSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Dropdown.ArrowAnchor:SetScaledPoint("RIGHT", Dropdown, 0, 0)
	
	local ArrowMiddle = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowMiddle:SetScaledPoint("CENTER", Dropdown.ArrowAnchor, 0, 0)
	ArrowMiddle:SetScaledSize(4, 1)
	ArrowMiddle:SetTexture(Media:GetTexture("Blank"))
	ArrowMiddle:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	ArrowMiddle.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowMiddle.BG:SetScaledPoint("TOPLEFT", ArrowMiddle, -1, 1)
	ArrowMiddle.BG:SetScaledPoint("BOTTOMRIGHT", ArrowMiddle, 1, -1)
	ArrowMiddle.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowMiddle.BG:SetVertexColor(0, 0, 0)
	
	local ArrowTop = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowTop:SetScaledSize(6, 1)
	ArrowTop:SetScaledPoint("BOTTOM", ArrowMiddle, "TOP", 0, 0)
	ArrowTop:SetTexture(Media:GetTexture("Blank"))
	ArrowTop:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	ArrowTop.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowTop.BG:SetScaledPoint("TOPLEFT", ArrowTop, -1, 1)
	ArrowTop.BG:SetScaledPoint("BOTTOMRIGHT", ArrowTop, 1, -1)
	ArrowTop.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowTop.BG:SetVertexColor(0, 0, 0)
	
	ArrowTop.Anim = CreateAnimationGroup(ArrowTop):CreateAnimation("Width")
	ArrowTop.Anim:SetEasing("in")
	ArrowTop.Anim:SetDuration(0.15)
	
	local ArrowBottom = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowBottom:SetScaledSize(2, 1)
	ArrowBottom:SetScaledPoint("TOP", ArrowMiddle, "BOTTOM", 0, 0)
	ArrowBottom:SetTexture(Media:GetTexture("Blank"))
	ArrowBottom:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	ArrowBottom.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowBottom.BG:SetScaledPoint("TOPLEFT", ArrowBottom, -1, 1)
	ArrowBottom.BG:SetScaledPoint("BOTTOMRIGHT", ArrowBottom, 1, -1)
	ArrowBottom.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowBottom.BG:SetVertexColor(0, 0, 0)
	
	ArrowBottom.Anim = CreateAnimationGroup(ArrowBottom):CreateAnimation("Width")
	ArrowBottom.Anim:SetEasing("in")
	ArrowBottom.Anim:SetDuration(0.15)
	
	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:SetScaledPoint("TOPLEFT", Dropdown, "BOTTOMLEFT", SPACING, -2)
	Dropdown.Menu:SetScaledSize(DROPDOWN_WIDTH - (SPACING * 2), 1)
	Dropdown.Menu:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu:EnableMouseWheel(true)
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)
	
	Dropdown.Button.ArrowBottom = ArrowBottom
	Dropdown.Button.ArrowMiddle = ArrowMiddle
	Dropdown.Button.ArrowTop = ArrowTop
	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown
	
	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)
	
	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in")
	Dropdown.Menu.FadeIn:SetDuration(0.15)
	Dropdown.Menu.FadeIn:SetChange(1)
	
	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu)
	Dropdown.Menu.BG:SetScaledPoint("BOTTOMLEFT", Dropdown.Menu, -SPACING, -SPACING)
	Dropdown.Menu.BG:SetScaledPoint("TOPRIGHT", Dropdown, "BOTTOMRIGHT", 0, 1)
	Dropdown.Menu.BG:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu.BG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Dropdown.Menu.BG:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu.BG:EnableMouse(true)
	Dropdown.Menu.BG:SetScript("OnMouseWheel", function() end) -- Just to prevent misclicks from going through the frame
	
	local Count = 0
	local LastMenuItem
	
	for Key, Value in PairsByKeys(values) do
		Count = Count + 1
		
		local MenuItem = CreateFrame("Frame", nil, Dropdown.Menu)
		MenuItem:SetScaledSize(DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
		MenuItem:SetBackdrop(vUI.BackdropAndBorder)
		MenuItem:SetBackdropColor(HexToRGB(Settings["ui-widget-bg-color"]))
		MenuItem:SetBackdropBorderColor(0, 0, 0)
		MenuItem:SetScript("OnMouseUp", MenuItemOnMouseUp)
		MenuItem:SetScript("OnEnter", MenuItemOnEnter)
		MenuItem:SetScript("OnLeave", MenuItemOnLeave)
		MenuItem.Key = Key
		MenuItem.Value = Value
		MenuItem.ID = id
		MenuItem.Parent = MenuItem:GetParent()
		MenuItem.GrandParent = MenuItem:GetParent():GetParent()
		
		MenuItem.Highlight = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Highlight:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Highlight:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Highlight:SetTexture(Media:GetTexture("Blank"))
		MenuItem.Highlight:SetVertexColor(1, 1, 1, 0.4)
		MenuItem.Highlight:SetAlpha(0)
		
		MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
		MenuItem.Texture:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Texture:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		MenuItem.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
		
		MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Selected:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Selected:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Selected:SetTexture(Media:GetTexture("RenHorizonUp"))
		MenuItem.Selected:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
		MenuItem.Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
		
		MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
		MenuItem.Text:SetScaledPoint("LEFT", MenuItem, 5, 0)
		MenuItem.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
		MenuItem.Text:SetJustifyH("LEFT")
		MenuItem.Text:SetShadowColor(0, 0, 0)
		MenuItem.Text:SetShadowOffset(1, -1)
		MenuItem.Text:SetText(Key)
		
		if (custom == "Texture") then
			MenuItem.Texture:SetTexture(Media:GetTexture(Key))
		elseif (custom == "Font") then
			MenuItem.Text:SetFont(Media:GetFont(Key), 12)
		end
		
		if custom then
			if (MenuItem.Key == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		else
			if (MenuItem.Value == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		end
		
		tinsert(Dropdown.Menu, MenuItem)
		
		if LastMenuItem then
			MenuItem:SetScaledPoint("TOP", LastMenuItem, "BOTTOM", 0, 1)
		else
			MenuItem:SetScaledPoint("TOP", Dropdown.Menu, 0, 0)
		end
		
		LastMenuItem = MenuItem
	end
	
	if (custom == "Texture") then
		Dropdown.Texture:SetTexture(Media:GetTexture(value))
	elseif (custom == "Font") then
		Dropdown.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		Dropdown.Current:SetFont(Media:GetFont(Settings[id]), 12)
	else
		Dropdown.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	end
	
	if (#Dropdown.Menu > DROPDOWN_MAX_SHOWN) then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:SetScaledHeight(((WIDGET_HEIGHT - 1) * Count) + 1)
	end
	
	tinsert(self.Widgets, Anchor)
	
	return Dropdown
end

-- Slider
local SLIDER_WIDTH = 80
local EDITBOX_WIDTH = 48

local SliderOnValueChanged = function(self)
	local Value = self:GetValue()
	
	if (self.EditBox.StepValue >= 1) then
		Value = floor(Value)
	else
		if (self.EditBox.StepValue <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	self.EditBox.Value = Value
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
	
	SetVariable(self.ID, Value)
	
	if self.Hook then
		self.Hook(Value, self.ID)
	end
end

local SliderOnMouseWheel = function(self, delta)
	local Value = self.EditBox.Value
	local Step = self.EditBox.StepValue
	
	if (delta < 0) then
		Value = Value - Step
	else
		Value = Value + Step
	end
	
	if (Step >= 1) then
		Value = floor(Value)
	else
		if (Step <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	if (Value < self.EditBox.MinValue) then
		Value = self.EditBox.MinValue
	elseif (Value > self.EditBox.MaxValue) then
		Value = self.EditBox.MaxValue
	end
	
	self.EditBox.Value = Value
	
	self:SetValue(Value)
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
end

local EditBoxOnEnterPressed = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		return
	end
	
	if (Value ~= self.Value) then
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)
	end
	
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
	self:SetText(self.Value)
end

local EditBoxOnEditFocusLost = function(self)
	if (self.Value > self.MaxValue) then
		self.Value = self.MaxValue
	elseif (self.Value < self.MinValue) then
		self.Value = self.MinValue
	end
	
	self:SetText(self.Prefix..self.Value..self.Postfix)
end

local EditBoxOnChar = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		self:SetText(self.Value)
	end
end

local EditBoxOnMouseWheel = function(self, delta)
	if self:HasFocus() then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
	
	if (delta > 0) then
		self.Value = self.Value + self.StepValue
		
		if (self.Value > self.MaxValue) then
			self.Value = self.MaxValue
		end
	else
		self.Value = self.Value - self.StepValue
		
		if (self.Value < self.MinValue) then
			self.Value = self.MinValue
		end
	end
	
	self:SetText(self.Value)
	self.Slider:SetValue(self.Value)
end

local EditBoxOnEnter = function(self)
	self.Parent.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local EditboxOnLeave = function(self)
	self.Parent.Highlight:SetAlpha(0)
end

local SliderOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local SliderOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SliderEnable = function(self)
	self:EnableMouse(true)
	self:EnableMouseWheel(true)
	
	self.EditBox:EnableKeyboard(true)
	self.EditBox:EnableMouse(true)
	self.EditBox:EnableMouseWheel(true)
	
	self.EditBox:SetTextColor(1, 1, 1)
	self.Progress:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	self.Disabled = false
end

local SliderDisable = function(self)
	self:EnableMouse(false)
	self:EnableMouseWheel(false)
	
	self.EditBox:EnableKeyboard(false)
	self.EditBox:EnableMouse(false)
	self.EditBox:EnableMouseWheel(false)
	
	self.EditBox:SetTextColor(0.65, 0.65, 0.65)
	self.Progress:SetVertexColor(0.65, 0.65, 0.65)
	self.Disabled = true
end

GUI.Widgets.CreateSlider = function(self, id, value, minvalue, maxvalue, step, label, tooltip, hook, prefix, postfix)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, DROPDOWN_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	
	if prefix then
		prefix = "|cFF"..Settings["ui-header-font-color"]..prefix.."|r"
	else
		prefix = ""
	end
	
	if postfix then
		postfix = "|cFF"..Settings["ui-header-font-color"]..postfix.."|r"
	else
		postfix = ""
	end
	
	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:SetScaledSize(EDITBOX_WIDTH, WIDGET_HEIGHT)
	EditBox:SetScaledPoint("RIGHT", Anchor, 0, 0)
	EditBox:SetBackdrop(vUI.BackdropAndBorder)
	EditBox:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	EditBox:SetBackdropBorderColor(0, 0, 0)
	
	EditBox.Texture = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Texture:SetScaledPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Texture:SetScaledPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	EditBox.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetScaledPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Highlight:SetScaledPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Highlight:SetTexture(Media:GetTexture("Blank"))
	EditBox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	EditBox.Highlight:SetAlpha(0)
	
	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	EditBox.Box:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	EditBox.Box:SetScaledPoint("TOPLEFT", EditBox, SPACING, -2)
	EditBox.Box:SetScaledPoint("BOTTOMRIGHT", EditBox, -SPACING, 2)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(5)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetShadowColor(0, 0, 0)
	EditBox.Box:SetShadowOffset(1, -1)
	EditBox.Box:SetText(prefix..value..postfix)
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = step
	EditBox.Box.Value = value
	EditBox.Box.Prefix = prefix
	EditBox.Box.Postfix = postfix
	EditBox.Box.Parent = EditBox
	
	EditBox.Box:SetScript("OnMouseWheel", EditBoxOnMouseWheel)
	EditBox.Box:SetScript("OnMouseDown", EditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	EditBox.Box:SetScript("OnChar", EditBoxOnChar)
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditboxOnLeave)
	
	local Slider = CreateFrame("Slider", nil, self)
	Slider:SetScaledPoint("RIGHT", EditBox, "LEFT", -2, 0)
	Slider:SetScaledSize(SLIDER_WIDTH, WIDGET_HEIGHT)
	Slider:SetThumbTexture(Media:GetTexture("Blank"))
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(step)
	Slider:SetBackdrop(vUI.BackdropAndBorder)
	Slider:SetBackdropColor(0, 0, 0)
	Slider:SetBackdropBorderColor(0, 0, 0)
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(value)
	Slider:EnableMouseWheel(true)
	Slider:SetScript("OnMouseWheel", SliderOnMouseWheel)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider:SetScript("OnEnter", SliderOnEnter)
	Slider:SetScript("OnLeave", SliderOnLeave)
	Slider.Enable = SliderEnable
	Slider.Disable = SliderDisable
	Slider.Prefix = prefix or ""
	Slider.Postfix = postfix or ""
	Slider.EditBox = EditBox.Box
	Slider.Hook = hook
	Slider.ID = id
	
	Slider.Text = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Slider.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Slider.Text:SetJustifyH("LEFT")
	Slider.Text:SetShadowColor(0, 0, 0)
	Slider.Text:SetShadowOffset(1, -1)
	Slider.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Slider.TrackTexture = Slider:CreateTexture(nil, "ARTWORK")
	Slider.TrackTexture:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.TrackTexture:SetScaledPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.TrackTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.TrackTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Thumb = Slider:GetThumbTexture()
	Thumb:SetScaledSize(8, WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture("Blank"))
	Thumb:SetVertexColor(0, 0, 0)
	
	Slider.NewThumb = CreateFrame("Frame", nil, Slider)
	Slider.NewThumb:SetScaledPoint("TOPLEFT", Thumb, 0, -1)
	Slider.NewThumb:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 1)
	Slider.NewThumb:SetBackdrop(vUI.BackdropAndBorder)
	Slider.NewThumb:SetBackdropColor(HexToRGB(Settings["ui-widget-bg-color"]))
	Slider.NewThumb:SetBackdropBorderColor(0, 0, 0)
	
	Slider.NewThumb.Texture = Slider.NewThumb:CreateTexture(nil, "OVERLAY")
	Slider.NewThumb.Texture:SetScaledPoint("TOPLEFT", Slider.NewThumb, 1, 0)
	Slider.NewThumb.Texture:SetScaledPoint("BOTTOMRIGHT", Slider.NewThumb, -1, 0)
	Slider.NewThumb.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.NewThumb.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.Progress:SetScaledPoint("BOTTOMRIGHT", Slider.NewThumb.Texture, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.Progress:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	
	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY", 8)
	Slider.Highlight:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.Highlight:SetScaledPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.Highlight:SetTexture(Media:GetTexture("Blank"))
	Slider.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Slider.Highlight:SetAlpha(0)
	
	EditBox.Box.Slider = Slider
	
	Slider:Show()
	
	tinsert(self.Widgets, Anchor)
	
	return Slider
end

-- Color
local COLOR_WIDTH = 80
local SWATCH_SIZE = 20
local MAX_SWATCHES_X = 20
local MAX_SWATCHES_Y = 10

local ColorSwatchOnMouseUp = function(self)
	GUI.ColorPicker.Transition:SetChange(HexToRGB(self.Value))
	GUI.ColorPicker.Transition:Play()
	GUI.ColorPicker.NewHexText:SetText("#"..self.Value)
	GUI.ColorPicker.Selected = self.Value
end

local ColorSwatchOnEnter = function(self)
	self.Highlight:SetAlpha(1)
end

local ColorSwatchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ColorPickerAccept = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	local Active = self:GetParent().Active
	
	if GUI.ColorPicker.Selected then
		Active.Transition:SetChange(HexToRGB(GUI.ColorPicker.Selected))
		Active.Transition:Play()
		
		Active.MiddleText:SetText("#"..upper(GUI.ColorPicker.Selected))
		Active.Value = GUI.ColorPicker.Selected
		
		SetVariable(Active.ID, Active.Value)
		
		if Active.Hook then
			Active.Hook(Active.Value, Active.ID)
		end
	end
	
	GUI.ColorPicker.FadeOut:Play()
end

local ColorPickerCancel = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	GUI.ColorPicker.FadeOut:Play()
end

local ColorPickerOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ColorPickerOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SwatchEditBoxOnEscapePressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local SwatchEditBoxOnEnterPressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local SwatchEditBoxOnEditFocusLost = function(self)
	local Value = self:GetText()
	
	Value = gsub(Value, "#", "")
	
	if (Value and match(Value, "%x%x%x%x%x%x")) then
		self:SetText("#"..Value)
		
		GUI.ColorPicker.Transition:SetChange(HexToRGB(Value))
		GUI.ColorPicker.Selected = Value
	else
		vUI:print(format('Invalid hex code "%s".', Value))
		
		self:SetText("#" .. GUI.ColorPicker.Active.Value)
		
		GUI.ColorPicker.Transition:SetChange(HexToRGB(GUI.ColorPicker.Active.Value))
		GUI.ColorPicker.Selected = GUI.ColorPicker.Active.Value
	end
	
	GUI.ColorPicker.Transition:Play()
end

local SwatchEditBoxOnChar = function(self)
	local Value = self:GetText()
	
	Value = gsub(Value, "#", "")
	Value = upper(Value)
	
	self:SetText(Value)
	
	if (Value and match(Value, "%x%x%x%x%x%x")) then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
end

local SwatchEditBoxOnEditFocusGained = function(self)
	local Text = self:GetText()
	
	Text = gsub(Text, "#", "")
	
	self:SetText(Text)
	self:HighlightText()
end

local SwatchButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local CreateColorPicker = function()
	if GUI.ColorPicker then
		return
	end
	
	local ColorPicker = CreateFrame("Frame", "vUIColorPicker", GUI)
	ColorPicker:SetScaledSize(389, 270)
	ColorPicker:SetScaledPoint("CENTER", UIParent, 0, 81)
	ColorPicker:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	ColorPicker:SetBackdropBorderColor(0, 0, 0)
	ColorPicker:SetFrameStrata("HIGH")
	ColorPicker:Hide()
	ColorPicker:SetAlpha(0)
	ColorPicker:SetMovable(true)
	ColorPicker:EnableMouse(true)
	ColorPicker:RegisterForDrag("LeftButton")
	ColorPicker:SetScript("OnDragStart", ColorPicker.StartMoving)
	ColorPicker:SetScript("OnDragStop", ColorPicker.StopMovingOrSizing)
	
	-- Header
	ColorPicker.Header = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Header:SetScaledHeight(HEADER_HEIGHT)
	ColorPicker.Header:SetScaledPoint("TOPLEFT", ColorPicker, 2, -2)
	ColorPicker.Header:SetScaledPoint("TOPRIGHT", ColorPicker, 0, -2)
	ColorPicker.Header:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Header:SetBackdropColor(0, 0, 0)
	ColorPicker.Header:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.HeaderTexture = ColorPicker.Header:CreateTexture(nil, "OVERLAY")
	ColorPicker.HeaderTexture:SetScaledPoint("TOPLEFT", ColorPicker.Header, 1, -1)
	ColorPicker.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Header, -1, 1)
	ColorPicker.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.HeaderTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.Header.Text = ColorPicker.Header:CreateFontString(nil, "OVERLAY")
	ColorPicker.Header.Text:SetScaledPoint("LEFT", ColorPicker.Header, HEADER_SPACING, -1)
	ColorPicker.Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 14)
	ColorPicker.Header.Text:SetJustifyH("LEFT")
	ColorPicker.Header.Text:SetShadowColor(0, 0, 0)
	ColorPicker.Header.Text:SetShadowOffset(1, -1)
	ColorPicker.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Select a color".."|r")
	
	-- Selection parent
	ColorPicker.SwatchParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.SwatchParent:SetScaledPoint("TOPLEFT", ColorPicker.Header, "BOTTOMLEFT", 0, -2)
	ColorPicker.SwatchParent:SetScaledPoint("BOTTOMRIGHT", ColorPicker, 0, 3)
	ColorPicker.SwatchParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.SwatchParent:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	ColorPicker.SwatchParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Close button
	ColorPicker.Header.CloseButton = CreateFrame("Frame", nil, ColorPicker.Header)
	ColorPicker.Header.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	ColorPicker.Header.CloseButton:SetScaledPoint("RIGHT", ColorPicker.Header, 0, 0)
	ColorPicker.Header.CloseButton:SetScript("OnEnter", function(self) self.Text:SetTextColor(1, 0, 0) end)
	ColorPicker.Header.CloseButton:SetScript("OnLeave", function(self) self.Text:SetTextColor(1, 1, 1) end)
	ColorPicker.Header.CloseButton:SetScript("OnMouseUp", function() ColorPicker.FadeOut:Play() end)
	
	ColorPicker.Header.CloseButton.Text = ColorPicker.Header.CloseButton:CreateFontString(nil, "OVERLAY", 7)
	ColorPicker.Header.CloseButton.Text:SetScaledPoint("CENTER", ColorPicker.Header.CloseButton, 0, 0)
	ColorPicker.Header.CloseButton.Text:SetFont(Media:GetFont("PT Sans"), 18)
	ColorPicker.Header.CloseButton.Text:SetJustifyH("CENTER")
	ColorPicker.Header.CloseButton.Text:SetShadowColor(0, 0, 0)
	ColorPicker.Header.CloseButton.Text:SetShadowOffset(1, -1)
	ColorPicker.Header.CloseButton.Text:SetText("×")
	
	-- Current
	ColorPicker.Current = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Current:SetScaledSize(119, 20)
	ColorPicker.Current:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent, "BOTTOMLEFT", 3, 45)
	ColorPicker.Current:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Current:SetBackdropColor(0, 0, 0)
	ColorPicker.Current:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentTexture = ColorPicker.Current:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentTexture:SetScaledPoint("TOPLEFT", ColorPicker.Current, 1, -1)
	ColorPicker.CurrentTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Current, -1, 1)
	ColorPicker.CurrentTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.CurrentTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.CurrentText = ColorPicker.Current:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentText:SetScaledPoint("CENTER", ColorPicker.Current, HEADER_SPACING, -1)
	ColorPicker.CurrentText:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	ColorPicker.CurrentText:SetJustifyH("CENTER")
	ColorPicker.CurrentText:SetShadowColor(0, 0, 0)
	ColorPicker.CurrentText:SetShadowOffset(1, -1)
	ColorPicker.CurrentText:SetText(Language["Current"])
	ColorPicker.CurrentText:SetTextColor(HexToRGB(Settings["ui-header-font-color"]))
	
	ColorPicker.CurrentHex = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CurrentHex:SetScaledSize(97, 20)
	ColorPicker.CurrentHex:SetScaledPoint("TOPLEFT", ColorPicker.Current, "BOTTOMLEFT", 0, -2)
	ColorPicker.CurrentHex:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CurrentHex:SetBackdropColor(0, 0, 0)
	ColorPicker.CurrentHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentHexTexture = ColorPicker.CurrentHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentHexTexture:SetScaledPoint("TOPLEFT", ColorPicker.CurrentHex, 1, -1)
	ColorPicker.CurrentHexTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CurrentHex, -1, 1)
	ColorPicker.CurrentHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.CurrentHexTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	ColorPicker.CurrentHexText = ColorPicker.CurrentHex:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentHexText:SetScaledPoint("CENTER", ColorPicker.CurrentHex, 0, 0)
	ColorPicker.CurrentHexText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	ColorPicker.CurrentHexText:SetJustifyH("CENTER")
	ColorPicker.CurrentHexText:SetShadowColor(0, 0, 0)
	ColorPicker.CurrentHexText:SetShadowOffset(1, -1)
	
	ColorPicker.CompareCurrentParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CompareCurrentParent:SetScaledSize(20, 20)
	ColorPicker.CompareCurrentParent:SetScaledPoint("LEFT", ColorPicker.CurrentHex, "RIGHT", 2, 0)
	ColorPicker.CompareCurrentParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CompareCurrentParent:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.CompareCurrentParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareCurrent = ColorPicker.CompareCurrentParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareCurrent:SetScaledPoint("TOPLEFT", ColorPicker.CompareCurrentParent, 1, -1)
	ColorPicker.CompareCurrent:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CompareCurrentParent, -1, 1)
	ColorPicker.CompareCurrent:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	-- New
	ColorPicker.New = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.New:SetScaledSize(119, 20)
	ColorPicker.New:SetScaledPoint("TOPLEFT", ColorPicker.Current, "TOPRIGHT", 2, 0)
	ColorPicker.New:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.New:SetBackdropColor(0, 0, 0)
	ColorPicker.New:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewTexture = ColorPicker.New:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewTexture:SetScaledPoint("TOPLEFT", ColorPicker.New, 1, -1)
	ColorPicker.NewTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.New, -1, 1)
	ColorPicker.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.NewTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.NewText = ColorPicker.New:CreateFontString(nil, "OVERLAY")
	ColorPicker.NewText:SetScaledPoint("CENTER", ColorPicker.New, 0, -1)
	ColorPicker.NewText:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	ColorPicker.NewText:SetJustifyH("CENTER")
	ColorPicker.NewText:SetShadowColor(0, 0, 0)
	ColorPicker.NewText:SetShadowOffset(1, -1)
	ColorPicker.NewText:SetText(Language["New"])
	ColorPicker.NewText:SetTextColor(HexToRGB(Settings["ui-header-font-color"]))
	
	ColorPicker.NewHex = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.NewHex:SetScaledSize(97, 20)
	ColorPicker.NewHex:SetScaledPoint("TOPRIGHT", ColorPicker.New, "BOTTOMRIGHT", 0, -2)
	ColorPicker.NewHex:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.NewHex:SetBackdropColor(0, 0, 0)
	ColorPicker.NewHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewHexTexture = ColorPicker.NewHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewHexTexture:SetScaledPoint("TOPLEFT", ColorPicker.NewHex, 1, -1)
	ColorPicker.NewHexTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.NewHex, -1, 1)
	ColorPicker.NewHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.NewHexTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	ColorPicker.NewHexText = CreateFrame("EditBox", nil, ColorPicker.NewHex)
	ColorPicker.NewHexText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	ColorPicker.NewHexText:SetScaledPoint("TOPLEFT", ColorPicker.NewHex, SPACING, -2)
	ColorPicker.NewHexText:SetScaledPoint("BOTTOMRIGHT", ColorPicker.NewHex, -SPACING, 2)
	ColorPicker.NewHexText:SetJustifyH("CENTER")
	ColorPicker.NewHexText:SetMaxLetters(7)
	ColorPicker.NewHexText:SetAutoFocus(false)
	ColorPicker.NewHexText:EnableKeyboard(true)
	ColorPicker.NewHexText:EnableMouse(true)
	ColorPicker.NewHexText:SetShadowColor(0, 0, 0)
	ColorPicker.NewHexText:SetShadowOffset(1, -1)
	ColorPicker.NewHexText:SetText("")
	ColorPicker.NewHexText:SetHighlightColor(0, 0, 0)
	ColorPicker.NewHexText:SetScript("OnEscapePressed", SwatchEditBoxOnEscapePressed)
	ColorPicker.NewHexText:SetScript("OnEnterPressed", SwatchEditBoxOnEnterPressed)
	ColorPicker.NewHexText:SetScript("OnEditFocusLost", SwatchEditBoxOnEditFocusLost)
	ColorPicker.NewHexText:SetScript("OnEditFocusGained", SwatchEditBoxOnEditFocusGained)
	ColorPicker.NewHexText:SetScript("OnChar", SwatchEditBoxOnChar)
	
	ColorPicker.CompareNewParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CompareNewParent:SetScaledSize(20, 20)
	ColorPicker.CompareNewParent:SetScaledPoint("RIGHT", ColorPicker.NewHex, "LEFT", -2, 0)
	ColorPicker.CompareNewParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CompareNewParent:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.CompareNewParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareNew = ColorPicker.CompareNewParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareNew:SetScaledSize(ColorPicker.CompareNewParent:GetWidth() - 2, 19)
	ColorPicker.CompareNew:SetScaledPoint("TOPLEFT", ColorPicker.CompareNewParent, 1, -1)
	ColorPicker.CompareNew:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CompareNewParent, -1, 1)
	ColorPicker.CompareNew:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	ColorPicker.Transition = CreateAnimationGroup(ColorPicker.CompareNew):CreateAnimation("Color")
	ColorPicker.Transition:SetColorType("vertex")
	ColorPicker.Transition:SetEasing("in")
	ColorPicker.Transition:SetDuration(0.15)
	
	-- Accept
	ColorPicker.Accept = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Accept:SetScaledSize(120, 20)
	ColorPicker.Accept:SetScaledPoint("TOPLEFT", ColorPicker.New, "TOPRIGHT", 2, 0)
	ColorPicker.Accept:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Accept:SetBackdropColor(0, 0, 0)
	ColorPicker.Accept:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Accept:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Accept:SetScript("OnMouseUp", ColorPickerAccept)
	ColorPicker.Accept:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Accept:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Accept.Texture = ColorPicker.Accept:CreateTexture(nil, "ARTWORK")
	ColorPicker.Accept.Texture:SetScaledPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Texture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Accept.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	ColorPicker.Accept.Highlight = ColorPicker.Accept:CreateTexture(nil, "OVERLAY")
	ColorPicker.Accept.Highlight:SetScaledPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Highlight:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Highlight:SetTexture(Media:GetTexture("Blank"))
	ColorPicker.Accept.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Accept.Highlight:SetAlpha(0)
	
	ColorPicker.AcceptText = ColorPicker.Accept:CreateFontString(nil, "OVERLAY")
	ColorPicker.AcceptText:SetScaledPoint("CENTER", ColorPicker.Accept, 0, 0)
	ColorPicker.AcceptText:SetFont(Media:GetFont(Settings["ui-button-font"]), 12)
	ColorPicker.AcceptText:SetJustifyH("CENTER")
	ColorPicker.AcceptText:SetShadowColor(0, 0, 0)
	ColorPicker.AcceptText:SetShadowOffset(1, -1)
	ColorPicker.AcceptText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Accept"].."|r")
	
	-- Cancel
	ColorPicker.Cancel = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Cancel:SetScaledSize(120, 20)
	ColorPicker.Cancel:SetScaledPoint("TOPLEFT", ColorPicker.Accept, "BOTTOMLEFT", 0, -2)
	ColorPicker.Cancel:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Cancel:SetBackdropColor(0, 0, 0)
	ColorPicker.Cancel:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Cancel:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Cancel:SetScript("OnMouseUp", ColorPickerCancel)
	ColorPicker.Cancel:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Cancel:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Cancel.Texture = ColorPicker.Cancel:CreateTexture(nil, "ARTWORK")
	ColorPicker.Cancel.Texture:SetScaledPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Texture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Cancel.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	ColorPicker.Cancel.Highlight = ColorPicker.Cancel:CreateTexture(nil, "OVERLAY")
	ColorPicker.Cancel.Highlight:SetScaledPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Highlight:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Highlight:SetTexture(Media:GetTexture("Blank"))
	ColorPicker.Cancel.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Cancel.Highlight:SetAlpha(0)
	
	ColorPicker.CancelText = ColorPicker.Cancel:CreateFontString(nil, "OVERLAY")
	ColorPicker.CancelText:SetScaledPoint("CENTER", ColorPicker.Cancel, 0, 0)
	ColorPicker.CancelText:SetFont(Media:GetFont(Settings["ui-button-font"]), 12)
	ColorPicker.CancelText:SetJustifyH("CENTER")
	ColorPicker.CancelText:SetShadowColor(0, 0, 0)
	ColorPicker.CancelText:SetShadowOffset(1, -1)
	ColorPicker.CancelText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Cancel"].."|r")
	
	ColorPicker.BG = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.BG:SetScaledPoint("TOPLEFT", ColorPicker.Header, -3, 3)
	ColorPicker.BG:SetScaledPoint("BOTTOMRIGHT", ColorPicker, 3, 0)
	ColorPicker.BG:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.BG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.BG:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.Fade = CreateAnimationGroup(ColorPicker)
	
	ColorPicker.FadeIn = ColorPicker.Fade:CreateAnimation("Fade")
	ColorPicker.FadeIn:SetEasing("in")
	ColorPicker.FadeIn:SetDuration(0.15)
	ColorPicker.FadeIn:SetChange(1)
	
	ColorPicker.FadeOut = ColorPicker.Fade:CreateAnimation("Fade")
	ColorPicker.FadeOut:SetEasing("out")
	ColorPicker.FadeOut:SetDuration(0.15)
	ColorPicker.FadeOut:SetChange(0)
	ColorPicker.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	local Palette = Media:GetPalette(Settings["ui-picker-palette"])
	
	ColorPicker.SetColorPalette = function(self, name)
		local Palette = Media:GetPalette(name)
		local Swatch
		
		for i = 1, MAX_SWATCHES_Y do
			for j = 1, MAX_SWATCHES_X do
				Swatch = self.SwatchParent[i][j]
				
				if (Palette[i] and Palette[i][j]) then
					Swatch.Value = Palette[i][j]
					Swatch:SetScript("OnMouseUp", ColorSwatchOnMouseUp)
					Swatch:SetScript("OnEnter", ColorSwatchOnEnter)
					Swatch:SetScript("OnLeave", ColorSwatchOnLeave)
					--Swatch:Show()
				else
					Swatch.Value = "5C5C5C"
					Swatch:SetScript("OnMouseUp", nil)
					Swatch:SetScript("OnEnter", nil)
					Swatch:SetScript("OnLeave", nil)
					--Swatch:Hide()
				end
				
				Swatch.Texture:SetVertexColor(HexToRGB(Swatch.Value))
			end
		end
	end
	
	for i = 1, MAX_SWATCHES_Y do
		for j = 1, MAX_SWATCHES_X do
			local Swatch = CreateFrame("Frame", nil, ColorPicker)
			Swatch:SetScaledSize(SWATCH_SIZE, SWATCH_SIZE)
			Swatch:SetBackdrop(vUI.BackdropAndBorder)
			Swatch:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
			Swatch:SetBackdropBorderColor(0, 0, 0)
			
			if (Palette[i] and Palette[i][j]) then
				Swatch.Value = Palette[i][j]
				Swatch:SetScript("OnMouseUp", ColorSwatchOnMouseUp)
				Swatch:SetScript("OnEnter", ColorSwatchOnEnter)
				Swatch:SetScript("OnLeave", ColorSwatchOnLeave)
			else
				Swatch.Value = "5C5C5C"
				Swatch:SetScript("OnMouseUp", nil)
				Swatch:SetScript("OnEnter", nil)
				Swatch:SetScript("OnLeave", nil)
				--Swatch:Hide()
			end
			
			Swatch.Texture = Swatch:CreateTexture(nil, "OVERLAY")
			Swatch.Texture:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Texture:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Swatch.Texture:SetVertexColor(HexToRGB(Swatch.Value))
			
			Swatch.Highlight = CreateFrame("Frame", nil, Swatch)
			Swatch.Highlight:SetBackdrop(vUI.Outline)
			Swatch.Highlight:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Highlight:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Highlight:SetBackdropColor(0, 0, 0)
			Swatch.Highlight:SetBackdropBorderColor(1, 1, 1)
			Swatch.Highlight:SetAlpha(0)
			
			if (not ColorPicker.SwatchParent[i]) then
				ColorPicker.SwatchParent[i] = {}
			end
			
			if (i == 1) then
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent, 3, -3)
				else
					Swatch:SetScaledPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			else
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent[i-1][1], "BOTTOMLEFT", 0, 1)
				else
					Swatch:SetScaledPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			end
			
			ColorPicker.SwatchParent[i][j] = Swatch
		end
	end
	
	GUI.ColorPicker = ColorPicker
end

local SetSwatchObject = function(active)
	GUI.ColorPicker.Active = active
	
	GUI.ColorPicker.CompareCurrent:SetVertexColor(HexToRGB(active.Value))
	GUI.ColorPicker.CurrentHexText:SetText("#"..active.Value)
	
	GUI.ColorPicker.NewHexText:SetText("")
	GUI.ColorPicker.CompareNew:SetVertexColor(1, 1, 1)
	GUI.ColorPicker.Selected = active.Value
end

local ColorSelectionOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ColorSelectionOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ColorSelectionOnMouseUp = function(self)
	if (not GUI.ColorPicker) then
		CreateColorPicker()
	end
	
	if GUI.ColorPicker:IsShown() then
		if (self ~= GUI.ColorPicker.Active) then
			SetSwatchObject(self)
		else
			GUI.ColorPicker.FadeOut:Play()
		end
	else
		SetSwatchObject(self)
		
		GUI.ColorPicker:Show()
		GUI.ColorPicker.FadeIn:Play()
	end
end

GUI.Widgets.CreateColorSelection = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	
	local Swatch = CreateFrame("Frame", nil, Anchor)
	Swatch:SetScaledSize(SWATCH_SIZE, SWATCH_SIZE)
	Swatch:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Swatch:SetBackdrop(vUI.BackdropAndBorder)
	Swatch:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Swatch:SetBackdropBorderColor(0, 0, 0)
	
	Swatch.Texture = Swatch:CreateTexture(nil, "OVERLAY")
	Swatch.Texture:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
	Swatch.Texture:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
	Swatch.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Swatch.Texture:SetVertexColor(HexToRGB(value))
	
	local Button = CreateFrame("Frame", nil, Anchor)
	Button:SetScaledSize(COLOR_WIDTH, WIDGET_HEIGHT)
	Button:SetScaledPoint("RIGHT", Swatch, "LEFT", -2, 0)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnEnter", ColorSelectionOnEnter)
	Button:SetScript("OnLeave", ColorSelectionOnLeave)
	Button:SetScript("OnMouseUp", ColorSelectionOnMouseUp)
	Button.ID = id
	Button.Hook = hook
	Button.Value = value
	Button.Tooltip = tooltip
	Button.Swatch = Swatch
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Texture = Button:CreateTexture(nil, "ARTWORK")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Button.Transition = CreateAnimationGroup(Swatch.Texture):CreateAnimation("Color")
	Button.Transition:SetColorType("vertex")
	Button.Transition:SetEasing("in")
	Button.Transition:SetDuration(0.15)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetScaledPoint("CENTER", Button, "CENTER", 0, 0)
	Button.MiddleText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetShadowColor(0, 0, 0)
	Button.MiddleText:SetShadowOffset(1, -1)
	Button.MiddleText:SetText("#"..upper(value))
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetShadowColor(0, 0, 0)
	Button.Text:SetShadowOffset(1, -1)
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Button
end

-- GUI
local ButtonOnEnter = function(self)
	self.Text:SetTextColor(1, 1, 0)
end

local ButtonOnLeave = function(self)
	self.Text:SetTextColor(1, 1, 1)
end

GUI.SortButtons = function(self)
	tsort(self.Buttons, function(a, b)
		return a.Name < b.Name
	end)
	
	for i = 1, #self.Buttons do
		self.Buttons[i]:ClearAllPoints()
		
		if (i == 1) then
			self.Buttons[i]:SetScaledPoint("TOPLEFT", self.SelectionParent, SPACING, -SPACING)
		else
			self.Buttons[i]:SetScaledPoint("TOP", self.Buttons[i-1], "BOTTOM", 0, -2)
		end
	end
end

local Scroll = function(self)
	local LeftFirst = false
	local RightFirst = false
	
	for i = 1, self.WidgetCount do
		if self.LeftWidgets[i] then
			self.LeftWidgets[i]:ClearAllPoints()
			
			if (i >= self.Offset) and (i <= self.Offset + self:GetParent().WindowCount - 1) then
				if (not LeftFirst) then
					self.LeftWidgets[i]:SetScaledPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
					LeftFirst = true
				else
					self.LeftWidgets[i]:SetScaledPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.LeftWidgets[i]:Show()
			else
				self.LeftWidgets[i]:Hide()
			end
		end
		
		if self.RightWidgets[i] then
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i >= self.Offset) and (i <= self.Offset + self:GetParent().WindowCount - 1) then
				if (not RightFirst) then
					self.RightWidgets[i]:SetScaledPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
					RightFirst = true
				else
					self.RightWidgets[i]:SetScaledPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.RightWidgets[i]:Show()
			else
				self.RightWidgets[i]:Hide()
			end
		end
	end
end

local SetOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (self.WidgetCount - (self:GetParent().WindowCount - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	self:SetOffsetByDelta(delta)
	self:Scroll()
	self.ScrollBar:SetValue(self.Offset)
end

local SetOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.WidgetCount - self:GetParent().WindowCount - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:Scroll()
end

local WindowScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value
	
	Parent:Scroll()
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local AddScrollBar = function(self)
	local LeftMaxValue = (#self.LeftWidgets - (self:GetParent().WindowCount - 1))
	local RightMaxValue = (#self.RightWidgets - (self:GetParent().WindowCount - 1))
	
	self.MaxScroll = max(LeftMaxValue, RightMaxValue, 1)
	self.WidgetCount = max(#self.LeftWidgets, #self.RightWidgets)
	
	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetScaledPoint("TOPRIGHT", self, 0, 0)
	ScrollBar:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	ScrollBar:SetScaledWidth(WIDGET_HEIGHT)
	ScrollBar:SetThumbTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, self.MaxScroll)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)
	
	ScrollBar.Window = self
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetScaledSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetScaledPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetScaledPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetScaledPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Progress:SetVertexColor(R * 0.65, G * 0.65, B * 0.65)
	
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", WindowOnMouseWheel)
	
	self.Scroll = Scroll
	self.SetOffset = SetOffset
	self.SetOffsetByDelta = SetOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetOffset(1)
	
	ScrollBar:Show()
	
	if (self.MaxScroll == 1) then
		Thumb:Hide()
		ScrollBar.NewTexture:Hide()
		ScrollBar.NewTexture2:Hide()
		ScrollBar.Progress:Hide()
	end
end

local SortWindow = function(self)
	local NumLeftWidgets = #self.LeftWidgets
	local NumRightWidgets = #self.RightWidgets
	
	if NumLeftWidgets then
		for i = 1, NumLeftWidgets do
			self.LeftWidgets[i]:ClearAllPoints()
		
			if (i == 1) then
				self.LeftWidgets[i]:SetScaledPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
			else
				self.LeftWidgets[i]:SetScaledPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	if NumRightWidgets then
		for i = 1, NumRightWidgets do
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i == 1) then
				self.RightWidgets[i]:SetScaledPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
			else
				self.RightWidgets[i]:SetScaledPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	AddScrollBar(self)
end

GUI.ShowWindow = function(self, name)
	for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()
			Window.Button.FadeOut:Play()
		end
	end
	
	CloseLastDropdown()
	
	local Window = self.Windows[name]
	
	if (not Window.Sorted) then
		Window:SortWindow()
		
		Window.Sorted = true
	end
	
	Window.Button.FadeIn:Play()
	Window:Show()
end

local WindowButtonOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local WindowButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local WindowButtonOnMouseUp = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	self.Parent:ShowWindow(self.Name)
end

local WindowButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

GUI.NewWindow = function(self, name, default)
	if self.Windows[name] then
		return self.Windows[name]
	end
	
	self.WindowCount = self.WindowCount or 0
	
	-- Button
	local Button = CreateFrame("Frame", nil, self)
	Button:SetScaledSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColor(0, 0, 0)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetFrameLevel(self:GetFrameLevel() + 2)
	Button.Name = name
	Button.Parent = self
	Button:SetScript("OnEnter", WindowButtonOnEnter)
	Button:SetScript("OnLeave", WindowButtonOnLeave)
	Button:SetScript("OnMouseUp", WindowButtonOnMouseUp)
	Button:SetScript("OnMouseDown", WindowButtonOnMouseDown)
	
	Button.Selected = Button:CreateTexture(nil, "OVERLAY")
	Button.Selected:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Selected:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetTexture(Media:GetTexture("RenHorizonUp"))
	Button.Selected:SetVertexColor(HexToRGB(Settings["ui-widget-color"]))
	Button.Selected:SetAlpha(0)
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Texture = Button:CreateTexture(nil, "ARTWORK")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	Button.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("CENTER", Button, 0, -1)
	Button.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 14)
	Button.Text:SetJustifyH("CENTER")
	Button.Text:SetShadowColor(0, 0, 0)
	Button.Text:SetShadowOffset(1, -1)
	Button.Text:SetText("|cFF"..Settings["ui-button-font-color"]..name.."|r")
	
	Button.Fade = CreateAnimationGroup(Button.Selected)
	
	Button.FadeIn = Button.Fade:CreateAnimation("Fade")
	Button.FadeIn:SetEasing("in")
	Button.FadeIn:SetDuration(0.15)
	Button.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Button.FadeOut = Button.Fade:CreateAnimation("Fade")
	Button.FadeOut:SetEasing("out")
	Button.FadeOut:SetDuration(0.15)
	Button.FadeOut:SetChange(0)
	
	tinsert(self.Buttons, Button)
	
	-- Window
	local Window = CreateFrame("Frame", nil, self)
	Window:SetScaledWidth(PARENT_WIDTH)
	Window:SetScaledPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	Window:SetScaledPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -2)
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:Hide()
	
	Window.LeftWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.LeftWidgetsBG:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG:SetScaledPoint("TOPLEFT", Window, 0, 0)
	Window.LeftWidgetsBG:SetScaledPoint("BOTTOMLEFT", Window, 0, 0)
	Window.LeftWidgetsBG:SetBackdrop(vUI.BackdropAndBorder)
	Window.LeftWidgetsBG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Window.LeftWidgetsBG:SetBackdropBorderColor(0, 0, 0)
	
	Window.RightWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG:SetScaledPoint("TOPLEFT", Window.LeftWidgetsBG, "TOPRIGHT", 2, 0)
	Window.RightWidgetsBG:SetScaledPoint("BOTTOMLEFT", Window.LeftWidgetsBG, "BOTTOMRIGHT", 2, 0)
	Window.RightWidgetsBG:SetBackdrop(vUI.BackdropAndBorder)
	Window.RightWidgetsBG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Window.RightWidgetsBG:SetBackdropBorderColor(0, 0, 0)
	
	Window.Parent = self
	Window.Button = Button
	Window.LeftWidgets = {}
	Window.RightWidgets = {}
	Window.SortWindow = SortWindow
	
	Window.LeftWidgetsBG.Widgets = Window.LeftWidgets
	Window.RightWidgetsBG.Widgets = Window.RightWidgets
	
	for Name, Function in pairs(self.Widgets) do
		Window.LeftWidgetsBG[Name] = Function
		Window.RightWidgetsBG[Name] = Function
	end
	
	self.Windows[name] = Window
	
	self:SortButtons()
	
	self.WindowCount = self.WindowCount + 1
	
	if default then
		self.DefaultWindow = name
	end
	
	-- return left and right widget group too?
	return Window.LeftWidgetsBG, Window.RightWidgetsBG
end

GUI.GetWindow = function(self, name)
	if self.Windows[name] then
		return self.Windows[name]
	else
		return self.Windows[self.DefaultWindow]
	end
end

GUI.AddOptions = function(self, func)
	if (type(func) == "function") then
		tinsert(self.Queue, func)
	end
end

-- Frame
function GUI:Create()
	-- This just makes the animation look better. That's all. ಠ_ಠ
	self.BlackTexture = self:CreateTexture(nil, "BACKGROUND")
	self.BlackTexture:SetScaledPoint("TOPLEFT", self, 0, 0)
	self.BlackTexture:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BlackTexture:SetTexture(Media:GetTexture("Blank"))
	self.BlackTexture:SetVertexColor(0, 0, 0)
	
	self:SetScaledSize(GUI_WIDTH, GUI_HEIGHT)
	self:SetScaledPoint("CENTER", UIParent, 0, 0)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:Hide()
	
	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:SetScaledSize(HEADER_WIDTH, HEADER_HEIGHT)
	self.Header:SetScaledPoint("TOPLEFT", self, SPACING, -SPACING)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	self.Header.Texture:SetScaledPoint("TOPLEFT", self.Header, 1, -1)
	self.Header.Texture:SetScaledPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetScaledPoint("CENTER", self.Header, 0, -1)
	self.Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 16)
	self.Header.Text:SetJustifyH("CENTER")
	self.Header.Text:SetShadowColor(0, 0, 0)
	self.Header.Text:SetShadowOffset(1, -1)
	self.Header.Text:SetTextColor(HexToRGB(Settings["ui-header-font-color"]))
	self.Header.Text:SetText(format(Language["- vUI version %s -"], vUI.Version))
	--self.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"]..format(Language["- |cff%svUI|r version %s -"], Settings["ui-widget-color"], vUI.Version).."|r")
	
	-- Selection parent
	self.SelectionParent = CreateFrame("Frame", nil, self)
	self.SelectionParent:SetScaledWidth(BUTTON_LIST_WIDTH)
	self.SelectionParent:SetScaledPoint("BOTTOMLEFT", self, SPACING, SPACING)
	self.SelectionParent:SetScaledPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.SelectionParent:SetBackdrop(vUI.BackdropAndBorder)
	self.SelectionParent:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	self.SelectionParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self.Header)
	self.CloseButton:SetScaledSize(HEADER_HEIGHT - 2, HEADER_HEIGHT - 2)
	self.CloseButton:SetScaledPoint("RIGHT", self.Header, -1, 0)
	self.CloseButton:SetBackdrop(vUI.Backdrop)
	self.CloseButton:SetBackdropColor(0, 0, 0, 0)
	self.CloseButton:SetScript("OnEnter", function(self) self.Text:SetTextColor(1, 0, 0) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Text:SetTextColor(1, 1, 1) end)
	self.CloseButton:SetScript("OnMouseUp", function()
		self.FadeOut:Play()
		
		if (self.ColorPicker and self.ColorPicker:GetAlpha() > 0) then
			self.ColorPicker.FadeOut:Play()
		end
	end)
	
	self.CloseButton.Text = self.CloseButton:CreateFontString(nil, "OVERLAY")
	self.CloseButton.Text:SetScaledPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Text:SetFont(Media:GetFont("PT Sans"), 18)
	self.CloseButton.Text:SetJustifyH("CENTER")
	self.CloseButton.Text:SetShadowColor(0, 0, 0)
	self.CloseButton.Text:SetShadowOffset(1, -1)
	self.CloseButton.Text:SetText("×")
end

-- Groups
GUI.Buttons = {}
GUI.Windows = {}
GUI.Queue = {}

GUI.Fade = CreateAnimationGroup(GUI)

GUI.FadeIn = GUI.Fade:CreateAnimation("Fade")
GUI.FadeIn:SetEasing("in")
GUI.FadeIn:SetDuration(0.15)
GUI.FadeIn:SetChange(1)

GUI.FadeOut = GUI.Fade:CreateAnimation("Fade")
GUI.FadeOut:SetEasing("out")
GUI.FadeOut:SetDuration(0.15)
GUI.FadeOut:SetChange(0)
GUI.FadeOut:SetScript("OnFinished", function(self)
	self:GetParent():Hide()
end)

function GUI:RunQueue()
	if (#self.Queue > 0) then
		local Func
		
		for i = 1, #self.Queue do
			Func = tremove(self.Queue, 1)
			
			Func(self)
		end
	end
end

__vUIReset = function() -- /run __vUIReset()
	vUIProfiles = nil
	vUIData = nil
	ReloadUI()
end

function GUI:VARIABLES_LOADED()
	if (not vUIData) then
		vUIData = {}
		
		Profiles:NewProfile("Default")
	end
	
	local Key = vUIData["ui-profile"] or "Default"
	
	Profiles:ImportProfiles()
	Profiles:ApplyProfile(Key)
	
	-- Load the GUI
	self:Create()
	self:RunQueue()
	
	-- Set the frame height
	local Height = HEADER_HEIGHT + (self.WindowCount * WIDGET_HEIGHT) + (self.WindowCount * SPACING) - 1
	
	self:SetScaledHeight(Height)
	
	-- Show the default window, if one was found
	if self.DefaultWindow then
		self:ShowWindow(self.DefaultWindow)
	end
	
	self:UnregisterEvent("VARIABLES_LOADED")
end

function GUI:PLAYER_REGEN_DISABLED()
	if self:IsVisible() then
		self:SetAlpha(0)
		self:Hide()
		CloseLastDropdown()
		self.WasCombatClosed = true
	end
end

function GUI:PLAYER_REGEN_ENABLED()
	if self.WasCombatClosed then
		self:Show()
		self:SetAlpha(1)
		self.WasCombatClosed = false
	end
end

GUI:RegisterEvent("PLAYER_REGEN_DISABLED")
GUI:RegisterEvent("PLAYER_REGEN_ENABLED")
GUI:RegisterEvent("VARIABLES_LOADED")
GUI:SetScript("OnEvent", function(self, event)
	if self[event] then
		self[event](self)
	end
end)

GUI.Toggle = function(self)
	if (not self:IsVisible()) then
		if InCombatLockdown() then
			vUI:print(ERR_NOT_IN_COMBAT)
			
			return
		end
		
		self:SetAlpha(0)
		self:Show()
		self.FadeIn:Play()
	else
		self.FadeOut:Play()
		
		if (self.ColorPicker and self.ColorPicker:GetAlpha() > 0) then
			self.ColorPicker.FadeOut:Play()
		end
		
		CloseLastDropdown()
	end
end

-- Move this to a commands file later
SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = function()
	GUI:Toggle()
end

GUI:AddOptions(function(self)
	local Left, Right = self:NewWindow(Language["Templates"], true)
	
	Left:CreateHeader(Language["Templates"])
	Left:CreateDropdown("ui-template", Settings["ui-template"], Media:GetTemplateList(), Language["Select Template"], "", function(v) Media:ApplyTemplate(v); ReloadUI(); end)
	
	Right:CreateHeader(Language["Console"])
	Right:CreateButton(Language["Reload"], Language["Reload UI"], "", ReloadUI)
	Right:CreateButton(Language["Delete"], Language["Delete Saved Variables"], "", function() vUISettings = nil; ReloadUI(); end)
	
	Right:CreateHeader(Language["Windows"])
	Right:CreateColorSelection("ui-window-bg-color", Settings["ui-window-bg-color"], Language["Background Color"], "")
	Right:CreateColorSelection("ui-window-main-color", Settings["ui-window-main-color"], Language["Main Color"], "")
	
	Right:CreateHeader(Language["Buttons"])
	Right:CreateColorSelection("ui-button-font-color", Settings["ui-button-font-color"], Language["Text Color"], "")
	Right:CreateColorSelection("ui-button-texture-color", Settings["ui-button-texture-color"], Language["Texture Color"], "")
	Right:CreateDropdown("ui-button-texture", Settings["ui-button-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Right:CreateDropdown("ui-button-font", Settings["ui-button-font"], Media:GetFontList(), Language["Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Headers"])
	Left:CreateColorSelection("ui-header-font-color", Settings["ui-header-font-color"], Language["Text Color"], "")
	Left:CreateColorSelection("ui-header-texture-color", Settings["ui-header-texture-color"], Language["Texture Color"], "")
	Left:CreateDropdown("ui-header-texture", Settings["ui-header-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-header-font", Settings["ui-header-font"], Media:GetFontList(), Language["Header Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Widgets"])
	Left:CreateColorSelection("ui-widget-color", Settings["ui-widget-color"], Language["Color"], "")
	Left:CreateColorSelection("ui-widget-bright-color", Settings["ui-widget-bright-color"], Language["Bright Color"], "")
	Left:CreateColorSelection("ui-widget-bg-color", Settings["ui-widget-bg-color"], Language["Background Color"], "")
	Left:CreateColorSelection("ui-widget-font-color", Settings["ui-widget-font-color"], Language["Label Color"], "")
	Left:CreateDropdown("ui-widget-texture", Settings["ui-widget-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-widget-font", Settings["ui-widget-font"], Media:GetFontList(), Language["Font"], "", nil, "Font")
end)

local UpdateProfile = function(value)
	if (value ~= vUIData["ui-profile"]) then
		vUIData["ui-profile"] = value
		
		ReloadUI()
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:NewWindow(Language["Profiles"])
	
	Left:CreateHeader(Language["Profiles"])
	Left:CreateDropdown("ui-profile", vUIData["ui-profile"], Profiles:GetProfileList(), Language["Set Profile"], "", UpdateProfile)
end)