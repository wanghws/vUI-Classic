local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

-- The most important file there is.

-- Cinematic Mode with black lines on the top and bottom of the screen. Reposition the UI parent
-- Notification system with a bell icon under the minimap or something. This is just a small log where it shows things like version handshakes, update news etc

-- To do: A bag slot visualizer (Yes, like FFXIV)
-- black square, 2x2 pixels inside, colored by what's in the slot if occupied, 0.3 opacity if it's an empty slot.

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local tostring = tostring

local GetFramerate = GetFramerate

-- This is currently just a test page to see how GUI controls work, and debug them.
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
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-3") end)
	
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
	Left:CreateInput("test-input-1", vUI.User, "Test Input 1", nil, function(v) print(v) end)
	Left:CreateInput("test-input-2", vUI.User, "Test Input 2", nil, function(v) print(v) end)
	Left:CreateInput("test-input-3", vUI.User, "Test Input 3", nil, function(v) print(v) end)
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	-- Testing
	self:CreateWindow("Unit Frames")
	self:CreateWindow("Tooltips")
	self:CreateWindow("Misc.")
	self:CreateWindow("Search")
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow("Info")
	
	Left:CreateHeader("UI Information")
	Left:CreateDoubleLine("Version", vUI.Version)
	Left:CreateDoubleLine("UI Scale", Settings["ui-scale"].."%")
	Left:CreateDoubleLine("Resolution", select(GetCurrentResolution(), GetScreenResolutions()))
	Left:CreateDoubleLine("Profile", Profiles:GetActiveProfileName())
	Left:CreateDoubleLine("Template", Settings["ui-template"])
	Left:CreateDoubleLine("Locale", vUI.Locale)
	
	Right:CreateHeader("User Information")
	Right:CreateDoubleLine("User", vUI.User)
	Right:CreateDoubleLine("Class", vUI.Class)
	Right:CreateDoubleLine("Realm", vUI.Realm)
	
	Left:CreateFooter()
	Right:CreateFooter()
end)

-- small quick concept
local Throttles = {}
Throttles.Inactive = {}
Throttles.Active = {}

function Throttles:NewThrottle(name, duration)
	if (self.Active[name] or self.Inactive[name]) then
		return
	end
	
	self.Inactive[name] = duration
end

function Throttles:IsThrottled(name)
	if self.Active[name] then
		return true
	end
end

function Throttles:Start(name)
	-- put into an updater
end

function Throttles:Stop(name)
	
end