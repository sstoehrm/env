local wezterm = require("wezterm")
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

wezterm.on("gui-startup", function(cmd)
	-- Tab 1: "env" — 1 left, 2 right
	local tab1, pane, window = wezterm.mux.spawn_window({ cwd = wezterm.home_dir .. "/repos" })
	window:gui_window():maximize()
	tab1:set_title("env")
	local right = pane:split({ direction = "Right", size = 0.5, cwd = wezterm.home_dir .. "/repos" })
	right:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos" })

	-- Tab 2: "dev 1" — 4 vertical, left 3 split horizontally = 6 total
	local tab2, pane2 = window:spawn_tab({ cwd = wezterm.home_dir .. "/repos/private" })
	tab2:set_title("dev 1")
	local col2 = pane2:split({ direction = "Right", size = 0.75, cwd = wezterm.home_dir .. "/repos/private" })
	local col3 = col2:split({ direction = "Right", size = 0.666, cwd = wezterm.home_dir .. "/repos/private" })
	local col4 = col3:split({ direction = "Right", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })
	pane2:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })
	col2:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })
	col3:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })
	col4:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })

	-- Tab 3: "dev 2" — 1 left, 2 right
	local tab3, pane3 = window:spawn_tab({ cwd = wezterm.home_dir .. "/repos/private" })
	tab3:set_title("dev 2")
	local right3 = pane3:split({ direction = "Right", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })
	right3:split({ direction = "Bottom", size = 0.5, cwd = wezterm.home_dir .. "/repos/private" })

	-- Tab 4: "stuff" — 4 panes (2x2 grid)
	local tab4, pane4 = window:spawn_tab({})
	tab4:set_title("stuff")
	local right4 = pane4:split({ direction = "Right", size = 0.5 })
	pane4:split({ direction = "Bottom", size = 0.5 })
	right4:split({ direction = "Bottom", size = 0.5 })

	-- Focus first tab
	window:gui_window():perform_action(wezterm.action.ActivateTab(0), tab1:active_pane())
end)

wezterm.on("format-window-title", function()
	return "WezTerm"
end)

config.term = "wezterm"
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
	{
		key = "S",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "O",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local state = resurrect.state_manager.load_state(id, "workspace")
				resurrect.workspace_state.restore_workspace(state, {
					resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
						local type = string.match(id, "^([^/]+)") -- match before '/'
						id = string.match(id, "([^/]+)$") -- match after '/'
						id = string.match(id, "(.+)%..+$") -- remove file extention
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
					end),
				})
			end)
		end),
	},
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

resurrect.state_manager.periodic_save({
	interval_seconds = 300,
	save_tabs = true,
	save_windows = true,
	save_workspaces = true,
})

return config
