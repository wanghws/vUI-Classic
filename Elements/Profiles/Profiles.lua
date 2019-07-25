local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local DefaultKey = "%s-%s"
local pairs = pairs
local date = date
local match = string.match

--[[
	To do:
	
	Profiles:ClearEmptyProfiles()
	Profiles:ClearUnusedProfiles()
	Profiles:Rename(from, to)
	Profiles:SetMetadata(name, meta, value) Profiles:SetMetadata("Default", "profile-created-by", "Nickname")
--]]

Profiles.List = {}

local Filter = {
	["profile-name"] = true,
	["profile-created"] = true,
	["profile-created-by"] = true,
	["profile-last-modified"] = true,
}

-- Some settings shouldn't be sent to others
local DontTransmit = {
	["ui-scale"] = true,
	["ui-language"] = true,
	
	-- To be decided. I think I should leave these to Templates exclusively, but will that feel restrictive?
	["ui-widget-font"] = true,
	["ui-header-font"] = true,
	["ui-button-font"] = true,
	["ui-widget-texture"] = true,
	["ui-header-texture"] = true,
	["ui-button-texture"] = true,
	["ui-header-font-color"] = true,
	["ui-header-texture-color"] = true,
	["ui-window-bg-color"] = true,
	["ui-window-main-color"] = true,
	["ui-widget-color"] = true,
	["ui-widget-bright-color"] = true,
	["ui-widget-bg-color"] = true,
	["ui-widget-font-color"] = true,
	["ui-button-font-color"] = true,
	["ui-button-texture-color"] = true,
}

local GetCurrentDate = function()
	return date("%Y-%m-%d %I:%M %p")
end

-- If the date given is today, change "2019-07-24 2:06 PM" to "Today 2:06 PM"
local IsToday = function(s)
	local Date, Time = match(s, "(%d+%-%d+%-%d+)%s(.+)")
	
	if (not Date or not Time) then
		return s
	end
	
	if (Date == date("%Y-%m-%d")) then
		s = format("%s %s", Language["Today"], Time)
	end
	
	return s
end

function Profiles:UpdateProfileList()
	if vUIProfiles then
		for Name in pairs(vUIProfiles) do
			self.List[Name] = Name
		end
	end
end

function Profiles:GetProfileCount()
	local Count = 0
	
	for Name in pairs(self.List) do
		Count = Count + 1
	end
	
	return Count
end

function Profiles:GetDefaultProfileKey()
	return format(DefaultKey, vUI.User, vUI.Realm)
end

function Profiles:SetLastModified(name)
	local Profile = self:GetProfile(name)
	
	Profile["profile-last-modified"] = GetCurrentDate()
end

function Profiles:GetActiveProfileName() -- Will this ever be called in a case where it needs a fallback?
	if (vUIProfileData and vUIProfileData[vUI.Realm]) then
		if vUIProfileData[vUI.Realm][vUI.User] then
			return vUIProfileData[vUI.Realm][vUI.User]
		end
	end
end

function Profiles:GetActiveProfile()
	if (vUIProfileData and vUIProfileData[vUI.Realm]) then
		if vUIProfileData[vUI.Realm][vUI.User] then
			return self:GetProfile(vUIProfileData[vUI.Realm][vUI.User])
		end
	end
end

function Profiles:SetActiveProfile(name)
	if (vUIProfileData and vUIProfileData[vUI.Realm]) then
		if vUIProfileData[vUI.Realm][vUI.User] then
			vUIProfileData[vUI.Realm][vUI.User] = name
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

function Profiles:CreateProfileData()
	if (not vUIProfileData) then -- No profile data exists, create a default
		self:CreateProfile("Default")
	end
	
	if (not vUIProfileData[vUI.Realm]) then
		vUIProfileData[vUI.Realm] = {}
	end
	
	if (not vUIProfileData[vUI.Realm][vUI.User]) then
		vUIProfileData[vUI.Realm][vUI.User] = self:GetMostUsedProfile()
	end
end

