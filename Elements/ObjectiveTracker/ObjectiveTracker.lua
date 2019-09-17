local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Move = vUI:GetModule("Move")

local QuestTracker = CreateFrame("Frame")
QuestTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
QuestTracker:SetScript("OnEvent", function(self, event)
	--[[local Mover = Move:Add(QuestWatchFrame)
	
	Mover:ClearAllPoints()
	Mover:SetScaledPoint("RIGHT", UIPArent, -300, 0)
	
	QuestWatchFrame:SetParent(Mover)
	QuestWatchFrame:Show()
	QuestWatchFrame:SetAlpha(1)
	--QuestWatchFrame:ClearAllPoints()
	--QuestWatchFrame:SetScaledPoint("TOPRIGHT", Mover, 0, 0)
	--QuestWatchFrame.ClearAllPoints = function() end
	
	self:UnregisterEvent(event)]]
end)