local Defaults = select(2, ...):get(6)

-- These are just default values. Use the GUI to change settings.

-- UI
Defaults["ui-scale"] = 71.11111
Defaults["ui-display-welcome"] = true
Defaults["ui-display-dev-tools"] = false
Defaults["ui-display-whats-new"] = true

-- Media
Defaults["ui-picker-palette"] = "Default" -- Media:GetPaletteList()
Defaults["ui-picker-format"] = "Hex" -- Hex/RGB/(HSV?)

Defaults["ui-template"] = "vUI"

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

-- Action Bars
Defaults["action-bars-enable"] = true
Defaults["action-bars-layout"] = "COMPACT"
Defaults["action-bars-show-hotkeys"] = true
Defaults["action-bars-button-size"] = 32
Defaults["action-bars-button-highlight"] = "Blank"

-- Chat
Defaults["chat-enable"] = true
Defaults["chat-bg-opacity"] = 70
Defaults["chat-enable-url-links"] = true
Defaults["chat-enable-discord-links"] = true
Defaults["chat-enable-email-links"] = true
Defaults["chat-enable-friend-links"] = true

-- Experience
Defaults["experience-enable"] = true
Defaults["experience-display-level"] = false
Defaults["experience-display-progress"] = false
Defaults["experience-display-percent"] = false
Defaults["experience-animate"] = true
Defaults["experience-width"] = 310
Defaults["experience-height"] = 16
Defaults["experience-position"] = "TOP"
Defaults["experience-progress-visibility"] = "ALWAYS"
Defaults["experience-percent-visibility"] = "ALWAYS"

-- Minimap
Defaults["minimap-enable"] = true
Defaults["minimap-size"] = 140