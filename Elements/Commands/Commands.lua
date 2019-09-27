local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Commands = function(msg)
	if (msg == "move") then
		vUI:GetModule("Move"):Toggle()
	elseif (msg == "help") then
		
	else
		GUI:Toggle()
	end
end

SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = Commands