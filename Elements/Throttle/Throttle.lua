local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local tinsert = table.insert
local tremove = table.remove

local Throttles = {}
Throttles.Inactive = {}
Throttles.Active = {}

local OnUpdate = function(self, ela)
	for i = 1, #self.Active do
		self.Active[i] = self.Active[i] - ela
		
		if (self.Active[i].Time <= 0) then
			tinsert(self.Inactive, tremove(self.Active, i))
		end
	end
	
	if (#self.Active == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

function Throttles:Create(name, duration)
	if self:IsThrottled(name) then
		vUI:print(format('A throttle already exists with the name "%s".', name))
		
		return
	end
	
	tinsert(self.Inactive, {Name = name, Time = duration})
end

function Throttles:IsThrottled(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			return true
		end
	end
	
	return false
end

function Throttles:Start(name)
	if (not self.Inactive[name]) then
		return
	end
	
	for i = 1, #self.Inactive do
		if (self.Inactive[i].Name == name) then
			tinsert(self.Active, tremove(self.Inactive, i))
			
			if (not self:GetScript("OnUpdate")) then
				self:SetScript("OnUpdate", OnUpdate)
			end
			
			break
		end
	end
end

function Throttles:Stop(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			tinsert(self.Inactive, tremove(self.Active, i))
			
			break
		end
	end
	
	if (#self.Active == 0) then
		self:SetScript("OnUpdate", nil)
	end
end