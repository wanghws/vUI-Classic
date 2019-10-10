local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetNumFriends = C_FriendList.GetNumFriends
local GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local BNGetNumFriends = BNGetNumFriends

local Update = function(self)
	local NumFriends = GetNumFriends()
	local NumOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	
	local Total = NumFriends + NumBNFriends
	local Online = NumOnline + NumBNOnline
	
	self.Text:SetFormattedText("%s: %s", Language["Friends"], Online)
end

local OnEnable = function(self)
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", Update)
	
	C_FriendList.ShowFriends()
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Friends", OnEnable, OnDisable, Update)