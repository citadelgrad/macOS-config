local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Explicit size: the 12pt default is too small on the BenQ MA320U
-- (~93 logical pt/in). Cmd+= zoom is per window and lost on relaunch.
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 14.0

return config
