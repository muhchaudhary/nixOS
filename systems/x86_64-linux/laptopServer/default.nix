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
  imports = [./hardware.nix];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  internal = {
    system = enabled;
    virtualisation = enabled; # Docker only, no NVIDIA
    user.uid = 1001;
  };

  environment.systemPackages = [ pkgs.kitty.terminfo ];

  # Run headless with lid closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [51820];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Replace with your actual public key: cat ~/.ssh/id_ed25519.pub
  users.users.muhammad.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw/pFaCTF2sGl7WBmIRld/6ClenyRvbFm8kfzTE9Cf6 muhammadahmchaudhary@gmail.com"
  ];

  # Intel power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Disable flapping Synaptics fingerprint reader (06cb:00bd) on USB 1-9
  # Internal connector is faulty, causing constant connect/disconnect loop in dmesg
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="00bd", RUN+="/bin/sh -c 'echo 0 > /sys/$env{DEVPATH}/authorized'"
  '';

  system.stateVersion = "25.05";
}
