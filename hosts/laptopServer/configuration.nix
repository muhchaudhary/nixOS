{
  pkgs,
  inputs,
  nixosModules,
  ...
}: {
  imports = with nixosModules; [
    ./hardware.nix
    inputs.nixos-hardware.result.nixosModules.lenovo-thinkpad-x1-7th-gen
    inputs.nixos-hardware.result.nixosModules.common-cpu-intel
    inputs.nixos-hardware.result.nixosModules.common-pc-ssd

    # Headless: only boot, locale and networking — no sound/bluetooth/printer.
    boot
    locale
    network
    virtualisation
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This host pins a non-default uid (the user module defaults to 1000 via mkDefault).
  users.users.muhammad.uid = 1001;

  environment.systemPackages = [pkgs.kitty.terminfo];

  # Run headless with lid closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  networking.firewall.allowedTCPPorts = [80 443 25565];
  networking.firewall.allowedUDPPorts = [51820 25565];

  # iwd handles Channel Switch Announcements and reconnects more robustly
  # than wpa_supplicant on Intel cards (AC 9560) — prevents CSA locking into legacy 802.11a mode
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Replace with your actual public key: cat ~/.ssh/id_ed25519.pub
  users.users.muhammad.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw/pFaCTF2sGl7WBmIRld/6ClenyRvbFm8kfzTE9Cf6 muhammadahmchaudhary@gmail.com"
  ];

  # Performance-first power management — server stays plugged in
  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      # Run at full performance on AC
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_BOOST_ON_AC = 1;

      # Battery charge limits extend longevity while plugged in permanently
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # Disable WiFi power saving — powertop auto-tune throttles WiFi to ~20 Mbit/s
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # Exclude ASIX AX88179A USB Ethernet adapter from TLP's USB autosuspend handling
      # so it can't undo the udev rule below
      USB_DENYLIST = "0b95:1790";
    };
  };

  services.udev.extraRules = ''
    # Disable flapping Synaptics fingerprint reader (06cb:00bd) on USB 1-9
    # Internal connector is faulty, causing constant connect/disconnect loop in dmesg
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="00bd", RUN+="/bin/sh -c 'echo 0 > /sys/$env{DEVPATH}/authorized'"

    # Disable USB autosuspend on ASIX AX88179A USB Ethernet adapter (0b95:1790)
    # Autosuspend drops the Ethernet link after 2s and it never recovers
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0b95", ATTR{idProduct}=="1790", ATTR{power/control}="on"
  '';

  system.stateVersion = "25.05";
}
