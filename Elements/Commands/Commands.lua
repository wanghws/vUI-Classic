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
		Commands["settings"]()
	end
end

SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = RunCommands

SLASH_GLOBALFIND1 = "/gfind"
SlashCmdList["GLOBALFIND"] = function(query)
	for Key, Value in pairs(_G) do
		if (Value and type(Value) == "string") then
			if Value:find(query) then
				print(format("|cffFFFF00%s|r |cffFFFFFF= %s|r", Key, Value))
			end
		end
	end
end