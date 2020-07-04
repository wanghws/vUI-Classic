local vUI, GUI, Language, Assets, Settings = select(2, ...):get()
--[[
local Languages = {
	["English"] = "enUS",
	["German"] = "deDE",
	["Spanish (Spain)"] = "esES",
	["Spanish (Mexico)"] = "esMX",
	["French"] = "frFR",
	["Italian"] = "itIT",
	["Korean"] = "koKR",
	["Portuguese (Brazil)"] = "ptBR",
	["Russian"] = "ruRU",
	["Chinese (Simplified)"] = "zhCN",
	["Chinese (Traditional)"] = "zhTW",
}

local UpdateLanguage = function(value)
	-- set override language cvar
end

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["General"])
	
	Right:CreateHeader(Language["Language"])
	Right:CreateDropdown("ui-language", vUI.UserLocale, Languages, Language["UI Language"], "", ReloadUI):RequiresReload(true)
	Right:CreateButton(Language["Contribute"], Language["Help Localize"], Language["Contribute"], function() vUI:print("") end)
end)
]]
--[[
local IconSize = 40
local IconHeight = floor(IconSize * 0.6)
local IconRatio = (1 - (IconHeight / IconSize)) / 2

local Icon = CreateFrame("Frame", nil, vUI.UIParent)
Icon:SetScaledPoint("CENTER")
Icon:SetScaledSize(IconSize, IconHeight)
Icon:SetBackdrop(vUI.Backdrop)
Icon:SetBackdropColor(0, 0, 0)

Icon.t = Icon:CreateTexture(nil, "OVERLAY")
Icon.t:SetScaledPoint("TOPLEFT", Icon, 1, -1)
Icon.t:SetScaledPoint("BOTTOMRIGHT", Icon, -1, 1)
Icon.t:SetTexture("Interface\\ICONS\\spell_warlock_soulburn")
Icon.t:SetTexCoord(0.1, 0.9, 0.1 + IconRatio, 0.9 - IconRatio)]]