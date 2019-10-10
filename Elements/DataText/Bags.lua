local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots

local Update = function(self)
	local TotalSlots = 0
	local FreeSlots = 0
	
	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetContainerNumSlots(i)
		
		if NumSlots then
			FreeSlots = FreeSlots + GetContainerNumFreeSlots(i)
			TotalSlots = TotalSlots + NumSlots
		end
	end
	
	self.Text:SetFormattedText("%s: %s/%s", Language["Bags"], FreeSlots, TotalSlots)
end

local OnEnable = function(self)
	self:RegisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Bags", OnEnable, OnDisable, Update)