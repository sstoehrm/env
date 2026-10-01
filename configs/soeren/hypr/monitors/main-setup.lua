-- Monitor layout: main-setup
-- Deployed to ~/.config/hypr/monitors.lua by the monitors step of the env repo.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Two 27" 1440p panels side by side, the Dell on the left and the Samsung
-- (main) on the right. Matched by description rather than port name, so
-- swapping cables between DP and HDMI does not reshuffle the layout.
--
-- Scale 1.25 makes everything 1.25x larger. It divides 2560x1440 evenly
-- (2048x1152 logical), so Hyprland uses it as is. 1.5 does not (2560 / 1.5 is
-- not a whole number) and Hyprland would round it to a neighbouring scale.
-- Positions are in logical pixels, hence the main monitor sits at x = 2048.

local scale = 1.25

-- GTK only scales by whole numbers. Omarchy's default of 2 is meant for
-- high-DPI panels and would blow XWayland GTK apps up to 2x here.
hl.env("GDK_SCALE", "1")

-- Left: Dell AW2721D
hl.monitor({
  output = "desc:Dell Inc. Dell AW2721D #G7IYMxgwABAN",
  mode = "2560x1440@144",
  position = "0x0",
  scale = scale,
})

-- Right, main: Samsung Odyssey G7 (LC27G7xT)
hl.monitor({
  output = "desc:Samsung Electric Company LC27G7xT H4ZT200091",
  mode = "2560x1440@144",
  position = "2048x0",
  scale = scale,
})

-- Anything else that gets plugged in.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
