local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString

local Update = function(self)
	self.Text:SetText(GetCoinTextureString(GetMoney()))
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", nil)
	
	self.Text:SetText("")
end

DT:Register("Gold", OnEnable, OnDisable, Update)