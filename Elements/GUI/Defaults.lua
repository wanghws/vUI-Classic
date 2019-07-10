local Settings = select(2, ...):get(5)

-- These are just default values. Use the GUI to change settings.

-- UI
Settings["ui-scale"] = 0.71
Settings["ui-display-welcome"] = true
Settings["ui-display-dev-tools"] = false

-- Media
Settings["ui-template"] = "vUI"

Settings["ui-header-font"] = "Roboto"
Settings["ui-widget-font"] = "Roboto"
Settings["ui-button-font"] = "Roboto"

Settings["ui-header-texture"] = "Ferous"
Settings["ui-widget-texture"] = "Ferous"
Settings["ui-button-texture"] = "Ferous"

Settings["ui-header-font-color"] = "FFE6C0"
Settings["ui-header-texture-color"] = "616161"

Settings["ui-window-bg-color"] = "424242"
Settings["ui-window-main-color"] = "2B2B2B"

Settings["ui-widget-color"] = "FFCE54"
Settings["ui-widget-bright-color"] = "8E8E8E"
Settings["ui-widget-bg-color"] = "424242"
Settings["ui-widget-font-color"] = "FFFFFF"

Settings["ui-button-font-color"] = "FFCE54"
Settings["ui-button-texture-color"] = "616161"

-- Chat
Settings["chat-enable"] = true
Settings["chat-bg-opacity"] = 70
Settings["chat-enable-url-links"] = true
Settings["chat-enable-discord-links"] = true
Settings["chat-enable-email-links"] = true
Settings["chat-enable-friend-links"] = true

-- Experience
Settings["experience-enable"] = true
Settings["experience-display-level"] = false
Settings["experience-display-progress"] = false
Settings["experience-display-percent"] = false
Settings["experience-animate"] = true
Settings["experience-width"] = 310
Settings["experience-height"] = 16
Settings["experience-position"] = "TOP"
Settings["experience-progress-visibility"] = "ALWAYS"
Settings["experience-percent-visibility"] = "ALWAYS"

-- Minimap
Settings["minimap-enable"] = true
Settings["minimap-size"] = 140