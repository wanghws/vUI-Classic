local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local MinimapButtons = vUI:NewModule("Minimap Buttons")

MinimapButtons.items = {}

-- TODO: clean this list up
local MinimapButtonsBlacklist = {
	-- Blizzard
	["BattlefieldMinimap"] = true,
	["ButtonCollectFrame"] = true,
	["FeedbackUIButton"] = true,
	["GameTimeFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapTracking"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MinimapBackdrop"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["QueueStatusMinimapButton"] = true,
	["TimeManagerClockButton"] = true,
	["MiniMapTrackingFrame"] = true,

	-- Naughty AddOns
	["QuestieFrameGroup"] = true
}

local MinimapButtonTextureIdsToRemove = {
	[136430] = true,
	[136467] = true,
	[130924] = true,
}

local ResizeAndPosition = function(direction)
  local lastButton, width, height
  local panelTotalPadding = 6
  local numButtons = #MinimapButtons.items
  local spacing = Settings["minimap-buttonbar-buttonspacing"] or 1
  local buttonSize = Settings["minimap-buttonbar-buttonsize"] or 24
  local direction = direction or Settings["minimap-buttonbar-direction"] or "LEFT"

  if (direction == "UP" or direction == "DOWN") then
    width = buttonSize + panelTotalPadding
    height = (numButtons * buttonSize) + ((numButtons - 1) * spacing) + panelTotalPadding
  else
    width = (numButtons * buttonSize) + ((numButtons - 1) * spacing) + panelTotalPadding
    height = buttonSize + panelTotalPadding
  end

  MinimapButtons.Panel:SetScaledSize(width, height)

	for i, Button in pairs(MinimapButtons.items) do
    if (Button:IsShown()) then
      Button:SetScaledSize(buttonSize)
			Button:ClearAllPoints()

      if not lastButton then
        if (direction == "LEFT") then
          Button:SetScaledPoint("TOPRIGHT", MinimapButtons.Panel, -3, -3)
        end

        if (direction == "RIGHT") then
          Button:SetScaledPoint("TOPLEFT", MinimapButtons.Panel, 3, -3)
        end

        if (direction == "DOWN") then
          Button:SetScaledPoint("TOPLEFT", MinimapButtons.Panel, 3, -3)
        end

        if (direction == "UP") then
          Button:SetScaledPoint("BOTTOMRIGHT", MinimapButtons.Panel, -3, 3)
        end
      else
        if (direction == "LEFT") then
          Button:SetScaledPoint("RIGHT", lastButton, "LEFT", -spacing, 0)
        end

        if (direction == "RIGHT") then
          Button:SetScaledPoint("LEFT", lastButton, "RIGHT", spacing, 0)
        end

        if (direction == "DOWN") then
          Button:SetScaledPoint("TOP", lastButton, "BOTTOM", 0, -spacing)
        end

        if (direction == "UP") then
          Button:SetScaledPoint("BOTTOM", lastButton, "TOP", 0, spacing)
        end
			end

			lastButton = Button
		end
	end
end

function MinimapButtons:SkinButtons()
  for _, Child in ipairs({Minimap:GetChildren()}) do
		local name = Child:GetName()

		if name and not MinimapButtonsBlacklist[name] and Child:IsShown() then	
			for i = 1, Child:GetNumRegions() do
				local region = select(i, Child:GetRegions())
				
				if region:GetObjectType() == "Texture" then
					local t = region:GetTexture() or ""
					local texture = string.lower(t)
					local textureId = region:GetTextureFileID()

					if (textureId and MinimapButtonTextureIdsToRemove[textureId]) then
						region:SetTexture(nil)
					end

					if (
						string.find(texture, [[interface\characterframe]]) or
						string.find(texture, [[interface\minimap]]) or
						string.find(texture, 'border') or 
						string.find(texture, 'background') or 
						string.find(texture, 'alphamask') or
						string.find(texture, 'highlight')
					) then
						region:SetTexture(nil)
						region:SetAlpha(0)
					end
	
					region:ClearAllPoints()
					region:SetScaledPoint("TOPLEFT", Child, 1, -1)
					region:SetScaledPoint("BOTTOMRIGHT", Child, -1, 1)
					region:SetDrawLayer('ARTWORK')
					region:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				end	
			end

			Child.Backdrop = CreateFrame("Frame", nil, Child)
			Child.Backdrop:SetScaledPoint("TOPLEFT", Child, 0, 0)
			Child.Backdrop:SetScaledPoint("BOTTOMRIGHT", Child, 0, 0)
			Child.Backdrop:SetBackdrop(vUI.Backdrop)
			Child.Backdrop:SetBackdropColor(0, 0, 0)
			Child.Backdrop:SetFrameLevel(Child:GetFrameLevel() - 1)
			
			Child.Backdrop.Texture = Child.Backdrop:CreateTexture(nil, "BACKDROP")
			Child.Backdrop.Texture:SetScaledPoint("TOPLEFT", Child.Backdrop, 1, -1)
			Child.Backdrop.Texture:SetScaledPoint("BOTTOMRIGHT", Child.Backdrop, -1, 1)
			Child.Backdrop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
			Child.Backdrop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))

			Child:SetFrameLevel(Minimap:GetFrameLevel() + 10)
			Child:SetFrameStrata(Minimap:GetFrameStrata())

			-- TODO: highlight state
      -- TODO: pushed state
      -- TODO: tooltip styling

			table.insert(self.items, Child)
		end
	end
end

function MinimapButtons:CreatePanel()
  local Panel = CreateFrame("Frame", "vUI Minimap Buttons", UIParent)
	Panel:SetBackdrop(vUI.BackdropAndBorder)
	Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Panel:SetBackdropBorderColor(0, 0, 0)
  Panel:SetFrameStrata("LOW")
  Panel:SetScaledPoint("TOPRIGHT", _G["vUI Minimap"], "TOPLEFT", -6, 0)

  self.Panel = Panel
end

function MinimapButtons:Load()
  if (not Settings["minimap-buttonbar-enable"]) then
    return
  end

  self:SkinButtons()	
  self:CreatePanel()
  
  ResizeAndPosition()

  Move:Add(self.Panel)
end

-- TODO: see if we want to tie into PLAYER_ENTERING_WORLD or anything
MinimapButtons:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)


GUI:AddOptions(function(self)
  -- TODO: how can I reference an existing window?
	local Left, Right = self:CreateWindow(Language["Minimap Buttons"])

	Left:CreateHeader(Language["Minimap Buttons"])
	Left:CreateSwitch("minimap-buttonbar-enable", Settings["minimap-buttonbar-enable"], "Enable Minimap Button Bar", "Skin and move Minimap Buttons into a bar", ReloadUI):RequiresReload(true)
  Left:CreateDropdown("minimap-buttonbar-direction", Settings["minimap-buttonbar-direction"], { ["Up"] = "UP", ["Down"] = "DOWN", ["Left"] = "LEFT", ["Right"] = "RIGHT"}, "Button bar direction", "", ResizeAndPosition)
  Left:CreateSlider("minimap-buttonbar-buttonsize", Settings["minimap-buttonbar-buttonsize"], 16, 44, 1, "Button Size", "", ResizeAndPosition)
  Left:CreateSlider("minimap-buttonbar-buttonspacing", Settings["minimap-buttonbar-buttonspacing"], 1, 3, 1, "Button Spacing", "", ResizeAndPosition)

	Left:CreateFooter()
end)