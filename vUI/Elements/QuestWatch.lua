local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

-- QUESTS_LABEL = "Quests"
-- QUEST_OBJECTIVES = "Quest Objectives"
-- TRACKER_HEADER_QUESTS = "Quests"

local Quest = vUI:NewModule("Quest Watch")

function Quest:StyleFrame()
	self:SetSize(156, 40)
	self:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -400)
	
	local Title = QuestWatchFrame:CreateFontString(nil, "OVERLAY")
	Title:SetPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, 0)
	vUI:SetFontInfo(Title, Settings["ui-header-font"], 12)
	Title:SetJustifyH("LEFT")
	Title:SetText(QUESTS_LABEL)
	
	local TitleDiv = CreateFrame("Frame", nil, QuestWatchFrame)
	TitleDiv:SetSize(156, 4)
	TitleDiv:SetPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, -6)
	TitleDiv:SetBackdrop(vUI.BackdropAndBorder)
	TitleDiv:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	TitleDiv:SetBackdropBorderColor(0, 0, 0)
	
	TitleDiv.Texture = TitleDiv:CreateTexture(nil, "OVERLAY")
	TitleDiv.Texture:SetPoint("TOPLEFT", TitleDiv, 1, -1)
	TitleDiv.Texture:SetPoint("BOTTOMRIGHT", TitleDiv, -1, 1)
	TitleDiv.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TitleDiv.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	QuestWatchFrame:Show()
	
	local Region
	local Child
	
	for i = 1, QuestTimerFrame:GetNumRegions() do
		Region = select(i, QuestTimerFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:SetTexture(nil)
		elseif (Region:GetObjectType() == "FontString") then
			vUI:SetFontInfo(Region, Settings["ui-header-font"], 12)
		end
	end
	
	for i = 1, 30 do
		vUI:SetFontInfo(_G["QuestWatchLine" .. i], Settings["ui-header-font"], 12)
	end
	
	for i = 1, 20 do
		vUI:SetFontInfo(_G["QuestTimer" .. i .. "Text"], Settings["ui-header-font"], 12)
	end
	
	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 60)
	QuestTimerFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 60)
	QuestTimerFrame:SetHeight(30)
	
	QuestTimerFrame.ClearAllPoints = function() end
	QuestTimerFrame.SetPoint = function() end
	
	vUI:CreateMover(self)
end

function Quest:Load()
	self:StyleFrame()
end