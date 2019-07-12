local vUI, GUI, Language, Media, Settings = select(2, ...):get()

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
	I can likely do 2 lined widgets by just creating 2 anchors and inserting them so that the scroll system still handles them just fine.
	[Line of text anchor]
	[Editbox for input anchor]
	
	Test different resolutions and find the pixel perfect scale for each. Then either set or suggest the scale
	
	Debug window of the GUI. With info like ui scale, resolution, windowed, language, etc etc
	
	To do:
	
	Shorten Dropdowns, sliders, and buttons, and set both sides of the page to the same width
	
	Adjust sizes & spacing, and add Scrolling by rows
	
	widgets:
	input (longer editbox that accepts text input, as well as dropping spells/actions/items into it)
	
	Input label blah blah
	[      editbox on line below      ]
	
	widget methods
	
	widget:SetWarning(true) -- to determine if the widget should pop up a warning before proceeding
	widget:RequiresReload(true) -- to determine if the widget should pop up a warning before proceeding
	widget:Disable()
	widget:Enable()
--]]

-- Constants
local GUI_WIDTH = 682
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
local MENU_BUTTON_HEIGHT = HEADER_HEIGHT

local MAX_BUTTONS_SHOWN = 16

local LABEL_SPACING = 3

local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local LAST_ACTIVE_DROPDOWN

-- Functions
local SetVariable = function(id, value)
	vUISettings[id] = value
	Settings[id] = value
end

local GetVariable = function(id)
	if (Settings[id] ~= nil) then
		return Settings[id]
	end
end

local HexToRGB = function(hex)
	hex = gsub(hex, "#", "")

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

-- Button
local BUTTON_HEIGHT = 20
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
	self.MiddleText:SetTextColor(vUI:HexToRGB(Settings["ui-widget-color"]))
end

local ButtonWidgetOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	self.MiddleText:SetTextColor(1, 1, 1)
end

GUI.Widgets.CreateButton = function(self, value, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), BUTTON_HEIGHT)
	Anchor.WidgetHeight = BUTTON_HEIGHT
	
	local Button = CreateFrame("Frame", nil, self)
	Button:SetScaledSize(BUTTON_WIDTH, BUTTON_HEIGHT)
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
local STATUSBAR_HEIGHT = 20
local STATUSBAR_WIDTH = 100

GUI.Widgets.CreateStatusBar = function(self, value, minvalue, maxvalue, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), STATUSBAR_HEIGHT)
	Anchor.WidgetHeight = STATUSBAR_HEIGHT
	
	local Backdrop = CreateFrame("Frame", nil, Anchor)
	Backdrop:SetScaledSize(STATUSBAR_WIDTH, STATUSBAR_HEIGHT)
	Backdrop:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Backdrop:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Backdrop:SetBackdropBorderColor(0, 0, 0)
	Backdrop.Value = value
	Backdrop.Hook = hook
	Backdrop.Tooltip = tooltip
	Backdrop.ID = id
	
	Backdrop.BG = Backdrop:CreateTexture(nil, "ARTWORK")
	Backdrop.BG:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Backdrop.BG:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Backdrop.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Backdrop.BG:SetVertexColor(HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Bar = CreateFrame("StatusBar", nil, Backdrop)
	Bar:SetScaledSize(STATUSBAR_WIDTH, STATUSBAR_HEIGHT)
	Bar:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Bar:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Bar:SetBackdrop(vUI.BackdropAndBorder)
	Bar:SetBackdropColor(0, 0, 0, 0)
	Bar:SetBackdropBorderColor(0, 0, 0, 0)
	Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Bar:SetStatusBarColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	Bar:SetMinMaxValues(minvalue, maxvalue)
	Bar:SetValue(value)
	Bar.Hook = hook
	Bar.Tooltip = tooltip
	
	Bar.Anim = CreateAnimationGroup(Bar):CreateAnimation("progress")
	Bar.Anim:SetEasing("in")
	Bar.Anim:SetDuration(0.15)
	
	Bar.Spark = Bar:CreateTexture(nil, "ARTWORK")
	Bar.Spark:SetScaledSize(1, STATUSBAR_HEIGHT - 2)
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
local CHECKBOX_SIZE = 20

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
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), CHECKBOX_SIZE)
	Anchor.WidgetHeight = CHECKBOX_SIZE
	
	local Checkbox = CreateFrame("Frame", nil, Anchor)
	Checkbox:SetScaledSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
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
local SWITCH_HEIGHT = 20
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
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), SWITCH_HEIGHT)
	Anchor.WidgetHeight = SWITCH_HEIGHT
	
	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:SetScaledSize(SWITCH_WIDTH, SWITCH_HEIGHT)
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
	Switch.Thumb:SetScaledSize(SWITCH_HEIGHT, SWITCH_HEIGHT)
	Switch.Thumb:SetBackdrop(vUI.BackdropAndBorder)
	Switch.Thumb:SetBackdropBorderColor(0, 0, 0)
	Switch.Thumb:SetBackdropColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	Switch.ThumbTexture = Switch.Thumb:CreateTexture(nil, "ARTWORK")
	Switch.ThumbTexture:SetScaledSize(SWITCH_HEIGHT - 2, SWITCH_HEIGHT - 2)
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

