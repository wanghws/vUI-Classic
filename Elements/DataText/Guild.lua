local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local select = select

local Update = function(self)
	if (not IsInGuild) then
		self.Text:SetText(Language["No Guild"])
	end
	
	local NumOnline = select(3, GetNumGuildMembers())
	
	if NumOnline then
		self.Text:SetFormattedText("%s: %s", Language["Guild"], NumOnline)
	end
end

local OnEnable = function(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:SetScript("OnEvent", Update)
	
	GuildRoster()
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Guild", OnEnable, OnDisable, Update)