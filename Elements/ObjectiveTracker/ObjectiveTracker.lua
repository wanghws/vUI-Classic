local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Tracker = CreateFrame("Frame")
Tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
Tracker:SetScript("OnEvent", function(self, event)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetScaledPoint("RIGHT", UIParent, -300, 0)
	
	self:UnregisterEvent(event)
end)