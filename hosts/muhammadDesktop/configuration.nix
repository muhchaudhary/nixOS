{
  config,
  lib,
  pkgs,
  inputs,
  nixosModules,
  ...
}: {
  imports = with nixosModules; [
    ./hardware.nix
    inputs.nixos-hardware.result.nixosModules.common-cpu-amd
    inputs.nixos-hardware.result.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.result.nixosModules.common-pc-ssd
    inputs.nixos-hardware.result.nixosModules.common-gpu-nvidia-nonprime
    inputs.nix-gaming.result.nixosModules.pipewireLowLatency

    system
    gaming
    hyprland
    fonts
    polkit
    gtk
    nvidia
    v4l2loopback
    virtualisation
    nordvpn
    tailscale
  ];

  # SSH over the tailnet only: the port isn't opened on the LAN, and tailscale0
  # is a trusted interface (see the tailscale module).
  services.openssh = {
    enable = true;
    openFirewall = false;
    # Key-only: keyboard-interactive would otherwise still allow the account
    # password via PAM.
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.muhammad.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw/pFaCTF2sGl7WBmIRld/6ClenyRvbFm8kfzTE9Cf6 muhammadahmchaudhary@gmail.com"
  ];

  # Extra boot entry for serving LLMs (~/Documents/LLMs) while away: no
  # graphical session (frees its VRAM, and no hypridle to suspend the machine)
  # and no Sunshine. Boot into it once with
  #   systemctl reboot --boot-loader-entry=<entry from `bootctl list`>
  # and the next plain reboot comes back to the normal desktop.
  specialisation.headless.configuration = {
    system.nixos.tags = ["headless"];

    services.displayManager.sddm.enable = lib.mkForce false;
    services.sunshine.enable = lib.mkForce false;

    # Nothing should put the machine to sleep while it's serving.
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    # With no display client holding the GPU open, keep the driver initialised
    # so model loads don't pay GPU init each time.
    hardware.nvidia.nvidiaPersistenced = true;

    # 300 W: ~94% of stock LLM decode speed, ~70 W less, ~7 °C cooler
    # (see ~/Documents/LLMs/powertest/20261027-171504/summary.md). The limit
    # doesn't survive a reboot, so the normal desktop boot stays at stock 370 W.
    systemd.services.nvidia-power-limit = {
      description = "Set NVIDIA GPU power limit";
      wantedBy = ["multi-user.target"];
      after = ["systemd-modules-load.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl 300";
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Prefer dropping page cache over swapping out apps; loading multi-GB LLM
  # weights otherwise pushes idle browser/desktop memory into swap.
  boot.kernel.sysctl."vm.swappiness" = 10;

  # Make Hyprland the default SDDM session (was internal.desktop.hyprland.makeDefaultSession).
  services.displayManager.defaultSession = "hyprland-uwsm";

  # NVIDIA container runtime for Docker (was internal.virtualisation.nvidia = true).
  # The container toolkit itself is enabled by the nvidia module.
  virtualisation.docker.extraOptions = "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";

  environment.systemPackages = with pkgs; [
    spice-gtk
    r2modman
    lm_sensors
    quickemu
    ethtool
    # `sudo reboot-headless`: boot the headless specialisation once (works over
    # SSH); the next plain reboot is back to the normal desktop.
    (writeShellApplication {
      name = "reboot-headless";
      runtimeInputs = [jq config.systemd.package];
      text = ''
        # Entry ids are hashes that change every generation, so find it by
        # title; bootctl lists newest first.
        # (stderr: bootctl warns that NixOS's entry versions aren't valid version strings)
        entry=$(bootctl list --json=short 2>/dev/null | jq -r 'first(.[] | select(.title | test("headless"))) | .id')
        if [ -z "$entry" ]; then
          echo "no headless boot entry found" >&2
          exit 1
        fi
        echo "rebooting into $entry"
        systemctl reboot --boot-loader-entry="$entry"
      '';
    })
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
    # GameSir controllers (GameSir Connect under Wine)
    # (uaccess TAG is ignored here: 99-local runs after 73-seat-late applies it)
    SUBSYSTEMS=="usb|hidraw", ATTRS{idVendor}=="3537", MODE="0666"
    # GameSir firmware-update bootloader (JieLi BR23 UBOOT), for USB passthrough to a VM
    SUBSYSTEM=="usb", ATTRS{idVendor}=="4c4a", ATTRS{idProduct}=="2342", MODE="0666"
    # Front hub ports 1-4.1 and 1-4.2 are passed through to the Windows VM by port (any VID:PID)
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", KERNEL=="1-4.1|1-4.2", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"

    # Wake-on-LAN (magic packet) on the wired NIC, so laptopServer's
    # `wake-desktop` can wake it from suspend or power-off. Matched by MAC
    # rather than a .link file, which would replace the default naming policy.
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="70:85:c2:96:b5:37", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol g"
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

  security.rtkit.enable = true;

  nix.settings = {
    cores = 8;
    max-jobs = 8;
  };
  system.stateVersion = "23.05"; # Did you read the comment?
}
