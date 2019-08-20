local AddOn, Namespace = ...
local tonumber = tonumber
local tostring = tostring
local select = select
local sub = string.sub
local format = string.format
local floor = math.floor
local ceil = math.ceil
local min = math.min
local max = math.max
local type = type
local oldprint = print
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local vUI = CreateFrame("Frame")

vUI.Modules = {}

function vUI:NewModule(name, version)
	if self.Modules[name] then
		return self.Modules[name]
	end
	
	local Module = CreateFrame("Frame", name, UIParent)
	
	Module.Name = name
	Module.Version = version
	Module.Loaded = false
	
	self.Modules[name] = Module
	self.Modules[#self.Modules + 1] = Module
	
	return Module
end

function vUI:GetModule(name)
	if self.Modules[name] then
		return self.Modules[name]
	end
end

function vUI:LoadModule(name)
	if (not self.Modules[name]) then
		return
	end
	
	local Module = self.Modules[name]
	
	if (not Module.Loaded) and Module.Load then
		Module:Load()
		Module.Loaded = true
	end
end

function vUI:LoadModules(version)
	for i = 1, #self.Modules do
		if (not self.Modules[i].Version or self.Modules[i].Version == version) then
			if self.Modules[i].Load then
				self.Modules[i]:Load()
			end
		end
	end
end

function vUI:VARIABLES_LOADED(event) -- Migrate VARIABLES_LOADED from GUI to here eventually, unimportant now
	
end

function vUI:PLAYER_ENTERING_WORLD(event)
	self:LoadModules(self:GetClientVersion())
	
	self:UnregisterEvent(event)
end

-- Some Data
vUI.UIVersion = GetAddOnMetadata("vUI", "Version")
vUI.GameVersion = GetBuildInfo()
vUI.TOCVersion = select(4, GetBuildInfo())
vUI.UserName = UnitName("player")
vUI.UserClass = select(2, UnitClass("player"))
vUI.UserClassName = UnitClass("player")
vUI.UserRace = UnitRace("player")
vUI.UserRealm = GetRealmName()
vUI.UserFaction = UnitFactionGroup("player")
vUI.UserLocale = GetLocale()
vUI.UserProfileKey = format("%s:%s", vUI.UserName, vUI.UserRealm)
vUI.UserGoldKey = format("%s:%s:%s", vUI.UserName, vUI.UserRealm, vUI.UserFaction)

local vUIParent = CreateFrame("Frame", nil, UIParent)
vUIParent:SetSize(UIParent:GetWidth(), UIParent:GetHeight())
vUIParent:SetPoint("CENTER")

if (vUI.UserLocale == "enGB") then
	vUI.UserLocale = "enUS"
end

local Core = {
	[1] = vUI, -- Functions/Constants
	[2] = CreateFrame("Frame", nil, UIParent), -- GUI
	[3] = {}, -- Language
	[4] = {}, -- Media
	[5] = {}, -- Settings
	[6] = {}, -- Defaults
	[7] = {}, -- Profiles
}

Core[2].Queue = {}

Core[2].CreateWindow = function(self, name, func)
	-- add to a table by name where the function is run when the window is selected. After this and AddToWindow are run, flag for a sort
end

Core[2].AddToWindow = function(self, name, func)
	
end

Core[2].AddOptions = function(self, func)
	if (type(func) == "function") then
		tinsert(self.Queue, func)
	end
end

--[[
	Scale comprehension references:
	https://wow.gamepedia.com/UI_Scale
	https://www.reddit.com/r/WowUI/comments/95o7qc/other_how_to_pixel_perfect_ui_xpost_rwow/
	https://www.wowinterface.com/forums/showthread.php?t=31813
--]]

local Resolution = GetCurrentResolution()
local ScreenHeight
local Scale = 1

local GetScale = function(x)
	return Scale * x
end

function vUI:SetScale(x)
	x = max(0.64, x)
	x = min(8, x)
	
	UIParent:SetScale(x)
	--vUIParent:SetScale(x)
	
	Resolution = GetCurrentResolution()
	
	if (Resolution > 0) then
		vUI.ScreenResolution = select(Resolution, GetScreenResolutions())
		ScreenHeight = tonumber(string.match(vUI.ScreenResolution, "%d+x(%d+)"))
	else -- Windowed
		ScreenHeight = UIParent:GetHeight()
		vUI.ScreenResolution = UIParent:GetWidth().."x"..UIParent:GetHeight()
	end
	
	Scale = (768 / ScreenHeight) / x
	
	self.BackdropAndBorder.edgeSize = GetScale(x)
	self.Outline.edgeSize = GetScale(x)
end

function vUI:SetSuggestedScale()
	self:SetScale(self:GetSuggestedScale())
end

function vUI:GetSuggestedScale()
	return (768 / ScreenHeight)
end

-- Temporary so I can code on retail and disable Classic-only things
function vUI:IsClassic()
	return self.TOCVersion < 20000 and true or false
end

function vUI:GetClientVersion()
	return self.TOCVersion > 19999 and "Live" or "Classic"
end

function vUI:ShortValue(num)
	if (num >= 1000000) then
		return format("%.2fm", num / 1000000)
	elseif (num >= 1000) then
		return format("%dk", num / 1000)
	else
		return num
	end
end

vUI.Backdrop = {
	bgFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.BackdropAndBorder = {
	bgFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	edgeFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.Outline = {
	edgeFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

function vUI:HexToRGB(hex)
    return tonumber("0x"..sub(hex, 1, 2)) / 255, tonumber("0x"..sub(hex, 3, 4)) / 255, tonumber("0x"..sub(hex, 5, 6)) / 255
end

function vUI:RGBToHex(r, g, b)
	return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function vUI:RGBToHSV(r, g, b) -- https://www.rapidtables.com/convert/color/rgb-to-hsv.html
	local R = r / 255
	local G = g / 255
	local B = b / 255
	
	local Min = min(R, G, B)
	local Max = max(R, G, B)
end

function vUI:FormatTime(seconds)
	if (seconds >= 86400) then
		return format("%dd", ceil(seconds / 86400))
	elseif (seconds >= 3600) then
		return format("%dh", ceil(seconds / 3600))
	elseif (seconds >= 60) then
		return format("%dm", ceil(seconds / 60))
	elseif (seconds >= 60 / 12) then
		return floor(seconds)
	end
	
	return format("%.1fs", seconds)
end

function vUI:Reset() -- /run vUI:Reset()
	-- Create a prompt
	vUIProfiles = nil
	vUIProfileData = nil
	ReloadUI()
end

vUI.Delimiter = " "

print = function(...)
	local NumArgs = select("#", ...)
	local String = ""
	
	if (NumArgs == 0) then
		return
	elseif (NumArgs > 1) then
		for i = 1, NumArgs do
			if (i == 1) then
				String = tostring(select(i, ...))
			else
				String = String..vUI.Delimiter..tostring(select(i, ...))
			end
		end
		
		if vUI.FormatLinks then
			String = vUI.FormatLinks(String)
		end
		
		DEFAULT_CHAT_FRAME:AddMessage(String)
	else
		if vUI.FormatLinks then
			String = vUI.FormatLinks(tostring(...))
			
			DEFAULT_CHAT_FRAME:AddMessage(String)
		else
			DEFAULT_CHAT_FRAME:AddMessage(...)
		end
	end
end

function vUI:print(...)
	if Core[5]["ui-widget-color"] then
		print("|cFF"..Core[5]["ui-widget-color"].."vUI|r:", ...)
	else
		print("|cFF"..Core[6]["ui-widget-color"].."vUI|r:", ...)
	end
end

function Namespace:get(key)
	if (not key) then
		return Core[1], Core[2], Core[3], Core[4], Core[5], Core[6], Core[7]
	else
		return Core[key]
	end
end

local SetScaledHeight = function(self, height)
	self:SetHeight(GetScale(height))
end

local SetScaledWidth = function(self, width)
	self:SetWidth(GetScale(width))
end

local SetScaledSize = function(self, width, height)
	self:SetSize(GetScale(width), GetScale(height or width))
end

local SetScaledPoint = function(self, anchor1, parent, anchor2, x, y)
	if (type(parent) == "number") then parent = GetScale(parent) end
	if (type(anchor2) == "number") then anchor2 = GetScale(anchor2) end
	if (type(x) == "number") then x = GetScale(x) end
	if (type(y) == "number") then y = GetScale(y) end
	
	self:SetPoint(anchor1, parent, anchor2, x, y)
end

local SetTextColorHex = function(self, hex)
	self:SetTextColor(vUI:HexToRGB(hex))
end

-- Thank you Tukz for letting me use this script!
local AddMethods = function(object)
	local metatable = getmetatable(object).__index
	
	if (not object.SetScaledHeight) then metatable.SetScaledHeight = SetScaledHeight end
	if (not object.SetScaledWidth) then metatable.SetScaledWidth = SetScaledWidth end
	if (not object.SetScaledSize) then metatable.SetScaledSize = SetScaledSize end
	if (not object.SetScaledPoint) then metatable.SetScaledPoint = SetScaledPoint end
	
	if metatable.SetTextColor then object.SetTextColorHex = SetTextColorHex end
end

local Handled = {["Frame"] = true}

local Object = CreateFrame("Frame")
AddMethods(Object)
AddMethods(Object:CreateTexture())
AddMethods(Object:CreateFontString())

Object = EnumerateFrames()

while Object do
	if (not Handled[Object:GetObjectType()]) then
		AddMethods(Object)
		Handled[Object:GetObjectType()] = true
	end
	
	Object = EnumerateFrames(Object)
end

local OnEvent = function(self, event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end

vUI:RegisterEvent("VARIABLES_LOADED")
vUI:RegisterEvent("PLAYER_ENTERING_WORLD")
vUI:SetScript("OnEvent", OnEvent)

_G["vUI"] = Namespace