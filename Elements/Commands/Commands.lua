local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	vUI:GetModule("Move"):Toggle()
end

Commands["help"] = function()
	print("...")
end

Commands["settings"] = function()
	GUI:Toggle()
end

local RunCommands = function(msg)
	if Commands[msg] then
		Commands[msg]()
	else
		GUI:Toggle()
	end
end

SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = RunCommands