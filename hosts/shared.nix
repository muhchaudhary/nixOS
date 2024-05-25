{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
    mime = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    material-design-icons
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
    roboto-mono
    roboto-slab
    jetbrains-mono
  ];

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

  # Window Manger
  programs = {
    fish.enable = true;
    hyprland.enable = true;
    hyprland.xwayland.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
  };
  services.blueman.enable = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://hydra.build/"
      "https://hyprland.cachix.org"
      "https://nix-config.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://cache.nixos.org/"
    ];

    trusted-public-keys = [
      "headcounter.org:/7YANMvnQnyvcVB6rgFTdb8p5LG1OTXaO+21CaOSBzg="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.muhammad = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Muhammad Chaudhary";
    extraGroups = ["networkmanager" "wheel" "input" "docker"];
  };

  nix.settings.trusted-users = [
    "muhammad"
  ];

  # Fix nautilis video thumbnails and information
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  environment.systemPackages = with pkgs; [
    home-manager
    git
    micro
    wget
    curl
    zip
    ntfs3g
    nix-index
    unzip
    lm_sensors
    pciutils
    wine
    neofetch
    htop
    firefox
  ];
  environment.variables = {
    EDITOR = "micro";
    NIXOS_OZONE_WL = "1";
  };

  services = {
    # Show laptop and other device battery life
    upower.enable = true;
    # allow nautilus to see trash:/// (https://nixos.wiki/wiki/Nautilus)
    gvfs.enable = true;
  };

  # enable power profile switching through dbus
  services.power-profiles-daemon.enable = true;
}
