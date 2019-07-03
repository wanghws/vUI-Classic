local Language = select(2, ...):get(3)

local Default = GetLocale()
local Locale

if (Default == "enGB") then
	Default = "enUS"
end

local index = function(t, key)
	if (vUISettings and vUISettings["ui-language"]) then
		Locale = vUISettings["ui-language"]
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