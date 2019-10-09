local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local Slots = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18}
local GetInventoryItemDurability = GetInventoryItemDurability
local floor = math.floor

local Update = function(self)
	local Total, Count = 0, 0
	local Current, Max
	
	for i = 1, #Slots do
		Current, Max = GetInventoryItemDurability(Slots[i])
		
		if Current then
			Total = Total + (Current / Max)
			Count = Count + 1
		end
	end
	
	self.Text:SetFormattedText("%s: %s%%", Language["Durability"], floor(Total / Count * 100))
end

local OnEnable = function(self)
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("MERCHANT_SHOW")
	self:SetScript("OnEvent", Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_SHOW")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Durability", OnEnable, OnDisable, Update)