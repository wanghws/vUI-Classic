local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemCount = GetInventoryItemCount
local Label = Language["Ammo"]

local Update = function(self)
	local Count = 0
	
	if (GetInventoryItemID("player", 0) > 0) then -- Ammo slot
		Count = GetInventoryItemCount("player", 0)
	elseif (GetInventoryItemID("player", 18) > 0) then -- Thrown weapons
		Count = GetInventoryItemCount("player", 18)
	end
	
	self.Text:SetFormattedText("%s: %s", Label, Count)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:SetType("Ammo", OnEnable, OnDisable, Update)