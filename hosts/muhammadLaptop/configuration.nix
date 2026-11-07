{
  pkgs,
  inputs,
  nixosModules,
  ...
}: {
  imports = with nixosModules; [
    ./hardware.nix
    inputs.nixos-hardware.result.nixosModules.lenovo-thinkpad-t14-amd-gen4

    system
    gaming
    hyprland
    fonts
    polkit
    gtk
    v4l2loopback
    secrets
    nordvpn
    tailscale
    odesc
  ];

  boot.kernelParams = ["button.lid_init_state=open"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # sops-nix: the `secrets` module wires the age key + packages; the host points
  # at its own encrypted file and declares secrets (`sops.secrets.<name>`).
  sops.defaultSopsFile = ./secrets.yaml;

  services.fwupd.enable = true;

  services.libinput.enable = true; # Enable touchpad support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
    ];
  };

  hardware.system76.power-daemon.enable = false;

  services.udev.extraRules = ''
    # Integrated camera (Chicony 04f2:b74f): raw USB access for all users
    SUBSYSTEM=="usb", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b74f", MODE="0666"
    SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ENV{HID_ID}=="*:00002E8A:000010C6", TAG+="seat", TAG+="uaccess"
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

  security.rtkit.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
