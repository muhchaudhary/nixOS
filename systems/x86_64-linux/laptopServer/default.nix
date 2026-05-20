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
  boot.kernelModules = ["iptable_nat" "iptable_filter"];

  internal = {
    system = enabled;
    virtualisation = enabled; # Docker only, no NVIDIA
  };

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
  services.tlp.enable = true;

  system.stateVersion = "25.05";
}
