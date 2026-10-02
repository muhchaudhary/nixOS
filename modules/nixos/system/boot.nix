{config, ...}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      timeout = 10;
    };
    kernelParams =
      if config.boot.plymouth.enable
      then [
        # Silent Boot Params
        "quiet"
        "splash" # See splash screen
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "boot.shell_on_fail"
      ]
      else [];
  };
}