function Profiles:AddProfile(profile)
	if (type(profile) ~= "table") then
		return
	end
	
	local Name = profile["profile-name"]
	
	-- Do I overwrite the imported profiles metadata with new stuff for the player?
	
	if (Name and not vUIProfiles[Name]) then
		vUIProfiles[Name] = profile
		self.List[Name] = Name
		
		vUI:SendAlert(Language["Import successful"], format(Language["New profile: %s"], Name))
	else
		vUI:print(format('A profile already exists with the name "%s."', Name))
	end
end

function Profiles:CreateProfile(name)
	if (not vUIProfiles) then
		vUIProfiles = {}
	end
	
	if (not vUIProfileData) then
		vUIProfileData = {}
		vUIProfileData[vUI.Realm] = {}
	end
	
	if (not name) then
		name = self:GetDefaultProfileKey()
	end
	
	if (not vUIProfileData[vUI.Realm][vUI.User]) then
		vUIProfileData[vUI.Realm][vUI.User] = name
	end
	
	if vUIProfiles[name] then
		self.List[name] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
	
	-- Some metadata just for some additional information
	vUIProfiles[name]["profile-name"] = name
	vUIProfiles[name]["profile-created"] = GetCurrentDate()
	vUIProfiles[name]["profile-created-by"] = self:GetDefaultProfileKey()
	vUIProfiles[name]["profile-last-modified"] = GetCurrentDate()
	
	vUIProfileData[vUI.Realm][vUI.User] = name
	
	self.List[name] = name
	
	return vUIProfiles[name]
end

function Profiles:GetProfile(name)
	if vUIProfiles[name] then
		return vUIProfiles[name]
	else
		local Default = self:GetMostUsedProfile()
		
		if (not Default) then
			local Profile = self:CreateProfile("Default")
			
			return Profile
		elseif (Default and vUIProfiles[Default]) then
			return vUIProfiles[Default]
		end
	end
end

function Profiles:GetProfileList()
	return self.List
end

function Profiles:IsUsedBy(name)
	
end

function Profiles:GetMostUsedProfile() -- Return most used profile as a fallback instead of "Default" which may not even exist if the user deletes it
	local Temp = {}
	local HighestValue = 0
	local HighestName
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			Temp[ProfileName] = (Temp[ProfileName] or 0) + 1
		end
	end
	
	for Name, Value in pairs(Temp) do
		if (Value > HighestValue) then
			HighestValue = Value
			HighestName = Name
		end
	end
	
	return HighestName, vUIProfileData[HighestName]
end

function Profiles:GetNumServedBy(name)
	local Count = 0
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			if (ProfileName == name) then
				Count = Count + 1
			end
		end
	end
	
	return Count
end

function Profiles:DeleteProfile(name)
	if vUIProfiles[name] then
		vUIProfiles[name] = nil
		self.List[name] = nil
		
		local Default = self:GetMostUsedProfile()
		
		-- If we just wiped out a profile that characters were using, reroute them to a different profile for the time being.
		for Realm, Value in pairs(vUIProfileData) do
			for Player, ProfileName in pairs(Value) do
				if (ProfileName == name) then
					vUIProfileData[Realm][Player] = Default
				end
			end
		end
		
		vUI:print(format('Deleted profile "%s".', name))
	else
		vUI:print(format('No profile exists with the name "%s".', name))
	end
	
	if (self:GetProfileCount() == 0) then
		self:CreateProfile("Default") -- If we just deleted our last profile, make a new default.
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
	if Profile then
		for ID, Value in pairs(Profile) do
			Values[ID] = Value
		end
	end
	
	return Values
end

function Profiles:ApplyProfile(name)
	--[[if (not vUIProfiles[name]) then -- I think we're protected against this, and will manage default if needed?
		return
	end]]
	
	local Values = self:MergeWithDefaults(name)
	
	for ID, Value in pairs(Values) do
		Settings[ID] = Value
	end
	
	vUIProfileData[vUI.Realm][vUI.User] = name
	
	Values = nil
end

local UpdateProfile = function(value)
	if (value ~= Profiles:GetActiveProfileName()) then
		Profiles:SetActiveProfile(value)
		
		ReloadUI()
	end
end

