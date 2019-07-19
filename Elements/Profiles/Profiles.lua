local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local DefaultKey = "%s-%s"
local pairs = pairs
local date = date

Profiles.List = {}

local Filter = {
	["profile-created"] = true,
	["profile-last-modified"] = true,
}

local GetCurrentDate = function()
	local Date = date("%Y-%m-%d")
	--local Now2 = date("%a, %b %d")
	
	return Date
end

function Profiles:ImportProfiles()
	if vUIProfiles then
		for Name in pairs(vUIProfiles) do
			self.List[Name] = Name
		end
	end
end

function Profiles:GetNumProfiles()
	local Count = 0
	
	for Name in pairs(self.List) do
		Count = Count + 1
	end
	
	return Count
end

function Profiles:SetLastModified(name)
	local Profile = self:GetProfile(name)
	
	Profile["profile-last-modified"] = GetCurrentDate()
end

function Profiles:GetActiveProfileName()
	if (vUIData and vUIData["ui-profile"]) then
		return vUIData["ui-profile"]
	end
end

function Profiles:GetActiveProfile()
	if (vUIData and vUIData["ui-profile"]) then
		if vUIProfiles[vUIData["ui-profile"]] then
			return vUIProfiles[vUIData["ui-profile"]]
		end
	end
end

function Profiles:CountChangedValues(name)
	local Profile = self:GetProfile(name)
	local Count = 0
	
	for ID, Value in pairs(Profile) do
		if (not Filter[ID]) then
			Count = Count + 1
		end
	end
	
	return Count
end

function Profiles:NewProfile(name)
	if (not vUIProfiles) then
		vUIProfiles = {}
	end
	
	if (not name) then
		name = format(DefaultKey, vUI.User, vUI.Realm)
	end
	
	if vUIProfiles[name] then
		self.List[name] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
	vUIProfiles[name]["profile-created"] = GetCurrentDate()
	self.List[name] = name
	
	return vUIProfiles[name]
end

function Profiles:GetProfile(name)
	if vUIProfiles[name] then
		return vUIProfiles[name]
	else
		return vUIProfiles["Default"]
	end
end

function Profiles:GetProfileList()
	return self.List
end

function Profiles:DeleteProfile(name)
	if vUIProfiles[name] then
		vUIProfiles[name] = nil
		vUI:print(format('Deleted profile "%s".', name))
	else
		vUI:print(format('No profile exists with the name "%s".', name))
	end
end

function Profiles:MergeWithDefaults(name)
	local Values = {}
	local Profile = self:GetProfile(name)
	
	-- Collect default values
	for ID, Value in pairs(Defaults) do
		Values[ID] = Value
	end
	
	-- And apply stored values
	for ID, Value in pairs(Profile) do
		Values[ID] = Value
	end
	
	return Values
end

function Profiles:ApplyProfile(name)
	if (not vUIProfiles[name]) then
		return
	end
	
	local Values = self:MergeWithDefaults(name)
	
	for ID, Value in pairs(Values) do
		Settings[ID] = Value
	end
	
	vUIData["ui-profile"] = name
end