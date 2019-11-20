local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local KeyBinding = vUI:NewModule("Key Binding")

local GetMouseFocus = GetMouseFocus
local match = string.match

KeyBinding.ValidBindings = {
	["ACTIONBUTTON1"] = true, ["ACTIONBUTTON2"] = true, ["ACTIONBUTTON3"] = true, ["ACTIONBUTTON4"] = true, ["ACTIONBUTTON5"] = true, ["ACTIONBUTTON6"] = true, ["ACTIONBUTTON7"] = true, ["ACTIONBUTTON8"] = true, ["ACTIONBUTTON9"] = true, ["ACTIONBUTTON10"] = true, ["ACTIONBUTTON11"] = true, ["ACTIONBUTTON12"] = true,
	["BONUSACTIONBUTTON1"] = true, ["BONUSACTIONBUTTON2"] = true, ["BONUSACTIONBUTTON3"] = true, ["BONUSACTIONBUTTON4"] = true, ["BONUSACTIONBUTTON5"] = true, ["BONUSACTIONBUTTON6"] = true, ["BONUSACTIONBUTTON7"] = true, ["BONUSACTIONBUTTON8"] = true, ["BONUSACTIONBUTTON9"] = true, ["BONUSACTIONBUTTON10"] = true,
	["MULTIACTIONBAR1BUTTON1"] = true, ["MULTIACTIONBAR1BUTTON2"] = true, ["MULTIACTIONBAR1BUTTON3"] = true, ["MULTIACTIONBAR1BUTTON4"] = true, ["MULTIACTIONBAR1BUTTON5"] = true, ["MULTIACTIONBAR1BUTTON6"] = true, ["MULTIACTIONBAR1BUTTON7"] = true, ["MULTIACTIONBAR1BUTTON8"] = true, ["MULTIACTIONBAR1BUTTON9"] = true, ["MULTIACTIONBAR1BUTTON10"] = true, ["MULTIACTIONBAR1BUTTON11"] = true, ["MULTIACTIONBAR1BUTTON12"] = true,
	["MULTIACTIONBAR2BUTTON1"] = true, ["MULTIACTIONBAR2BUTTON2"] = true, ["MULTIACTIONBAR2BUTTON3"] = true, ["MULTIACTIONBAR2BUTTON4"] = true, ["MULTIACTIONBAR2BUTTON5"] = true, ["MULTIACTIONBAR2BUTTON6"] = true, ["MULTIACTIONBAR2BUTTON7"] = true, ["MULTIACTIONBAR2BUTTON8"] = true, ["MULTIACTIONBAR2BUTTON9"] = true, ["MULTIACTIONBAR2BUTTON10"] = true, ["MULTIACTIONBAR2BUTTON11"] = true, ["MULTIACTIONBAR2BUTTON12"] = true,
	["MULTIACTIONBAR3BUTTON1"] = true, ["MULTIACTIONBAR3BUTTON2"] = true, ["MULTIACTIONBAR3BUTTON3"] = true, ["MULTIACTIONBAR3BUTTON4"] = true, ["MULTIACTIONBAR3BUTTON5"] = true, ["MULTIACTIONBAR3BUTTON6"] = true, ["MULTIACTIONBAR3BUTTON7"] = true, ["MULTIACTIONBAR3BUTTON8"] = true, ["MULTIACTIONBAR3BUTTON9"] = true, ["MULTIACTIONBAR3BUTTON10"] = true, ["MULTIACTIONBAR3BUTTON11"] = true,
	["MULTIACTIONBAR3BUTTON12"] = true, ["MULTIACTIONBAR4BUTTON1"] = true, ["MULTIACTIONBAR4BUTTON2"] = true, ["MULTIACTIONBAR4BUTTON3"] = true, ["MULTIACTIONBAR4BUTTON4"] = true, ["MULTIACTIONBAR4BUTTON5"] = true, ["MULTIACTIONBAR4BUTTON6"] = true, ["MULTIACTIONBAR4BUTTON7"] = true, ["MULTIACTIONBAR4BUTTON8"] = true, ["MULTIACTIONBAR4BUTTON9"] = true, ["MULTIACTIONBAR4BUTTON10"] = true, ["MULTIACTIONBAR4BUTTON11"] = true, ["MULTIACTIONBAR4BUTTON12"] = true,
	["SHAPESHIFTBUTTON1"] = true, ["SHAPESHIFTBUTTON2"] = true, ["SHAPESHIFTBUTTON3"] = true, ["SHAPESHIFTBUTTON4"] = true, ["SHAPESHIFTBUTTON5"] = true, ["SHAPESHIFTBUTTON6"] = true, ["SHAPESHIFTBUTTON7"] = true, ["SHAPESHIFTBUTTON8"] = true, ["SHAPESHIFTBUTTON9"] = true, ["SHAPESHIFTBUTTON10"] = true,
}

