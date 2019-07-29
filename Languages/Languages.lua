local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Locale

local index = function(t, key)
	if (Settings and Settings["ui-language"]) then
		Locale = Settings["ui-language"]
	else
		Locale = vUI.UserLocale
	end
	
	if (t[Locale] and t[Locale][key]) then
		return t[Locale][key]
	else
		return key
	end
end

setmetatable(Language, {__index = index})