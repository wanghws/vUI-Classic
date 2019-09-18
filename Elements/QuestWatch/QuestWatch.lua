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
	
	local Header = QuestWatchFrame:CreateFontString(nil, "OVERLAY")
	Header:SetScaledPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, 0)
	Header:SetFontInfo(Settings["ui-header-font"], 12)
	Header:SetJustifyH("LEFT")
	Header:SetText(format("|cFF%s%s|r", Settings["ui-header-font-color"], TRACKER_HEADER_QUESTS))
	
	local HeaderDiv = CreateFrame("Frame", nil, Anchor)
	HeaderDiv:SetScaledSize(156, 4)
	HeaderDiv:SetScaledPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, -6)
	HeaderDiv:SetBackdrop(vUI.BackdropAndBorder)
	HeaderDiv:SetBackdropColorHex(Settings["ui-button-texture-color"])
	HeaderDiv:SetBackdropBorderColor(0, 0, 0)
	
	HeaderDiv.Texture = HeaderDiv:CreateTexture(nil, "OVERLAY")
	HeaderDiv.Texture:SetScaledPoint("TOPLEFT", HeaderDiv, 1, -1)
	HeaderDiv.Texture:SetScaledPoint("BOTTOMRIGHT", HeaderDiv, -1, 1)
	HeaderDiv.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	HeaderDiv.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	QuestWatchFrame:SetParent(Mover)
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetScaledPoint("TOPLEFT", Mover, "TOPLEFT", 0, 0)
	
	Move:Add(Mover)
end

Quest:RegisterEvent("PLAYER_ENTERING_WORLD")
Quest:SetScript("OnEvent", function(self, event)
	self:StyleFrame()
	
	self:UnregisterEvent(event)
end)