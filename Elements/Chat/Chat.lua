local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local select = select
local tostring = tostring
local format = string.format
local sub = string.sub
local gsub = string.gsub
local match = string.match

local FRAME_WIDTH = 392
local FRAME_HEIGHT = 104
local BAR_HEIGHT = 22

local TabButtons = {}
local TabNames = {"General", "Whispers", "Loot", "Trade"}
local TabIDs = {1, 3, 4, 5}
local ButtonWidth = (FRAME_WIDTH / 4) + 1

local SetHyperlink = ItemRefTooltip.SetHyperlink
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_UpdateHeader = ChatEdit_UpdateHeader

local Discord = "https://discord.gg/%s"

local FormatDiscordHyperlink = function(id) -- /run print("https://discord.gg/1a2b")
	local Link = format(Discord, id)
	
	return format("|cFF7289DA|Hdiscord:%s|h[%s: %s]|h|r", Link, Language["Discord"], id)
end

local FormatURLHyperlink = function(url) -- /run print("www.google.com")
	return format("|cFF%s|Hurl:%s|h[%s]|h|r", Settings["ui-widget-color"], url, url)
end

local FormatEmailHyperlink = function(address) -- /run print("user@gmail.com")
	return format("|cFF%s|Hemail:%s|h[%s]|h|r", Settings["ui-widget-color"], address, address)
end

-- This can be b.net or discord, so just calling it a "friend tag" for now.
local FormatFriendHyperlink = function(tag) -- /run print("Player#1111")
	return format("|cFF00AAFF|Hfriend:%s|h[%s]|h|r", tag, tag)
end

