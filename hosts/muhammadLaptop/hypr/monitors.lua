hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd(scripts .. "lid_close"), { locked = true })
-- hl.bind("switch:off:Lid Switch", hl.monitor({ output = "eDP-1", disabled = false }),  { locked = true })
