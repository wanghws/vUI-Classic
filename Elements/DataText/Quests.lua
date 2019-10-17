local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local Label = Language["Quests"]

local Update = function(self, event)
	--self.Text:SetFormattedText("%s: %s")
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

--DT:SetType("Quests", OnEnable, OnDisable, Update)