local vUI, GUI, Language, Media, Settings = select(2, ...):get()

--[[PlayerFrame.Show = function() end
PlayerFrame:Hide()

TargetFrame.Show = function() end
TargetFrame:Hide()
]]
local RestylePlayer = function()
	if PlayerFrame then
		
	end
end

local Temp = CreateFrame("Frame")
Temp:RegisterEvent("PLAYER_ENTERING_WORLD")
Temp:SetScript("OnEvent", function(self)
	RestylePlayer()
end)