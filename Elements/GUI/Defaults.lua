local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

-- These are just default values. Use the GUI to change settings.

-- UI
Defaults["ui-scale"] = 0.71111111111111 --vUI:GetSuggestedScale()
Defaults["ui-language"] = GetLocale()
Defaults["ui-display-welcome"] = true
Defaults["ui-display-dev-tools"] = false
Defaults["ui-display-whats-new"] = true

-- Media
Defaults["ui-picker-palette"] = "Default"
Defaults["ui-picker-format"] = "Hex"
Defaults["ui-picker-show-texture"] = true

Defaults["ui-style"] = "vUI"

Defaults["ui-header-font"] = "Roboto"
Defaults["ui-widget-font"] = "Roboto"
Defaults["ui-button-font"] = "Roboto"

Defaults["ui-header-texture"] = "Ferous"
Defaults["ui-widget-texture"] = "Ferous"
Defaults["ui-button-texture"] = "Ferous"

Defaults["ui-header-font-color"] = "FFE6C0"
Defaults["ui-header-texture-color"] = "616161"

Defaults["ui-window-bg-color"] = "424242"
Defaults["ui-window-main-color"] = "2B2B2B"

Defaults["ui-widget-color"] = "FFCE54"
Defaults["ui-widget-bright-color"] = "8E8E8E"
Defaults["ui-widget-bg-color"] = "424242"
Defaults["ui-widget-font-color"] = "FFFFFF"

Defaults["ui-button-font-color"] = "FFCE54"
Defaults["ui-button-texture-color"] = "616161"

Defaults["ui-highlight-texture"] = "Blank" -- TBI
Defaults["ui-highlight-color"] = "FFFFFF" -- TBI

-- Classes (populating retail colors as well) -- The commented colors are 10% darker, I like it better on some textures
Defaults["color-death-knight"] = "C41F3B" -- 7F222D
Defaults["color-demon-hunter"] = "A330C9" -- 922BB4
Defaults["color-druid"] = "FF7D0A" -- E56F08
Defaults["color-hunter"] = "ABD473" -- 98BD66
Defaults["color-mage"] = "40C7EB" -- 38B2D2
Defaults["color-monk"] = "00FF96" -- 00E586
Defaults["color-paladin"] = "F58CBA" -- DB7DA7
Defaults["color-priest"] = "FFFFFF" -- E5E5E5
Defaults["color-rogue"] = "FFF569" -- E5DB5D
Defaults["color-shaman"] = "0070DE" -- 0046C6
Defaults["color-warlock"] = "8787ED" -- 6969B8
Defaults["color-warrior"] = "C79C6E" -- B28B62

-- Power Types
Defaults["color-mana"] = "477CB2" -- 0000FF for the default mana color
Defaults["color-rage"] = "E53935" -- FF0000 ^
Defaults["color-energy"] = "FFEB3B" -- FFFF00 ^
Defaults["color-focus"] = "FF7F3F"
Defaults["color-fuel"] = "008C7F"
Defaults["color-insanity"] = "6600CC"
Defaults["color-holy-power"] = "F2E599"
Defaults["color-fury"] = "C842FC"
Defaults["color-pain"] = "FF9C00"
Defaults["color-runic-power"] = "00D1FF"
Defaults["color-chi"] = "B5FFEA"
Defaults["color-maelstrom"] = "007FFF"
Defaults["color-lunar-power"] = "4C84E5"
Defaults["color-arcane-charges"] = "1919F9"
Defaults["color-ammo-slot"] = "CC9900"
Defaults["color-soul-shards"] = "7F518C"
Defaults["color-runes"] = "7F7F7F"
Defaults["color-combo-points"] = "FFF468"

-- Reactions
Defaults["color-reaction-1"] = "BF4400" -- Hated
Defaults["color-reaction-2"] = "BF4400" -- Hostile
Defaults["color-reaction-3"] = "BF4400" -- Unfriendly
Defaults["color-reaction-4"] = "E5B200" -- Neutral
Defaults["color-reaction-5"] = "009919" -- Friendly
Defaults["color-reaction-6"] = "009919" -- Honored
Defaults["color-reaction-7"] = "009919" -- Revered
Defaults["color-reaction-8"] = "009919" -- Exalted

-- Zone PVP Types
Defaults["color-sanctuary"] = "68CCEF"
Defaults["color-arena"] = "FF1919"
Defaults["color-hostile"] = "FF1919"
Defaults["color-combat"] = "FF1919"
Defaults["color-friendly"] = "19FF19"
Defaults["color-contested"] = "FFB200"
Defaults["color-other"] = "FFECC1"

-- Debuff Types
Defaults["color-curse"] = "9900FF"
Defaults["color-disease"] = "996600"
Defaults["color-magic"] = "3399FF"
Defaults["color-poison"] = "009900"
Defaults["color-none"] = "CC0000"

