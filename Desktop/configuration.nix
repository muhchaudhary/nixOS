# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./services.sunshine.nix
      ./shared.nix
      ./nvidia-gpu.nix
    ];

  # Enable sunshine 
  services.sunshine.enable = true;
    
#  # Use Docker
#  virtualisation.docker = {
#    enable = true;
#    enableNvidia = true;
#  };

  # Set up automatic garbage collector 
  nix = {
  	settings.auto-optimise-store = true;
  	gc = {
  		dates = "weekly";
  		options = "--delete-older than 7d";
  	};
  };

  #Kernel perams
  boot.kernelParams = [ "module_blacklist=nouveau" "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  


  networking.hostName = "muhammadDeskop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";

    # Enable the GNOME Desktop Env
    displayManager.gdm.wayland = false;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.muhammad = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Muhammad Chaudhary";
    extraGroups = [ "networkmanager" "wheel" "input" "docker"];
  };

  # enable fish shell
  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  environment.systemPackages = with pkgs; [
    home-manager
    git
    micro
    wget
    curl
    zip
    ntfs3g
    unzip

    python311
    python310
    lm_sensors
    pciutils
    wine
    
    neofetch
    htop
    firefox
    openrgb
    i2c-tools
    gcc
    gperftools
    glibc
    nix-index
    unetbootin
    gtk2
    ventoy
    appimage-run
  ];

    environment.variables.EDITOR = "micro";

  services.udev.packages = with pkgs; [
	  openrgb
  ];
	
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # This is to enable flatpak support
  services.flatpak.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
