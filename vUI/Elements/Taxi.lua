local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Taxi = vUI:NewModule("Taxi")

local TaxiOnEvent = function(self)
    if UnitOnTaxi("player") then
        self:Show()
    else
		self:Hide()
    end
end

local RequestLanding = function(self)
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
		self:Hide()
    end
end

local OnEnter = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-widget-font-color"])
	
	GameTooltip:SetOwner(Taxi.Frame, "ANCHOR_PRESERVE")
	GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, R, G, B)
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

Taxi:RegisterEvent("PLAYER_ENTERING_WORLD")
Taxi:SetScript("OnEvent", function(self, event)
	local TaxiFrame = CreateFrame("Frame", "vUI Taxi", UIParent)
	TaxiFrame:SetSize(Settings["minimap-size"] + 8, 22)
	TaxiFrame:SetPoint("TOP", _G["vUI Minimap"], "BOTTOM", 0, -2)
	TaxiFrame:SetBackdrop(vUI.BackdropAndBorder)
	TaxiFrame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	TaxiFrame:SetBackdropBorderColor(0, 0, 0)
	TaxiFrame:SetFrameStrata("HIGH")
	TaxiFrame:SetFrameLevel(10)
	TaxiFrame:SetScript("OnMouseUp", RequestLanding)
	TaxiFrame:SetScript("OnEnter", OnEnter)
	TaxiFrame:SetScript("OnLeave", OnLeave)
	TaxiFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	TaxiFrame:SetScript("OnEvent", TaxiOnEvent)
	
    if UnitOnTaxi("player") then
        TaxiFrame:Show()
    else
		TaxiFrame:Hide()
    end
	
	TaxiFrame.Texture = TaxiFrame:CreateTexture(nil, "ARTWORK")
	TaxiFrame.Texture:SetPoint("TOPLEFT", TaxiFrame, 1, -1)
	TaxiFrame.Texture:SetPoint("BOTTOMRIGHT", TaxiFrame, -1, 1)
	TaxiFrame.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TaxiFrame.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	TaxiFrame.Text = TaxiFrame:CreateFontString(nil, "OVERLAY", 7)
	TaxiFrame.Text:SetPoint("CENTER", TaxiFrame, 0, -1)
	vUI:SetFontInfo(TaxiFrame.Text, Settings["ui-header-font"], Settings["ui-font-size"])
	TaxiFrame.Text:SetSize(TaxiFrame:GetWidth() - 12, 20)
	TaxiFrame.Text:SetText(Language["Land Early"])
	
	self.Frame = TaxiFrame
end)