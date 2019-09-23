local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Auras = vUI:NewModule("Auras")

local Name, Texture, Count, DebuffType
local UnitAura = UnitAura
local unpack = unpack

BUFF_MIN_ALPHA = 0.4

local SkinAura = function(button, name, index)
	button:SetBackdrop(vUI.BackdropAndBorder)
	button:SetBackdropColorHex("00000000")
	button:SetBackdropBorderColorHex("000000")
	
	button.duration:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	button.duration:ClearAllPoints()
	button.duration:SetScaledPoint("TOP", button, "BOTTOM", 0, -4)
	button.duration.SetFontObject = function() end
	
	button.count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	button.count.SetFontObject = function() end
	
	local Icon = _G[name .. index .. "Icon"]
	local Border = _G[name .. index .. "Border"]
	
	if Icon then
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if Border then
		Border:SetTexture(nil)
	end
	
	button.Handled = true
end

Auras.BuffFrame_UpdateAllBuffAnchors = function()
	if BuffFrame then
		local Aura
		local PreviousAura
		local NumEnchants = BuffFrame.numEnchants
		local NumAuras = 0
		local NumRows = 0
		local RowAnchor
		local Index
		
		for i = 1, BUFF_ACTUAL_DISPLAY do
			Aura = _G["BuffButton" .. i]
			
			NumAuras = NumAuras + 1
			Index = NumAuras + NumEnchants
			
			Aura:ClearAllPoints()
			
			if (Index > 1 and (Index % Settings["auras-per-row"] == 1)) then
				Aura:SetScaledPoint("TOP", RowAnchor, "BOTTOM", 0, -Settings["auras-row-spacing"])
				
				RowAnchor = Aura
				NumRows = NumRows + 1
			elseif (Index == 1) then
				Aura:SetScaledPoint("TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
				
				RowAnchor = Aura
				NumRows = 1
			else
				if (NumAuras == 1) then
					if (NumEnchants > 0) then
						Aura:SetScaledPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPLEFT", -2, 0)
					else
						Aura:SetScaledPoint("TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
					end
				else
					Aura:SetScaledPoint("RIGHT", PreviousAura, "LEFT", -2, 0)
				end
			end
			
			PreviousAura = Aura
		end
	end
end

Auras.DebuffButton_UpdateAnchors = function(name, index)
	local NumAuras = BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants
	local Rows = ceil(NumAuras / BUFFS_PER_ROW)
	local Aura = _G[name .. index]
	
	Aura:ClearAllPoints()
	
	if ((index > 1) and (index % Settings["auras-per-row"] == 1)) then
		Aura:SetScaledPoint("TOP", _G[name .. (index - Settings["auras-per-row"])], "BOTTOM", 0, -Settings["auras-row-spacing"])
	elseif (index == 1) then
		if (Rows < 2) then
			Aura.offsetY = 1 * ((2 * Settings["auras-spacing"]) + Settings["auras-size"]) -- Make the default UI happy
		else
			Aura.offsetY = Rows * (Settings["auras-spacing"] + Settings["auras-size"])
		end
		
		Aura:SetScaledPoint("TOPRIGHT", Auras.Debuffs, "TOPRIGHT", 0, 0)
	else
		Aura:SetScaledPoint("RIGHT", _G[name..(index - 1)], "LEFT", -5, 0)
	end
end

Auras.AuraButton_Update = function(name, index)
	local Button = _G[name .. index]
	local Filter = name == "BuffButton" and "HELPFUL" or "HARMFUL"
	
	if (not Button) then
		return
	end
	
	if (not Button.Handled) then
		SkinAura(Button, name, index)
	end
	
	Button:SetScaledSize(Settings["auras-size"])
	
	Name, Texture, Count, DebuffType = UnitAura("player", index, Filter)
	
	if (Name and DebuffType and Filter == "HARMFUL") then
		Button:SetBackdropBorderColor(unpack(vUI.DebuffColors[DebuffType]))
	else
		Button:SetBackdropBorderColor(0, 0, 0)
	end
end

function Auras:Load()
	if (not Settings["auras-enable"]) then
		return
	end
	
	self:Hook("AuraButton_Update")
	self:Hook("BuffFrame_UpdateAllBuffAnchors")
	self:Hook("DebuffButton_UpdateAnchors")
	
	local BuffRows = ceil(BUFF_MAX_DISPLAY / Settings["auras-per-row"])
	local DebuffRows = ceil(DEBUFF_MAX_DISPLAY / Settings["auras-per-row"])
	
	self.Buffs = CreateFrame("Frame", "vUI Buffs", UIParent)
	self.Buffs:SetScaledSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * BuffRows) + (Settings["auras-row-spacing"] * (BuffRows - 1))))
	self.Buffs:SetScaledPoint("TOPRIGHT", UIParent, "TOPRIGHT", -(Settings["minimap-size"] + 22), -12)
	
	self.Debuffs = CreateFrame("Frame", "vUI Debuffs", UIParent)
	self.Debuffs:SetScaledSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * DebuffRows) + Settings["auras-row-spacing"]))
	self.Debuffs:SetScaledPoint("TOPRIGHT", self.Buffs, "BOTTOMRIGHT", 0, -2)
	
	vUI:GetModule("Move"):Add(self.Buffs)
	vUI:GetModule("Move"):Add(self.Debuffs)
	
	BuffFrame_Update()
end

local UpdateSizes = function()
	-- Resize movers
	
	BuffFrame_Update()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Auras"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], "Enable the vUI auras module", ReloadUI):RequiresReload(true)
	Right:CreateHeader(Language["Styling"])
	Right:CreateSlider("auras-size", Settings["auras-size"], 20, 40, 1, "Size", "Set the size of auras", UpdateSizes)
	Right:CreateSlider("auras-spacing", Settings["auras-spacing"], 0, 10, 1, "Spacing", "Set the spacing between auras", UpdateSizes)
	Right:CreateSlider("auras-row-spacing", Settings["auras-row-spacing"], 0, 30, 1, "Row Spacing", "Set the vertical spacing between aura rows", UpdateSizes)
	Right:CreateSlider("auras-per-row", Settings["auras-per-row"], 8, 16, 1, "Display Per Row", "Set the number of auras per row", UpdateSizes)
	
	Left:CreateFooter()
	Right:CreateFooter()
end)