local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local temp = {
	--["Hydrazine:Whitemane"] = 1,
}

if (not temp[vUI.UserProfileKey]) then
	return
end

local ContainerFrame_GetContainerNumSlots = ContainerFrame_GetContainerNumSlots

local Bags = vUI:NewModule("Bags")

Bags.Slots = {}

local SkinButton = function(self)
	local Name = self:GetName()
	local Normal = _G[Name .. "NormalTexture"]
	local Count = _G[Name .. "Count"]
	local Stock = _G[Name .. "Stock"]
	
	if Normal then
		Normal:SetTexture(nil)
	end
	
	if Count then
		Count:ClearAllPoints()
		Count:SetScaledPoint("BOTTOMRIGHT", 0, 2)
		Count:SetJustifyH("RIGHT")
		Count:SetFontInfo(Settings["ui-widget-font"], 12)
	end
	
	if Stock then
		Stock:ClearAllPoints()
		Stock:SetScaledPoint("TOPLEFT", 0, -2)
		Stock:SetJustifyH("LEFT")
		Stock:SetFontInfo(Settings["ui-widget-font"], 12)
	end
	
	if self.icon then
		self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	self.BG = self:CreateTexture(nil, "BACKGROUND")
	self.BG:SetScaledPoint("TOPLEFT", self, -1, 1)
	self.BG:SetScaledPoint("BOTTOMRIGHT", self, 1, -1)
	self.BG:SetColorTexture(0, 0, 0)
	
	local Highlight = self:CreateTexture(nil, "ARTWORK")
	Highlight:SetScaledPoint("TOPLEFT", self, 0, 0)
	Highlight:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	Highlight:SetColorTexture(1, 1, 1)
	Highlight:SetAlpha(0.2)
	
	self:SetHighlightTexture(Highlight)
	
	local Pushed = self:CreateTexture(nil, "ARTWORK", 7)
	Pushed:SetScaledPoint("TOPLEFT", self, 0, 0)
	Pushed:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	Pushed:SetColorTexture(0.2, 0.9, 0.2)
	Pushed:SetAlpha(0.4)
	
	self:SetPushedTexture(Pushed)
	
	self.Handled = true
end

function Bags:CreateBagFrame()
	local RowCount = 0
	local RowStart
	local Slot
	local Size
	
	for i = 1, 5 do
		Size = ContainerFrame_GetContainerNumSlots(i -1)
		
		if (Size > 0) then
			for j = 1, Size do
				Slot = _G["ContainerFrame" .. i .. "Item" .. j]
				
				if Slot then
					tinsert(self.Slots, Slot)
				end
			end
		end
	end
	
	local Last
	
	for i = 1, #self.Slots do
		self.Slots[i]:ClearAllPoints()
		self.Slots[i]:SetParent(self.Frame)
		self.Slots[i]:SetSize(30, 30)
		self.Slots[i]:SetScale(UIParent:GetScale())
		
		if (not self.Slots[i].Handled) then
			SkinButton(self.Slots[i])
		end
		
		if (i == 1) then
			self.Slots[i]:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 3, 3)
			
			if (not RowStart) then
				RowStart = self.Slots[i]
			end
			
			Last = self.Slots[i]
			RowCount = RowCount + 1
		elseif (RowCount == 10) then
			self.Slots[i]:SetPoint("TOPRIGHT", RowStart, "TOPRIGHT", 0, -33)
			self.Slots[i]:SetPoint("BOTTOMLEFT", RowStart, "BOTTOMLEFT", 0, -33)
			
			RowStart = self.Slots[i]
			RowCount = 1
		else
			self.Slots[i]:SetPoint("BOTTOMLEFT", Last, "BOTTOMRIGHT", 3, 0)
			
			RowCount = RowCount + 1
		end
	end
end

--[[ToggleBackpack = function()
	if Bags.Frame:IsShown() then
		Bags.Frame:Hide()
	else
		Bags.Frame:Show()
	end
end

ToggleBag = function()
	if Bags.Frame:IsShown() then
		Bags.Frame:Hide()
	else
		Bags.Frame:Show()
	end
end

OpenBag = function()
	if (not Bags.Frame:IsShown()) then
		Bags.Frame:Show()
	end
end]]

function Bags:BAG_OPEN()
	if (not self.Frame:IsShown()) then
		self.Frame:Show()
	end
end

function Bags:BAG_CLOSED()
	if self.Frame:IsShown() then
		self.Frame:Hide()
	end
end

function Bags:PLAYER_ENTERING_WORLD(...)
	self:CreateBagFrame()
end

local OnEvent = function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Bags:Load()
	local Frame = CreateFrame("Frame", "vUI Bags", UIParent)
	Frame:SetScaledSize(390, 300)
	--Frame:SetScaledPoint("BOTTOMRIGHT", UIParent, -13, 13)
	Frame:SetScaledPoint("CENTER", UIParent, -13, 13)
	Frame:SetBackdrop(vUI.BackdropAndBorder)
	Frame:SetBackdropColorHex(Settings["ui-window-bg-color"])
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame:SetFrameStrata("LOW")
	Frame:SetAlpha(0.5)
	--Frame:Hide()
	
	self.Frame = Frame
	
	self:CreateBagFrame()
	
	--self:RegisterEvent("BAG_OPEN")
	--self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", OnEvent)
end