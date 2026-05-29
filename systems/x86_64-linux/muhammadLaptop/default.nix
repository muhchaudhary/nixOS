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
    services.wgHotspot = {
      enable = true;
      upstream = "wlp2s0";
      passwordFile = config.sops.secrets.hotspot-passphrase.path;
    };
    secrets = {
      enable = true;
      defaultSopsFile = ../../../secrets/laptop.yaml;
    };
  };

  sops.secrets.hotspot-passphrase = {
    mode = "0400";
    owner = "root";
    restartUnits = ["wg-hotspot.service"];
  };

  services.libinput.enable = true; # Enable touchpad support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
    ];
  };

  hardware.system76.power-daemon.enable = false;

  services.udev.extraRules = ''
    # ODESC
    SUBSYSTEM=="usb", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b74f", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0d3[0-9]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"
  '';

  services = {
    system76-scheduler.enable = false;
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_BOOST_ON_BAT = 0;
        RADEON_DPM_STATE_ON_BAT = "battery";
        RADEON_POWER_PROFILE_ON_BAT = "low";
        # TODO: re-enable ("on") once hotspot throughput issues are resolved — ath11k power save
        # tanks AP-mode throughput, so we trade battery for working hotspot.
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "off";
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitch = "suspend";
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  networking.wg-quick.interfaces.wg0 = {
    address = ["10.8.0.3/24"];
    dns = ["1.1.1.1"];
    privateKeyFile = "/etc/wireguard/private.key";
    autostart = false;
    postUp = "ip route add 10.0.0.38/32 dev wg0";
    preDown = "ip route del 10.0.0.38/32 dev wg0";
    peers = [
      {
        publicKey = "F4dgmEFS4H4mHABPzyE0PIIlM2c9mAKX1fxt2RxWiUw=";
        presharedKeyFile = "/etc/wireguard/psk.key";
        allowedIPs = ["0.0.0.0/0"];
        endpoint = "vpn.ahmadyyz.ca:51820";
      }
    ];
  };
  networking.networkmanager.unmanaged = ["wg0"];
  # TODO: re-enable (remove this line or set true) once hotspot throughput issues are resolved.
  networking.networkmanager.wifi.powersave = false;

  nix.distributedBuilds = true;
  nix.settings = {
    builders-use-substitutes = true;
  };
  security.rtkit = enabled;

  system.stateVersion = "25.05"; # Did you read the comment?
}