KeyBinding.Translate = {
	["MultiBarBottomLeftButton"] = "MULTIACTIONBAR1BUTTON",
	["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
	["MultiBarRightButton"] = "MULTIACTIONBAR3BUTTON",
	["MultiBarLeftButton"] = "MULTIACTIONBAR4BUTTON",
}

KeyBinding.Filter = {
	["BACKSPACE"] = true,
	["LALT"] = true,
	["RALT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["ENTER"] = true,
	["ESCAPE"] = true,
}

function KeyBinding:OnKeyUp(key)
	if (not IsKeyPressIgnoredForBinding(key) and not self.Filter[key] and self.TargetBindingName) then
		local Alt = IsAltKeyDown() and "ALT-" or ""
		local Ctrl = IsControlKeyDown() and "CTRL-" or ""
		local Shift = IsShiftKeyDown() and "SHIFT-" or ""
		
		if (Alt or Ctrl or Shift) then
			key = Alt .. Ctrl .. Shift .. key
		end
		
		local OldAction = GetBindingAction(key, true)
		
		if OldAction then
			local OldName = GetBindingName(OldAction)
			
			vUI:print(format(Language['Unbound "%s" from %s'], key, OldName))
		end
		
		SetBinding(key, self.TargetBindingName, 1)
		
		local NewAction = GetBindingAction(key, true)
		local NewName = GetBindingName(NewAction)
		
		vUI:print(format(Language['Bound "%s" to %s'], key, NewName))
		
		GUI:GetWidgetByWindow(Language["Action Bars"], "save"):Enable()
		GUI:GetWidgetByWindow(Language["Action Bars"], "discard"):Enable()
	end
end

function KeyBinding:OnKeyDown(key)
	local MouseFocus = GetMouseFocus()
	
	if (MouseFocus and MouseFocus.GetName) then
		local Name = MouseFocus:GetName()
		local ButtonName = match(Name, "%D+")
		local ActionNum = match(Name, "(%d+)$")
		
		if self.Translate[ButtonName] then
			local BindingName = self.Translate[ButtonName] .. ActionNum
			
			if self.ValidBindings[BindingName] then
				self.TargetBindingName = BindingName
				self.TargetName = Name
			end
		end
	end
end

function KeyBinding:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.05) then
		local MouseFocus = GetMouseFocus()
		
		if (MouseFocus and MouseFocus.action) then
			self.Hover:SetScaledPoint("TOPLEFT", MouseFocus, 1, -1)
			self.Hover:SetScaledPoint("BOTTOMRIGHT", MouseFocus, -1, 1)
			self.Hover:Show()
		elseif self.Hover:IsShown() then
			self.Hover:Hide()
		end
		
		self.Elapsed = 0
	end
end

local DisableKeyBindingMode = function()
	KeyBinding:Disable()
end

function KeyBinding:Enable()
	self:EnableKeyboard(true)
	self:SetScript("OnUpdate", self.OnUpdate)
	self:SetScript("OnKeyDown", self.OnKeyDown)
	self:SetScript("OnKeyUp", self.OnKeyUp)
	self.Active = true
	
	vUI:print("Binding mode enabled.")
	
	vUI:DisplayPopup(Language["Attention"], Language["Key binding mode is currently active. Would you like to exit key binding mode?"], Language["Accept"], DisableKeyBindingMode, Language["Cancel"])
end

function KeyBinding:Disable()
	self:EnableKeyboard(false)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnKeyDown", nil)
	self:SetScript("OnKeyUp", nil)
	self.Active = false
	self.TargetBindingName = nil
	
	vUI:print("Binding mode is disabled.")
	vUI:ClearPopup()
end

function KeyBinding:Toggle()
	if self.Active then
		self:Disable()
	else
		self:Enable()
	end
end

function KeyBinding:Load()
	self.Elapsed = 0
	
	self.Hover = CreateFrame("Frame", nil, self)
	self.Hover:SetFrameLevel(50)
	self.Hover:SetFrameStrata("DIALOG")
	self.Hover:SetBackdrop(vUI.Outline)
	self.Hover:SetBackdropBorderColorHex("388E3C")
	self.Hover:Hide()
end

local ToggleBindingMode = function()
	KeyBinding:Toggle()
end

local OnAccept = function()
	AttemptToSaveBindings(GetCurrentBindingSet())
	
	GUI:GetWidgetByWindow(Language["Action Bars"], "discard"):Disable()
	GUI:GetWidgetByWindow(Language["Action Bars"], "save"):Disable()
	
	KeyBinding:Disable()
end

local SaveChanges = function()
	vUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to save these key binding changes?"], Language["Accept"], OnAccept, Language["Cancel"])
end

local DiscardChanges = function()
	vUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to discard these key binding changes?"], Language["Accept"], ReloadUI, Language["Cancel"])
end

--[[GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["Action Bars"])
	
	Right:CreateHeader(Language["Key Binding"])
	Right:CreateButton(Language["Toggle"], Language["Key Bind Mode"], "While toggled, you can hover over action buttons|nand press a key combination to rebind that action", ToggleBindingMode)
	Right:CreateButton(Language["Save"], Language["Save Changes"], "Save key binding changes", SaveChanges)
	Right:CreateButton(Language["Discard"], Language["Discard Changes"], "Discard key binding changes", DiscardChanges)
	
	self:GetWidgetByWindow(Language["Action Bars"], "save"):Disable()
	self:GetWidgetByWindow(Language["Action Bars"], "discard"):Disable()
end)]]