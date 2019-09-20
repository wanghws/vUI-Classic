local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

-- QUESTS_LABEL = "Quests"
-- QUEST_OBJECTIVES = "Quest Objectives"
-- TRACKER_HEADER_QUESTS = "Quests"

local Move = vUI:GetModule("Move")
local Quest = vUI:NewModule("Quest")


function Quest:StyleFrame()
	for i = 1, 30 do
		_G["QuestWatchLine" .. i]:SetFontInfo(Settings["ui-header-font"], 12)
	end
	
	local Mover = CreateFrame("Frame", "vUI Quest Watch", UIParent)
	Mover:SetScaledSize(156, 40)
	Mover:SetScaledPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -400)
	
	--[[local Title = QuestWatchFrame:CreateFontString(nil, "OVERLAY")
	Title:SetScaledPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, 0)
	Title:SetFontInfo(Settings["ui-header-font"], 12)
	Title:SetJustifyH("LEFT")
	Title:SetTextColorHex(Settings["ui-header-font-color"])
	Title:SetText(Language["Quests"])
	
	local TitleDiv = CreateFrame("Frame", nil, QuestWatchFrame)
	TitleDiv:SetScaledSize(156, 4)
	TitleDiv:SetScaledPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, -6)
	TitleDiv:SetBackdrop(vUI.BackdropAndBorder)
	TitleDiv:SetBackdropColorHex(Settings["ui-button-texture-color"])
	TitleDiv:SetBackdropBorderColor(0, 0, 0)
	
	TitleDiv.Texture = TitleDiv:CreateTexture(nil, "OVERLAY")
	TitleDiv.Texture:SetScaledPoint("TOPLEFT", TitleDiv, 1, -1)
	TitleDiv.Texture:SetScaledPoint("BOTTOMRIGHT", TitleDiv, -1, 1)
	TitleDiv.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	TitleDiv.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])]]
	
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetScaledPoint("TOPLEFT", Mover, "TOPLEFT", 0, 0)
	
	local Region
	local Child
	
	for i = 1, QuestTimerFrame:GetNumRegions() do
		Region = select(i, QuestTimerFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:SetTexture(nil)
		elseif (Region:GetObjectType() == "FontString") then
			Region:SetFontInfo(Settings["ui-header-font"], 12)
		end
	end
	
	for i = 1, QuestTimerFrame:GetNumChildren() do -- QuestTimer1-20
		Child = select(i, QuestTimerFrame:GetChildren())
		
		for i = 1, Child:GetNumRegions() do
			Region = select(i, Child:GetRegions())
			
			if (Region:GetObjectType() == "FontString") then
				Region:SetFontInfo(Settings["ui-header-font"], 12)
			end
		end
	end
	
	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetScaledPoint("TOPLEFT", Mover, "TOPLEFT", 0, 60)
	QuestTimerFrame:SetScaledPoint("TOPRIGHT", Mover, "TOPRIGHT", 0, 60)
	QuestTimerFrame:SetScaledHeight(30)
	
	QuestTimerFrame.ClearAllPoints = function() end
	QuestTimerFrame.SetPoint = function() end
	
	Move:Add(Mover)
end

Quest:RegisterEvent("PLAYER_ENTERING_WORLD")
Quest:SetScript("OnEvent", function(self, event)
	self:StyleFrame()
	
	self:UnregisterEvent(event)
end)