if (1 == 1) then
	return
end

local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Bubbles = vUI:NewModule("Chat Bubbles")

local select = select
local GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

function Bubbles:SkinBubble(bubble)
	for i = 1, bubble:GetNumRegions() do
		local Region = select(i, bubble:GetRegions())
		
		if Region:IsObjectType("Texture") then
			Region:SetTexture()
		elseif Region:IsObjectType("FontString") then
			bubble.Text = Region
		end
	end
	
	bubble.Text:SetFontInfo(Settings["ui-font"], 14, Settings["ui-font-flags"])
	
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	bubble:SetBackdrop(vUI.BackdropAndBorder)
	bubble:SetBackdropColor(R, G, B, 0.7)
	bubble:SetBackdropBorderColor(0, 0, 0)
	
	local Scale = vUI:GetSuggestedScale()
	
	bubble:SetScale(Scale)
	
	bubble.Top = bubble:CreateTexture(nil, "OVERLAY")
	bubble.Top:SetScaledHeight(2)
	bubble.Top:SetTexture(Media:GetTexture("Blank"))
	bubble.Top:SetVertexColorHex(Settings["ui-window-bg-color"])
	bubble.Top:SetScaledPoint("TOPLEFT", bubble, 1, -1)
	bubble.Top:SetScaledPoint("TOPRIGHT", bubble, -1, -1)
	
	bubble.Bottom = bubble:CreateTexture(nil, "OVERLAY")
	bubble.Bottom:SetScaledHeight(2)
	bubble.Bottom:SetTexture(Media:GetTexture("Blank"))
	bubble.Bottom:SetVertexColorHex(Settings["ui-window-bg-color"])
	bubble.Bottom:SetScaledPoint("BOTTOMLEFT", bubble, 1, 1)
	bubble.Bottom:SetScaledPoint("BOTTOMRIGHT", bubble, -1, 1)
	
	bubble.Left = bubble:CreateTexture(nil, "OVERLAY")
	bubble.Left:SetScaledWidth(2)
	bubble.Left:SetTexture(Media:GetTexture("Blank"))
	bubble.Left:SetVertexColorHex(Settings["ui-window-bg-color"])
	bubble.Left:SetScaledPoint("BOTTOMLEFT", bubble, 1, 1)
	bubble.Left:SetScaledPoint("TOPLEFT", bubble, 1, -1)
	
	bubble.Right = bubble:CreateTexture(nil, "OVERLAY")
	bubble.Right:SetScaledWidth(2)
	bubble.Right:SetTexture(Media:GetTexture("Blank"))
	bubble.Right:SetVertexColorHex(Settings["ui-window-bg-color"])
	bubble.Right:SetScaledPoint("BOTTOMRIGHT", bubble, -1, 1)
	bubble.Right:SetScaledPoint("TOPRIGHT", bubble, -1, -1)
	
	bubble.InnerBorder = CreateFrame("Frame", nil, bubble)
	bubble.InnerBorder:SetScaledPoint("TOPLEFT", bubble, 3, -3)
	bubble.InnerBorder:SetScaledPoint("BOTTOMRIGHT", bubble, -3, 3)
	bubble.InnerBorder:SetBackdrop(vUI.Outline)
	bubble.InnerBorder:SetBackdropBorderColor(0, 0, 0)
	
	bubble.Skinned = true
end

function Bubbles:ScanForBubbles()
	local Bubble
	
	for Index, Bubble in pairs(GetAllChatBubbles()) do
		if (Bubble and not Bubble.Skinned) then
			self:SkinBubble(Bubble)
		end
	end
end

local OnUpdate = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.1) then
		self:ScanForBubbles()
		
		self.Elapsed = 0
	end
end

function Bubbles:Load()
	self.Elapsed = 0
	self:SetScript("OnUpdate", OnUpdate)
end