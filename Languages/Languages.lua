local vUI, GUI, Language, Media, Settings = select(2, ...):get()
local rawget = rawget
local Locale

local index = function(self, key)
	if (Settings and Settings["ui-language"]) then
		Locale = Settings["ui-language"]
	else
		Locale = vUI.UserLocale
	end
	
	local Result = rawget(self, Locale)
	
	if (Result and Result[key]) then
		return Result[key]
	else
		return key
	end
	
	--[[if (self[Locale] and self[Locale][key]) then
		return self[Locale][key]
	else
		return key
	end]]
end

setmetatable(Language, {__index = index})