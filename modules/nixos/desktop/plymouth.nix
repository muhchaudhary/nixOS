# Plymouth boot splash: a graphical screen during boot and shutdown instead of
# scrolling kernel/systemd messages. The kernel params silence that text so it
# doesn't draw over the splash (`boot.shell_on_fail` still drops to a shell if
# stage 1 fails).
{...}: {
  boot.plymouth.enable = true;

  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"
  ];
}
