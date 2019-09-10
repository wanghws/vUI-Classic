local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

local Announcements = vUI:NewModule("Announcements")
local EventType, SourceGUID, DestName, CastID, CastName, SpellID, SpellName
local InterruptMessage = ACTION_SPELL_INTERRUPT .. " %s's %s."
local DispelledMessage = ACTION_SPELL_DISPEL .. " %s's %s."
local StolenMessage = ACTION_SPELL_STOLEN .. " %s's %s."
local CastMessage = "casts %s on %s."
local UNKNOWN = UNKNOWN
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local SendChatMessage = SendChatMessage
local UnitIsFriend = UnitIsFriend
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty
local UnitExists = UnitExists
local UnitName = UnitName
local GetNumGroupMembers = GetNumGroupMembers
local format = format
local MyGUID = UnitGUID("player")
local PetGUID = ""
local _

Announcements.Spells = {
	--[49576] = CastMessage, -- Death Grip
}

function Announcements:GetChannelToSend()
	if UnitInRaid("player") then
		return "RAID"
	elseif UnitInParty("player") then
		return "PARTY"
	else
		return "EMOTE"
	end
end

Announcements.Events = {
	["SPELL_INTERRUPT"] = function(destName, spellID, spellName)
		SendChatMessage(format(InterruptMessage, destName, spellName), "EMOTE")
	end,
	
	--[[["SPELL_DISPEL"] = function(destName, spellID, spellName)
		if (not UnitIsFriend("player", destName)) then
			SendChatMessage(format(DispelledMessage, destName, spellName), "EMOTE")
		end
	end,]]
	
	["SPELL_STOLEN"] = function(destName, spellID, spellName)
		SendChatMessage(format(StolenMessage, destName, spellName), "EMOTE")
	end,
	
	--[[["SPELL_CAST_SUCCESS"] = function(destName, _, _, spellID, spellName)
		if Spells[spellID] then
			SendChatMessage(format(Spells[spellID], spellID, spellName, destName), "EMOTE")
		end
	end,]]
}

function Announcements:COMBAT_LOG_EVENT_UNFILTERED()
	_, EventType, _, SourceGUID, _, _, _, _, DestName, _, _, CastID, CastName, _, SpellID, SpellName = CombatLogGetCurrentEventInfo()
	
	if (not self.Events[EventType]) then
		return
	end
	
	if (SourceGUID == MyGUID or SourceGUID == PetGUID) then
		self.Events[EventType](DestName, SpellID, SpellName, CastID, CastName)
	end
end

function Announcements:GROUP_ROSTER_UPDATE()
	if (GetNumGroupMembers() > 0) then
		if (not self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")) then
			self:UNIT_PET("player")
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	elseif self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function Announcements:UNIT_PET(owner)
	if (owner ~= "player") then
		return
	end
	
	if (UnitExists("pet") and UnitName("pet") ~= UNKNOWN) then
		PetGUID = UnitGUID("pet")
	end
end

local OnEvent = function(self, event, arg)
	self[event](self, arg)
end

function Announcements:Load()
	self:GROUP_ROSTER_UPDATE()
	self:UNIT_PET("player")
	
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent", OnEvent)
end