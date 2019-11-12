local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Gold = vUI:NewModule("Gold")

local GetMoney = GetMoney
local GetCoinText = GetCoinText -- amount, delim

function Gold:PLAYER_MONEY()
	
end

function Gold:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

Gold:RegisterEvent("LOOT_READY")
Gold:SetScript("OnEvent", Gold.OnEvent)