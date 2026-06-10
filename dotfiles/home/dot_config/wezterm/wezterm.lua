local wezterm = require 'wezterm'
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local config = wezterm.config_builder()

-- Let terminal apps that support enhanced keyboard protocols distinguish
-- Shift+Enter from plain Enter. This is the reliable modern multiline path.
config.enable_kitty_keyboard = true

-- WezTerm has no config field for suppressing a trailing newline on copy.
-- It already omits soft-wrap newlines; block selections avoid selecting the
-- physical line ending when that matters.

-- Auto-save state every 15 minutes
resurrect.state_manager.periodic_save()

-- Restore session automatically on launch
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

config.keys = {
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = act.SendKey { key = 'Enter', mods = 'SHIFT' },
  },
  -- Some shells/apps don't bind WezTerm's CSI End sequence (ESC [ 1 ; 1 F),
  -- which can leak as literal [1;1F. Ctrl-e is the portable end-of-line key.
  {
    key = 'End',
    mods = 'NONE',
    action = act.SendKey { key = 'e', mods = 'CTRL' },
  },
  -- Save current workspace state
  {
    key = 'w',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(
        resurrect.workspace_state.get_workspace_state()
      )
    end),
  },
  -- Save current window state
  {
    key = 'W',
    mods = 'ALT',
    action = resurrect.window_state.save_window_action(),
  },
  -- Save current tab state
  {
    key = 'T',
    mods = 'ALT',
    action = resurrect.tab_state.save_tab_action(),
  },
  -- Fuzzy load a saved state (workspace, window, or tab)
  {
    key = 'r',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)")
        id = string.match(id, "([^/]+)$")
        id = string.match(id, "(.+)%..+$")
        local opts = {
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.state_manager.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "window" then
          local state = resurrect.state_manager.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.state_manager.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
}

-- WezTerm's config model doesn't expose macOS/X1/X2 side mouse buttons as
-- bindable MouseButton values. If your mouse/driver emits horizontal wheel
-- events, these will switch tabs. For true side buttons, map them in the
-- mouse driver/BetterTouchTool/Hammerspoon to Cmd-Alt-Left/Right below.
config.mouse_bindings = {
  -- Make ordinary left-drag use rectangular/block selection, matching the
  -- default Option-drag behavior on macOS. This avoids copying indentation,
  -- prompt gutters, and hard line endings outside the highlighted rectangle.
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.SelectTextAtMouseCursor('Block'),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection('ClipboardAndPrimarySelection'),
  },
  {
    event = { Down = { streak = 1, button = { WheelLeft = 1 } } },
    mods = 'NONE',
    action = act.ActivateTabRelative(-1),
  },
  {
    event = { Down = { streak = 1, button = { WheelRight = 1 } } },
    mods = 'NONE',
    action = act.ActivateTabRelative(1),
  },
}

-- Stable target bindings for external mouse-button mappers.
table.insert(config.keys, {
  key = 'LeftArrow',
  mods = 'CMD|ALT',
  action = act.ActivateTabRelative(-1),
})
table.insert(config.keys, {
  key = 'RightArrow',
  mods = 'CMD|ALT',
  action = act.ActivateTabRelative(1),
})

return config
