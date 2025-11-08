{
  lib,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
with lib;
with lib.internal; {
  imports = [
    ./hardware.nix
  ];

  boot.kernelParams = ["button.lid_init_state=open"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  internal = {
    system = enabled;
    gaming = enabled;
    desktop.fonts = enabled;
    themes.gtk = enabled;
    desktop.hyprland = enabled;
    polkit = enabled;
  };

  services.libinput.enable = true; # Enable touchpad support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
    ];
  };

  hardware.system76.power-daemon.enable = true;

  services.udev.extraRules = ''
    # ODESC
    SUBSYSTEM=="usb", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b74f", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0d3[0-9]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"
  '';

  services = {
    # using system76-power
    system76-scheduler.enable = true;
    power-profiles-daemon.enable = false;
    upower.enable = true;

    cpupower-gui.enable = true;
    logind = {
      extraConfig = "HandlePowerKey=suspend";
      lidSwitch = "suspend";
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  nix.distributedBuilds = true;
  nix.settings = {
    builders-use-substitutes = true;
  };
  security.rtkit = enabled;

  system.stateVersion = "25.05"; # Did you read the comment?
}
