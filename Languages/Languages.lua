local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Default = GetLocale()
local Locale

if (Default == "enGB") then
	Default = "enUS"
end

local index = function(t, key)
	if (Settings and Settings["ui-language"]) then
		Locale = Settings["ui-language"]
	else
		Locale = Default
	end
	
	if (t[Locale] and t[Locale][key]) then
		return t[Locale][key]
	else
		return key
	end
end

setmetatable(Language, {__index = index})