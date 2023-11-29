# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./services.sunshine.nix
    ];

  # Enable sunshine 
  services.sunshine.enable = true;
    

  # Set up automatic garbage collector 
  nix = {
  	settings.auto-optimise-store = true;
  	gc = {
  		dates = "weekly";
  		options = "--delete-older than 7d";
  	};
  };

  #Kernel perams
  boot.kernelParams = [ "module_blacklist=nouveau, nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "muhammadDeskop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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


  #---------------------------------------------------------------- ADDED NOW 
  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
    ];

  # Tell Xorg to use the nvidia driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;

    # for Hyperland
    powerManagement.enabled = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  nixpkgs.overlays = [
  	(final: prev: {
	    blender = prev.blender.override { cudaSupport = true; };
	    sunshine = prev.sunshine.override {cudaSupport = true; 
	                                       stdenv = pkgs.cudaPackages.backendStdenv;
	                                      };
    })
  ];
  #-----------------------------------------------------------------

    
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
    roboto
  ];
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.muhammad = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Muhammad Chaudhary";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      steam
      gnome.gnome-tweaks
      blender
      orchis-theme
      minecraft
      kora-icon-theme
      onlyoffice-bin
      kicad
      yuzu-early-access
      vscode-fhs
      spotify
      jellyfin-media-player
      jellyfin-mpv-shim
    ];
  };

  # enable fish shell
  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.cudaSupport = true;
  #config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  environment.systemPackages = with pkgs; [
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  (python311.withPackages(ps: with ps; [
  	pandas
  	requests
  	networkx
  ]))
  (python310.withPackages(ps: with ps; [
  	pandas
  	requests
  	networkx
  ]))
    wget
    micro
    zip
    ntfs3g
    unzip
    python311
    python310
    lm_sensors
    pciutils
    wine
    git
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
    zerotierone
    appimage-run
    #	sunshine
    #sunshine = ./sunshine.nix;
  ];

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
  #services.udev.extraRules =  builtins.readFile openrgb-rules;

#  sunshine = ./sunshine.nix;
}
