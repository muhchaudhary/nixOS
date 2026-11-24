-- HDMI-A-1: TCL TV over HDMI 2.1 (FRL); 4K@144 needs the full 48 Gbps link, so use an
-- Ultra High Speed (HDMI 2.1-certified) cable and the TV's game/PC mode on that input.
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@144", position = "0x0",    scale = 1 })
hl.monitor({ output = "DP-1",     mode = "2560x1440@75",  position = "3840x0", scale = 1 })

-- Gaming Mode's workspace lives on the TV. gaming-mode already opens it there
-- (/etc/gaming-mode/output); the rule keeps it there: if the TV drops off (powered
-- off, HDMI re-link after suspend) Hyprland parks the workspace on DP-1, and moves
-- it back once HDMI-A-1 reconnects. Under Sunshine HDMI-A-1 is disabled, so the
-- rule can't resolve and the workspace opens on the headless output as before.
hl.workspace_rule({ workspace = "name:gaming", monitor = "HDMI-A-1" })

-- Sunshine's headless output (created at startup by create_headless_monitor);
-- declared so config reloads keep it off until sunshine_headless_connect enables it.
hl.monitor({ output = "HEADLESS-1", disabled = true })


hl.device({
  name = "wacom-intuos-bt-m-pen",
  transform = 0,
  output = "HDMI-A-1",
})

hl.config({
  misc = { vrr = 1 },
  -- Don't flip HDMI-A-1 into HDR when a fullscreen client (VS Code/Chromium via the
  -- color-management protocol) tags its surface as HDR/wide-gamut: the switch is a full
  -- modeset, which blanks the screen for a second. (This also stops games auto-switching;
  -- set `cm = "hdr"` on the monitor instead if HDR is wanted.)
  render = { cm_auto_hdr = 0 },
})
