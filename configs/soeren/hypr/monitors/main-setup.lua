-- Monitor layout: main-setup
-- Deployed to ~/.config/hypr/monitors.lua by the monitors step of the env repo.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Two 27" 1440p panels side by side, the Dell on the left and the Samsung
-- (main) on the right, both at 144 Hz. Matched by description rather than port
-- name, so swapping cables between DP and HDMI does not reshuffle the layout.
--
-- Scale 1: on 27" 1440p the desktop is fine at native size, and only text is
-- enlarged, through "display_text_size" in preferences.json.
-- GDK_SCALE is left unset (1); Omarchy's 2 is meant for high-DPI panels.

-- Left: Dell AW2721D
hl.monitor({
  output = "desc:Dell Inc. Dell AW2721D #G7IYMxgwABAN",
  mode = "2560x1440@144",
  position = "0x0",
  scale = 1,
})

-- Right, main: Samsung Odyssey G7 (LC27G7xT)
hl.monitor({
  output = "desc:Samsung Electric Company LC27G7xT H4ZT200091",
  mode = "2560x1440@144",
  position = "2560x0",
  scale = 1,
})

-- Anything else that gets plugged in.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