GUI.Widgets.CreateDropdown = function(self, id, value, values, label, tooltip, hook, custom)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), DROPDOWN_HEIGHT)
	Anchor.WidgetHeight = DROPDOWN_HEIGHT
	
	local Dropdown = CreateFrame("Frame", nil, self)
	Dropdown:SetScaledSize(DROPDOWN_WIDTH, DROPDOWN_HEIGHT)
	Dropdown:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Dropdown:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown:SetBackdropColor(0.6, 0.6, 0.6)
	Dropdown:SetBackdropBorderColor(0, 0, 0)
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 1)
	Dropdown.Values = values
	Dropdown.Value = value
	Dropdown.Hook = hook
	Dropdown.Tooltip = tooltip
	Dropdown.WidgetHeight = DROPDOWN_HEIGHT
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
	Dropdown.Button:SetScaledSize(DROPDOWN_WIDTH, DROPDOWN_HEIGHT)
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
	Dropdown.ArrowAnchor:SetScaledSize(DROPDOWN_HEIGHT, DROPDOWN_HEIGHT)
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
	Dropdown.Menu:SetScaledPoint("TOP", Dropdown, "BOTTOM", 0, -2)
	Dropdown.Menu:SetScaledSize(DROPDOWN_WIDTH - 6, 1)
	Dropdown.Menu:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameLevel(Dropdown.Menu:GetFrameLevel() + 1)
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
	Dropdown.Menu.FadeOut:SetEasing("in")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu)
	Dropdown.Menu.BG:SetScaledPoint("TOPLEFT", Dropdown.Menu, -3, 3)
	Dropdown.Menu.BG:SetScaledPoint("BOTTOMRIGHT", Dropdown.Menu, 3, -3)
	Dropdown.Menu.BG:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu.BG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Dropdown.Menu.BG:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu.BG:EnableMouse(true) -- Just to prevent misclicks from going through the frame
	
	local Count = 0
	local LastMenuItem
	
	for Key, Value in PairsByKeys(values) do
		Count = Count + 1
		
		local MenuItem = CreateFrame("Frame", nil, Dropdown.Menu)
		MenuItem:SetScaledSize(DROPDOWN_WIDTH - 6, DROPDOWN_HEIGHT)
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
	
	Dropdown.Menu:SetScaledHeight(((DROPDOWN_HEIGHT - 1) * Count) + 1)
	
	tinsert(self.Widgets, Anchor)
	
	return Dropdown
end

-- Slider
local SLIDER_HEIGHT = 20
local SLIDER_WIDTH = 80

local EDITBOX_WIDTH = 48
local EDITBOX_HEIGHT = SLIDER_HEIGHT

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
	self.Value = tonumber(self:GetText())
	
	if (self.Value ~= self.Value) then
		self.Slider:SetValue(self.Value)
		SliderOnValueChanged(self.Slider)
	else
		self.Slider:SetValue(self.Value)
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

GUI.Widgets.CreateSlider = function(self, id, value, minvalue, maxvalue, step, label, tooltip, hook, prefix, postfix)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), DROPDOWN_HEIGHT)
	Anchor.WidgetHeight = SLIDER_HEIGHT
	
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
	
	local EditBox = CreateFrame("Frame", nil, self)
	EditBox:SetScaledSize(EDITBOX_WIDTH, EDITBOX_HEIGHT)
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
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditboxOnLeave)
	
	local Slider = CreateFrame("Slider", nil, self)
	Slider:SetScaledPoint("RIGHT", EditBox, "LEFT", -2, 0)
	Slider:SetScaledSize(SLIDER_WIDTH, SLIDER_HEIGHT)
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
	Slider.WidgetHeight = SLIDER_HEIGHT
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
	Thumb:SetScaledSize(8, SLIDER_HEIGHT)
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
local COLOR_HEIGHT = 20
local COLOR_WIDTH = 80
local SWATCH_SIZE = 20

local ColorSwatchOnMouseUp = function(self)
	GUI.SwatchWindow.Transition:SetChange(HexToRGB(self.Value))
	GUI.SwatchWindow.Transition:Play()
	GUI.SwatchWindow.NewHexText:SetText("#"..self.Value)
	GUI.SwatchWindow.Selected = self.Value
end

local ColorSwatchOnEnter = function(self)
	self.Highlight:SetAlpha(1)
end

local ColorSwatchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SwatchWindowAccept = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	local Active = self:GetParent().Active
	
	if GUI.SwatchWindow.Selected then
		Active.Transition:SetChange(HexToRGB(GUI.SwatchWindow.Selected))
		Active.Transition:Play()
		
		Active.MiddleText:SetText("#"..upper(GUI.SwatchWindow.Selected))
		Active.Value = GUI.SwatchWindow.Selected
		
		SetVariable(Active.ID, Active.Value)
		
		if Active.Hook then
			Active.Hook(Active.Value, Active.ID)
		end
	end
	
	GUI.SwatchWindow.FadeOut:Play()
end

local SwatchWindowCancel = function(self)
	self.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	GUI.SwatchWindow.FadeOut:Play()
end

local SwatchWindowOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local SwatchWindowOnLeave = function(self)
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
		
		GUI.SwatchWindow.Transition:SetChange(HexToRGB(Value))
		GUI.SwatchWindow.Transition:Play()
		GUI.SwatchWindow.Selected = Value
	else
		vUI:print(format('Invalid hex code "%s". Default to white.', Value))
		
		self:SetText("#FFFFFF")
		
		GUI.SwatchWindow.Transition:SetChange(1, 1, 1)
		GUI.SwatchWindow.Transition:Play()
		GUI.SwatchWindow.Selected = "FFFFFF"
	end
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

