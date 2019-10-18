local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetNumFriends = C_FriendList.GetNumFriends
local GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfoByID = BNGetFriendInfoByID
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local Label = Language["Friends"]

local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local NumFriends = GetNumFriends()
	local NumOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local FriendInfo
	
	-- BNet Friends
	for i = 1, NumBNFriends do
		PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND = BNGetFriendInfoByID(i)
		
		if (PresenceID and IsOnline) then
			GameTooltip:AddDoubleLine(AccountName, CharacterName)
		end
	end
	
	for i = 1, NumFriends do
		FriendInfo = GetFriendInfoByIndex(i)
		
		if FriendInfo.connected then
			GameTooltip:AddDoubleLine(FriendInfo.name, FriendInfo.level)
		end
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local NumOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	
	local Online = NumOnline + NumBNOnline
	
	self.Text:SetFormattedText("%s: %s", Label, Online)
end

local OnEnable = function(self)
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", Update)
	--self:SetScript("OnEnter", OnEnter)
	--self:SetScript("OnLeave", Onleave)
	
	C_FriendList.ShowFriends()
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", nil)
	--self:SetScript("OnEnter", nil)
	--self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DT:SetType("Friends", OnEnable, OnDisable, Update)