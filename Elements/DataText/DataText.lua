local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:NewModule("DataText")

DT.Anchors = {}
DT.Types = {}

function DT:NewAnchor(name, parent)
	if self.Anchors[name] then
		return
	end
	
	local Anchor = CreateFrame("Frame", nil, UIParent)
	Anchor:SetScaledSize(120, 20)
	Anchor:SetFrameLevel(20)
	Anchor:SetFrameStrata("HIGH")
	Anchor:SetBackdrop(vUI.Backdrop)
	Anchor:SetBackdropColor(0, 0, 0, 0)
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
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
	
	Anchor.Enable = Type.Enable
	Anchor.Disable = Type.Disable
	Anchor.Update = Type.Update
	
	Anchor:Enable()
end

function DT:Register(name, enable, disable, update)
	if self.Types[name] then
		return
	end
	
	self.Types[name] = {Enable = enable, Disable = disable, Update = update}
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
	
	self:SetDataText("Chat-Left", "Gold")
	self:SetDataText("Chat-Middle", "Crit")
	self:SetDataText("Chat-Right", "Power")
end