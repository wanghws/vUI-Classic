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
local vUI = {}

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

Core[2].AddOptions = function(self, func)
	if (type(func) == "function") then
		tinsert(self.Queue, func)
	end
end

local Resolution = select(GetCurrentResolution(), GetScreenResolutions())
local ScreenHeight = string.match(Resolution, "%d+x(%d+)")
local UIParentHeight = UIParent:GetHeight()
local Height = GetScreenHeight()

local Mult = 768 / Height / ((GetCVar("useUiScale") and GetCVar("uiScale") or 0.71))

local Scale = function(num)
	return Mult * floor(num / Mult + 0.5)
end

-- Some Data
vUI.Version = GetAddOnMetadata("vUI", "Version")
vUI.UserName = UnitName("player")
vUI.UserClass = select(2, UnitClass("player"))
vUI.UserClassName = UnitClass("player")
vUI.UserRace = UnitRace("player")
vUI.UserRealm = GetRealmName()
vUI.UserFaction = UnitFactionGroup("player")
vUI.UserLocale = GetLocale()
vUI.UserProfileKey = format("%s:%s", vUI.UserName, vUI.UserRealm)
vUI.UserGoldKey = format("%s:%s:%s", vUI.UserName, vUI.UserRealm, vUI.UserFaction)

if (vUI.UserLocale == "enGB") then
	vUI.UserLocale = "enUS"
end

vUI.Backdrop = {
	bgFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.BackdropAndBorder = {
	bgFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	edgeFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga",
	edgeSize = Scale(1),
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.Outline = {
	edgeFile = "Interface\\AddOns\\vUI\\Media\\Textures\\Blank.tga", edgeSize = Scale(1),
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
	
	if (NumArgs > 1) then
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
	print("|cFF"..Core[5]["ui-widget-color"].."vUI|r:", ...)
end

function Namespace:get(key)
	if (not key) then
		return Core[1], Core[2], Core[3], Core[4], Core[5], Core[6], Core[7]
	else
		return Core[key]
	end
end

local SetScaledHeight = function(self, height)
	self:SetHeight(Scale(height))
end

local SetScaledWidth = function(self, width)
	self:SetWidth(Scale(width))
end

local SetScaledSize = function(self, width, height)
	self:SetSize(Scale(width), Scale(height or width))
end

local SetScaledPoint = function(self, a1, p, a2, xoff, yoff)
	if (type(p) == "number") then p = Scale(p) end
	if (type(a2) == "number") then a2 = Scale(a2) end
	if (type(xoff) == "number") then xoff = Scale(xoff) end
	if (type(yoff) == "number") then yoff = Scale(yoff) end
	
	self:SetPoint(a1, p, a2, xoff, yoff)
end

-- Thank you Tukz for letting me use this script!
local AddMethods = function(object)
	local mt = getmetatable(object).__index
	
	if (not object.SetScaledHeight) then mt.SetScaledHeight = SetScaledHeight end
	if (not object.SetScaledWidth) then mt.SetScaledWidth = SetScaledWidth end
	if (not object.SetScaledSize) then mt.SetScaledSize = SetScaledSize end
	if (not object.SetScaledPoint) then mt.SetScaledPoint = SetScaledPoint end
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

_G["vUI"] = Namespace