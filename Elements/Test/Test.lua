local vUI, GUI, Language, Media, Settings = select(2, ...):get()

-- The most important file there is.

-- Cinematic Mode with black lines on the top and bottom of the screen. Reposition the UI parent
-- Notification system with a bell icon under the minimap or something. This is just a small log where it shows things like version handshakes, update news etc

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local tostring = tostring

local GetFramerate = GetFramerate

-- This is currently just a test page to text how GUI controls work, and debug them.
GUI:AddOptions(function(self)
	local Window = self:NewWindow("Test")
	
	Window:CreateHeader("Left", Language["Checkboxes"])
	Window:CreateCheckbox("Left", "test-checkbox-1", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateCheckbox("Left", "test-checkbox-2", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateCheckbox("Left", "test-checkbox-3", false, "Checkbox Demo", "Show the textuals", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Window:CreateHeader("Right", Language["Selections"])
	Window:CreateDropdown("Right", "test-dropdown-1", "Roboto", Media:GetFontList(), "Font Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Font")
	Window:CreateDropdown("Right", "test-dropdown-2", "Blank", Media:GetTextureList(), "Texture Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	Window:CreateDropdown("Right", "test-dropdown-3", "RenHorizonUp", Media:GetHighlightList(), "Highlight Menu Demo", "", function(v, id)vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	
	Window:CreateHeader("Right", Language["Sliders"])
	Window:CreateSlider("Right", "test-slider-1", 3, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateSlider("Right", "test-slider-2", 7, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " px")
	Window:CreateSlider("Right", "test-slider-3", 4, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " s")
	
	Window:CreateHeader("Right", Language["Buttons"])
	Window:CreateButton("Right", "Test", "Button Demo", "Enable something", function() vUI:print("test-button-1") end)
	Window:CreateButton("Right", "Test", "Button Demo", "Enable something", function() vUI:print("test-button-2") end)
	Window:CreateButton("Right", "Test", "Button Demo", "Enable something", function() vUI:print("test-button-3") end)
	
	Window:CreateHeader("Left", Language["Switches"])
	Window:CreateSwitch("Left", "test-switch-1", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateSwitch("Left", "test-switch-2", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateSwitch("Left", "test-switch-3", false, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Window:CreateHeader("Left", Language["Colors"])
	Window:CreateColorSelection("Left", "test-color-1", "B0BEC5", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateColorSelection("Left", "test-color-2", "607D8B", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Window:CreateColorSelection("Left", "test-color-3", "263238", "Color Selection Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Window:CreateHeader("Left", Language["StatusBars"])
	
	local Bar = Window:CreateStatusBar("Left", 0, 0, 0, "Statusbar Demo", "", function(v)
		Framerate = floor(GetFramerate())
		
		return 0, 350, Framerate, Framerate
	end)
	
	Window:CreateStatusBar("Left", 5, 0, 10, "Statusbar Demo", "")
	Window:CreateStatusBar("Left", 75, 0, 100, "Statusbar Demo", "", nil, "%")
	
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
	
	-- Testing
	local Window = self:NewWindow("Action Bars")
	local Window = self:NewWindow("Unit Frames")
	local Window = self:NewWindow("Tooltips")
	local Window = self:NewWindow("Misc.")
	local Window = self:NewWindow("Info")
	local Window = self:NewWindow("Search")
end)