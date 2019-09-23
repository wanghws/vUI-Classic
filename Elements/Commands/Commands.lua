local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = function()
	GUI:Toggle()
end