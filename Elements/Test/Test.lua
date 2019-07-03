local vUI, GUI, Language, Media, Settings = select(2, ...):get()

-- The most important file there is.

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local tostring = tostring

local GetFramerate = GetFramerate

-- This is currently just a test page to text how GUI controls work, and debug them.
GUI:AddOptions(function(self)
	local TestOptions = self:NewWindow("Test")
	local GeneralGroup = TestOptions:CreateGroup("Checkboxes", "Left")
	
	GeneralGroup:CreateCheckbox("test-checkbox-1", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	GeneralGroup:CreateCheckbox("test-checkbox-2", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	GeneralGroup:CreateCheckbox("test-checkbox-3", false, "Checkbox Demo", "Show the textuals", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	local DropdownGroup = TestOptions:CreateGroup("Selections", "Right")
	
	DropdownGroup:CreateDropdown("test-dropdown-1", "Roboto", Media:GetFontList(), "Font Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Font")
	DropdownGroup:CreateDropdown("test-dropdown-2", "Blank", Media:GetTextureList(), "Texture Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	DropdownGroup:CreateDropdown("test-dropdown-3", "RenHorizonUp", Media:GetHighlightList(), "Highlight Menu Demo", "", function(v, id)vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	
	local SlidersGroup = TestOptions:CreateGroup("Sliders", "Right")
	
	SlidersGroup:CreateSlider("test-slider-1", 3, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	SlidersGroup:CreateSlider("test-slider-2", 7, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " px")
	SlidersGroup:CreateSlider("test-slider-3", 4, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " s")
	
	local ButtonsGroup = TestOptions:CreateGroup("Buttons", "Right")
	
	ButtonsGroup:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-1") end)
	ButtonsGroup:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-2") end)
	ButtonsGroup:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-3") end)
	
	local SwitchGroup = TestOptions:CreateGroup("Switches", "Left")
	
	SwitchGroup:CreateSwitch("test-switch-1", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	SwitchGroup:CreateSwitch("test-switch-2", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	SwitchGroup:CreateSwitch("test-switch-3", false, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	local ColorGroup = TestOptions:CreateGroup("Colors", "Left")
	
	ColorGroup:CreateColorSelection("test-color-1", "B0BEC5", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	ColorGroup:CreateColorSelection("test-color-2", "607D8B", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	ColorGroup:CreateColorSelection("test-color-3", "263238", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	local StatusBarsGroup = TestOptions:CreateGroup("StatusBars", "Left")
	
	local Bar = StatusBarsGroup:CreateStatusBar(0, 0, 0, "Statusbar Demo", "", function(v)
		Framerate = floor(GetFramerate())
		
		return 0, 250, Framerate, Framerate
	end)
	
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
end)