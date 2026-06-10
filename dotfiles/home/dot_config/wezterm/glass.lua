local wezterm = require 'wezterm'

-- Load the normal config first so existing keys/plugins/session restore still work.
local base_config = os.getenv('HOME') .. '/.config/wezterm/wezterm.lua'
local config = dofile(base_config)

-- Floating glass panel profile.
-- Launched via: ~/.local/bin/wezterm-glass
config.window_background_opacity = 0.0
config.macos_window_background_blur = 40
config.window_decorations = 'RESIZE'
config.enable_tab_bar = false
config.window_padding = {
  left = 18,
  right = 18,
  top = 14,
  bottom = 14,
}
config.initial_cols = 90
config.initial_rows = 24

config.colors = config.colors or {}
config.colors.foreground = '#f5f5f5'
config.colors.background = '#000000'

return config