local FormatLinks = function(message)
	if (not message) then
		return
	end
	
	if Settings["chat-enable-discord-links"] then
		local NewMessage, Subs = gsub(message, "https://discord.gg/(%S+)", FormatDiscordHyperlink("%1"))
		
		if (Subs > 0) then
			return NewMessage
		end
		
		local NewMessage, Subs = gsub(message, "discord.gg/(%S+)", FormatDiscordHyperlink("%1"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-url-links"] then
		if (match(message, "%a+://(%S+)%.%a+/%S+") == "discord") and (not Settings["chat-enable-discord-links"]) then
			return message
		end
		
		local NewMessage, Subs = gsub(message, "(%a+)://(%S+)", FormatURLHyperlink("%1://%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
		
		NewMessage, Subs = gsub(message, "www%.([_A-Za-z0-9-]+)%.(%S+)", FormatURLHyperlink("www.%1.%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-email-links"] then
		NewMessage, Subs = gsub(message, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)", FormatEmailHyperlink("%1@%2%3%4"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	if Settings["chat-enable-friend-links"] then
		local NewMessage, Subs = gsub(message, "(%a+)#(%d+)", FormatFriendHyperlink("%1#%2"))
		
		if (Subs > 0) then
			return NewMessage
		end
	end
	
	return message
end

local FindLinks = function(self, event, msg, ...)
	msg = FormatLinks(msg)
	
	return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", FindLinks)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", FindLinks)

-- Scooping the GMOTD to see if there's any yummy links.
ChatFrame_DisplayGMOTD = function(frame, gmotd)
	if (gmotd and (gmotd ~= "")) then
		local info = ChatTypeInfo["GUILD"]
		
		gmotd = format(GUILD_MOTD_TEMPLATE, gmotd)
		gmotd = FormatLinks(gmotd)
		
		frame:AddMessage(gmotd, info.r, info.g, info.b, info.id)
	end
end

local SetEditBoxToLink = function(box, text)
	box:SetText("")
	
	if (not box:IsShown()) then
		ChatEdit_ActivateChat(box)
	else
		ChatEdit_UpdateHeader(box)
	end
	
	box:Insert(text)
	box:HighlightText()
end

ItemRefTooltip.SetHyperlink = function(self, link, text, button, chatFrame)
	if (sub(link, 1, 3) == "url") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Link = sub(link, 5)
		
		EditBox:SetAttribute("chatType", "URL")
		
		SetEditBoxToLink(EditBox, Link)
	elseif (sub(link, 1, 5) == "email") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Email = sub(link, 7)
		
		EditBox:SetAttribute("chatType", "EMAIL")
		
		SetEditBoxToLink(EditBox, Email)
	elseif (sub(link, 1, 7) == "discord") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Link = sub(link, 9)
		
		EditBox:SetAttribute("chatType", "DISCORD")
		
		SetEditBoxToLink(EditBox, Link)
	elseif (sub(link, 1, 6) == "friend") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Tag = sub(link, 8)
		
		EditBox:SetAttribute("chatType", "FRIEND")
		
		SetEditBoxToLink(EditBox, Tag)
	elseif (sub(link, 1, 7) == "command") then
		local EditBox = ChatEdit_ChooseBoxForSend()
		local Command = sub(link, 9)
		
		EditBox:SetText("")
		
		if (not EditBox:IsShown()) then
			ChatEdit_ActivateChat(EditBox)
		else
			ChatEdit_UpdateHeader(EditBox)
		end
		
		EditBox:Insert(Command)
		ChatEdit_ParseText(EditBox, 1)
	else
		SetHyperlink(self, link, text, button, chatFrame)
	end
end

local TabButton_OnEnter = function(self)
	self.Text:SetTextColor(vUI:HexToRGB(Settings["ui-widget-font-color"]))
end

local TabButton_OnLeave = function(self)
	self.Text:SetTextColor(vUI:HexToRGB(Settings["ui-button-font-color"]))
end

local TabButton_OnMouseDown = function(self)
	self.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
end

local TabButton_OnMouseUp = function(self, button)
	self.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	if (self.ID == 3) then
		if (self.Anim and self.Anim:IsPlaying()) then
			self.Anim:Stop()
			self.GlowParent:SetAlpha(0)
		end
	end
	
    SELECTED_CHAT_FRAME = self.Frame
	FCF_SelectDockFrame(self.Frame)
	FCF_DockUpdate()
end

local TabButton_OnEvent = function(self, event)
	if self.Frame:IsShown() then
		return
	end
	
	if (not self.Anim) then
		self.Anim = CreateAnimationGroup(self.GlowParent)
		self.Anim:SetLooping(true)
		
		self.FadeIn = self.Anim:CreateAnimation("Fade")
		self.FadeIn:SetDuration(1)
		self.FadeIn:SetEasing("inout")
		self.FadeIn:SetChange(1)
		self.FadeIn:SetOrder(1)
		
		self.FadeOut = self.Anim:CreateAnimation("Fade")
		self.FadeOut:SetDuration(1)
		self.FadeOut:SetEasing("inout")
		self.FadeOut:SetChange(0)
		self.FadeOut:SetOrder(2)
	end
	
	if (event == "CHAT_MSG_WHISPER") then
		self.Glow:SetVertexColor(ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b)
	else
		self.Glow:SetVertexColor(ChatTypeInfo["BN_WHISPER"].r, ChatTypeInfo["BN_WHISPER"].g, ChatTypeInfo["BN_WHISPER"].b)
	end
	
	self.Anim:Play()
end

local CreateChatFramePanels = function(self)
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	local LeftChatFrameBottom = CreateFrame("Frame", "vUIChatFrameBottom", UIParent)
	LeftChatFrameBottom:SetSize(FRAME_WIDTH, BAR_HEIGHT)
	LeftChatFrameBottom:SetScaledPoint("BOTTOMLEFT", UIParent, 13, 13)
	LeftChatFrameBottom:SetBackdrop(vUI.BackdropAndBorder)
	LeftChatFrameBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	LeftChatFrameBottom:SetBackdropBorderColor(0, 0, 0)
	LeftChatFrameBottom:SetFrameStrata("MEDIUM")
	
	LeftChatFrameBottom.Texture = LeftChatFrameBottom:CreateTexture(nil, "OVERLAY")
	LeftChatFrameBottom.Texture:SetScaledPoint("TOPLEFT", LeftChatFrameBottom, 1, -1)
	LeftChatFrameBottom.Texture:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameBottom, -1, 1)
	LeftChatFrameBottom.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	LeftChatFrameBottom.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	local ChatFrameBG = CreateFrame("Frame", "vUIChatFrame", UIParent)
	ChatFrameBG:SetScaledSize(FRAME_WIDTH, FRAME_HEIGHT)
	ChatFrameBG:SetScaledPoint("BOTTOM", LeftChatFrameBottom, "TOP", 0, 2)
	ChatFrameBG:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBG:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	ChatFrameBG:SetBackdropBorderColor(0, 0, 0)
	ChatFrameBG:SetFrameStrata("LOW")
	
	local LeftChatFrameTop = CreateFrame("Frame", "vUIChatFrameTop", UIParent)
	LeftChatFrameTop:SetScaledSize(FRAME_WIDTH, BAR_HEIGHT)
	LeftChatFrameTop:SetScaledPoint("BOTTOM", ChatFrameBG, "TOP", 0, 2)
	LeftChatFrameTop:SetBackdrop(vUI.BackdropAndBorder)
	LeftChatFrameTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	LeftChatFrameTop:SetBackdropBorderColor(0, 0, 0)
	LeftChatFrameTop:SetFrameStrata("LOW")
	
	LeftChatFrameTop.Texture = LeftChatFrameTop:CreateTexture(nil, "OVERLAY")
	LeftChatFrameTop.Texture:SetScaledPoint("TOPLEFT", LeftChatFrameTop, 1, -1)
	LeftChatFrameTop.Texture:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, -1, 1)
	LeftChatFrameTop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	LeftChatFrameTop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- All this just to achieve an empty center :P
	local ChatFrameBGTop = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGTop:SetScaledPoint("TOPLEFT", LeftChatFrameTop, -3, 3)
	ChatFrameBGTop:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameTop, 3, -3)
	ChatFrameBGTop:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGTop:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGTop:SetFrameStrata("LOW")
	
	local ChatFrameBGBottom = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGBottom:SetScaledPoint("TOPLEFT", LeftChatFrameBottom, -3, 3)
	ChatFrameBGBottom:SetScaledPoint("BOTTOMRIGHT", LeftChatFrameBottom, 3, -3)
	ChatFrameBGBottom:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGBottom:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGBottom:SetFrameStrata("LOW")
	
	local ChatFrameBGLeft = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGLeft:SetScaledWidth(4)
	ChatFrameBGLeft:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	ChatFrameBGLeft:SetScaledPoint("BOTTOMLEFT", ChatFrameBGBottom, "TOPLEFT", 0, 0)
	ChatFrameBGLeft:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGLeft:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGLeft:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGLeft:SetFrameStrata("LOW")
	
	local ChatFrameBGRight = CreateFrame("Frame", nil, ChatFrameBG)
	ChatFrameBGRight:SetScaledWidth(4)
	ChatFrameBGRight:SetScaledPoint("TOPRIGHT", ChatFrameBGTop, 0, 0)
	ChatFrameBGRight:SetScaledPoint("BOTTOMRIGHT", ChatFrameBGBottom, 0, 0)
	ChatFrameBGRight:SetBackdrop(vUI.BackdropAndBorder)
	ChatFrameBGRight:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ChatFrameBGRight:SetBackdropBorderColor(0, 0, 0, 0)
	ChatFrameBGRight:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", nil, ChatFrameBG)
	OuterOutline:SetScaledPoint("TOPLEFT", ChatFrameBGTop, 0, 0)
	OuterOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBGBottom, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerOutline = CreateFrame("Frame", nil, ChatFrameBG)
	InnerOutline:SetScaledPoint("TOPLEFT", ChatFrameBG, 0, 0)
	InnerOutline:SetScaledPoint("BOTTOMRIGHT", ChatFrameBG, 0, 0)
	InnerOutline:SetBackdrop(vUI.Outline)
	InnerOutline:SetBackdropBorderColor(0, 0, 0)
	
	for i = 1, 4 do
		local TabID = TabIDs[i]
		
		local Button = CreateFrame("Frame", "vUI_CustomTab"..i, LeftChatFrameTop)
		Button:SetScaledSize(ButtonWidth, 22)
		Button:SetFrameStrata("MEDIUM")
		Button:SetBackdrop(vUI.BackdropAndBorder)
		Button:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
		Button:SetBackdropBorderColor(0, 0, 0)
		Button.ID = TabID
		Button.Frame = _G["ChatFrame"..TabID]
		
		_G["ChatFrame"..TabID.."Tab"]:EnableMouse(false)
		_G["ChatFrame"..TabID.."Tab"]:SetAlpha(0)
		
		Button.Tex = Button:CreateTexture(nil, "BORDER")
		Button.Tex:SetScaledPoint("TOPLEFT", Button, 1, -1)
		Button.Tex:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
		Button.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
		Button.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		Button.Text = Button:CreateFontString(nil, "OVERLAY")
		Button.Text:SetScaledPoint("CENTER", Button, 0, 0)
		Button.Text:SetFont(Media:GetFont(Settings["ui-button-font"]), 12)
		Button.Text:SetText(TabNames[i])
		Button.Text:SetTextColor(vUI:HexToRGB(Settings["ui-button-font-color"]))
		Button.Text:SetShadowColor(0, 0, 0)
		Button.Text:SetShadowOffset(1, -1)
		
		if (i == 1) then
			Button:SetScaledPoint("LEFT", LeftChatFrameTop, 0, 0)
			Button:SetScaledWidth(ButtonWidth - 1)
		else
			Button:SetScaledPoint("LEFT", TabButtons[i-1], "RIGHT", -1, 0)
		end
		
		if (i == 2) then
			Button.GlowParent = CreateFrame("Frame", nil, Button)
			Button.GlowParent:SetAllPoints(Button)
			Button.GlowParent:SetAlpha(0)
			Button.GlowParent:SetFrameStrata("MEDIUM")
			Button.GlowParent:SetFrameLevel(Button:GetFrameLevel())
			
			Button.Glow = Button.GlowParent:CreateTexture(nil, "OVERLAY")
			Button.Glow:SetTexture(Media:GetTexture("RenHorizonUp"))
			Button.Glow:SetScaledSize(76, 16)
			Button.Glow:SetScaledPoint("BOTTOM", Button, 0, 1)
			Button.Glow:SetBlendMode("ADD")
			
			Button:RegisterEvent("CHAT_MSG_WHISPER")
			Button:RegisterEvent("CHAT_MSG_BN_WHISPER")
			Button:SetScript("OnEvent", TabButton_OnEvent)
		end
		
		Button:SetScript("OnEnter", TabButton_OnEnter)
		Button:SetScript("OnLeave", TabButton_OnLeave)
		Button:SetScript("OnMouseDown", TabButton_OnMouseDown)
		Button:SetScript("OnMouseUp", TabButton_OnMouseUp)
		
		TabButtons[i] = Button
	end
	
	_G["ChatFrame2Tab"]:EnableMouse(false)
end

local Kill = function(object)
	if not object then
		return
	end

	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	if (object.GetScript and object:GetScript("OnUpdate")) then
		object:SetScript("OnUpdate", nil)
	end
	
	object.Show = function() end
	object:Hide()
end

local OnMouseWheel = function(self, delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	end
end

-- To do: Print channel isn't setting width properly. don't have time to investigate atm, so making a note.
local UpdateEditBoxColor = function(editbox)
	local ChatType = editbox:GetAttribute("chatType")
	local Backdrop = editbox.Backdrop
	
	if Backdrop then
		if (ChatType == "CHANNEL") then
			local ID = GetChannelName(editbox:GetAttribute("channelTarget"))
			
			if (ID == 0) then
				Backdrop.Change:SetChange(vUI:HexToRGB(Settings["ui-header-texture-color"]))
			else
				Backdrop.Change:SetChange(ChatTypeInfo[ChatType..ID].r * 0.2, ChatTypeInfo[ChatType..ID].g * 0.2, ChatTypeInfo[ChatType..ID].b * 0.2)
			end
		else
			Backdrop.Change:SetChange(ChatTypeInfo[ChatType].r * 0.2, ChatTypeInfo[ChatType].g * 0.2, ChatTypeInfo[ChatType].b * 0.2)
		end
		
		Backdrop.Change:Play()
	end
	
	local HeaderText = editbox.header:GetText()
	local Subs = 0
	
	HeaderText, Subs = gsub(HeaderText, "%s$", "")
	
	if Subs then
		editbox.header:SetText(HeaderText)
	end
	
	editbox.HeaderBackdrop:SetScaledWidth(editbox.header:GetWidth() + 14)
end

local KillTextures = {
	"TabLeft",
	"TabMiddle",
	"TabRight",
	"TabSelectedLeft",
	"TabSelectedMiddle",
	"TabSelectedRight",
	"TabHighlightLeft",
	"TabHighlightMiddle",
	"TabHighlightRight",
	"ButtonFrameUpButton",
	"ButtonFrameDownButton",
	"ButtonFrameBottomButton",
	"ButtonFrameMinimizeButton",
	"ButtonFrame",
	"EditBoxFocusLeft",
	"EditBoxFocusMid",
	"EditBoxFocusRight",
	"EditBoxLeft",
	"EditBoxMid",
	"EditBoxRight",
}

local OnEditFocusLost = function(self)
	if (Settings["experience-position"] == "CHATFRAME") then
		vUIExperienceBar:Show()
		vUIChatFrameBottom:Hide()
	else
		vUIChatFrameBottom:Show()
	end
	
	self:Hide()
end

local OnEditFocusGained = function(self)
	if (Settings["experience-position"] == "CHATFRAME") then
		vUIExperienceBar:Hide()
	end
	
	vUIChatFrameBottom:Hide()
end

local StyleChatFrame = function(frame)
	if frame.Styled then
		return
	end
	
	local FrameName = frame:GetName()
	local Tab = _G[FrameName.."Tab"]
	local TabText = _G[FrameName.."TabText"]
	local EditBox = _G[FrameName.."EditBox"]
	local ScrollBar = frame.ScrollBar
	local ScrollToBottom = frame.ScrollToBottomButton
	local ThumbTexture = _G[FrameName.."ThumbTexture"]
	
	if ScrollBar then
		Kill(ScrollBar)
		Kill(ScrollToBottom)
		Kill(ThumbTexture)
	end
	
	if Tab.conversationIcon then
		Kill(Tab.conversationIconKill)
	end
	
	if Tab.glow then
		Kill(Tab.glow)
	end
	
	-- Hide editbox every time we click on a tab
	Tab:HookScript("OnClick", function()
		EditBox:Hide()
	end)
	
	-- Tabs Alpha
	Tab.mouseOverAlpha = 0
	Tab.noMouseAlpha = 0
	Tab:SetAlpha(0)
	Tab.SetAlpha = UIFrameFadeRemoveFrame
	
	Tab:Hide()
	Tab.Show = function() end
	
	TabText:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	TabText.SetFont = function() end
	
	TabText:SetTextColor(1, 1, 1)
	TabText.SetTextColor = function() end
	
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetFading(false)
	frame:SetScript("OnMouseWheel", OnMouseWheel)
	frame:SetScaledSize(vUIChatFrame:GetWidth() - 8, vUIChatFrame:GetHeight() - 8)
	frame:SetFrameLevel(vUIChatFrame:GetFrameLevel() + 1)
	frame:SetFrameStrata("MEDIUM")
	frame:SetJustifyH("LEFT")
	frame:Hide()
	
	if (not frame.isLocked) then
		FCF_SetLocked(frame, 1)
	end
	
	FCF_SetChatWindowFontSize(nil, frame, 12)
	
	EditBox:ClearAllPoints()
	EditBox:SetScaledPoint("TOPLEFT", vUIChatFrameBottom, 5, -2)
	EditBox:SetScaledPoint("BOTTOMRIGHT", vUIChatFrameBottom, -1, 2)
	EditBox:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	EditBox:SetAltArrowKeyMode(false)
	EditBox:Hide()
	EditBox:HookScript("OnEditFocusLost", OnEditFocusLost)
	EditBox:HookScript("OnEditFocusGained", OnEditFocusGained)
	
	EditBox.HeaderBackdrop = CreateFrame("Frame", nil, EditBox)
	EditBox.HeaderBackdrop:SetBackdrop(vUI.BackdropAndBorder)
	EditBox.HeaderBackdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.HeaderBackdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.HeaderBackdrop:SetScaledSize(60, 22)
	EditBox.HeaderBackdrop:SetScaledPoint("LEFT", vUIChatFrameBottom, 0, 0)
	EditBox.HeaderBackdrop:SetFrameStrata("HIGH")
	EditBox.HeaderBackdrop:SetFrameLevel(1)
	
	EditBox.HeaderBackdrop.Tex = EditBox.HeaderBackdrop:CreateTexture(nil, "BORDER")
	EditBox.HeaderBackdrop.Tex:SetScaledPoint("TOPLEFT", EditBox.HeaderBackdrop, 1, -1)
	EditBox.HeaderBackdrop.Tex:SetScaledPoint("BOTTOMRIGHT", EditBox.HeaderBackdrop, -1, 1)
	EditBox.HeaderBackdrop.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	EditBox.HeaderBackdrop.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	EditBox.HeaderBackdrop.AnimateWidth = CreateAnimationGroup(EditBox.HeaderBackdrop):CreateAnimation("Width")
	EditBox.HeaderBackdrop.AnimateWidth:SetEasing("in")
	EditBox.HeaderBackdrop.AnimateWidth:SetDuration(0.15)
	
	EditBox.Backdrop = CreateFrame("Frame", nil, EditBox)
	EditBox.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	EditBox.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	EditBox.Backdrop:SetBackdropBorderColor(0, 0, 0)
	EditBox.Backdrop:SetScaledPoint("TOPLEFT", EditBox.HeaderBackdrop, "TOPRIGHT", 2, 0)
	EditBox.Backdrop:SetScaledPoint("BOTTOMRIGHT", vUIChatFrameBottom, 0, 0)
	EditBox.Backdrop:SetFrameStrata("HIGH")
	EditBox.Backdrop:SetFrameLevel(1)
	
	EditBox.Backdrop.Tex = EditBox.Backdrop:CreateTexture(nil, "BORDER")
	EditBox.Backdrop.Tex:SetScaledPoint("TOPLEFT", EditBox.Backdrop, 1, -1)
	EditBox.Backdrop.Tex:SetScaledPoint("BOTTOMRIGHT", EditBox.Backdrop, -1, 1)
	EditBox.Backdrop.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	EditBox.Backdrop.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local AnimGroup = CreateAnimationGroup(EditBox.Backdrop.Tex)
	
	EditBox.Backdrop.Change = AnimGroup:CreateAnimation("Color")
	EditBox.Backdrop.Change:SetColorType("vertex")
	EditBox.Backdrop.Change:SetEasing("in")
	EditBox.Backdrop.Change:SetDuration(0.2)
	
	EditBox.header:ClearAllPoints()
	EditBox.header:SetScaledPoint("CENTER", EditBox.HeaderBackdrop, 0, 0)
	EditBox.header:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12, nil)
	EditBox.header:SetJustifyH("CENTER")
	EditBox.header:SetShadowColor(0, 0, 0)
	EditBox.header:SetShadowOffset(1, -1)
	
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end
	
	for i = 1, #KillTextures do
		Kill(_G[FrameName..KillTextures[i]])
	end
	
	frame.Styled = true
end

local StyleTemporaryWindow = function()
	local Frame = FCF_GetCurrentChatFrame()
	
	if (not Frame.Styled) then
		StyleChatFrame(Frame)
	end
end

local MoveChatFrames = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		-- Set font size and chat frame size
		Frame:SetScaledSize(vUIChatFrame:GetWidth() - 8, vUIChatFrame:GetHeight() - 8)
		Frame:SetFrameLevel(vUIChatFrame:GetFrameLevel() + 1)
		Frame:SetFrameStrata("MEDIUM")
		Frame:SetJustifyH("LEFT")
		Frame:Hide()
		
		-- Set default chat frame position
		if (Frame:GetID() == 1) then
			Frame:ClearAllPoints()
			Frame:SetScaledPoint("TOPLEFT", vUIChatFrame, 4, -4)
			Frame:SetScaledPoint("BOTTOMRIGHT", vUIChatFrame, -4, 4)
		end
		
		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end
		
		FCF_SetChatWindowFontSize(nil, Frame, 12)
		
		Frame:SetFont(Media:GetFont(Settings["ui-widget-font"]), 12)
	end
	
	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
end

local Setup = function()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		
		StyleChatFrame(Frame)
		FCFTab_UpdateAlpha(Frame)
	end
	
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
	
	Kill(ChatConfigFrameDefaultButton)
	Kill(ChatFrameMenuButton)
	Kill(QuickJoinToastButton)
	
	Kill(ChatFrameChannelButton)
	Kill(ChatFrameToggleVoiceDeafenButton)
	Kill(ChatFrameToggleVoiceMuteButton)
end

vUI_ChatInstall = function() -- /run vUI_ChatInstall()
	-- General
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, "General")
	ChatFrame1:Show()
	
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	
	-- Combat Log
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, "Combat")
	ChatFrame2:Show()
	
	-- Whispers
	FCF_OpenNewWindow("Whispers")
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	ChatFrame3:Show()
	
	-- Loot
	FCF_OpenNewWindow("Loot")
	FCF_DockFrame(ChatFrame4)
	ChatFrame4:Show()
	
	-- Trade
	FCF_OpenNewWindow("Trade")
	FCF_DockFrame(ChatFrame5)
	ChatFrame5:Show()
	
	-- General
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	
	-- Whispers
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_CONVERSATION")
	
	-- Loot & Reputation
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
	
	-- Trade
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddChannel(ChatFrame5, TRADE)
	ChatFrame_AddChannel(ChatFrame5, GENERAL)
	
	-- Enable Classcolor
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")	
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	
	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
	
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("WhisperMode", "inline")
	--SetCVar("BnWhisperMode", "inline")
	SetCVar("removeChatDelay", 1)
	
	MoveChatFrames()
	FCF_SelectDockFrame(ChatFrame1)
	
	ReloadUI()
