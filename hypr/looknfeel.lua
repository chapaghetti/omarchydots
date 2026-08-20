-- Change the default Omarchy look'n'feel.
-- Values ported from the old ~/.config/hypr/looknfeel.conf.bak (hyprlang).

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Window gaps and border thickness.
    border_size = 3,
    gaps_in = 2,
    gaps_out = 8,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 10,

    -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    -- dim_inactive = true,
    -- dim_strength = 0.15,
  },
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Bezier curves: fast & springy
hl.curve("spring", { type = "bezier", points = { { 0.55, 1.2 }, { 0.45, 1.0 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.3, 0 }, { 0.25, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.2, 0 }, { 0.1, 1.0 } } })

-- Windows animations
hl.animation({ leaf = "windows",     enabled = true, speed = 1.5, bezier = "spring" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 1.2, bezier = "quick" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.0, bezier = "quick" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.6, bezier = "spring" })

-- Fade animations
hl.animation({ leaf = "fade",       enabled = true, speed = 1.3, bezier = "smooth" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.1, bezier = "smooth" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 0.9, bezier = "quick" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 1.1, bezier = "smooth" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.2, bezier = "quick" })

-- Layers animations
hl.animation({ leaf = "layers",    enabled = true, speed = 1.5, bezier = "spring" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 1.2, bezier = "quick" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.1, bezier = "quick" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "spring" })
-- The old config used the invalid style "slide left"; "slide" is the closest valid one.
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth", style = "slide" })

-- Borders
hl.animation({ leaf = "border",      enabled = true, speed = 2.0, bezier = "spring" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 2.2, bezier = "smooth" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
