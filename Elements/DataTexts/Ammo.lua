local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount
local Label = Language["Ammo"]

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	if GetInventoryItemID("player", 0) then
		GameTooltip:SetInventoryItem("player", 0)
	elseif GetInventoryItemID("player", 18) then
		GameTooltip:SetInventoryItem("player", 18)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local Count = 0
	
	if (GetInventoryItemID("player", 0) > 0) then -- Ammo slot
		Count = GetInventoryItemCount("player", 0)
	elseif GetInventoryItemID("player", 18) then -- Thrown weapons
		Count = GetInventoryItemCount("player", 18)
	end
	
	self.Text:SetFormattedText("%s: %s", Label, Count)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DT:SetType("Ammo", OnEnable, OnDisable, Update)