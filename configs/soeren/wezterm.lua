local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 12
config.color_scheme = "Oxocarbon Dark (Gogh)"

config.leader = { key = "p", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "h", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "f", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "C", mods = "LEADER|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "Q", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{
		key = "R",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Tab name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "!", mods = "LEADER|SHIFT", action = act.ActivateTab(0) },
	{ key = '"', mods = "LEADER|SHIFT", action = act.ActivateTab(1) },
	{ key = "§", mods = "LEADER|SHIFT", action = act.ActivateTab(2) },
	{ key = "$", mods = "LEADER|SHIFT", action = act.ActivateTab(3) },
	{ key = "%", mods = "LEADER|SHIFT", action = act.ActivateTab(4) },
	{ key = "&", mods = "LEADER|SHIFT", action = act.ActivateTab(5) },
	{ key = "/", mods = "LEADER|SHIFT", action = act.ActivateTab(6) },
	{ key = "(", mods = "LEADER|SHIFT", action = act.ActivateTab(7) },
	{ key = ")", mods = "LEADER|SHIFT", action = act.ActivateTab(8) },
	{ key = "H", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(1) },
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_mode",
			one_shot = false,
			timeout_milliseconds = 2000,
		}),
	},
	{ key = "y", mods = "LEADER", action = act.ActivateCopyMode },
}

config.key_tables = {
	resize_mode = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 2 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
