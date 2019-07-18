local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Default = GetLocale()
local Locale

if (Default == "enGB") then
	Default = "enUS"
end

local index = function(t, key)
	--local Key = vUIData and vUIData["ui-profile"] or "Default"
	
	--if (vUIProfiles and vUIProfiles[Key] and vUIProfiles[Key]["ui-language"]) then
	if (Settings and Settings["ui-language"]) then
		Locale = Settings["ui-language"]
	else
		Locale = Default
	end
	
	if t[Locale][key] then
		return t[Locale][key]
	else
		return key
	end
end

setmetatable(Language, {__index = index})