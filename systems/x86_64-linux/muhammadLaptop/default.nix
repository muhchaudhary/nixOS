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
      vpl-gpu-rt
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Power saving
  services.cpupower-gui.enable = true;
  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
    # configFile = "--ignore-cpuid-check --workaround-enabled";
  };
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  services.logind = {
    extraConfig = "HandlePowerKey=suspend";

    lidSwitch = "suspend";
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  nix.distributedBuilds = true;
  nix.settings = {
    builders-use-substitutes = true;
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