local CreateSwatchWindow = function()
	if GUI.SwatchWindow then
		return
	end
	
	local SwatchWindow = CreateFrame("Frame", nil, GUI)
	SwatchWindow:SetScaledSize(370, 270)
	SwatchWindow:SetScaledPoint("CENTER", UIParent, 0, 81)
	SwatchWindow:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	SwatchWindow:SetBackdropBorderColor(0, 0, 0)
	SwatchWindow:SetFrameStrata("HIGH")
	SwatchWindow:Hide()
	SwatchWindow:SetAlpha(0)
	SwatchWindow:SetMovable(true)
	SwatchWindow:EnableMouse(true)
	SwatchWindow:RegisterForDrag("LeftButton")
	SwatchWindow:SetScript("OnDragStart", SwatchWindow.StartMoving)
	SwatchWindow:SetScript("OnDragStop", SwatchWindow.StopMovingOrSizing)
	
	-- Header
	SwatchWindow.Header = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.Header:SetScaledHeight(HEADER_HEIGHT)
	SwatchWindow.Header:SetScaledPoint("TOPLEFT", SwatchWindow, 2, -2)
	SwatchWindow.Header:SetScaledPoint("TOPRIGHT", SwatchWindow, 0, -2)
	SwatchWindow.Header:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.Header:SetBackdropColor(0, 0, 0)
	SwatchWindow.Header:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.HeaderTexture = SwatchWindow.Header:CreateTexture(nil, "OVERLAY")
	SwatchWindow.HeaderTexture:SetScaledPoint("TOPLEFT", SwatchWindow.Header, 1, -1)
	SwatchWindow.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Header, -1, 1)
	SwatchWindow.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	SwatchWindow.HeaderTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	SwatchWindow.Header.Text = SwatchWindow.Header:CreateFontString(nil, "OVERLAY")
	SwatchWindow.Header.Text:SetScaledPoint("LEFT", SwatchWindow.Header, HEADER_SPACING, -1)
	SwatchWindow.Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 14)
	SwatchWindow.Header.Text:SetJustifyH("LEFT")
	SwatchWindow.Header.Text:SetShadowColor(0, 0, 0)
	SwatchWindow.Header.Text:SetShadowOffset(1, -1)
	SwatchWindow.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Select a color".."|r")
	
	-- Selection parent
	SwatchWindow.SwatchParent = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.SwatchParent:SetScaledSize(BUTTON_LIST_WIDTH, BUTTON_LIST_HEIGHT)
	SwatchWindow.SwatchParent:SetScaledPoint("TOPLEFT", SwatchWindow.Header, "BOTTOMLEFT", 0, -2)
	SwatchWindow.SwatchParent:SetScaledPoint("BOTTOMRIGHT", SwatchWindow, 0, 3)
	SwatchWindow.SwatchParent:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.SwatchParent:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	SwatchWindow.SwatchParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Close button
	SwatchWindow.Header.CloseButton = CreateFrame("Frame", nil, SwatchWindow.Header)
	SwatchWindow.Header.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	SwatchWindow.Header.CloseButton:SetScaledPoint("RIGHT", SwatchWindow.Header, 0, 0)
	SwatchWindow.Header.CloseButton:SetScript("OnEnter", function(self) self.Text:SetTextColor(1, 0, 0) end)
	SwatchWindow.Header.CloseButton:SetScript("OnLeave", function(self) self.Text:SetTextColor(1, 1, 1) end)
	SwatchWindow.Header.CloseButton:SetScript("OnMouseUp", function() SwatchWindow.FadeOut:Play() end)
	
	SwatchWindow.Header.CloseButton.Text = SwatchWindow.Header.CloseButton:CreateFontString(nil, "OVERLAY", 7)
	SwatchWindow.Header.CloseButton.Text:SetScaledPoint("CENTER", SwatchWindow.Header.CloseButton, 0, 0)
	SwatchWindow.Header.CloseButton.Text:SetFont(Media:GetFont("PT Sans"), 18)
	SwatchWindow.Header.CloseButton.Text:SetJustifyH("CENTER")
	SwatchWindow.Header.CloseButton.Text:SetShadowColor(0, 0, 0)
	SwatchWindow.Header.CloseButton.Text:SetShadowOffset(1, -1)
	SwatchWindow.Header.CloseButton.Text:SetText("×")
	
	-- Current
	SwatchWindow.Current = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.Current:SetScaledSize(119, 20)
	SwatchWindow.Current:SetScaledPoint("TOPLEFT", SwatchWindow.SwatchParent, "BOTTOMLEFT", 3, 45)
	SwatchWindow.Current:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.Current:SetBackdropColor(0, 0, 0)
	SwatchWindow.Current:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.CurrentTexture = SwatchWindow.Current:CreateTexture(nil, "OVERLAY")
	SwatchWindow.CurrentTexture:SetScaledPoint("TOPLEFT", SwatchWindow.Current, 1, -1)
	SwatchWindow.CurrentTexture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Current, -1, 1)
	SwatchWindow.CurrentTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	SwatchWindow.CurrentTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	SwatchWindow.CurrentText = SwatchWindow.Current:CreateFontString(nil, "OVERLAY")
	SwatchWindow.CurrentText:SetScaledPoint("CENTER", SwatchWindow.Current, HEADER_SPACING, -1)
	SwatchWindow.CurrentText:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	SwatchWindow.CurrentText:SetJustifyH("CENTER")
	SwatchWindow.CurrentText:SetShadowColor(0, 0, 0)
	SwatchWindow.CurrentText:SetShadowOffset(1, -1)
	SwatchWindow.CurrentText:SetText(Language["Current"])
	SwatchWindow.CurrentText:SetTextColor(HexToRGB(Settings["ui-header-font-color"]))
	
	SwatchWindow.CurrentHex = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.CurrentHex:SetScaledSize(97, 20)
	SwatchWindow.CurrentHex:SetScaledPoint("TOPLEFT", SwatchWindow.Current, "BOTTOMLEFT", 0, -2)
	SwatchWindow.CurrentHex:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.CurrentHex:SetBackdropColor(0, 0, 0)
	SwatchWindow.CurrentHex:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.CurrentHexTexture = SwatchWindow.CurrentHex:CreateTexture(nil, "OVERLAY")
	SwatchWindow.CurrentHexTexture:SetScaledPoint("TOPLEFT", SwatchWindow.CurrentHex, 1, -1)
	SwatchWindow.CurrentHexTexture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.CurrentHex, -1, 1)
	SwatchWindow.CurrentHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SwatchWindow.CurrentHexTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	SwatchWindow.CurrentHexText = SwatchWindow.CurrentHex:CreateFontString(nil, "OVERLAY")
	SwatchWindow.CurrentHexText:SetScaledPoint("CENTER", SwatchWindow.CurrentHex, 0, 0)
	SwatchWindow.CurrentHexText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	SwatchWindow.CurrentHexText:SetJustifyH("CENTER")
	SwatchWindow.CurrentHexText:SetShadowColor(0, 0, 0)
	SwatchWindow.CurrentHexText:SetShadowOffset(1, -1)
	
	SwatchWindow.CompareCurrentParent = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.CompareCurrentParent:SetScaledSize(20, 20)
	SwatchWindow.CompareCurrentParent:SetScaledPoint("LEFT", SwatchWindow.CurrentHex, "RIGHT", 2, 0)
	SwatchWindow.CompareCurrentParent:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.CompareCurrentParent:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	SwatchWindow.CompareCurrentParent:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.CompareCurrent = SwatchWindow.CompareCurrentParent:CreateTexture(nil, "OVERLAY")
	SwatchWindow.CompareCurrent:SetScaledPoint("TOPLEFT", SwatchWindow.CompareCurrentParent, 1, -1)
	SwatchWindow.CompareCurrent:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.CompareCurrentParent, -1, 1)
	SwatchWindow.CompareCurrent:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	-- New
	SwatchWindow.New = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.New:SetScaledSize(119, 20)
	SwatchWindow.New:SetScaledPoint("TOPLEFT", SwatchWindow.Current, "TOPRIGHT", 2, 0)
	SwatchWindow.New:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.New:SetBackdropColor(0, 0, 0)
	SwatchWindow.New:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.NewTexture = SwatchWindow.New:CreateTexture(nil, "OVERLAY")
	SwatchWindow.NewTexture:SetScaledPoint("TOPLEFT", SwatchWindow.New, 1, -1)
	SwatchWindow.NewTexture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.New, -1, 1)
	SwatchWindow.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	SwatchWindow.NewTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	SwatchWindow.NewText = SwatchWindow.New:CreateFontString(nil, "OVERLAY")
	SwatchWindow.NewText:SetScaledPoint("CENTER", SwatchWindow.New, 0, -1)
	SwatchWindow.NewText:SetFont(Media:GetFont(Settings["ui-header-font"]), 12)
	SwatchWindow.NewText:SetJustifyH("CENTER")
	SwatchWindow.NewText:SetShadowColor(0, 0, 0)
	SwatchWindow.NewText:SetShadowOffset(1, -1)
	SwatchWindow.NewText:SetText(Language["New"])
	SwatchWindow.NewText:SetTextColor(HexToRGB(Settings["ui-header-font-color"]))
	
	SwatchWindow.NewHex = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.NewHex:SetScaledSize(97, 20)
	SwatchWindow.NewHex:SetScaledPoint("TOPRIGHT", SwatchWindow.New, "BOTTOMRIGHT", 0, -2)
	SwatchWindow.NewHex:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.NewHex:SetBackdropColor(0, 0, 0)
	SwatchWindow.NewHex:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.NewHexTexture = SwatchWindow.NewHex:CreateTexture(nil, "OVERLAY")
	SwatchWindow.NewHexTexture:SetScaledPoint("TOPLEFT", SwatchWindow.NewHex, 1, -1)
	SwatchWindow.NewHexTexture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.NewHex, -1, 1)
	SwatchWindow.NewHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SwatchWindow.NewHexTexture:SetVertexColor(HexToRGB(Settings["ui-widget-bright-color"]))
	
	SwatchWindow.NewHexText = CreateFrame("EditBox", nil, SwatchWindow.NewHex)
	SwatchWindow.NewHexText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	SwatchWindow.NewHexText:SetScaledPoint("TOPLEFT", SwatchWindow.NewHex, SPACING, -2)
	SwatchWindow.NewHexText:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.NewHex, -SPACING, 2)
	SwatchWindow.NewHexText:SetJustifyH("CENTER")
	SwatchWindow.NewHexText:SetMaxLetters(7)
	SwatchWindow.NewHexText:SetAutoFocus(false)
	SwatchWindow.NewHexText:EnableKeyboard(true)
	SwatchWindow.NewHexText:EnableMouse(true)
	SwatchWindow.NewHexText:SetShadowColor(0, 0, 0)
	SwatchWindow.NewHexText:SetShadowOffset(1, -1)
	SwatchWindow.NewHexText:SetText("#FFFFFF")
	SwatchWindow.NewHexText:SetHighlightColor(0, 0, 0)
	SwatchWindow.NewHexText:SetScript("OnEscapePressed", SwatchEditBoxOnEscapePressed)
	SwatchWindow.NewHexText:SetScript("OnEnterPressed", SwatchEditBoxOnEnterPressed)
	SwatchWindow.NewHexText:SetScript("OnEditFocusLost", SwatchEditBoxOnEditFocusLost)
	SwatchWindow.NewHexText:SetScript("OnEditFocusGained", SwatchEditBoxOnEditFocusGained)
	SwatchWindow.NewHexText:SetScript("OnChar", SwatchEditBoxOnChar)
	
	SwatchWindow.CompareNewParent = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.CompareNewParent:SetScaledSize(20, 20)
	SwatchWindow.CompareNewParent:SetScaledPoint("RIGHT", SwatchWindow.NewHex, "LEFT", -2, 0)
	SwatchWindow.CompareNewParent:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.CompareNewParent:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	SwatchWindow.CompareNewParent:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.CompareNew = SwatchWindow.CompareNewParent:CreateTexture(nil, "OVERLAY")
	SwatchWindow.CompareNew:SetScaledSize(SwatchWindow.CompareNewParent:GetWidth() - 2, 19)
	SwatchWindow.CompareNew:SetScaledPoint("TOPLEFT", SwatchWindow.CompareNewParent, 1, -1)
	SwatchWindow.CompareNew:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.CompareNewParent, -1, 1)
	SwatchWindow.CompareNew:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	SwatchWindow.Transition = CreateAnimationGroup(SwatchWindow.CompareNew):CreateAnimation("Color")
	SwatchWindow.Transition:SetColorType("vertex")
	SwatchWindow.Transition:SetEasing("in")
	SwatchWindow.Transition:SetDuration(0.15)
	
	-- Accept
	SwatchWindow.Accept = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.Accept:SetScaledSize(120, 20)
	SwatchWindow.Accept:SetScaledPoint("TOPLEFT", SwatchWindow.New, "TOPRIGHT", 2, 0)
	SwatchWindow.Accept:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.Accept:SetBackdropColor(0, 0, 0)
	SwatchWindow.Accept:SetBackdropBorderColor(0, 0, 0)
	SwatchWindow.Accept:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	SwatchWindow.Accept:SetScript("OnMouseUp", SwatchWindowAccept)
	SwatchWindow.Accept:SetScript("OnEnter", SwatchWindowOnEnter)
	SwatchWindow.Accept:SetScript("OnLeave", SwatchWindowOnLeave)
	
	SwatchWindow.Accept.Texture = SwatchWindow.Accept:CreateTexture(nil, "ARTWORK")
	SwatchWindow.Accept.Texture:SetScaledPoint("TOPLEFT", SwatchWindow.Accept, 1, -1)
	SwatchWindow.Accept.Texture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Accept, -1, 1)
	SwatchWindow.Accept.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	SwatchWindow.Accept.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	SwatchWindow.Accept.Highlight = SwatchWindow.Accept:CreateTexture(nil, "OVERLAY")
	SwatchWindow.Accept.Highlight:SetScaledPoint("TOPLEFT", SwatchWindow.Accept, 1, -1)
	SwatchWindow.Accept.Highlight:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Accept, -1, 1)
	SwatchWindow.Accept.Highlight:SetTexture(Media:GetTexture("Blank"))
	SwatchWindow.Accept.Highlight:SetVertexColor(1, 1, 1, 0.4)
	SwatchWindow.Accept.Highlight:SetAlpha(0)
	
	SwatchWindow.AcceptText = SwatchWindow.Accept:CreateFontString(nil, "OVERLAY")
	SwatchWindow.AcceptText:SetScaledPoint("CENTER", SwatchWindow.Accept, 0, 0)
	SwatchWindow.AcceptText:SetFont(Media:GetFont(Settings["ui-button-font"]), 12)
	SwatchWindow.AcceptText:SetJustifyH("CENTER")
	SwatchWindow.AcceptText:SetShadowColor(0, 0, 0)
	SwatchWindow.AcceptText:SetShadowOffset(1, -1)
	SwatchWindow.AcceptText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Accept"].."|r")
	
	-- Cancel
	SwatchWindow.Cancel = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.Cancel:SetScaledSize(120, 20)
	SwatchWindow.Cancel:SetScaledPoint("TOPLEFT", SwatchWindow.Accept, "BOTTOMLEFT", 0, -2)
	SwatchWindow.Cancel:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.Cancel:SetBackdropColor(0, 0, 0)
	SwatchWindow.Cancel:SetBackdropBorderColor(0, 0, 0)
	SwatchWindow.Cancel:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	SwatchWindow.Cancel:SetScript("OnMouseUp", SwatchWindowCancel)
	SwatchWindow.Cancel:SetScript("OnEnter", SwatchWindowOnEnter)
	SwatchWindow.Cancel:SetScript("OnLeave", SwatchWindowOnLeave)
	
	SwatchWindow.Cancel.Texture = SwatchWindow.Cancel:CreateTexture(nil, "ARTWORK")
	SwatchWindow.Cancel.Texture:SetScaledPoint("TOPLEFT", SwatchWindow.Cancel, 1, -1)
	SwatchWindow.Cancel.Texture:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Cancel, -1, 1)
	SwatchWindow.Cancel.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	SwatchWindow.Cancel.Texture:SetVertexColor(HexToRGB(Settings["ui-button-texture-color"]))
	
	SwatchWindow.Cancel.Highlight = SwatchWindow.Cancel:CreateTexture(nil, "OVERLAY")
	SwatchWindow.Cancel.Highlight:SetScaledPoint("TOPLEFT", SwatchWindow.Cancel, 1, -1)
	SwatchWindow.Cancel.Highlight:SetScaledPoint("BOTTOMRIGHT", SwatchWindow.Cancel, -1, 1)
	SwatchWindow.Cancel.Highlight:SetTexture(Media:GetTexture("Blank"))
	SwatchWindow.Cancel.Highlight:SetVertexColor(1, 1, 1, 0.4)
	SwatchWindow.Cancel.Highlight:SetAlpha(0)
	
	SwatchWindow.CancelText = SwatchWindow.Cancel:CreateFontString(nil, "OVERLAY")
	SwatchWindow.CancelText:SetScaledPoint("CENTER", SwatchWindow.Cancel, 0, 0)
	SwatchWindow.CancelText:SetFont(Media:GetFont(Settings["ui-button-font"]), 12)
	SwatchWindow.CancelText:SetJustifyH("CENTER")
	SwatchWindow.CancelText:SetShadowColor(0, 0, 0)
	SwatchWindow.CancelText:SetShadowOffset(1, -1)
	SwatchWindow.CancelText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Cancel"].."|r")
	
	SwatchWindow.BG = CreateFrame("Frame", nil, SwatchWindow)
	SwatchWindow.BG:SetScaledPoint("TOPLEFT", SwatchWindow.Header, -3, 3)
	SwatchWindow.BG:SetScaledPoint("BOTTOMRIGHT", SwatchWindow, 3, 0)
	SwatchWindow.BG:SetBackdrop(vUI.BackdropAndBorder)
	SwatchWindow.BG:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	SwatchWindow.BG:SetBackdropBorderColor(0, 0, 0)
	
	SwatchWindow.Fade = CreateAnimationGroup(SwatchWindow)
	
	SwatchWindow.FadeIn = SwatchWindow.Fade:CreateAnimation("Fade")
	SwatchWindow.FadeIn:SetEasing("in")
	SwatchWindow.FadeIn:SetDuration(0.15)
	SwatchWindow.FadeIn:SetChange(1)
	
	SwatchWindow.FadeOut = SwatchWindow.Fade:CreateAnimation("Fade")
	SwatchWindow.FadeOut:SetEasing("in")
	SwatchWindow.FadeOut:SetDuration(0.15)
	SwatchWindow.FadeOut:SetChange(0)
	SwatchWindow.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	local Palette = Media:GetPalette("Material")
	
	for i = 1, #Palette do
		for j = 1, #Palette[i] do
			local Swatch = CreateFrame("Frame", nil, SwatchWindow)
			Swatch:SetScaledSize(SWATCH_SIZE, SWATCH_SIZE)
			Swatch:SetBackdrop(vUI.BackdropAndBorder)
			Swatch:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
			Swatch:SetBackdropBorderColor(0, 0, 0)
			Swatch:SetScript("OnMouseUp", ColorSwatchOnMouseUp)
			Swatch:SetScript("OnEnter", ColorSwatchOnEnter)
			Swatch:SetScript("OnLeave", ColorSwatchOnLeave)
			Swatch.Value = Palette[i][j]
			
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
			
			if (not SwatchWindow.SwatchParent[i]) then
				SwatchWindow.SwatchParent[i] = {}
			end
			
			tinsert(SwatchWindow.SwatchParent[i], Swatch)
			
			if (i == 1) then
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", SwatchWindow.SwatchParent, 3, -3)
				else
					Swatch:SetScaledPoint("LEFT", SwatchWindow.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			else
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", SwatchWindow.SwatchParent[i-1][1], "BOTTOMLEFT", 0, 1)
				else
					Swatch:SetScaledPoint("LEFT", SwatchWindow.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			end
			
			SwatchWindow.SwatchParent[i][j] = Swatch
		end
	end
	
	GUI.SwatchWindow = SwatchWindow
end

local SetSwatchObject = function(active)
	GUI.SwatchWindow.Active = active
	
	GUI.SwatchWindow.CompareCurrent:SetVertexColor(HexToRGB(active.Value))
	GUI.SwatchWindow.CurrentHexText:SetText("#"..active.Value)
end

local ColorSelectionOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ColorSelectionOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ColorSelectionOnMouseUp = function(self)
	if (not GUI.SwatchWindow) then
		CreateSwatchWindow()
	end
	
	if GUI.SwatchWindow:IsShown() then
		if (self ~= GUI.SwatchWindow.Active) then
			SetSwatchObject(self)
			
			GUI.SwatchWindow.NewHexText:SetText("#FFFFFF")
			GUI.SwatchWindow.CompareNew:SetVertexColor(1, 1, 1)
			GUI.SwatchWindow.Selected = "FFFFFF"
		else
			GUI.SwatchWindow.FadeOut:Play()
		end
	else
		SetSwatchObject(self)
		
		GUI.SwatchWindow.NewHexText:SetText("#FFFFFF")
		GUI.SwatchWindow.CompareNew:SetVertexColor(1, 1, 1)
		GUI.SwatchWindow.Selected = "FFFFFF"
		
		GUI.SwatchWindow:Show()
		GUI.SwatchWindow.FadeIn:Play()
	end
end

GUI.Widgets.CreateColorSelection = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH - (SPACING * 2), COLOR_HEIGHT)
	Anchor.WidgetHeight = COLOR_HEIGHT
	
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
	
	local Button = CreateFrame("Frame", nil, self)
	Button:SetScaledSize(COLOR_WIDTH, COLOR_HEIGHT)
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

local SortGroupWindows = function(self)
	local NumLeftGroups = #self.LeftGroups
	
	if NumLeftGroups then
		for i = 1, NumLeftGroups do
			self.LeftGroups[i]:ClearAllPoints()
			
			if (i == 1) then
				self.LeftGroups[i]:SetScaledPoint("TOPLEFT", self, SPACING, -SPACING)
			else
				self.LeftGroups[i]:SetScaledPoint("TOP", self.LeftGroups[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	local NumRightGroups = #self.RightGroups
	
	if NumRightGroups then
		for i = 1, NumRightGroups do
			self.RightGroups[i]:ClearAllPoints()
			
			if (i == 1) then
				self.RightGroups[i]:SetScaledPoint("TOPRIGHT", self, -SPACING, -SPACING)
			else
				self.RightGroups[i]:SetScaledPoint("TOP", self.RightGroups[i-1], "BOTTOM", 0, -2)
			end
		end
	end
end

local SortGroupWidgets = function(self)
	local Height = SPACING
	
	for i = 1, #self.Widgets do
		if (i == 1) then
			self.Widgets[i]:SetScaledPoint("TOPLEFT", self.WidgetParent, SPACING, -2)
		else
			self.Widgets[i]:SetScaledPoint("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -2)
		end
		
		Height = Height + self.Widgets[i].WidgetHeight + 2
	end
	
	self:SetScaledHeight(HEADER_HEIGHT + Height)
	self.WidgetParent:SetScaledHeight(Height)
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

local CreateGroup = function(self, name, side)
	local Key
	
	if (lower(side) == "left") then
		Key = "LeftGroups"
	else
		Key = "RightGroups"
	end
	
	-- Frame
	local Group = CreateFrame("Frame", nil, self)
	Group:SetScaledSize(GROUP_WIDTH, GROUP_HEIGHT)
	Group:SetScaledPoint("CENTER", self, 0, 0)
	Group:SetBackdrop(vUI.BackdropAndBorder)
	Group:SetBackdropColor(0.4, 0.4, 0.4)
	Group:SetBackdropBorderColor(0, 0, 0)
	
	-- Header
	Group.Header = CreateFrame("Frame", nil, Group)
	Group.Header:SetScaledSize(GROUP_WIDTH, HEADER_HEIGHT)
	Group.Header:SetScaledPoint("TOPLEFT", Group, 0, 0)
	Group.Header:SetBackdrop(vUI.BackdropAndBorder)
	Group.Header:SetBackdropColor(0.3, 0.3, 0.3)
	Group.Header:SetBackdropBorderColor(0, 0, 0)
	
	Group.NewTexture = Group.Header:CreateTexture(nil, "OVERLAY")
	Group.NewTexture:SetScaledPoint("TOPLEFT", Group.Header, 1, -1)
	Group.NewTexture:SetScaledPoint("BOTTOMRIGHT", Group.Header, -1, 1)
	Group.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Group.NewTexture:SetVertexColor(HexToRGB(Settings["ui-header-texture-color"]))
	
	Group.Header.Text = Group.Header:CreateFontString(nil, "OVERLAY")
	Group.Header.Text:SetScaledPoint("LEFT", Group.Header, HEADER_SPACING, 0)
	Group.Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 14)
	Group.Header.Text:SetJustifyH("LEFT")
	Group.Header.Text:SetShadowColor(0, 0, 0)
	Group.Header.Text:SetShadowOffset(1, -1)
	Group.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"]..name.."|r")
	
	-- Widget parent
	Group.WidgetParent = CreateFrame("Frame", nil, Group)
	Group.WidgetParent:SetScaledSize(GROUP_WIDTH, GROUP_WIDGETHEIGHT)
	Group.WidgetParent:SetScaledPoint("TOP", Group.Header, "BOTTOM", 0, 0)
	Group.WidgetParent:SetBackdrop(vUI.BackdropAndBorder)
	Group.WidgetParent:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Group.WidgetParent:SetBackdropBorderColor(0, 0, 0, 0)
	
	Group.Outline = CreateFrame("Frame", nil, Group)
	Group.Outline:SetScaledPoint("TOPLEFT", Group.Header, 0, 0)
	Group.Outline:SetScaledPoint("BOTTOMRIGHT", Group.WidgetParent, 0, 0)
	Group.Outline:SetBackdrop(vUI.Outline)
	Group.Outline:SetBackdropBorderColor(0, 0, 0)
	
	tinsert(self[Key], Group)
	
	for Name, Function in pairs(GUI.Widgets) do
		Group[Name] = Function
	end
	
	Group.SortGroupWidgets = SortGroupWidgets
	
	self:SortGroupWindows()
	
	-- Widgets
	Group.Widgets = {}
	
	return Group
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
		if (#Window.LeftGroups > 0) then
			for i = 1, #Window.LeftGroups do
				Window.LeftGroups[i]:SortGroupWidgets()
			end
		end
		
		if (#Window.RightGroups > 0) then
			for i = 1, #Window.RightGroups do
				Window.RightGroups[i]:SortGroupWidgets()
			end
		end
		
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
	Button.Text:SetFont(Media:GetFont(Settings["ui-widget-font"]), 16)
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
	Window:SetScaledSize(PARENT_WIDTH, PARENT_HEIGHT)
	Window:SetScaledPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	Window:SetBackdrop(vUI.BackdropAndBorder)
	Window:SetBackdropColor(HexToRGB(Settings["ui-window-bg-color"]))
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:Hide()
	
	Window.Parent = self
	Window.Button = Button
	Window.LeftGroups = {}
	Window.RightGroups = {}
	
	Window.CreateGroup = CreateGroup
	Window.SortGroupWindows = SortGroupWindows
	
	self.Windows[name] = Window
	
	self:SortButtons()
	
	if default then
		self.DefaultWindow = name
	end
	
	return Window
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
	self.Header.Text:SetTextColor(vUI:HexToRGB(Settings["ui-header-font-color"]))
	self.Header.Text:SetText(format(Language["- vUI version %s -"], vUI.Version))
	--self.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"]..format(Language["- |cff%svUI|r version %s -"], Settings["ui-widget-color"], vUI.Version).."|r")
	
	-- Selection parent
	self.SelectionParent = CreateFrame("Frame", nil, self)
	self.SelectionParent:SetScaledSize(BUTTON_LIST_WIDTH, BUTTON_LIST_HEIGHT)
	self.SelectionParent:SetScaledPoint("BOTTOMLEFT", GUI, SPACING, SPACING)
	self.SelectionParent:SetBackdrop(vUI.BackdropAndBorder)
	self.SelectionParent:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	self.SelectionParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Widget parent
	self.GroupParent = CreateFrame("Frame", nil, self)
	self.GroupParent:SetScaledSize(PARENT_WIDTH, PARENT_HEIGHT)
	self.GroupParent:SetScaledPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	self.GroupParent:SetBackdrop(vUI.BackdropAndBorder)
	self.GroupParent:SetBackdropColor(HexToRGB(Settings["ui-window-main-color"]))
	self.GroupParent:SetBackdropBorderColor(0, 0, 0)
	
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
		
		if (self.SwatchWindow and self.SwatchWindow:GetAlpha() > 0) then
			self.SwatchWindow.FadeOut:Play()
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
GUI.FadeOut:SetEasing("in")
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

function GUI:VARIABLES_LOADED()
	if (not vUISettings) then
		vUISettings = {}
	else
		for ID, Value in pairs(vUISettings) do
			Settings[ID] = Value
		end
	end
	
	self:Create()
	self:RunQueue()
	
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
		
		if (self.SwatchWindow and self.SwatchWindow:GetAlpha() > 0) then
			self.SwatchWindow.FadeOut:Play()
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
	local TemplatesOptions = self:NewWindow(Language["Templates"], true)
	
	local ConsoleGroup = TemplatesOptions:CreateGroup(Language["Console"], "Right")
	
	ConsoleGroup:CreateButton(Language["Reload"], Language["Reload UI"], "", ReloadUI)
	ConsoleGroup:CreateButton(Language["Delete"], Language["Delete Saved Variables"], "", function() vUISettings = {}; ReloadUI(); end)
	
	local TemplateGroup = TemplatesOptions:CreateGroup(Language["Templates"], "Left")
	
	TemplateGroup:CreateDropdown("ui-template", Settings["ui-template"], Media:GetTemplateList(), Language["Select Template"], "", function(v) Media:ApplyTemplate(v); ReloadUI(); end)
	
	local ButtonsGroup = TemplatesOptions:CreateGroup(Language["Buttons"], "Right")
	
	ButtonsGroup:CreateColorSelection("ui-button-font-color", "81D4FA", Language["Text Color"], "")
	ButtonsGroup:CreateColorSelection("ui-button-texture-color", "8E8E8E", Language["Texture Color"], "")
	ButtonsGroup:CreateDropdown("ui-button-texture", "Ferous 27", Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	ButtonsGroup:CreateDropdown("ui-button-font", "Roboto", Media:GetFontList(), Language["Font"], "", nil, "Font")
	
	local HeadersGroup = TemplatesOptions:CreateGroup(Language["Headers"], "Left")
	
	HeadersGroup:CreateColorSelection("ui-header-font-color", "81D4FA", Language["Text Color"], "")
	HeadersGroup:CreateColorSelection("ui-header-texture-color", "4D4D4D", Language["Texture Color"], "")
	HeadersGroup:CreateDropdown("ui-header-texture", "Ferous 27", Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	HeadersGroup:CreateDropdown("ui-header-font", "Roboto", Media:GetFontList(), Language["Header Font"], "", nil, "Font")
	
	local WidgetsGroup = TemplatesOptions:CreateGroup(Language["Widgets"], "Left")
	
	WidgetsGroup:CreateColorSelection("ui-widget-color", "F39C12", Language["Color"], "")
	WidgetsGroup:CreateColorSelection("ui-widget-bright-color", "8E8E8E", Language["Bright Color"], "")
	WidgetsGroup:CreateColorSelection("ui-widget-bg-color", "2B2B2B", Language["Background Color"], "")
	WidgetsGroup:CreateColorSelection("ui-widget-font-color", "FFFFFF", Language["Label Color"], "")
	WidgetsGroup:CreateDropdown("ui-widget-texture", "Ferous 27", Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	WidgetsGroup:CreateDropdown("ui-widget-font", "Roboto", Media:GetFontList(), Language["Font"], "", nil, "Font")
	
	local WindowsGroup = TemplatesOptions:CreateGroup(Language["Windows"], "Left")
	
	WindowsGroup:CreateColorSelection("ui-window-bg-color", "404040", Language["Background Color"], "")
	WindowsGroup:CreateColorSelection("ui-window-main-color", "424242", Language["Main Color"], "")
end)