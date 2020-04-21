local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

-- QUESTS_LABEL = "Quests"
-- QUEST_OBJECTIVES = "Quest Objectives"
-- TRACKER_HEADER_QUESTS = "Quests"

local Quest = vUI:NewModule("Quest")

function Quest:StyleFrame()
	local Mover = CreateFrame("Frame", "vUI Quest Watch", UIParent)
	Mover:SetScaledSize(156, 40)
	Mover:SetScaledPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -400)
	
	--[[local Title = QuestWatchFrame:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(Title, "BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, 0)
	vUI:SetFontInfo(Title, Settings["ui-header-font"], 12)
	Title:SetJustifyH("LEFT")
	Title:SetTextColor(vUI:HexToRGB(Settings["ui-header-font-color"]))
	Title:SetText(Language["Quests"])
	
	local TitleDiv = CreateFrame("Frame", nil, QuestWatchFrame)
	vUI:SetSize(TitleDiv, 156, 4)
	vUI:SetPoint(TitleDiv, "BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, -6)
	TitleDiv:SetBackdrop(vUI.BackdropAndBorder)
	TitleDiv:SetBackdropColorHex(Settings["ui-button-texture-color"])
	TitleDiv:SetBackdropBorderColor(0, 0, 0)
	
	TitleDiv.Texture = TitleDiv:CreateTexture(nil, "OVERLAY")
	vUI:SetPoint(TitleDiv.Texture, "TOPLEFT", TitleDiv, 1, -1)
	vUI:SetPoint(TitleDiv.Texture, "BOTTOMRIGHT", TitleDiv, -1, 1)
	TitleDiv.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TitleDiv.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))]]
	
	QuestWatchFrame:ClearAllPoints()
	vUI:SetPoint(QuestWatchFrame, "TOPLEFT", Mover, "TOPLEFT", 0, 0)
	
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
	vUI:SetPoint(QuestTimerFrame, "TOPLEFT", Mover, "TOPLEFT", 0, 60)
	vUI:SetPoint(QuestTimerFrame, "TOPRIGHT", Mover, "TOPRIGHT", 0, 60)
	vUI:SetHeight(QuestTimerFrame, 30)
	
	QuestTimerFrame.ClearAllPoints = function() end
	QuestTimerFrame.SetPoint = function() end
	
	vUI:CreateMover(Mover)
end

function Quest:Load()
	self:StyleFrame()
end