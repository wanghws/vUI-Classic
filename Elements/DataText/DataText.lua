local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:NewModule("DataText")

DT.Anchors = {}
DT.Types = {}
DT.List = {}

function DT:NewAnchor(name, parent)
	if self.Anchors[name] then
		return
	end
	
	if (not parent) then
		parent = UIParent
	end
	
	local Anchor = CreateFrame("Frame", nil, parent)
	Anchor:SetScaledSize(120, 20)
	Anchor:SetFrameLevel(parent:GetFrameLevel() + 1)
	Anchor:SetFrameStrata(parent:GetFrameStrata())
	Anchor:SetBackdrop(vUI.Backdrop)
	Anchor:SetBackdropColor(0, 0, 0, 0)
	
	Anchor.Text = Anchor:CreateFontString(nil, "ARTWORK")
	Anchor.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Text:SetScaledPoint("CENTER", Anchor, "CENTER", 0, 0)
	Anchor.Text:SetJustifyH("CENTER")
	
	self.Anchors[name] = Anchor
	
	return Anchor
end

function DT:SetDataText(name, data)
	if ((not self.Anchors[name]) or (not self.Types[data])) then
		return
	end
	
	local Anchor = self.Anchors[name]
	local Type = self.Types[data]
	
	if Anchor.Disable then
		Anchor:Disable()
	end
	
	Anchor.Enable = Type.Enable
	Anchor.Disable = Type.Disable
	Anchor.Update = Type.Update
	
	Anchor:Enable()
end

function DT:SetType(name, enable, disable, update) -- id, name
	if self.Types[name] then
		return
	end
	
	self.Types[name] = {Enable = enable, Disable = disable, Update = update}
	self.List[name] = name
end

function DT:Load()
	local Width = vUIChatFrameBottom:GetWidth() / 3
	local Height = vUIChatFrameBottom:GetWidth()
	
	local ChatLeft = self:NewAnchor("Chat-Left", vUIChatFrameBottom)
	ChatLeft:SetScaledWidth(Width, Height)
	ChatLeft:SetScaledPoint("LEFT", vUIChatFrameBottom, 0, 0)
	
	local ChatMiddle = self:NewAnchor("Chat-Middle", vUIChatFrameBottom)
	ChatMiddle:SetScaledWidth(Width, Height)
	ChatMiddle:SetScaledPoint("LEFT", ChatLeft, "RIGHT", 0, 0)
	
	local ChatRight = self:NewAnchor("Chat-Right", vUIChatFrameBottom)
	ChatRight:SetScaledWidth(Width, Height)
	ChatRight:SetScaledPoint("LEFT", ChatMiddle, "RIGHT", 0, 0)
	
	self:SetDataText("Chat-Left", Settings["data-text-chat-left"])
	self:SetDataText("Chat-Middle", Settings["data-text-chat-middle"])
	self:SetDataText("Chat-Right", Settings["data-text-chat-right"])
end

local UpdateLeftText = function(value)
	DT:SetDataText("Chat-Left", value)
end

local UpdateMiddleText = function(value)
	DT:SetDataText("Chat-Middle", value)
end

local UpdateRightText = function(value)
	DT:SetDataText("Chat-Right", value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["General"])
	
	Left:CreateHeader(Language["Data Texts"])
	Left:CreateDropdown("data-text-chat-left", Settings["data-text-chat-left"], DT.List, Language["Set Left Text"], Language["Set the information to be displayed in the|nleft data text anchor"], UpdateLeftText)
	Left:CreateDropdown("data-text-chat-middle", Settings["data-text-chat-middle"], DT.List, Language["Set Middle Text"], Language["Set the information to be displayed in the|nmiddle data text anchor"], UpdateMiddleText)
	Left:CreateDropdown("data-text-chat-right", Settings["data-text-chat-right"], DT.List, Language["Set Right Text"], Language["Set the information to be displayed in the|nright data text anchor"], UpdateRightText)
end)