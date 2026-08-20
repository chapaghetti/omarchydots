-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Keybindings ported from the old ~/.config/hypr/bindings.conf.bak (hyprlang).
local terminal = "uwsm-app -- xdg-terminal-exec"
local browser = "zen-browser"

-- Terminal bindings.
-- Note: SUPER+RETURN (Terminal), SUPER+ALT+RETURN (Tmux) and SUPER+CTRL+RETURN
-- (Herdr) were already bound; they are rebound to the old behavior below.
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + ALT + RETURN")
hl.unbind("SUPER + CTRL + RETURN")

o.bind("SUPER + RETURN", "Terminal", terminal .. ' --dir="$(omarchy-cmd-terminal-cwd)"')
o.bind(
	"SUPER + ALT + RETURN",
	"Tmux",
	terminal .. ' --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s Work"'
)
o.bind(
	"SUPER + CTRL + RETURN",
	"Terminal",
	terminal
		.. ' bash -c "cliamp" & '
		.. terminal
		.. ' bash -c "cbonsai -il" & '
		.. terminal
		.. ' bash -c "rmatrix -r" & '
		.. terminal
		.. ' bash -c "btop"'
)

-- App bindings (SUPER + SHIFT + ...).
-- Note: the default keys being replaced here were Browser (B), Docker (D),
-- Email/Hey (E), Obsidian (O), Google Photos (P), Google Maps (S), Omawrite
-- (W) and Browser (RETURN). A, C, F, G, M, N, X and Y already match the old
-- config, so they are left alone.
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Passwords", { launch = "bitwarden-desktop" })

hl.unbind("SUPER + SHIFT + D")
o.bind("SUPER + SHIFT + D", "Discord", { webapp = "https://discord.com/app" })

hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://protonmail.com" })

o.bind("SUPER + SHIFT + H", "OpenHue", { tui = "~/bin/hue-tui.sh", focus = true })
o.bind("SUPER + SHIFT + J", "Joplin", { launch = "Joplin" })
o.bind("SUPER + SHIFT + L", "LocalSend", { launch = "localsend" })

hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "OBS", { launch = "obs" })

hl.unbind("SUPER + SHIFT + P")
o.bind("SUPER + SHIFT + P", "Plastic SCM", { launch = "linplasticx" })

o.bind("SUPER + SHIFT + R", "Remmina", { launch = "remmina" })

hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Steam", { launch = "steam" })

o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + U", "Unity Hub", { launch = "unityhub" })

hl.unbind("SUPER + SHIFT + W")
o.bind(
	"SUPER + SHIFT + W",
	"TheWizard",
	{ launch = "/home/nugget/Documents/Unity/DevBuilds/2025_10_29/TheWizard.x86_64 -screen-fullscreen 0 -monitor 1" }
)

o.bind("SUPER + SHIFT + Z", "Zen", { launch = browser })

hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Web Browser", { launch = "chromium" })

-- App bindings (SUPER + SHIFT + CTRL + ...).
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + CTRL + A", "Aseprite", { launch = "aseprite", focus = "aseprite" })
o.bind("SUPER + SHIFT + CTRL + T", "Twitch", { webapp = "https://twitch.tv" })
o.bind("SUPER + SHIFT + CTRL + Z", "Zen (private)", { launch = "zen-browser --private-window" })

-- App bindings (SUPER + SHIFT + ALT + ...).
hl.unbind("SUPER + SHIFT + ALT + B")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { launch = "zen-browser --private-window" })
o.bind("SUPER + SHIFT + ALT + H", "Hacker News", { launch = "firefox https://news.ycombinator.com" })

-- PrintScreen screenshots are remapped to the "[" key (code:34) below.
hl.unbind("PRINT")
hl.unbind("SHIFT + PRINT")
hl.unbind("CTRL + PRINT")
hl.unbind("ALT + PRINT")
hl.unbind("CTRL + ALT + PRINT")
hl.unbind("SUPER + PRINT")

o.bind("SUPER + code:34", "Screenshot of region", "omarchy-capture-screenshot windows")
o.bind("SUPER + SHIFT + code:34", "Screenshot of window", "omarchy-capture-screenshot region")
o.bind("SUPER + CTRL + code:34", "Screenshot of display", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + ALT + code:34", "Screen record a region", "omarchy-capture-screenrecording")
o.bind("SUPER + CTRL + ALT + code:34", "Screen record display", "omarchy-capture-screenrecording --fullscreen")
