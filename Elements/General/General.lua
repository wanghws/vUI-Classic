local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Throttle = vUI:GetModule("Throttle")

local HasPrinted = false
local DevTools = Language["|Hcommand:/reload|h|cFF%s[Reload UI]|r|h |Hcommand:/eventtrace|h|cFF%s[Event Trace]|r|h |Hplayer:%s|h|cFF%s[Whisper Self]|r|h |Hcommand:/framestack|h|cFF%s[Frame Stack]|r|h"]

local UpdateDisplayDevTools = function()
	if (not HasPrinted) then
		local Color = Settings["ui-widget-color"]
		local Name = UnitName("player")
		
		print(format(DevTools, Color, Color, Name, Color, Color))
		
		HasPrinted = true
	end
end

local Languages = {
	["English"] = "enUS",
	--[[["German"] = "deDE",
	["Spanish (Spain)"] = "esES",
	["Spanish (Mexico)"] = "esMX",
	["French"] = "frFR",
	["Italian"] = "itIT",
	["Korean"] = "koKR",
	["Portuguese (Brazil)"] = "ptBR",
	["Russian"] = "ruRU",
	["Chinese (Simplified)"] = "zhCN",
	["Chinese (Traditional)"] = "zhTW",]]
}

local UpdateUIScale = function(value)
	value = tonumber(value)
	
	vUI:SetScale(value)
end

local GetDiscordLink = function()
	if (not Throttle:Exists("get-discord-link")) then
		Throttle:Create("get-discord-link", 10)
	end
	
	if (not Throttle:IsThrottled("get-discord-link")) then
		vUI:print("Join our Discord community! https://discord.gg/BKzWPhT")
		
		Throttle:Start("get-discord-link")
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["General"])
	
	Left:CreateHeader(Language["Welcome"])
	Left:CreateCheckbox("ui-display-welcome", Settings["ui-display-welcome"], Language["Display Welcome Message"], "")
	Left:CreateCheckbox("ui-display-whats-new", Settings["ui-display-whats-new"], Language[ [[Display "What's New" Pop-ups]] ], "")
	Left:CreateCheckbox("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Chat Tools"], "", UpdateDisplayDevTools)
	
	Left:CreateHeader("Discord")
	Left:CreateButton("Get Link", "Join Discord", "", GetDiscordLink)
	
	--[[Right:CreateHeader(Language["Language"])
	Right:CreateDropdown("ui-language", vUI.UserLocale, Languages, Language["UI Language"], "", ReloadUI):RequiresReload(true)
	Right:CreateButton(Language["Contribute"], Language["Help Localize"], Language["Contribute"], function() vUI:print("") end)]]
	
	Right:CreateHeader(Language["Scale"])
	Right:CreateInput("ui-scale", Settings["ui-scale"], Language["Set UI Scale"], "", UpdateUIScale)
	--Right:CreateDoubleLine("Suggested Scale:", vUI:GetSuggestedScale())
	
	Left:CreateFooter()
	Right:CreateFooter()
	
	if Settings["ui-display-welcome"] then
		local Color1 = Settings["ui-widget-color"]
		local Color2 = Settings["ui-header-font-color"]
		
		print(format(Language["Welcome to |cFF%svUI|r version |cFF%s%s|r."], Color1, Color2, vUI.UIVersion))
		print(format(Language["Type |cFF%s/vui|r to access the console for settings, or click |cFF%s|Hcommand:/vui|h[here]|h|r."], Color1, Color1))
		
		-- May as well put this here for now too.
		if Settings["ui-display-dev-tools"] then
			local Name = UnitName("player")
			
			print(format(DevTools, Color1, Color1, Name, Color1, Color1))
			
			HasPrinted = true
		end
	end
end)