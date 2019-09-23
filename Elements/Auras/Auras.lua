local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Auras = vUI:NewModule("Auras")

local Name, Texture, Count, DebuffType
local UnitAura = UnitAura
local unpack = unpack

BUFF_MIN_ALPHA = 0.4

local AuraSize = 30
local AuraSpacing = 2
local AuraHorizSpacing = 16

local SkinAura = function(button, name, index)
	button:SetBackdrop(vUI.BackdropAndBorder)
	button:SetBackdropColorHex("00000000")
	button:SetBackdropBorderColorHex("000000")
	
	button.duration:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	button.duration:ClearAllPoints()
	button.duration:SetScaledPoint("TOP", button, "BOTTOM", 0, -4)
	button.count:SetFontInfo(Settings["ui-font"], Settings["ui-font-size"], Settings["ui-font-flags"])
	
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
			
			if (Index > 1 and (Index % BUFFS_PER_ROW == 1)) then
				Aura:SetScaledPoint("TOP", RowAnchor, "BOTTOM", 0, -AuraHorizSpacing)
				
				RowAnchor = Aura
				NumRows = 1
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
	local Rows = ceil(NumAuras / BUFFS_PEW_ROW)
	local Aura = _G[name .. index]
	
	if ((index > 1) and (index % BUFFS_PER_ROW == 1)) then
		Aura:SetScaledPoint("TOP", _G[name .. (index - BUFFS_PER_ROW)], "BOTTOM", 0, -AuraHorizSpacing)
	elseif (index == 1) then
		if (Rows < 2) then
			DebuffButton1.offsetY = 1 * ((2 * AuraSpacing) + AuraSize)
		else
			DebuffButton1.offsetY = Rows * (AuraSpacing + AuraSize)
		end
		
		Aura:SetPoint("TOPRIGHT", Auras.Debuffs, "BOTTOMRIGHT", 0, -DebuffButton1.offsetY)
	else
		Aura:SetScaledPoint("RIGHT", _G[name..(index - 1)], "LEFT", -5, 0)
	end
end

Auras.AuraButton_Update = function(name, index)
	local Button = _G[name .. index]
	
	if (not Button) then
		return
	end
	
	if (not Button.Handled) then
		SkinAura(Button, name, index)
	end
	
	Name, Texture, Count, DebuffType = UnitAura("player", index, name == "BuffButton" and "HELPFUL" or "HARMFUL")
	
	if (Name and DebuffType) then
		Button:SetBackdropBorderColor(unpack(vUI.DebuffColors[DebuffType]))
	end
end

function Auras:Load()
	if (not Settings["auras-enable"]) then
		return
	end
	
	self:Hook("AuraButton_Update")
	self:Hook("BuffFrame_UpdateAllBuffAnchors")
	
	self.Buffs = CreateFrame("Frame", "vUI Buffs", UIParent)
	self.Buffs:SetScaledSize((BUFFS_PER_ROW * AuraSize + BUFFS_PER_ROW * AuraSpacing), ((AuraSize * 4) + (AuraHorizSpacing * 3)))
	self.Buffs:SetScaledPoint("TOPRIGHT", UIParent, "TOPRIGHT", -(Settings["minimap-size"] + 22), -12)
	
	self.Debuffs = CreateFrame("Frame", "vUI Debuffs", UIParent)
	self.Debuffs:SetScaledSize((BUFFS_PER_ROW * AuraSize + BUFFS_PER_ROW * AuraSpacing), ((AuraSize * 2) + AuraHorizSpacing))
	self.Debuffs:SetScaledPoint("TOPRIGHT", self.Buffs, "BOTTOMRIGHT", 0, -2)
	
	vUI:GetModule("Move"):Add(self.Buffs)
	vUI:GetModule("Move"):Add(self.Debuffs)
	
	BuffFrame_Update()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Auras"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], "Enable the vUI auras module", ReloadUI):RequiresReload(true)
	
	--Right:CreateHeader(Language["Size"])
	--Right:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, "Minimap Size", "Set the size of the Minimap", UpdateMinimapSize)
	
	Left:CreateFooter()
	Right:CreateFooter()
end)