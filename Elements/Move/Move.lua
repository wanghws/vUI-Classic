local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Move = vUI:NewModule("Move")

Move.Frames = {}
Move.Defaults = {}
Move.Active = false

local OnDragStart = function(self)
	self:StartMoving()
end

local OnDragStop = function(self)
	self:StopMovingOrSizing()
	
	local Name = self:GetName()
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	if (not Parent) then
		Parent = UIParent
	end
	
	vUIMove[self.Name] = {A1, Parent:GetName(), A2, X, Y}
end

function Move:Toggle()
	local Frame
	
	if self.Active then
		for i = 1, #self.Frames do
			Frame = self.Frames[i]
			
			Frame:EnableMouse(false)
			Frame:StopMovingOrSizing()
			Frame:SetScript("OnDragStart", nil)
			Frame:SetScript("OnDragStop", nil)
			Frame:Hide()
		end
		
		self.Active = false
	else
		for i = 1, #self.Frames do
			Frame = self.Frames[i]
			
			Frame:EnableMouse(true)
			Frame:RegisterForDrag("LeftButton")
			Frame:SetScript("OnDragStart", OnDragStart)
			Frame:SetScript("OnDragStop", OnDragStop)
			Frame:Show()
		end
	
		self.Active = true
	end
end

function Move:ResetAll()
	if (not vUIMove) then
		vUIMove = {}
	end
	
	local Frame
	
	for i = 1, #self.Frames do
		Frame = self.Frames[i]
		
		if self.Defaults[Frame.Name] then
			local A1, Parent, A2, X, Y = unpack(self.Defaults[Frame.Name])
			
			Frame:ClearAllPoints()
			Frame:SetScaledPoint(A1, _G[Parent], A2, X, Y)
			
			vUIMove[Frame.Name] = {A1, Parent, A2, X, Y}
		end
	end
end

local OnSizeChanged = function(self)
	self.Mover:SetScaledSize(self:GetSize())
end

local MoverOnMouseUp = function(self, button)
	if (button == "RightButton") then
		if Move.Defaults[self.Name] then
			local A1, Parent, A2, X, Y = unpack(Move.Defaults[self.Name])
			local ParentObject = _G[Parent]
			
			self:ClearAllPoints()
			self:SetScaledPoint(A1, ParentObject, A2, X, Y)
			
			vUIMove[self.Name] = {A1, Parent, A2, X, Y}
		end
	end
end

local MoverOnEnter = function(self)
	self:SetBackdropColorHex("FF4444")
end

local MoverOnLeave = function(self)
	self:SetBackdropColorHex(Settings["ui-window-bg-color"])
end

function Move:Add(frame)
	if (not vUIMove) then
		vUIMove = {}
	end
	
	local A1, Parent, A2, X, Y = frame:GetPoint()
	local Name = frame:GetName()
	
	if (not Name) then
		return
	end
	
	if (not Parent) then
		Parent = UIParent
	end
	
	ParentName = Parent:GetName()
	ParentObject = _G[ParentName]
	
	local Mover = CreateFrame("Frame", nil, UIParent)
	Mover:SetScaledSize(frame:GetSize())
	Mover:SetBackdrop(vUI.BackdropAndBorder)
	Mover:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Mover:SetBackdropBorderColor(0, 0, 0)
	Mover:SetFrameLevel(20)
	Mover:SetFrameStrata("HIGH")
	Mover:SetMovable(true)
	Mover:SetUserPlaced(true)
	Mover:SetClampedToScreen(true)
	Mover:SetScript("OnMouseUp", MoverOnMouseUp)
	Mover:SetScript("OnEnter", MoverOnEnter)
	Mover:SetScript("OnLeave", MoverOnLeave)
	Mover.Frame = frame
	Mover.Name = Name
	Mover:Hide()
	
	Mover.BG = CreateFrame("Frame", nil, Mover)
	Mover.BG:SetScaledSize(Mover:GetWidth() - 6, Mover:GetHeight() - 6)
	Mover.BG:SetScaledPoint("CENTER", Mover)
	Mover.BG:SetBackdrop(vUI.BackdropAndBorder)
	Mover.BG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Mover.BG:SetBackdropBorderColor(0, 0, 0)
	
	Mover.Label = Mover.BG:CreateFontString(nil, "OVERLAY")
	Mover.Label:SetFontInfo(Settings["ui-widget-font"], 12)
	Mover.Label:SetScaledPoint("CENTER", Mover, 0, 0)
	Mover.Label:SetText(Name)
	
	frame:ClearAllPoints()
	frame:SetScaledPoint("CENTER", Mover, 0, 0)
	frame.Mover = Mover
	frame:HookScript("OnSizeChanged", OnSizeChanged)
	
	self.Defaults[Name] = {A1, ParentName, A2, X, Y}
	
	if vUIMove[Name] then
		local A1, Parent, A2, X, Y = unpack(vUIMove[Name])
		local ParentObject = _G[Parent]		
		
		Mover:SetScaledPoint(A1, ParentObject, A2, X, Y)
	else
		Mover:SetScaledPoint(A1, ParentObject, A2, X, Y)
		
		vUIMove[Name] = {A1, ParentName, A2, X, Y}
	end
	
	table.insert(self.Frames, Mover)
end