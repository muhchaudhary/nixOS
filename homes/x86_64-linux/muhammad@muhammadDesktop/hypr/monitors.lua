hl.monitor({ output = "DP-1",     mode = "2560x1440@75", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2560x0", scale = 1, transform = 2 })

hl.device({
  name = "wacom-intuos-bt-m-pen",
  transform = 0,
  output = "DP-1",
})

hl.config({
  misc = { vrr = 1 },
})