end

-- Is this a stupid joke? Laziness? Is it supposed to be funny? Annoying.
RAID_CLASS_COLORS["SHAMAN"].r = 0
RAID_CLASS_COLORS["SHAMAN"].g = 0.44
RAID_CLASS_COLORS["SHAMAN"].b = 0.87
RAID_CLASS_COLORS["SHAMAN"].colorStr = "0070DE"

ChatClassColorOverrideShown = function()
	return true
end

local ChatFrameOnEvent
local CHAT_PRINT_GET

local NewChatFrameOnEvent = function(self, event, msg, ...)
	if (event == "CHAT_MSG_PRINT") then
		-- Check if the msg was meant to be interpretted as script
		local Result
		
		-- Check if it needs a return or not
		if (not strfind(msg, "return")) then
			Result = loadstring("return "..msg)
		else
			Result = loadstring(msg)
		end
		
		if Result then
			local NumArgs = select("#", Result())
			
			if (NumArgs > 1) then
				local String = ""
				
				for i = 1, NumArgs do
					if (i == 1) then
						String = tostring(select(i, Result()))
					else
						String = String..", "..tostring(select(i, Result()))
					end
				end
				
				self:AddMessage(CHAT_PRINT_GET..String)
			else
				self:AddMessage(CHAT_PRINT_GET..tostring(Result()))
			end
		else
			self:AddMessage(CHAT_PRINT_GET..msg)
		end
	else
		ChatFrameOnEvent(self, event, msg, ...)
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript("OnEvent", function(self, event)
	if (not Settings["chat-enable"]) then
		self:UnregisterEvent(event)
		
		return
	end
	
	CreateChatFramePanels()
	Setup()
	--Install()
	MoveChatFrames()
	
	CHAT_DISCORD_SEND = Language["Discord: "]
	CHAT_URL_SEND = Language["URL: "]
	CHAT_EMAIL_SEND = Language["Email: "]
	CHAT_FRIEND_SEND = Language["Friend Tag:"]
	CHAT_PRINT_SEND = "Print: "
	CHAT_PRINT_GET = "|Hchannel:PRINT|h|cFF66d6ff[Print]|h|r: "
	
	ChatTypeInfo["URL"] = {sticky = 0, r = 255/255, g = 206/255,  b = 84/255}
	ChatTypeInfo["EMAIL"] = {sticky = 0, r = 102/255, g = 187/255,  b = 106/255}
	ChatTypeInfo["DISCORD"] = {sticky = 0, r = 114/255, g = 137/255,  b = 218/255}
	ChatTypeInfo["FRIEND"] = {sticky = 0, r = 0, g = 170/255,  b = 255/255}
	ChatTypeInfo["PRINT"] = {sticky = 1, r = 0.364, g = 0.780,  b = 1}
	
	TabButton_OnMouseUp(TabButtons[1])
	
	hooksecurefunc("ChatEdit_UpdateHeader", UpdateEditBoxColor)
	hooksecurefunc("FCF_OpenTemporaryWindow", StyleTemporaryWindow)
	
	if (not ChatFrameOnEvent) then
		ChatFrameOnEvent = DEFAULT_CHAT_FRAME:GetScript("OnEvent")
	end
	
	self:UnregisterEvent(event)
end)

