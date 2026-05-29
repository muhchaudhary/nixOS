{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  hyprlandPackages = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.${namespace}.desktop.hyprland;
in {
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether to enable hyprland configuration. Includes everything required to feel like a desktop environment.";
    hyprlock = mkOpt attrs {} "Extra Hyprlock settings.";
    hypridle = mkOpt attrs {} "Extra Hypridle settings.";
    hyprsunset = mkOpt attrs {} "Extra Hyprsunset settings.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
    with pkgs.${namespace}; [
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
      };
    };

    home.file.".config/code-flags.conf".text = ''
      --disable-gpu-sandbox
      --ozone-platform-hint=auto
      --UseOzonePlatformozone-platform-wayland
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
      --enable-features=WebRTCPipeWireCapturer
      --enable-features=WaylandWindowDecorations
    '';

    wayland.windowManager.hyprland = {
      configType = "lua";
      enable = true;
      portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
      systemd.enable = false; # UWSM manages the systemd session
    };

    programs.hyprlock = mkMerge [
      {
        enable = true;
        settings = {
          general = {
            no_fade_in = true;
            no_fade_out = true;
            hide_cursor = false;
            grace = 0;
            disable_loading_bar = true;
          };
          background = [
            {
              monitor = "";
              path = "$HOME/.config/wall.png";
              color = "rgba(25, 20, 20, 1.0)";
              blur_passes = 2;
              contrast = 1;
              brightness = 0.5;
              vibrancy = 0.2;
              vibrancy_darkness = 0.2;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "300, 60";
              outline_thickness = 0;
              dots_size = 0.25;
              dots_spacing = 0.55;
              dots_center = true;
              dots_rounding = -1;
              outer_color = "rgba(242, 243, 244, 0)";
              inner_color = "rgba(242, 243, 244, 0)";
              font_color = "rgba(242, 243, 244, 0.75)";
              font_family = "JetBrains Mono";
              fade_on_empty = false;
              placeholder_text = ''<b>Input Password</b>'';
              hide_input = false;
              check_color = "rgba(204, 136, 34, 0)";
              fail_color = "rgba(204, 34, 34, 0)";
              fail_text = "$FAIL <b>($ATTEMPTS)</b>";
              fail_transition = 300;
              capslock_color = -1;
              numlock_color = -1;
              bothlock_color = -1;
              invert_numlock = false;
              swap_font_color = false;
              position = "0, -468";
              halign = "center";
              valign = "center";
            }
          ];
          label = [
            {
              monitor = "";
              text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
              color = "rgba(242, 243, 244, 0.75)";
              font_size = 20;
              font_family = "JetBrains Mono Extrabold";
              position = "0, 405";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = ''cmd[update:1000] echo "$(date +"%-I:%M")"'';
              color = "rgba(242, 243, 244, 0.75)";
              font_size = 93;
              font_family = "JetBrains Mono Extrabold";
              position = "0, 310";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = "Muhammad Chaudhary";
              color = "rgba(242, 243, 244, 0.75)";
              font_size = 12;
              font_family = "JetBrains Mono Extrabold";
              position = "0, -407";
              halign = "center";
              valign = "center";
            }
          ];
        };
      }
      cfg.hyprlock
    ];

    services.hyprsunset = mkMerge [
      {
        enable = true;
      }
      cfg.hyprsunset
    ];

    services.hypridle = mkMerge [
      {
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
      }
      cfg.hypridle
    ];

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
      };
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
    services.cliphist.enable = true;
    services.udiskie.enable = true;
  };
}
