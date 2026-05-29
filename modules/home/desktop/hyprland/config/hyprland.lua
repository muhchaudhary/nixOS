-- Per-host monitor/device configuration (deployed separately per host)
require("monitors")

--------------------
-- ENVIRONMENT VARIABLES
--------------------

hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("MOZ_WEBRENDER", "1")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("QT_QPA_PLATFORM", "wayland")

--------------------
-- AUTOSTART
--------------------

hl.on("hyprland.start", function()
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/launch_fabric")
  hl.exec_cmd("sleep 2 && systemctl --user start tray.target")
  hl.exec_cmd("sleep 1 && " .. os.getenv("HOME") .. "/.config/hypr/scripts/randomize_wallpaper")
end)

--------------------
-- LOOK AND FEEL
--------------------

hl.config({
  cursor = {
    no_warps = true,
    no_hardware_cursors = true,
  },
  general = {
    gaps_in = 8,
    gaps_out = 16,
    border_size = 2,
    col = {
      active_border = "rgba(333333cc)",
      inactive_border = "rgba(33333377)",
    },
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
  },
  decoration = {
    rounding = 22,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
      enabled = true,
      range = 30,
      render_power = 2,
    },
    blur = {
      enabled = true,
      size = 5,
      passes = 4,
      new_optimizations = true,
      vibrancy = 0.25,
      vibrancy_darkness = 0.0,
      brightness = 1.0,
      contrast = 0.9,
      noise = 0.02,
    },
  },
  animations = {
    enabled = true,
  },
  dwindle = {
    preserve_split = true,
  },
  gestures = {
    workspace_swipe_invert = true,
    workspace_swipe_distance = 300,
  },
  input = {
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.25,
    },
  },
  misc = {
    disable_hyprland_logo = true,
    middle_click_paste = false,
  },
})

--------------------
-- ANIMATIONS
--------------------

-- snap: near-critically-damped — fast settle, barely any overshoot (window open/close)
hl.curve("snap", { type = "spring", mass = 1, stiffness = 220, dampening = 28 })
-- flow: moderately underdamped — smooth glide with a gentle spring (workspace/layer transitions)
hl.curve("flow", { type = "spring", mass = 1, stiffness = 130, dampening = 16 })
-- ease-out bezier for opacity fades (springs don't add value for pure fade)
hl.curve("ease-out", { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })

hl.animation({ leaf = "windowsIn",        enabled = true, speed = 1, spring = "snap", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1, spring = "snap", style = "popin 87%" })
hl.animation({ leaf = "windows",          enabled = true, speed = 1, spring = "snap" })
hl.animation({ leaf = "border",           enabled = true, speed = 1, spring = "flow" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3, bezier = "ease-out" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 1, spring = "flow" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, spring = "snap", style = "slidevert" })

--------------------
-- GESTURES
--------------------

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

--------------------
-- WORKSPACE RULES
--------------------

hl.workspace_rule({ workspace = "w[t1]",  gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "w[tg1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

--------------------
-- WINDOW RULES
--------------------

-- No borders/rounding on single-window and fullscreen workspaces
hl.window_rule({
  name = "no-border-wt1",
  match = { workspace = "w[t1]" },
  border_size = 0,
})
hl.window_rule({
  name = "no-decor-wt1-tiled",
  match = { float = false, workspace = "w[t1]" },
  border_size = 0,
  rounding = 0,
})
hl.window_rule({
  name = "no-decor-wtg1-tiled",
  match = { float = false, workspace = "w[tg1]" },
  border_size = 0,
  rounding = 0,
})
hl.window_rule({
  name = "no-decor-f1-tiled",
  match = { float = false, workspace = "f[1]" },
  border_size = 0,
  rounding = 0,
})

--------------------
-- LAYER RULES
--------------------

hl.layer_rule({ name = "fabric-blur",    match = { namespace = "fabric" }, blur = true })
hl.layer_rule({ name = "fabric-alpha",   match = { namespace = "fabric" }, ignore_alpha = 0.0 })
hl.layer_rule({ name = "fabric-no-anim", match = { namespace = "fabric" }, no_anim = true })

--------------------
-- KEYBINDINGS
--------------------

require("binds")
