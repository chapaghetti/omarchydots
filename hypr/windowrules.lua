-- Personal window rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- App rules ported from the old ~/.config/hypr/looknfeel.conf.bak (hyprlang).
--
-- Use Omarchy's o.window(match, rules) helper:
--   o.window("some-class", { effect = value, ... })
--   o.window({ class = "x", float = true }, { effect = value, ... })
--
-- Rules are evaluated top to bottom; the last match wins. Named rules
-- (hl.window_rule({ name = ... })) take precedence over anonymous ones.

-- Steam: keep the client floating and centered, and ignore its buggy maximize.
o.window("steam", {
  float = true,
  center = true,
  suppress_event = "maximize",
})

-- Discord (Chromium PWA): float a fixed-size window, centered on screen.
o.window("chrome-discord\\.com", {
  float = true,
  size = { 1100, 720 },
  center = true,
})

-- Steam games: mark as games (HDR/VRR/content handling) and keep the screen
-- awake while fullscreen.
o.window("steam_app_\\d+", {
  content = "game",
  idle_inhibit = "fullscreen",
})

-- Warcraft 1 (Orcs & Humans) via DOSBox: fullscreen and never idle.
o.window({ class = "^steam_app_0$", title = "^DOSBox" }, {
  fullscreen = true,
  idle_inhibit = "always",
})
o.window({ class = "^steam_app_0$", title = "^DOSBox" }, {
  no_blur = true,
})

-- Hue-Tui: small floating window.
o.window("org\\.omarchy\\.hue-tui\\.sh", {
  float = true,
  center = true,
  size = { 576, 270 },
})

-- Unity popups and dialogs: pin, keep focus, no blur, fully opaque.
o.window({ class = "^Unity$", float = true, title = "^UnityEditor\\*$" }, {
  stay_focused = true,
  pin = true,
})
o.window({ class = "^Unity$", title = "^UnityEditor\\*$" }, {
  no_blur = true,
  opacity = "1 override 1 override",
})
o.window({ class = "^Unity$", title = "^Unity$" }, {
  no_blur = true,
  float = true,
  opacity = "1 override 1 override",
})
o.window("Unity", {
  no_blur = true,
  opacity = "1 override 1 override",
})
o.window({ class = "^Unity$", title = "^.*Color$" }, {
  float = true,
  center = true,
  stay_focused = true,
  pin = true,
  min_size = { 1, 1 },
  no_blur = true,
})

-- Aseprite: tile at full opacity and maximize.
o.window("Aseprite", {
  tile = true,
  opacity = "1 override 1 override",
  maximize = true,
})

-- Windows VM (xfreerdp): open on workspace 6 and maximize.
o.window("xfreerdp", {
  workspace = "6",
  maximize = true,
})

-- Discord desktop app: open on workspace 3.
o.window("chrome-discord\\.com__app-Default", {
  workspace = "3",
})

-- Ghostty: always tile.
o.window("com\\.mitchellh\\.ghostty", {
  tile = true,
})

-- Image viewer / movie player / password manager / system monitor: tile and
-- clear the floating-window tag.
o.window("imv", { tag = "-floating-window", tile = true })
o.window("mpv", { tag = "-floating-window", tile = true })
o.window("Bitwarden", { tag = "-floating-window", tile = true })
o.window("org\\.omarchy\\.btop", { tag = "-floating-window", tile = true })

-- Example: stop blur on video/content apps.
-- o.window("firefox", { no_blur = true })

-- Example: tint the border of fullscreen windows red.
-- o.window({ fullscreen = true }, { border_color = "rgb(FF0000) rgb(880808)" })

-- Example: keep password dialogs focused.
-- o.window("(pinentry-)(.*)", { stay_focused = true })

-- Example: open an app on a specific workspace (silent = don't switch to it).
-- o.window("code", { workspace = "1 silent" })
