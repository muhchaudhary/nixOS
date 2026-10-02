local mainMod = "SUPER"
local fabric = os.getenv("HOME") .. "/.config/hypr/scripts/launch_fabric"
local fabric_send = os.getenv("HOME") .. "/.config/hypr/scripts/fabric_send"

-- Window management
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))

-- Focus movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces / move windows (mainMod+ALT to move)
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key,       hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Keyboard resize
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x =  10, y =   0 }), { repeating = true })
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -10, y =   0 }), { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x =   0, y = -10 }), { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x =   0, y =  10 }), { repeating = true })

-- Fullscreen
hl.bind(mainMod .. " + F",       hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = 1 }))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && " .. fabric_send .. " 'toggle-system-osd' 'sound'"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%- && " .. fabric_send .. " 'toggle-system-osd' 'sound'"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+ && " .. fabric_send .. " 'toggle-system-osd' 'brightness'"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%- && " .. fabric_send .. " 'toggle-system-osd' 'brightness'"), { locked = true, repeating = true })
hl.bind("XF86KbdLightOnOff",     hl.dsp.exec_cmd(fabric_send .. " 'toggle-system-osd' 'kbd'"),                                     { locked = true })

-- Fabric / app launchers
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(fabric_send .. " 'toggle-appmenu'"))
hl.bind("ALT + Tab",        hl.dsp.exec_cmd(fabric_send .. " 'toggle-overview'"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(fabric_send .. " 'toggle-wallpaper-picker'"))

-- Screenshots / screencast
hl.bind("Print",                hl.dsp.exec_cmd(fabric_send .. " 'take-screenshot'"))
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd(fabric_send .. " 'take-screenshot' 'True'"))
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd(fabric_send .. " 'start-screencast'"))
hl.bind("CTRL + ALT + Print",   hl.dsp.exec_cmd(fabric_send .. " 'start-screencast' 'True'"))
hl.bind("ALT + Print",          hl.dsp.exec_cmd(fabric_send .. " 'stop-screencast'"))

-- Restart Fabric
hl.bind("CTRL + SHIFT + R", hl.dsp.exec_cmd(fabric_send .. " 'quit' || sleep 0.5 && " .. fabric))