vUI.FormatLinks = FormatLinks

local OldSendChatMessage = SendChatMessage

SendChatMessage = function(msg, chatType, language, channel)
	if (chatType == "PRINT") then
		NewChatFrameOnEvent(ChatFrame1, "CHAT_MSG_PRINT", msg)
		
		return
	elseif (chatType == "URL" or chatType == "EMAIL" or chatType == "DISCORD" or chatType == "FRIEND") then -- So you can hit enter instead of escape.
		local EditBox = ChatEdit_ChooseBoxForSend()
		
		if EditBox then
			EditBox:ClearFocus()
			ChatEdit_ResetChatTypeToSticky(EditBox)
			ChatEdit_ResetChatType(EditBox)
		end
	else
		OldSendChatMessage(msg, chatType, language, channel)
	end
end

hooksecurefunc("ChatEdit_HandleChatType", function(eb, msg, cmd, send)
	if (cmd == "/PRINT") then
		eb:SetAttribute("chatType", "PRINT")
		eb:SetText(msg)
		ChatEdit_UpdateHeader(eb)
	end
end)

local UpdateOpacity = function(value)
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	vUIChatFrame:SetBackdropColor(R, G, B, (value / 100))
end

GUI:AddOptions(function(self)
	local ChatOptions = self:NewWindow(Language["Chat"])
	
	local EnableGroup = ChatOptions:CreateGroup(Language["Enable"], "Left")
	
	EnableGroup:CreateCheckbox("chat-enable", Settings["chat-enable"], Language["Enable Chat"], "")
	
	local Opacity = ChatOptions:CreateGroup(Language["Opacity"], "Right")
	
	Opacity:CreateSlider("chat-bg-opacity", Settings["chat-bg-opacity"], 0, 100, 10, "Background Opacity", "", UpdateOpacity, nil, "%")
	
	-- Add options to hyperlink things
	
	local LinksGroup = ChatOptions:CreateGroup(Language["Links"], "Left")
	
	LinksGroup:CreateCheckbox("chat-enable-url-links", Settings["chat-enable-url-links"], Language["Enable URL Links"], "")
	LinksGroup:CreateCheckbox("chat-enable-discord-links", Settings["chat-enable-discord-links"], Language["Enable Discord Links"], "")
	LinksGroup:CreateCheckbox("chat-enable-email-links", Settings["chat-enable-email-links"], Language["Enable Email Links"], "")
	LinksGroup:CreateCheckbox("chat-enable-friend-links", Settings["chat-enable-friend-links"], Language["Enable Friend Tag Links"], "")
end)