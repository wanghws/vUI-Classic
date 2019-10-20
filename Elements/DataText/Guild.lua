local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local select = select
local Label = Language["Guild"]

local Update = function(self)
	if (not IsInGuild()) then
		self.Text:SetText(Language["No Guild"])
	end
	
	local NumOnline = select(3, GetNumGuildMembers())
	
	if NumOnline then
		self.Text:SetFormattedText("%s: %s", Label, NumOnline)
	end
end

local OnEnable = function(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:SetScript("OnEvent", Update)
	
	GuildRoster()
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_GUILD_UPDATE")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:SetType("Guild", OnEnable, OnDisable, Update)