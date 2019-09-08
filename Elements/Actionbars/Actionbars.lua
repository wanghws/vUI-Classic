local vUI, GUI, Language, Media, Settings = select(2, ...):get()

-- Some of the settings callbacks still need checks for if Experience or Action Bars are enabled

-- 3 bottom bars, 2 right bars layout
-- Start on pet bar.

local BUTTON_SIZE = 32
local STANCE_SIZE = 32
local SPACING = 2

local BOTTOM_WIDTH = ((BUTTON_SIZE * 12) + (SPACING * 14))
local BOTTOM_HEIGHT = ((BUTTON_SIZE * 2) + (SPACING * 4))

local SIDE_WIDTH = ((BUTTON_SIZE * 3) + (SPACING * 5))
local SIDE_HEIGHT = ((BUTTON_SIZE * 12) + (SPACING * 14))

local PET_WIDTH = ((BUTTON_SIZE * 1) + (SPACING * 3))
local PET_HEIGHT = ((BUTTON_SIZE * 10) + (SPACING * 12))

local Num = NUM_ACTIONBAR_BUTTONS
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange

local ActionBars = CreateFrame("Frame")

local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
Hider:Hide()

local Kill = function(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	object:Hide()
end

local SkinButton = function(button)
	if button.IsSkinned then
		return
	end
	
	button:SetNormalTexture("")
	
	if button.Border then
		button.Border:SetTexture(nil)
	end
	
	if button.icon then
		button.icon:ClearAllPoints()
		button.icon:SetScaledPoint("TOPLEFT", button, 1, -1)
		button.icon:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if _G[button:GetName() .. "FloatingBG"] then
		Kill(_G[button:GetName() .. "FloatingBG"])
	end
	
	if button.HotKey then
		button.HotKey:ClearAllPoints()
		button.HotKey:SetScaledPoint("TOPLEFT", button, 2, -2)
		button.HotKey:SetFontInfo(Settings["ui-widget-font"], 12)
		button.HotKey:SetJustifyH("LEFT")
		button.HotKey:SetDrawLayer("OVERLAY")
		button.HotKey:SetTextColor(1, 1, 1)
		button.HotKey.SetTextColor = function() end
		
		local HotKeyText = button.HotKey:GetText()
		
		if HotKeyText then
			button.HotKey:SetText("|cffFFFFFF" .. HotKeyText .. "|r")
		end
		
		button.HotKey.OST = button.HotKey.SetText
		button.HotKey.SetText = function(self, text)
			self:OST("|cFFFFFFFF" .. text .. "|r")
		end
		
		if (not Settings["action-bars-show-hotkeys"]) then
			button.HotKey:Hide()
		end
	end
	
	if button.Name then
		button.Name:ClearAllPoints()
		button.Name:SetScaledPoint("BOTTOMLEFT", button, 2, 2)
		button.Name:SetScaledWidth(button:GetWidth() - 4)
		button.Name:SetFontInfo(Settings["ui-widget-font"], 12)
		button.Name:SetJustifyH("LEFT")
		button.Name:SetDrawLayer("OVERLAY")
		button.Name:SetTextColor(1, 1, 1)
		button.Name.SetTextColor = function() end
		
		if (not Settings["action-bars-show-macro-names"]) then
			button.Name:Hide()
		end
	end
	
	if (not button.CountBG) then
		button.CountBG = button:CreateTexture(nil, "BORDER")
		button.CountBG:SetScaledPoint("BOTTOMRIGHT", button, 0, 0)
		button.CountBG:SetScaledSize(24, 16)
		button.CountBG:SetTexture(Media:GetTexture("Blank"))
		button.CountBG:SetVertexColor(0, 0, 0, 0.9)
		button.CountBG:Hide()
	end
	
	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetScaledPoint("TOPRIGHT", button, -2, -2)
		button.Count:SetFontInfo(Settings["ui-widget-font"], 12)
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetDrawLayer("OVERLAY")
		button.Count:SetTextColor(1, 1, 1)
		button.Count.SetTextColor = function() end
		
		if (not Settings["action-bars-show-count"]) then
			button.Count:Hide()
		end
	end
	
	button.Backdrop = CreateFrame("Frame", nil, button)
	button.Backdrop:SetScaledPoint("TOPLEFT", button, 0, 0)
	button.Backdrop:SetScaledPoint("BOTTOMRIGHT", button, 0, 0)
	button.Backdrop:SetBackdrop(vUI.Backdrop)
	button.Backdrop:SetBackdropColor(0, 0, 0)
	button.Backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
	
	button.Backdrop.Texture = button.Backdrop:CreateTexture(nil, "BACKDROP")
	button.Backdrop.Texture:SetScaledPoint("TOPLEFT", button.Backdrop, 1, -1)
	button.Backdrop.Texture:SetScaledPoint("BOTTOMRIGHT", button.Backdrop, -1, 1)
	button.Backdrop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	button.Backdrop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	if (button.SetHighlightTexture and not button.Highlight) then
		local Highlight = button:CreateTexture(nil, "ARTWORK", button)
		Highlight:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Highlight:SetVertexColor(1, 1, 1, 0.2)
		Highlight:SetScaledPoint("TOPLEFT", button, 1, -1)
		Highlight:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Highlight = Highlight
		button:SetHighlightTexture(Highlight)
	end
	
	if (button.SetPushedTexture and not button.Pushed) then
		local Pushed = button:CreateTexture(nil, "ARTWORK", button)
		Pushed:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
		Pushed:SetScaledPoint("TOPLEFT", button, 1, -1)
		Pushed:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Pushed = Pushed
		button:SetPushedTexture(Pushed)
	end
	
	if (button.SetCheckedTexture and not button.Checked) then
		local Checked = button:CreateTexture(nil, "ARTWORK", button)
		Checked:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Checked:SetVertexColor(0.1, 1, 0.1, 0.2)
		Checked:SetScaledPoint("TOPLEFT", button, 1, -1)
		Checked:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Checked = Checked
		button:SetCheckedTexture(Checked)
	end
	
	local Range = button:CreateTexture(nil, "ARTWORK", button)
	Range:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
	Range:SetVertexColor(0.7, 0, 0)
	Range:SetScaledPoint("TOPLEFT", button, 1, -1)
	Range:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	Range:SetAlpha(0)
	
	button.Range = Range
	
	if button.cooldown then
		button.cooldown:ClearAllPoints()
		button.cooldown:SetScaledPoint("TOPLEFT", button, 1, -1)
		button.cooldown:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.cooldown:SetDrawEdge(true)
		button.cooldown:SetEdgeTexture(Media:GetTexture("Blank"))
		button.cooldown:SetSwipeColor(0, 0, 0, 1)
	end
	
	button:SetFrameLevel(15)
	button:SetFrameStrata("MEDIUM")
	
	button.IsSkinned = true
end

local ShowGridAndSkin = function()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local Button
		
		Button = _G[format("ActionButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		SkinButton(Button)
		
		Button = _G[format("MultiBarRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		SkinButton(Button)
		
		Button = _G[format("MultiBarBottomRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		SkinButton(Button)
		
		Button = _G[format("MultiBarLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		SkinButton(Button)
		
		Button = _G[format("MultiBarBottomLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		SkinButton(Button)
	end
end

local UpdateBar1 = function()
	local ActionBar1 = vUIActionBar1
	local Button
	
	for i = 1, Num do
		Button = _G["ActionButton"..i]
		ActionBar1:SetFrameRef("ActionButton"..i, Button)
	end
	
	ActionBar1:Execute([[
		Button = table.new()
		
		for i = 1, 12 do
			table.insert(Button, self:GetFrameRef("ActionButton"..i))
		end
	]])
	
	ActionBar1:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		for i, Button in ipairs(Button) do
			Button:SetAttribute("actionpage", tonumber(newstate))
		end
	]])
	
	RegisterStateDriver(ActionBar1, "page", ActionBar1.GetBar())
end

local CreateBar1 = function()
	local Druid, Rogue, Warrior, Priest = "", "", "", ""
	
	local ActionBar1 = CreateFrame("Frame", "vUIActionBar1", UIParent, "SecureHandlerStateTemplate")
	ActionBar1:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	ActionBar1:SetScaledPoint("BOTTOMLEFT", vUIBottomActionBarsPanel, (SPACING + 1), (SPACING + 1))
	ActionBar1:SetFrameStrata("MEDIUM")
	
	Rogue = "[bonusbar:1] 7;"
	Druid = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;"
	Warrior = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;"
	Priest = "[bonusbar:1] 7;"
	
	ActionBar1.Page = {
		["DRUID"] = Druid,
		["ROGUE"] = Rogue,
		["WARRIOR"] = Warrior,
		["PRIEST"] = Priest,
		["DEFAULT"] = "[bar:6] 6;[bar:5] 5;[bar:4] 4;[bar:3] 3;[bar:2] 2;[overridebar] 14;[shapeshift] 13;[vehicleui] 12;[possessbar] 12;",
	}
	
	ActionBar1.GetBar = function()
		local Condition = ActionBar1.Page["DEFAULT"]
		local Page = ActionBar1.Page[vUI.UserClass]
		
		if Page then
			Condition = Condition .. " " .. Page
		end
		
		Condition = Condition .. " [form] 1; 1"
		
		return Condition
	end
	
	for i = 1, Num do
		local Button = _G["ActionButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		Button:SetParent(ActionBar1)
		
		if (i == 1) then
			Button:SetScaledPoint("LEFT", 0, 0)
		else
			Button:SetScaledPoint("LEFT", ActionBar1[i-1], "RIGHT", SPACING, 0)
		end
		
		ActionBar1[i] = Button
	end
	
	UpdateBar1()
	ShowGridAndSkin()
	
	MainMenuBar:SetParent(Hider)
end

local CreateBar2 = function()
	local ActionBar2 = CreateFrame("Frame", "vUIActionBar2", UIParent, "SecureHandlerStateTemplate")
	ActionBar2:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	ActionBar2:SetFrameStrata("MEDIUM")
	
	MultiBarBottomLeft:SetParent(ActionBar2)
	
	for i = 1, Num do
		local Button = _G["MultiBarBottomLeftButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("LEFT", ActionBar2, 0, 0)
		else
			Button:SetScaledPoint("LEFT", ActionBar2[i-1], "RIGHT", SPACING, 0)
		end
		
		ActionBar2[i] = Button
	end
end

local CreateBar3 = function()
	local ActionBar3 = CreateFrame("Frame", "vUIActionBar3", UIParent, "SecureHandlerStateTemplate")
	ActionBar3:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar3:SetScaledPoint("RIGHT", vUISideActionBarsPanel, -(SPACING + 1), 0)
	ActionBar3:SetFrameStrata("MEDIUM")
	
	MultiBarRight:SetParent(ActionBar3)
	
	for i = 1, Num do
		local Button = _G["MultiBarRightButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar3, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar3[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar3[i] = Button
	end
end

local CreateBar4 = function()
	local ActionBar4 = CreateFrame("Frame", "vUIActionBar4", UIParent, "SecureHandlerStateTemplate")
	ActionBar4:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar4:SetFrameStrata("MEDIUM")
	
	MultiBarLeft:SetParent(ActionBar4)
	
	for i = 1, Num do
		local Button = _G["MultiBarLeftButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar4, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar4[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar4[i] = Button
	end
end

local CreateBar5 = function()
	local ActionBar5 = CreateFrame("Frame", "vUIActionBar5", UIParent, "SecureHandlerStateTemplate")
	ActionBar5:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar5:SetFrameStrata("MEDIUM")
	
	MultiBarBottomRight:SetParent(ActionBar5)
	
	for i = 1, Num do
		local Button = _G["MultiBarBottomRightButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar5, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar5[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar5[i] = Button
	end
end

local SkinPetButton = function(button)
	if button.Styled then
		return
	end
	
	local Name = button:GetName()
	local Icon = _G[Name .. "Icon"]
	local Normal2 = _G[Name .. "NormalTexture2"]
	local HotKey = _G[Name .. "HotKey"]
	local Shine = _G[Name .. "Shine"]
	
	Shine:SetScaledSize(BUTTON_SIZE - 6, BUTTON_SIZE - 6)
	Shine:ClearAllPoints()
	Shine:SetPoint("CENTER", button, 0, 0)
	
	Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Icon:SetDrawLayer("BACKGROUND", 7)
	
	button:SetNormalTexture("")
	button.SetNormalTexture = function() end
	
	_G[Name.."Flash"]:SetTexture("")
	
	if Normal2 then
		Normal2:ClearAllPoints()
		Normal2:SetPoint("TOPLEFT")
		Normal2:SetPoint("BOTTOMRIGHT")
	end
	
	button.Styled = true
end

local CreatePetBar = function()
	PetActionBarFrame:UnregisterEvent("PET_BAR_SHOWGRID")
	PetActionBarFrame:UnregisterEvent("PET_BAR_HIDEGRID")
	PetActionBarFrame.showgrid = 1
	
	local Max = NUM_PET_ACTION_SLOTS
	
	local PetActionBar = CreateFrame("Frame", "vUIPetActionBar", vUIPetActionBarsPanel, "SecureHandlerStateTemplate")
	PetActionBar:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * Max) + (SPACING * (Max - 1))))
	PetActionBar:SetScaledPoint("CENTER", vUIPetActionBarsPanel, 0, 0)
	PetActionBar:SetFrameStrata("MEDIUM")
	
	for i = 1, Max do
		local Button = _G["PetActionButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:SetParent(vUIPetActionBarsPanel)
		Button:ClearAllPoints()
		
		SkinPetButton(Button)
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", PetActionBar, 0, 0)
		else
			Button:SetScaledPoint("TOP", PetActionBar[i-1], "BOTTOM", 0, -SPACING)
		end
		
		PetActionBar:SetAttribute("addchild", Button)
		PetActionBar[i] = Button
	end
	
	RegisterStateDriver(vUIPetActionBarsPanel, "visibility", "[pet,nooverridebar,nobonusbar:5] show; hide")
end

local CreateStanceBar = function()
	local NumForms = GetNumShapeshiftForms()
	
	local StancePanel = CreateFrame("Frame", "vUI Stance", UIParent)
	StancePanel:SetScaledPoint("TOPLEFT", UIParent, 10, -10)
	StancePanel:SetBackdrop(vUI.BackdropAndBorder)
	StancePanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	StancePanel:SetBackdropBorderColor(0, 0, 0)
	StancePanel:SetFrameStrata("LOW")
	
	StancePanel:SetScaledWidth((STANCE_SIZE * NumForms) + (SPACING * (NumForms + 2)))
	StancePanel:SetScaledHeight(((STANCE_SIZE * 1) + (SPACING * 3)))
	
	vUI:GetModule("Move"):Add(StancePanel)
	
	local Button
	
	if (StanceBarFrame and StanceBarFrame.StanceButtons) then
		for i = 1, NUM_STANCE_SLOTS do
			Button = StanceBarFrame.StanceButtons[i]
			
			SkinButton(Button)
			Button:SetScaledSize(STANCE_SIZE)
			Button:SetParent(StancePanel)
			Button:SetFrameStrata("MEDIUM")
			Button:ClearAllPoints()
			
			if i == 1 then
				Button:SetScaledPoint("LEFT", StancePanel, 3, 0)
			else
				Button:SetScaledPoint("LEFT", StanceBarFrame.StanceButtons[i-1], "RIGHT", 2, 0)
			end
		end
	end
	
	ActionBars.StanceBar = StancePanel
end

local CreateBarPanels = function()
	local BottomPanel = CreateFrame("Frame", "vUIBottomActionBarsPanel", UIParent)
	BottomPanel:SetScaledSize(BOTTOM_WIDTH, BOTTOM_HEIGHT)
	BottomPanel:SetBackdrop(vUI.BackdropAndBorder)
	BottomPanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	BottomPanel:SetBackdropBorderColor(0, 0, 0)
	BottomPanel:SetFrameStrata("LOW")
	
	if (not Settings["action-bars-show-bottom-bg"]) then
		BottomPanel:SetAlpha(0)
	end
	
	local SidePanel = CreateFrame("Frame", "vUISideActionBarsPanel", UIParent)
	SidePanel:SetScaledSize(SIDE_WIDTH, SIDE_HEIGHT)
	SidePanel:SetScaledPoint("RIGHT", UIParent, -10, 0)
	SidePanel:SetBackdrop(vUI.BackdropAndBorder)
	SidePanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	SidePanel:SetBackdropBorderColor(0, 0, 0)
	SidePanel:SetFrameStrata("LOW")
	
	local PetPanel = CreateFrame("Frame", "vUIPetActionBarsPanel", UIParent)
	PetPanel:SetScaledSize(PET_WIDTH, PET_HEIGHT)
	PetPanel:SetScaledPoint("RIGHT", SidePanel, "LEFT", -SPACING, 0)
	PetPanel:SetBackdrop(vUI.BackdropAndBorder)
	PetPanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	PetPanel:SetBackdropBorderColor(0, 0, 0)
	PetPanel:SetFrameStrata("LOW")
	
	if (not Settings["action-bars-show-side-bg"]) then
		SidePanel:SetAlpha(0)
	end
	
	if (Settings["experience-position"] == "CLASSIC") then
		BottomPanel:SetScaledPoint("BOTTOM", vUIExperienceBar, "TOP", 0, 5)
	else
		BottomPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
	end
end

local SetClassicStyle = function()
	local Bar = vUIActionBar5
	
	Bar:ClearAllPoints()
	Bar:SetScaledPoint("TOPRIGHT", vUIBottomActionBarsPanel, -(SPACING + 1), -(SPACING + 1))
	Bar:SetScaledSize((BUTTON_SIZE * 6) + (SPACING * 5), (BUTTON_SIZE * 2) + SPACING)
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("TOPLEFT", vUIBottomActionBarsPanel, (SPACING + 1), -(SPACING + 1))
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("LEFT", vUISideActionBarsPanel, (SPACING + 1), 0)
	
	vUIBottomActionBarsPanel:SetScaledSize((BOTTOM_WIDTH + (BOTTOM_WIDTH / 2)) - SPACING, BOTTOM_HEIGHT)
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 2) + (SPACING * 4)), SIDE_HEIGHT)
	
	for i = 1, Num do
		Bar[i]:ClearAllPoints()
		
		if (i == 1) then
			Bar[i]:SetScaledPoint("BOTTOMLEFT", Bar, 0, 0)
		elseif (i == 7) then
			Bar[i]:SetScaledPoint("TOPLEFT", Bar, 0, 0)
		else
			Bar[i]:SetScaledPoint("LEFT", Bar[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set2x3Style = function()
	local Bar = vUIActionBar5
	
	Bar:ClearAllPoints()
	Bar:SetScaledPoint("LEFT", vUISideActionBarsPanel, (SPACING + 1), 0)
	Bar:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("TOP", vUIBottomActionBarsPanel, 0, -(SPACING + 1))
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("TOP", vUISideActionBarsPanel, 0, -(SPACING + 1))
	
	vUIBottomActionBarsPanel:SetScaledSize(BOTTOM_WIDTH, BOTTOM_HEIGHT)
	vUISideActionBarsPanel:SetScaledSize(SIDE_WIDTH, SIDE_HEIGHT)
	
	for i = 1, Num do
		Bar[i]:ClearAllPoints()
		
		if (i == 1) then
			Bar[i]:SetScaledPoint("TOP", Bar, 0, 0)
		else
			Bar[i]:SetScaledPoint("TOP", Bar[i-1], "BOTTOM", 0, -SPACING)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set3x2Style = function()
	local Bar = vUIActionBar5
	
	Bar:ClearAllPoints()
	Bar:SetScaledPoint("TOP", vUIBottomActionBarsPanel, 0, -(SPACING + 1))
	Bar:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("LEFT", vUIBottomActionBarsPanel, (SPACING + 1), 0)
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("LEFT", vUISideActionBarsPanel, (SPACING + 1), 0)
	
	vUIBottomActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 14)), ((BUTTON_SIZE * 3) + (SPACING * 5)))
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 2) + (SPACING * 4)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	
	for i = 1, Num do
		Bar[i]:ClearAllPoints()
		
		if (i == 1) then
			Bar[i]:SetScaledPoint("LEFT", Bar, 0, 0)
		else
			Bar[i]:SetScaledPoint("LEFT", Bar[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set4x1Style = function()
	
end

local SetActionBarLayout = function(value)
	if (value == "2x3") then
		Set2x3Style()
	elseif (value == "3x2") then
		Set3x2Style()
	elseif (value == "DEFAULT") then
		SetClassicStyle()
	end
end

local SetButtonSize = function(value)
	for i = 1, Num do
		vUIActionBar1[i]:SetScaledSize(value)
		vUIActionBar2[i]:SetScaledSize(value)
		vUIActionBar3[i]:SetScaledSize(value)
		vUIActionBar4[i]:SetScaledSize(value)
		vUIActionBar5[i]:SetScaledSize(value)
	end
	
	vUIActionBar1:SetScaledSize(((value * 12) + (SPACING * 11)), value)
	vUIActionBar2:SetScaledSize(((value * 12) + (SPACING * 11)), value)
	vUIActionBar3:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
	vUIActionBar4:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
	
	if (Settings["action-bars-layout"] == "2x3") then
		vUIActionBar5:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
		
		vUIBottomActionBarsPanel:SetScaledSize(((value * 12) + (SPACING * 14)), ((value * 2) + (SPACING * 4)))
		vUISideActionBarsPanel:SetScaledSize(((value * 3) + (SPACING * 5)), ((value * 12) + (SPACING * 14)))
	elseif (Settings["action-bars-layout"] == "3x2") then
		vUIActionBar5:SetScaledSize(((value * 12) + (SPACING * 11)), value)
		
		vUIBottomActionBarsPanel:SetScaledSize(((value * 12) + (SPACING * 14)), ((value * 3) + (SPACING * 5)))
		vUISideActionBarsPanel:SetScaledSize(((value * 2) + (SPACING * 4)), ((value * 12) + (SPACING * 14)))
	elseif (Settings["action-bars-layout"] == "DEFAULT") then
		vUIActionBar5:SetScaledSize((value * 6) + (SPACING * 5), (value * 2) + SPACING)
		
		vUISideActionBarsPanel:SetScaledSize(((value * 2) + (SPACING * 4)), ((value * 12) + (SPACING * 14)))
		vUIBottomActionBarsPanel:SetScaledSize((((value * 12) + (SPACING * 14))) * 1.5 - SPACING, ((value * 2) + (SPACING * 4)))
	end
end

local SetStanceSize = function(value)
	for i = 1, NUM_STANCE_SLOTS do
		StanceBarFrame.StanceButtons[i]:SetScaledSize(value, value)
	end
	
	local NumForms = GetNumShapeshiftForms()
	
	ActionBars.StanceBar:SetScaledWidth((value * NumForms) + (SPACING * (NumForms + 2)))
	ActionBars.StanceBar:SetScaledHeight(((value * 1) + (SPACING * 3)))
end

local SetHighlightTexture = function(value)
	local Texture = Media:GetTexture(value)
	
	for i = 1, Num do
		vUIActionBar1[i].Hover:SetTexture(Texture)
		vUIActionBar1[i].Pushed:SetTexture(Texture)
		vUIActionBar1[i].Checked:SetTexture(Texture)
		vUIActionBar1[i].Range:SetTexture(Texture)
		
		vUIActionBar2[i].Hover:SetTexture(Texture)
		vUIActionBar2[i].Pushed:SetTexture(Texture)
		vUIActionBar2[i].Checked:SetTexture(Texture)
		vUIActionBar2[i].Range:SetTexture(Texture)
		
		vUIActionBar3[i].Hover:SetTexture(Texture)
		vUIActionBar3[i].Pushed:SetTexture(Texture)
		vUIActionBar3[i].Checked:SetTexture(Texture)
		vUIActionBar3[i].Range:SetTexture(Texture)
		
		vUIActionBar4[i].Hover:SetTexture(Texture)
		vUIActionBar4[i].Pushed:SetTexture(Texture)
		vUIActionBar4[i].Checked:SetTexture(Texture)
		vUIActionBar4[i].Range:SetTexture(Texture)
		
		vUIActionBar5[i].Hover:SetTexture(Texture)
		vUIActionBar5[i].Pushed:SetTexture(Texture)
		vUIActionBar5[i].Checked:SetTexture(Texture)
		vUIActionBar5[i].Range:SetTexture(Texture)
	end
end

local UpdateButtonStatus = function(self)
	local IsUsable, NoMana = IsUsableAction(self.action)
	
	if IsUsable then
		local InRange = IsActionInRange(self.action)
		
		if (InRange == false) then
			self.icon:SetVertexColorHex("FF4C19")
		else
			self.icon:SetVertexColorHex("FFFFFF")
		end
	elseif NoMana then
		self.icon:SetVertexColorHex("3498D8")
	else
		self.icon:SetVertexColorHex("4C4C4C")
	end
end

local StanceBarUpdateState = function()
	local NumForms = GetNumShapeshiftForms()
	
	ActionBars.StanceBar:SetScaledWidth((STANCE_SIZE * NumForms) + (SPACING * NumForms))
end

ActionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBars:SetScript("OnEvent", function(self, event)
	if (not Settings["action-bars-enable"]) then
		return
	end
	
	BUTTON_SIZE = Settings["action-bars-button-size"]
	STANCE_SIZE = Settings["action-bars-stance-size"]
	
	CreateBarPanels()
	CreateBar1()
	CreateBar2()
	CreateBar3()
	CreateBar4()
	CreateBar5()
	CreatePetBar()
	CreateStanceBar()
	
	SetActionBarToggles(1, 1, 1, 1)
	
	SetActionBarLayout(Settings["action-bars-layout"])
	
	hooksecurefunc("ActionButton_OnUpdate", UpdateButtonStatus)
	hooksecurefunc("ActionButton_Update", UpdateButtonStatus)
	hooksecurefunc("ActionButton_UpdateUsable", UpdateButtonStatus)
	hooksecurefunc("StanceBar_UpdateState", StanceBarUpdateState)
	
	self:UnregisterEvent(event)
end)

local UpdateShowBottom = function(value)
	if value then
		vUIBottomActionBarsPanel:SetAlpha(1)
	else
		vUIBottomActionBarsPanel:SetAlpha(0)
	end
end

local UpdateShowSide = function(value)
	if value then
		vUISideActionBarsPanel:SetAlpha(1)
	else
		vUISideActionBarsPanel:SetAlpha(0)
	end
end

local UpdateShowHotKey = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].HotKey:Show()
			vUIActionBar2[i].HotKey:Show()
			vUIActionBar3[i].HotKey:Show()
			vUIActionBar4[i].HotKey:Show()
			vUIActionBar5[i].HotKey:Show()
		end
	else
		for i = 1, Num do
			vUIActionBar1[i].HotKey:Hide()
			vUIActionBar2[i].HotKey:Hide()
			vUIActionBar3[i].HotKey:Hide()
			vUIActionBar4[i].HotKey:Hide()
			vUIActionBar5[i].HotKey:Hide()
		end
	end
end

local UpdateShowMacroName = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].Name:Show()
			vUIActionBar2[i].Name:Show()
			vUIActionBar3[i].Name:Show()
			vUIActionBar4[i].Name:Show()
			vUIActionBar5[i].Name:Show()
		end
	else
		for i = 1, Num do
			vUIActionBar1[i].Name:Hide()
			vUIActionBar2[i].Name:Hide()
			vUIActionBar3[i].Name:Hide()
			vUIActionBar4[i].Name:Hide()
			vUIActionBar5[i].Name:Hide()
		end
	end
end

local UpdateShowCount = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].Count:Show()
			vUIActionBar2[i].Count:Show()
			vUIActionBar3[i].Count:Show()
			vUIActionBar4[i].Count:Show()
			vUIActionBar5[i].Count:Show()
		end
	else
		for i = 1, Num do
			vUIActionBar1[i].Count:Hide()
			vUIActionBar2[i].Count:Hide()
			vUIActionBar3[i].Count:Hide()
			vUIActionBar4[i].Count:Hide()
			vUIActionBar5[i].Count:Hide()
		end
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Action Bars"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateCheckbox("action-bars-enable", Settings["action-bars-enable"], "Enable Action Bars Module"):RequiresReload(true)
	
	Left:CreateHeader(Language["Backdrops"])
	Left:CreateCheckbox("action-bars-show-bottom-bg", Settings["action-bars-show-bottom-bg"], "Show Bottom Backdrop", "", UpdateShowBottom)
	Left:CreateCheckbox("action-bars-show-side-bg", Settings["action-bars-show-side-bg"], "Show Side Backdrop", "", UpdateShowSide)
	
	Right:CreateHeader(Language["Sizing"])
	Right:CreateSlider("action-bars-button-size", Settings["action-bars-button-size"], 24, 40, 1, "Button Size", "", SetButtonSize)
	Right:CreateSlider("action-bars-stance-size", Settings["action-bars-stance-size"], 24, 40, 1, "Stance Button Size", "", SetStanceSize)
	
	Right:CreateHeader(Language["Styling"])
	Right:CreateCheckbox("action-bars-show-hotkeys", Settings["action-bars-show-hotkeys"], "Show Hotkeys", "", UpdateShowHotKey)
	Right:CreateCheckbox("action-bars-show-macro-names", Settings["action-bars-show-macro-names"], "Show Macro Names", "", UpdateShowMacroName)
	Right:CreateCheckbox("action-bars-show-count", Settings["action-bars-show-count"], "Show Count Text", "", UpdateShowCount)
	
	Left:CreateHeader(Language["Layouts"])
	Left:CreateDropdown("action-bars-layout", Settings["action-bars-layout"], {["2 x 3"] = "2x3", ["3 x 2"] = "3x2", [Language["Default"]] = "DEFAULT"}, "Bar Layout", "", SetActionBarLayout)
	
	Left:CreateHeader(Language["Highlights"])
	Left:CreateDropdown("action-bars-button-highlight", Settings["action-bars-button-highlight"], Media:GetTextureList(), Language["Highlight Texture"], "", SetHighlightTexture, "Texture")
	
	Left:CreateFooter()
	Right:CreateFooter()
end)