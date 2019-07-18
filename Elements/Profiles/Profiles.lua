local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Default = "%s-%s"
local User = UnitName("player")
local Realm = GetRealmName()
local ProfileNames = {}

local pairs = pairs

local GetLastModified = function()
	
end

function Profiles:ImportProfiles()
	if vUIProfiles then
		for Name in pairs(vUIProfiles) do
			ProfileNames[Name] = Name
		end
	end
end

function Profiles:NewProfile(name)
	if (not vUIProfiles) then
		vUIProfiles = {}
	end
	
	if (not name) then
		name = format(Default, User, Realm)
	end
	
	if vUIProfiles[name] then
		ProfileNames[name] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
	
	--[[ Don't shove Defaults into the profile here. In fact don't even store values unless they ~= Defaults[ID]
	for ID, Value in pairs(Defaults) do
		vUIProfiles[name][ID] = Value
	end]]
	
	ProfileNames[name] = name
	
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
	return ProfileNames
end

function Profiles:DeleteProfile(name)
	if vUIProfiles[name] then
		vUIProfiles[name] = nil
	end
end

function Profiles:MergeWithDefaults(name)
	local Values = {}
	
	-- Collect default values
	for ID, Value in pairs(Defaults) do
		Values[ID] = Value
	end
	
	-- And apply stored values
	for ID, Value in pairs(vUIProfiles[name]) do
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