local CreateProfile = function(value)
	Profiles:CreateProfile(value)
end

local DeleteProfile = function(value)
	Profiles:DeleteProfile(value)
end

local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local Encoder = LibCompress:GetAddonEncodeTable()

function Profiles:GetEncoded()
	local Profile = self:GetActiveProfile()
	local Serialized = AceSerializer:Serialize(Profile)
	local Compressed = LibCompress:Compress(Serialized)
	local Encoded = Encoder:Encode(Compressed)
	
	return Encoded
end

function Profiles:GetDecoded(encoded)
	local Decoded = Encoder:Decode(encoded)
	local Decompressed = LibCompress:Decompress(Decoded)
	local Message, Deserialized = AceSerializer:Deserialize(Decompressed)
	
	if (not Message) then
		vUI:print("Failure deserializing.")
	else
		return Deserialized
	end
end

-- Test
local TestProfileString = function()
	local Profile = Profiles:GetActiveProfile()
	
	local Result = AceSerializer:Serialize(Profile)
	local Compressed = LibCompress:Compress(Result)
	local Encoded = Encoder:Encode(Compressed)
	
	local Decoded = Encoder:Decode(Encoded)
	local Decompressed = LibCompress:Decompress(Decoded)
	local Success, Value = AceSerializer:Deserialize(Decompressed)
	
	if Success then
		print("Success", Value["ui-display-dev-tools"])
		
		-- Merge values into settings
	else
		print(Value) -- Error
	end
end

__testSerialize = function() -- /run __testSerialize()
	TestProfileString()
end

local ShowExportWindow = function()
	local Readable = Profiles:GetEncoded()
	
	GUI:CreateExportWindow()
	GUI:SetExportWindowText(Readable)
	GUI:ToggleExportWindow()
end

local ShowImportWindow = function()
	GUI:CreateImportWindow()
	GUI:ToggleImportWindow()
end

GUI:AddOptions(function(self)
	local Left, Right = self:NewWindow(Language["Profiles"])
	
	Left:CreateHeader(Language["Profiles"])
	Left:CreateDropdown("ui-profile", Profiles:GetActiveProfileName(), Profiles:GetProfileList(), Language["Set Profile"], "", UpdateProfile)
	
	Left:CreateHeader(Language["Modify"])
	Left:CreateInputWithButton("profile-key", Profiles:GetDefaultProfileKey(), "Create", "Create New Profile", "", CreateProfile)
	Left:CreateInputWithButton("profile-delete", Profiles:GetDefaultProfileKey(), "Delete", "Delete Profile", "", DeleteProfile)
	
	Left:CreateHeader("Sharing is caring")
	Left:CreateButton("Import", "Import A Profile", "", ShowImportWindow)
	Left:CreateButton("Export", "Export Current Profile", "", ShowExportWindow)
	
	Right:CreateHeader("What is a profile?")
	Right:CreateLine("Profiles store your settings so that you can easily")
	Right:CreateLine("and quickly change between configurations.")
	
	local Name = Profiles:GetActiveProfileName()
	local Profile = Profiles:GetProfile(Name)
	
	if (Profile and not Profile["profile-created-by"]) then
		Profile["profile-created-by"] = UNKNOWN
	end
	
	Right:CreateHeader(Language["Info"])
	Right:CreateDoubleLine("Current Profile:", Name)
	Right:CreateDoubleLine("Created By:", Profile["profile-created-by"])
	Right:CreateDoubleLine("Created On:", IsToday(Profile["profile-created"]))
	Right:CreateDoubleLine("Last Modified:", IsToday(Profile["profile-last-modified"]))
	Right:CreateDoubleLine("Modifications:", Profiles:CountChangedValues(Name))
	Right:CreateDoubleLine("Serving Characters:", Profiles:GetNumServedBy(Name))
	
	Right:CreateHeader(Language["General"])
	Right:CreateDoubleLine("Popular Profile:", Profiles:GetMostUsedProfile())
	Right:CreateDoubleLine("Stored Profiles:", Profiles:GetProfileCount())
	
	Left:CreateFooter()
	Right:CreateFooter()
end)