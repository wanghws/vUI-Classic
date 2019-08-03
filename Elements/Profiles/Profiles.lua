local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local DefaultKey = "%s-%s"
local pairs = pairs
local date = date
local match = string.match

Profiles.List = {}

--[[
	To do:
	
	Profiles:CopyProfile(from, to)
--]]

Profiles.Metadata = {
	["profile-name"] = true,
	["profile-created"] = true,
	["profile-created-by"] = true,
	["profile-last-modified"] = true,
}

-- Some settings shouldn't be sent to others
Profiles.Preserve = {
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

function Profiles:GetCurrentDate()
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

function Profiles:UpdateProfileInfo()
	local Name = Profiles:GetActiveProfileName()
	local Profile = Profiles:GetProfile(Name)
	local MostUsed = Profiles:GetMostUsedProfile()
	local NumServed, IsAll = Profiles:GetNumServedBy(Name)
	local NumEmpty = Profiles:CountEmptyProfiles()
	local NumUnused = Profiles:CountUnusedProfiles()
	local MostUsedServed = NumServed
	
	if IsAll then
		NumServed = format("%d (%s)", NumServed, Language["All"])
	end
	
	if (Profile ~= MostUsed) then
		MostUsedServed = Profiles:GetNumServedBy(MostUsed)
	end
	
	GUI:GetWidgetByWindow(Language["Profiles"], "current-profile").Right:SetText(Name)
	GUI:GetWidgetByWindow(Language["Profiles"], "created-by").Right:SetText(Profile["profile-created-by"])
	GUI:GetWidgetByWindow(Language["Profiles"], "created-on").Right:SetText(IsToday(Profile["profile-created"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "last-modified").Right:SetText(IsToday(Profile["profile-last-modified"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "modifications").Right:SetText(Profiles:CountChangedValues(Name))
	GUI:GetWidgetByWindow(Language["Profiles"], "serving-characters").Right:SetText(NumServed)
	
	GUI:GetWidgetByWindow(Language["Profiles"], "popular-profile").Right:SetText(format("%s (%d)", MostUsed, MostUsedServed))
	GUI:GetWidgetByWindow(Language["Profiles"], "stored-profiles").Right:SetText(Profiles:GetProfileCount())
	GUI:GetWidgetByWindow(Language["Profiles"], "empty-profiles").Right:SetText(NumEmpty)
	GUI:GetWidgetByWindow(Language["Profiles"], "unused-profiles").Right:SetText(NumUnused)
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
	return format(DefaultKey, vUI.UserName, vUI.UserRealm)
end

function Profiles:SetLastModified(name)
	local Profile = self:GetProfile(name)
	
	Profile["profile-last-modified"] = self:GetCurrentDate()
end

function Profiles:GetActiveProfileName() -- Will this ever be called in a case where it needs a fallback?
	if (vUIProfileData and vUIProfileData[vUI.UserRealm]) then
		if vUIProfileData[vUI.UserRealm][vUI.UserName] then
			return vUIProfileData[vUI.UserRealm][vUI.UserName]
		end
	end
end

function Profiles:GetActiveProfile()
	if (vUIProfileData and vUIProfileData[vUI.UserRealm]) then
		if vUIProfileData[vUI.UserRealm][vUI.UserName] then
			return self:GetProfile(vUIProfileData[vUI.UserRealm][vUI.UserName])
		end
	end
end

function Profiles:SetActiveProfile(name)
	if (vUIProfileData and vUIProfileData[vUI.UserRealm]) then
		if vUIProfileData[vUI.UserRealm][vUI.UserName] then
			vUIProfileData[vUI.UserRealm][vUI.UserName] = name
		end
	end
end

function Profiles:CountChangedValues(name)
	local Profile = self:GetProfile(name)
	local Count = 0
	
	for ID, Value in pairs(Profile) do
		if (not self.Metadata[ID]) then
			Count = Count + 1
		end
	end
	
	return Count
end

function Profiles:CreateProfileData()
	if (not vUIProfileData) then -- No profile data exists, create a default
		self:CreateProfile("Default")
	end
	
	if (not vUIProfileData[vUI.UserRealm]) then
		vUIProfileData[vUI.UserRealm] = {}
	end
	
	if (not vUIProfileData[vUI.UserRealm][vUI.UserName]) then
		vUIProfileData[vUI.UserRealm][vUI.UserName] = self:GetMostUsedProfile()
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
		vUIProfileData[vUI.UserRealm] = {}
	end
	
	if (not name) then
		name = self:GetDefaultProfileKey()
	end
	
	if (not vUIProfileData[vUI.UserRealm][vUI.UserName]) then
		vUIProfileData[vUI.UserRealm][vUI.UserName] = name
	end
	
	if vUIProfiles[name] then
		self.List[name] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
	
	-- Some metadata just for some additional information
	vUIProfiles[name]["profile-name"] = name
	vUIProfiles[name]["profile-created"] = self:GetCurrentDate()
	vUIProfiles[name]["profile-created-by"] = self:GetDefaultProfileKey()
	vUIProfiles[name]["profile-last-modified"] = self:GetCurrentDate()
	
	--vUIProfileData[vUI.UserRealm][vUI.UserName] = name
	
	self.List[name] = name
	
	return vUIProfiles[name]
end

function Profiles:RestoreToDefault(name) -- /run vUI:get(7):RestoreToDefault("Test")
	if (not vUIProfiles[name]) then
		return
	end
	
	for ID, Value in pairs(vUIProfiles[name]) do
		if (not self.Metadata[ID]) then
			vUIProfiles[name][ID] = nil
		end
	end
	
	vUI:print(format('Restored profile "%s" to default.', name))
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
	
	return vUI:print("Please report that this case happened: Profiles:GetProfile()")
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
	local Total = 0
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			if (ProfileName == name) then
				Count = Count + 1
			end
			
			Total = Total + 1
		end
	end
	
	return Count, (Count == Total)
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
		
		for Realm, Value in pairs(vUIProfileData) do
			for Player, ProfileName in pairs(Value) do
				vUIProfileData[Realm][Player] = "Default"
			end
		end
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
	
	vUIProfileData[vUI.UserRealm][vUI.UserName] = name
	
	Values = nil
end

function Profiles:DeleteEmptyProfiles() -- /run vUI:get(7):DeleteEmptyProfiles()
	local Count = 0
	local Deleted = 0
	
	for Name, Value in pairs(vUIProfiles) do
		Count = 0
		
		for ID in pairs(Value) do
			if (not self.Metadata[ID]) then
				Count = Count + 1
			end
		end
		
		if (Count == 0) then
			self:DeleteProfile(Name)
			
			Deleted = Deleted + 1
		end
	end
	
	vUI:print(format("Deleted %s empty profiles.", Deleted))
end

function Profiles:CountEmptyProfiles() -- /run print(vUI:get(7):CountEmptyProfiles())
	local Count = 0
	local Total = 0
	
	for Name, Value in pairs(vUIProfiles) do
		Count = 0
		
		for ID in pairs(Value) do
			if (not self.Metadata[ID]) then
				Count = Count + 1
			end
		end
		
		if (Count == 0) then
			Total = Total + 1
		end
	end
	
	return Total
end

function Profiles:DeleteUnusedProfiles() -- /run vUI:get(7):DeleteUnusedProfiles()
	local Counts = {}
	local Deleted = 0
	
	self:UpdateProfileList()
	
	for Name in pairs(self.List) do
		Counts[Name] = 0
	end
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			Counts[ProfileName] = Counts[ProfileName] + 1
		end
	end
	
	for Name, Total in pairs(Counts) do
		if (Total == 0) then
			self:DeleteProfile(Name)
			
			Deleted = Deleted + 1
		end
	end
	
	Counts = nil
	
	vUI:print(format("Deleted %s unused profiles.", Deleted))
end

function Profiles:CountUnusedProfiles() -- /run print(vUI:get(7):CountUnusedProfiles())
	local Counts = {}
	local Unused = 0
	
	self:UpdateProfileList()
	
	for Name in pairs(self.List) do
		Counts[Name] = 0
	end
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			Counts[ProfileName] = Counts[ProfileName] + 1
		end
	end
	
	for Name, Total in pairs(Counts) do
		if (Total == 0) then
			Unused = Unused + 1
		end
	end
	
	Counts = nil
	
	return Unused
end

function Profiles:RenameProfile(from, to) -- /run vUI:get(7):RenameProfile("Default", "vUI")
	local FromProfile = vUIProfiles[from]
	local ToProfile = vUIProfiles[to]
	
	if (not FromProfile) then
		return
	elseif ToProfile then
		vUI:print(format('A profile already exists with the name "%s".', to))
		
		return
	end
	
	vUIProfiles[to] = FromProfile
	vUIProfiles[to]["profile-name"] = to
	
	vUIProfiles[from] = nil
	self.List[from] = nil
	self.List[to] = to
	
	-- Reroute characters who used this profile
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			if (ProfileName == from) then
				vUIProfileData[Realm][Player] = to
			end
		end
	end
	
	-- Update dropdown menu if needed
	
	vUI:print(format('Profile "%s" has been renamed to "%s".', from, to))
end

function Profiles:SetMetadata(name, meta, value) -- /run vUI:get(7):SetMetadata("Default", "profile-created-by", "Hydra")
	if vUIProfiles[name] then
		if self.Metadata[meta] then
			vUIProfiles[name][meta] = value
		end
	end
end

local UpdateActiveProfile = function(value)
	if (value ~= Profiles:GetActiveProfileName()) then
		Profiles:SetActiveProfile(value)
		
		--ReloadUI()
		Profiles:UpdateProfileInfo()
	end
end

local CreateProfile = function(value)
	Profiles:CreateProfile(value)
	Profiles:UpdateProfileInfo()
end

local DeleteProfile = function(value)
	Profiles:DeleteProfile(value)
	Profiles:UpdateProfileInfo()
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
	local Encoded = Profiles:GetEncoded()
	
	GUI:CreateExportWindow()
	GUI:SetExportWindowText(Encoded)
	GUI:ToggleExportWindow()
end

local ShowImportWindow = function()
	GUI:CreateImportWindow()
	GUI:ToggleImportWindow()
end

local DeleteEmpty = function()
	Profiles:DeleteEmptyProfiles()
	Profiles:UpdateProfileInfo()
end

local DeleteUnused = function()
	Profiles:DeleteUnusedProfiles()
	Profiles:UpdateProfileInfo()
end

local RenameProfile = function(value)
	Profiles:UpdateProfileInfo()
end

local UpdateProfileInfo = function()
	Profiles:UpdateProfileInfo()
end

local RestoreToDefault = function()
	Profiles:RestoreToDefault(Profiles:GetActiveProfileName())
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Profiles"])
	
	Left:CreateHeader(Language["Profiles"])
	Left:CreateDropdown("ui-profile", Profiles:GetActiveProfileName(), Profiles:GetProfileList(), Language["Select Profile"], "", UpdateActiveProfile)
	--Left:CreateButton("Apply", "Apply Current Profile", "", UpdateActiveProfile)
	
	Left:CreateHeader(Language["Modify"])
	Left:CreateInput("profile-key", Profiles:GetDefaultProfileKey(), "Create New Profile", "", CreateProfile)
	Left:CreateInput("profile-delete", Profiles:GetDefaultProfileKey(), "Delete Profile", "", DeleteProfile)
	Left:CreateInput("profile-rename", "", "Rename Profile", "", RenameProfile)
	Left:CreateButton("Restore", "Restore To Default", "", RestoreToDefault):RequiresReload(true)
	Left:CreateButton("Delete", "Delete Empty Profiles", "", DeleteEmpty):RequiresReload(true)
	Left:CreateButton("Delete", "Delete Unused Profiles", "", DeleteUnused):RequiresReload(true)
	
	Left:CreateHeader("Sharing is caring")
	Left:CreateButton("Import", "Import A Profile", "", ShowImportWindow)
	Left:CreateButton("Export", "Export Current Profile", "", ShowExportWindow)
	
	Right:CreateHeader("What is a profile?")
	Right:CreateLine("Profiles store your settings so that you can easily")
	Right:CreateLine("and quickly change between configurations.")
	
	local Name = Profiles:GetActiveProfileName()
	local Profile = Profiles:GetProfile(Name)
	local MostUsed = Profiles:GetMostUsedProfile()
	local NumServed, IsAll = Profiles:GetNumServedBy(Name)
	local NumEmpty = Profiles:CountEmptyProfiles()
	local NumUnused = Profiles:CountUnusedProfiles()
	local MostUsedServed = NumServed
	
	if IsAll then
		NumServed = format("%d (%s)", NumServed, Language["All"])
	end
	
	if (Profile ~= MostUsed) then
		MostUsedServed = Profiles:GetNumServedBy(MostUsed)
	end
	
	Right:CreateHeader(Language["Info"])
	Right:CreateDoubleLine("Current Profile:", Name)
	Right:CreateDoubleLine("Created By:", Profile["profile-created-by"])
	Right:CreateDoubleLine("Created On:", IsToday(Profile["profile-created"]))
	Right:CreateDoubleLine("Last Modified:", IsToday(Profile["profile-last-modified"]))
	Right:CreateDoubleLine("Modifications:", Profiles:CountChangedValues(Name))
	Right:CreateDoubleLine("Serving Characters:", NumServed)
	
	Right:CreateHeader(Language["General"])
	Right:CreateDoubleLine("Popular Profile:", format("%s (%d)", MostUsed, MostUsedServed))
	Right:CreateDoubleLine("Stored Profiles:", Profiles:GetProfileCount())
	Right:CreateDoubleLine("Empty Profiles:", NumEmpty)
	Right:CreateDoubleLine("Unused Profiles:", NumUnused)
	
	Left:CreateFooter()
	Right:CreateFooter()
end)