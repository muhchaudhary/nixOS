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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  internal = {
    system = enabled;
    gaming = enabled;
    desktop.hyprland = {
      enable = true;
      makeDefaultSession = true;
    };
    hardware.nvidia = enabled;
    hardware.v4l2loopback = enabled;
    desktop.fonts = enabled;
    themes.gtk = enabled;
    polkit = enabled;
    virtualisation = {
      enable = true;
      nvidia = true;
    };
  };

  environment.systemPackages = with pkgs; [
    spice-gtk
    r2modman
    lm_sensors
    quickemu
  ];

  environment.variables = rec {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
    # Bose ODESC
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0d3[0-9]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"
  '';

  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = true; # Required for KMS desktop capture
      package = pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      };
      # Mirrors what was already configured via the web UI, so switching to
      # a declarative apps.json doesn't reset encoder settings.
      #
      # output_name is deliberately left unset: it's a single global setting
      # (Sunshine's apps.json has no per-app capture-target field), but it's
      # re-evaluated per stream and auto-picks whichever output is the sole
      # enabled one at the time (verified empirically). The Headless app's
      # prep-cmd relies on this to switch capture between the physical
      # monitors and the headless output.
      settings = {
        nvenc_preset = 2;
        av1_mode = 1;
        nvenc_twopass = "full_res"; # better quality/bitrate, 3090 has the headroom
        nvenc_vbv_increase = 25; # smoother quality on complex frames; safe on LAN
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
          {
            name = "Headless";
            prep-cmd = [
              {
                do = "$(HOME)/.config/hypr/scripts/sunshine_headless_connect";
                undo = "$(HOME)/.config/hypr/scripts/sunshine_headless_disconnect";
              }
            ];
          }
          {
            # Used by MoonDeck (SteamDeck plugin) instead of a normal app entry;
            # MoonDeck Buddy tells Sunshine to launch this by name. Ending the
            # MoonDeckStream process ends the stream (auto-detach = false).
            # Same prep-cmd as "Headless" above, so games launched through
            # MoonDeck get the headless virtual desktop with physical
            # monitors turned off.
            name = "MoonDeckStream";
            cmd = "${pkgs.moondeck-buddy}/bin/moondeck-buddy --exec MoonDeckStream";
            auto-detach = "false";
            prep-cmd = [
              {
                do = "$(HOME)/.config/hypr/scripts/sunshine_headless_connect";
                undo = "$(HOME)/.config/hypr/scripts/sunshine_headless_disconnect";
              }
            ];
          }
        ];
      };
    };
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
    pipewire.lowLatency = {
      enable = true;
      quantum = 32;
      rate = 48000;
    };
    xserver.wacom.enable = true;
  };

  # MoonDeck Buddy's REST server, queried directly by the SteamDeck plugin.
  networking.firewall.allowedTCPPorts = [59999];

  security.rtkit = enabled;

  nix.settings = {
    cores = 8;
    max-jobs = 8;
  };
  system.stateVersion = "23.05"; # Did you read the comment?
}
