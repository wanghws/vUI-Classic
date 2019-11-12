local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")
local Gold = vUI:GetModule("Gold")

local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local TrashValue = select(2, vUI:GetTrashValue())
	local ServerInfo, ServerTotalGold = Gold:GetServerInfo()
	local Gain, Loss = Gold:GetSessionStats()
	
	GameTooltip:AddLine(format("%s - %s", vUI.UserRealm, vUI.UserFaction))
	GameTooltip:AddLine(" ")
	
	if (#ServerInfo > 1) then
		GameTooltip:AddDoubleLine(Language["Total"], GetCoinTextureString(ServerTotalGold))
	end
	
	for i = 1, #ServerInfo do
		GameTooltip:AddDoubleLine(ServerInfo[i][1], GetCoinTextureString(ServerInfo[i][2]))
	end
	
	if ((Gain > 0) or (Loss > 0)) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Session"])
		
		if (Gain > Loss) then
			GameTooltip:AddDoubleLine(Language["Profit"], GetCoinTextureString(Gain))
		else
			GameTooltip:AddDoubleLine(Language["Loss"], GetCoinTextureString(Loss))
		end
	end
	
	if (TrashValue > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(Language["Trash item vendor value:"], GetCoinTextureString(TrashValue))
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	self.Text:SetText(GetCoinTextureString(GetMoney()))
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DT:SetType("Gold", OnEnable, OnDisable, Update)