-- Happiness
Defaults["color-happiness-1"] = "FF3333"
Defaults["color-happiness-2"] = "FFFF33"
Defaults["color-happiness-3"] = "66FF66"

-- Difficulty
Defaults["color-trivial"] = "9A9A9A"
Defaults["color-standard"] = "27AE60"
Defaults["color-difficult"] = "F1C40F"
Defaults["color-verydifficult"] = "E57A45"
Defaults["color-impossible"] = "FF4444"

-- Combo Points
Defaults["color-combo-1"] = "FF6666"
Defaults["color-combo-2"] = "FFB266"
Defaults["color-combo-3"] = "FFFF66"
Defaults["color-combo-4"] = "B2FF66"
Defaults["color-combo-5"] = "66FF66"

-- Other
Defaults["color-tapped"] = "A6A6A6"
Defaults["color-disconnected"] = "A6A6A6"

-- Action Bars
Defaults["action-bars-enable"] = true
Defaults["action-bars-layout"] = "DEFAULT"
Defaults["action-bars-show-hotkeys"] = true
Defaults["action-bars-button-size"] = 32
Defaults["action-bars-stance-size"] = 32
Defaults["action-bars-button-highlight"] = "Blank"
Defaults["action-bars-show-bottom-bg"] = true
Defaults["action-bars-show-side-bg"] = true
Defaults["action-bars-show-stance-bg"] = true
Defaults["action-bars-show-hotkeys"] = true
Defaults["action-bars-show-macro-names"] = true
Defaults["action-bars-show-count"] = true

-- Chat
Defaults["chat-enable"] = true
Defaults["chat-bg-opacity"] = 70
Defaults["chat-enable-url-links"] = true
Defaults["chat-enable-discord-links"] = true
Defaults["chat-enable-email-links"] = true
Defaults["chat-enable-friend-links"] = true
Defaults["chat-font"] = "PT Sans"
Defaults["chat-font-size"] = 12
Defaults["chat-font-flags"] = ""
Defaults["chat-tab-font"] = "Roboto"
Defaults["chat-tab-font-size"] = 12
Defaults["chat-tab-font-flags"] = ""
Defaults["chat-tab-font-color"] = "FFCE54" -- F1C40F
Defaults["chat-frame-width"] = 392
Defaults["chat-frame-height"] = 104

-- Experience
Defaults["experience-enable"] = true
Defaults["experience-display-level"] = false
Defaults["experience-display-progress"] = true
Defaults["experience-display-percent"] = true
Defaults["experience-show-tooltip"] = true
Defaults["experience-animate"] = true
Defaults["experience-width"] = 310
Defaults["experience-height"] = 16
Defaults["experience-position"] = "TOP"
Defaults["experience-progress-visibility"] = "ALWAYS"
Defaults["experience-percent-visibility"] = "ALWAYS"
Defaults["experience-bar-color"] = "7DB545" -- 1AE045
Defaults["experience-rested-color"] = "00B4FF"

-- Minimap
Defaults["minimap-enable"] = true
Defaults["minimap-size"] = 140

-- Cooldowns
Defaults["cooldowns-enable"] = true

-- Micro Buttons
Defaults["micro-buttons-show"] = false

-- Bags Frame
Defaults["bags-frame-show"] = true

-- Auto Repair
Defaults["auto-repair-enable"] = true

-- Unitframes
Defaults["unitframes-enable"] = true
Defaults["unitframes-player-show-name"] = false
Defaults["unitframes-player-cc-health"] = false
Defaults["unitframes-target-cc-health"] = false
Defaults["unitframes-player-castbar-y"] = 130
Defaults["unitframes-target-castbar-y"] = 156
Defaults["unitframes-player-x"] = 156
Defaults["unitframes-player-y"] = 156
Defaults["unitframes-target-x"] = 156
Defaults["unitframes-target-y"] = 156
Defaults["unitframes-class-color"] = true -- temporary

-- Name Plates
Defaults["nameplates-enable"] = true
Defaults["nameplates-width"] = 134
Defaults["nameplates-height"] = 14
Defaults["nameplates-cc-health"] = false
Defaults["nameplates-topleft-text"] = "[NameColor][Name14]"
Defaults["nameplates-topright-text"] = "[LevelColor][Level][Plus]"
Defaults["nameplates-bottomleft-text"] = "" -- [Classification]
Defaults["nameplates-bottomright-text"] = "[HealthColor][perhp]"
Defaults["nameplates-class-color"] = true -- temporary

-- Tooltips
Defaults["tooltips-enable"] = true
Defaults["tooltips-show-sell-value"] = true

-- Bags
Defaults["bags-loot-from-left"] = false