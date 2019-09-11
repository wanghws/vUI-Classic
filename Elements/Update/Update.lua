local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local tonumber = tonumber
local match = string.match
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local UnitInBattleground = UnitInBattleground
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

-- Use a button in GUI to request newer versions? -- Put a pretty hard throttle on the button too so it can't be smashed.
-- vUI:print("If any version data is recieved, you will be prompted.")

local AddOnVersion = tonumber(vUI.UIVersion)

if (vUI.UserName == "Hydrazine") then
	AddOnVersion = 9999
end

local Update = CreateFrame("Frame")

-- We'll only store information on the previous 5-10 versions
local RecentVersions = { -- I guess I only need to put major versions in here, minor versions are ignored anyways
	--[1.01] = "Minor",
}

--[[local WhatsNew = {
	[1.01] = {
		"Alert frames",
		"Version check module",
	},
}
]]
local GetRecentMajorVersion = function(compare)
	local Major = 0
	
	for Version, Importance in pairs(RecentVersions) do
		if ((Version > compare) and (Importance == "Major")) then
			Major = Major + 1
		end
	end
	
	return Major
end

-- Make a frame to display a simple "What's new" list.
local WhatsNewOnMouseUp = function()
	
end

-- To be implemented. Add something here like a link or whatever to update.
local UpdateOnMouseUp = function()
	vUI:print("You can get an updated version of vUI here at https://www.curseforge.com/wow/addons/vui or by using the Twitch desktop app")
end

Update["PLAYER_ENTERING_WORLD"] = function(self, event)
	--[[if self.NewVersion then
		vUI:SendAlert("What's new?", "Click here to learn more", nil, WhatsNewOnMouseUp, true)
		
		self.NewVersion = false
	end]]
	
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
	
	if IsInRaid() then
		SendAddonMessage("vUI-Version", AddOnVersion, "RAID")
	elseif IsInGroup() then
		SendAddonMessage("vUI-Version", AddOnVersion, "PARTY")
	end
	
	if UnitInBattleground("player") then
		SendAddonMessage("vUI-Version", AddOnVersion, "BATTLEGROUND")
	end
	
	--self:UnregisterEvent(event)
end

-- /run vUIData.Version = 1 -- Leaving this here for a while so I can reset version manually for testing.
Update["VARIABLES_LOADED"] = function(self, event)
	if (not vUIData) then
		vUIData = {}
	end
	
	if (not vUIData.Version) then
		vUIData.Version = AddOnVersion
	end
	
	local StoredVersion = vUIData.Version
	
	--[[ You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if (WhatsNew[AddOnVersion] and Settings["ui-display-whats-new"]) then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end]]
	
	-- Store a new version if needed.
	if (StoredVersion ~= AddOnVersion) then
		vUIData.Version = AddOnVersion
	end
	
	self:UnregisterEvent(event)
end

local GetName = function(name)
	name = strsplit("-", name)
	
	return name
end

Update["CHAT_MSG_ADDON"] = function(self, event, prefix, message, channel, sender)
	if (match(sender, "(%S+)-%S+") == vUI.UserName) then
		return
	end
	
	if (prefix == "vUI-Version") then
		local SenderVersion = tonumber(message)
		
		if (channel == "WHISPER") then
			local Version, Major = match(message, "(%S+):(%S+)")
			Major = tonumber(Major)
			
			if (Major > 0) then
				--vUI:SendAlert("New Version", format("Update to version |cFF%s%s|r!", Settings["ui-header-font-color"], Version), format("Includes ~|cFF%s%s|r major updates.", Settings["ui-header-font-color"], Major), UpdateOnMouseUp, true)
				vUI:print(format("Update to version |cFF%s%s|r! (includes ~|cFF%s%s|r major updates) https://www.curseforge.com/wow/addons/vui", Settings["ui-header-font-color"], Version, Settings["ui-header-font-color"], Major))
			else
				--vUI:SendAlert("New Version", format("Update to version |cFF%s%s|r!", Settings["ui-header-font-color"], Version), nil, UpdateOnMouseUp, true)
				vUI:print(format("Update to version |cFF%s%s|r! https://www.curseforge.com/wow/addons/vui", Settings["ui-header-font-color"], Version))
			end
			
			self:UnregisterEvent(event)
		else
			if (AddOnVersion > SenderVersion) then -- They're behind, not us. Let them know what version you have, and if theres been major updates since their version.
				local Count = GetRecentMajorVersion(SenderVersion)
				local Message = format("%s:%d", AddOnVersion, Count)
				
				SendAddonMessage("vUI-Version", Message, "WHISPER", GetName(sender))
			end
		end
	end
end

Update:RegisterEvent("VARIABLES_LOADED")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end)

C_ChatInfo.RegisterAddonMessagePrefix("vUI-Version")