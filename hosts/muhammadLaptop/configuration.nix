# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../shared.nix
  ];

  # Use Docker
  virtualisation.docker = {
    enable = true;
  };

  boot.kernelParams = ["button.lid_init_state=open"];

  networking.hostName = "muhammadLaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # environment.variables = rec {
  #   LIBVA_DRIVER_NAME = "iHD";
  # };

  environment.systemPackages = with pkgs; [
    i2c-tools
    gcc
    gperftools
    glibc
    glib
    unetbootin
    ventoy
    appimage-run
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # This is to enable flatpak support

  # Power saving
  services.cpupower-gui.enable = true;

  services.logind = {
    extraConfig = "HandlePowerKey=suspend";

    lidSwitch = "suspend";
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
