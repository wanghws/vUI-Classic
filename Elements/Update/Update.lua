local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local tonumber = tonumber
local match = string.match
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local UnitInBattleground = UnitInBattleground
local UnitName = UnitName
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local User = UnitName("player")
local AddOnVersion = tonumber(vUI.Version)

local Update = CreateFrame("Frame")

-- We only store information on the previous 5-10 versions
local RecentVersions = {
	[1] = "Minor",
	[1.01] = "Minor",
}

local WhatsNew = {
	[1] = {
		"You installed vUI!"
	},
	[1.01] = {
		"Alert frames",
		"Version check module",
	},
}

local GetRecentVersionTypes = function(compare)
	local Major = 0
	
	for Version, Importance in pairs(RecentVersions) do
		if (Version > compare) then
			if (Importance == "Major") then
				Major = Major + 1
			end
		end
	end
	
	return Major
end

-- To be implemented. Add something here like a link or whatever to update.
local OnMouseUp = function()
	
end

-- Make a frame to display "What's new" list.

Update["PLAYER_ENTERING_WORLD"] = function(self, event)
	if self.NewVersion then
		vUI:SendAlert("What's new?", "Click here to learn more")
		
		self.NewVersion = true
	end
	
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
	
	if IsInGroup() then
		if IsInRaid() then
			SendAddonMessage("vUI-Version", AddOnVersion, "RAID")
		else
			SendAddonMessage("vUI-Version", AddOnVersion, "PARTY")
		end
	end
	
	if UnitInBattleground("player") then
		SendAddonMessage("vUI-Version", AddOnVersion, "BATTLEGROUND")
	end
	
	--self:UnregisterEvent(event)
end

-- /run vUISettings.Version = 1 -- Leaving this here for a while so I can reset version manually for testing.
Update["VARIABLES_LOADED"] = function(self, event)
	if (not vUISettings) then
		vUISettings = {}
	end
	
	if (not vUISettings.Version) then
		vUISettings.Version = AddOnVersion
	end
	
	local StoredVersion = vUISettings.Version
	
	-- You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if WhatsNew[AddOnVersion] then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end
	
	-- Store a new version if needed.
	if (StoredVersion ~= AddOnVersion) then
		vUISettings.Version = AddOnVersion
	end
	
	self:UnregisterEvent(event)
end

Update["CHAT_MSG_ADDON"] = function(self, event, prefix, message, channel, sender)
	if (prefix == "vUI-Version") then
		if (match(sender, "(%S+)-%S+") ~= User) then
			local SenderVersion = tonumber(message)
			
			if (AddOnVersion > SenderVersion) then -- They're behind, not us. Let them know what version you have, and if theres been major updates since their version.
				local Count = GetRecentVersionTypes(SenderVersion)
				
				SendAddonMessage("vUI-Version-Detailed", format("%s:%d", AddOnVersion, Count), "WHISPER", sender)
			end
		end
	elseif (prefix == "vUI-Version-Detailed") then -- Someone is sending us more detailed information because we were behind.
		if (match(sender, "(%S+)-%S+") ~= User) then
			local Version, Major = match(message, "(%S+):(%S+)")
			
			Major = tonumber(Major)
			
			if (Major > 0) then
				vUI:SendAlert("New Version!", format("Update to version |cff%s%s|r!", Settings["ui-header-font-color"], Version), format("Includes ~|cff%s%s|r major updates.", Settings["ui-header-font-color"], Major), OnMouseUp, true)
			else
				vUI:SendAlert("New Version!", format("Update to version |cff%s%s|r!", Settings["ui-header-font-color"], Version), nil, OnMouseUp, true)
			end
			
			self:UnregisterEvent(event)
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
C_ChatInfo.RegisterAddonMessagePrefix("vUI-Version-Detailed")

__updatetest = function() -- /run __updatetest()
	vUI:SendAlert("New Version!", format("Update to version |cff%s%s|r", Settings["ui-header-font-color"], 1.04), format("Includes ~|cff%s%s|r major updates.", Settings["ui-header-font-color"], 2), OnMouseUp, true)
end