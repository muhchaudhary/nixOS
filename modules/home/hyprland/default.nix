{
  pkgs,
  inputs,
  ...
}: let
  hyprlandPackages = inputs.hyprland.result.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [./hyprlock.nix];

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    libnotify
    hyprkeys
    wdisplays
    hyprshot
    pwvucontrol
    wf-recorder
    brightnessctl
    hyprpicker
    swappy
    slurp
    imagemagick
    libdbusmenu-gtk3
    playerctl
  ];

  xdg.configFile."hypr" = {
    source = ./config;
    recursive = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      kdePackages.xdg-desktop-portal-kde
    ];

    config.hyprland = {
      default = [
        "hyprland"
        "gnome"
        "kde"
      ];
      # hyprland's portal lacks RemoteDesktop and gnome's only works under
      # Mutter; without this Sunshine's startup probe errors in the journal.
      "org.freedesktop.impl.portal.RemoteDesktop" = ["none"];
    };
  };

  wayland.windowManager.hyprland = {
    configType = "lua";
    enable = true;
    portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
    systemd.enable = false; # UWSM manages the systemd session
  };

  services.hyprsunset = {
    enable = true;
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        unlock_cmd = "pkill -USR1 hyprlock";
        before_sleep_cmd = builtins.concatStringsSep "; " [
          "loginctl lock-session"
          "${pkgs.playerctl}/bin/playerctl pause"
        ];
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
    };
  };

  # services.kdeconnect = {
  #   enable = true;
  #   indicator = true;
  # };
  services.cliphist.enable = true;
  services.udiskie.enable = true;
}
