local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local DefaultKey = "%s-%s"
local pairs = pairs
local date = date

Profiles.List = {}

local Filter = {
	["profile-created"] = true,
	["profile-created-by"] = true,
	["profile-last-modified"] = true,
}

local GetCurrentDate = function()
	--return date("%Y-%m-%d")
	return date("%Y-%m-%d %I:%M %p")
end

function Profiles:ImportProfiles()
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
	
	if vUIProfiles[name] then
		self.List[name] = name
		
		--vUIProfileData[vUI.Realm][vUI.User] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
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
		return vUIProfiles["Default"]
	end
end

function Profiles:GetProfileList()
	return self.List
end

function Profiles:IsUsedBy(name)
	
end

function Profiles:GetMostUsedProfile() -- Return most used profile as a fallback instead of "Default" which may not even exist if the user deletes it
	local Temp = {}
	
	for Realm, Value in pairs(vUIProfileData) do
		for Player, ProfileName in pairs(Value) do
			Temp[ProfileName] = (Temp[ProfileName] or 0) + 1
		end
	end
	
	local HighestValue = 0
	local HighestName
	
	for Name, Value in pairs(Temp) do
		if (Value > HighestValue) then
			HighestValue = Value
			HighestName = Name
		end
	end
	
	return HighestName
end

function Profiles:DeleteProfile(name)
	if vUIProfiles[name] then
		vUIProfiles[name] = nil
		self.List[name] = nil
		
		local Default = self:GetMostUsedProfile()
		
		-- If we just wiped out a profile that characters were using, reroute them to a different profile for the time being.
		for Realm, Value in pairs(vUIProfileData) do
			for Player, ProfileName in pairs(Values) do
				if (ProfileName == name) then
					vUIProfileData[Realm][Player] = Default
				end
			end
		end
		
		vUI:print(format('Deleted profile "%s".', name))
	else
		vUI:print(format('No profile exists with the name "%s".', name))
	end
end

function Profiles:MergeWithDefaults(name)
	local Values = {}
	
	-- Collect default values
	for ID, Value in pairs(Defaults) do
		Values[ID] = Value
	end
	
	-- And apply stored values
	for ID, Value in pairs(self:GetProfile(name)) do
		Values[ID] = Value
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
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local Debug = true

function Profiles:GetEncoded()
	--[[local Result = AceSerializer:Serialize(self:GetActiveProfile())
	local Compressed = LibCompress:Compress(Result)
	local Encoded = LibCompress:Encode7bit(Compressed)
	
	return Encoded]]
	
	local Serialized = AceSerializer:Serialize(self:GetActiveProfile())
	local Compressed = LibDeflate:CompressDeflate(Serialized)
	
	local Encoded = ""
	
	if Debug then
		Encoded = Encoded..LibDeflate:EncodeForPrint(Compressed)
	else
		--Encoded = Encoded..LibDeflate:EncodeForWoWAddonChannel(Compressed)
		Encoded = Encoded..LibDeflate:EncodeForWoWChatChannel(Compressed)
	end
	
	return Encoded
end

local UpdateProfileString = function()
	Profile = Profiles:GetActiveProfile()
	
	local Result = AceSerializer:Serialize(Profile)
	local Compressed = LibCompress:Compress(Result)
	local Encoded = LibCompress:Encode7bit(Compressed)
	
	local Decoded = LibCompress:Decode7bit(Encoded)
	local Decompressed = LibCompress:Decompress(Decoded)
	local Success, Value = AceSerializer:Deserialize(Decompressed)
	
	if Success then
		print("Woah, we did it.", Value["ui-display-dev-tools"])
		
		-- Merge values into settings
	else
		print(Value) -- Error
	end
end

local LineMax = 25

local sub = string.sub
local len = string.len
local concat = table.concat

local ConvertToLines = function(str)
	local Lines = {}
	local Subbed
	local Remaining = str
	local TotalLines = 0
	
	while (len(Remaining) > 0) do
		Subbed = sub(Remaining, 1, LineMax)
		Remaining = sub(Remaining, LineMax, len(Remaining))
		
		Lines[#Lines + 1] = Subbed
	end
	
	return Lines
end

local Temp = function()
	vUI:print("Dump this in a window:")
	local Encoded = Profiles:GetEncoded()
	
	local Lines = ConvertToLines(Encoded)
	--local Text = concat(Lines, "", 1, #Lines)
	
	--print(string.len(Lines[1]))
	
	print(Encoded)
	
	local Window = GUI:CreateProfileWindow()
	
	Window.Input:SetText(Encoded)
	Window.Input:HighlightText()

	GUI:ToggleProfileWindow()
	Window.Input:Show()
	
	Lines = nil
end

GUI:AddOptions(function(self)
	local Left, Right = self:NewWindow(Language["Profiles"])
	
	Left:CreateHeader(Language["Profiles"])
	Left:CreateDropdown("ui-profile", Profiles:GetActiveProfileName(), Profiles:GetProfileList(), Language["Set Profile"], "", UpdateProfile)
	
	Left:CreateHeader(Language["Modify"])
	Left:CreateInputWithButton("profile-key", "|cFF808080"..Profiles:GetDefaultProfileKey().."|r", "Create", "Create New Profile", "", CreateProfile)
	Left:CreateInputWithButton("profile-delete", "", "Delete", "Delete Profile", "", DeleteProfile)

	--local String = Profiles:GetEncoded()
	
	Left:CreateHeader("Sharing Is Caring")
	Left:CreateButton("Export", "Export Current Profile", "", Temp)
	Left:CreateButton("Import", "Import A Profile", "")
	
	Right:CreateHeader("What is a profile?")
	Right:CreateLine("Profiles store your settings so that you can easily")
	Right:CreateLine("and quickly change between configurations.")
	
	local Name = Profiles:GetActiveProfileName()
	local Profile = Profiles:GetProfile(Name)
	
	if (not Profile["profile-created-by"]) then
		Profile["profile-created-by"] = UNKNOWN
	end
	
	Right:CreateHeader(Language["Info"])
	Right:CreateDoubleLine("Current Profile:", Name)
	Right:CreateDoubleLine("Created By:", Profile["profile-created-by"])
	Right:CreateDoubleLine("Created On:", Profile["profile-created"])
	Right:CreateDoubleLine("Last Modified:", Profile["profile-last-modified"])
	Right:CreateDoubleLine("Modifications:", Profiles:CountChangedValues(Name))
	Right:CreateDoubleLine("Popular Profile:", Profiles:GetMostUsedProfile())
	Right:CreateDoubleLine("Stored Profiles:", Profiles:GetProfileCount())
	
	Left:CreateFooter()
	Right:CreateFooter()
end)