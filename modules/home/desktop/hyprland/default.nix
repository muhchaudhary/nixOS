{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.hyprland;
in {
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether to enable hyprland configuration. Includes everything required to feel like a desktop environment.";
    type = mkOpt (enum [
      "desktop"
      "laptop"
    ]) "desktop" "Whether this is a desktop or laptop.";
    settings = mkOpt attrs {} "Extra Hyprland settings.";
    extraConfig = mkOpt lines "" "Extra Hyprland config lines.";
    hyprlock = mkOpt attrs {} "Extra Hyprlock settings.";
    hypridle = mkOpt attrs {} "Extra Hypridle settings.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
    with pkgs.${namespace}; [
      wl-clipboard
      cliphist
      libnotify
      hyprkeys
      wdisplays
      grimblast
      pwvucontrol

      wf-recorder
      brightnessctl
      hyprpicker

      grimblast

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
      enable = true;

      settings = mkMerge [
        {
          cursor = {
            no_warps = true;
            no_hardware_cursors = true;
          };
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 3;
            "col.active_border" = "rgba(85e0ffee)";
            "col.inactive_border" = "rgba(595959aa)";
            layout = "dwindle";
            resize_on_border = true;
            allow_tearing = false;
          };
          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              size = 1;
              passes = 4;
              brightness = 1;
              contrast = 1;
            };
          };
          animations = {
            enabled = "yes";
            bezier = [
              "myBezier, 0.05, 0.9, 0.1, 1.05"
            ];
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
              "specialWorkspace, 1, 6, default, slidevert"
            ];
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            # 3422no_gaps_when_only = 1;
          };
          gestures = {
            workspace_swipe = true;
            workspace_swipe_invert = true;
            workspace_swipe_distance = 300;
          };
          input = {
            touchpad = {
              natural_scroll = true;
              scroll_factor = 0.25;
            };
          };
          misc = {
            disable_hyprland_logo = true;
            middle_click_paste = false;
          };
          source = [
            "./binds.conf"
          ];
          exec-once = [
            "swww-daemon & disown"

            "dbus-update-activation-environment --systemd --all &"

            "sleep 1 && systemctl --user restart xdg-desktop-portal &"

            "./scripts/launch_fabric"
          ];
          windowrulev2 = [
            "stayfocused, title:^(?!.*Steam Settings)$, class:^(steam)$"
            "minsize 1 1, title:^()$, class:^(steam)$"

            "noborder, onworkspace:w[t1]"
            "bordersize 0, floating:0, onworkspace:w[t1]"
            "rounding 0, floating:0, onworkspace:w[t1]"
            "bordersize 0, floating:0, onworkspace:w[tg1]"
            "rounding 0, floating:0, onworkspace:w[tg1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0, floating:0, onworkspace:f[1]"
          ];

          workspace = [
            "w[t1], gapsout:0, gapsin:0"
            "w[tg1], gapsout:0, gapsin:0"
            "f[1], gapsout:0, gapsin:0"
          ];
          layerrule = [
            "blur, fabric"
            "ignorezero, fabric"
            "noanim, fabric"
          ];
          env = [
            "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
            "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
            "MOZ_WEBRENDER, 1" # for firefox to run on wayland
            "XDG_SESSION_TYPE, wayland"
            "WLR_NO_HARDWARE_CURSORS, 1"
            "WLR_RENDERER_ALLOW_SOFTWARE, 1"
            "QT_QPA_PLATFORM, wayland"
          ];
        }
        cfg.settings
      ];
      extraConfig = with pkgs;
        mkMerge [
          # TODO: MOVE BINDS HERE!
          cfg.extraConfig
        ];
    };

    programs.hyprlock = mkMerge [
      {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            no_fade_in = false;
            disable_loading_bar = true;
            grace = 0;
          };
          background = [
            {
              monitor = "";
              path = "$HOME/.config/wall.png";
              color = "rgba(25, 20, 20, 1.0)";
              blur_passes = 1;
              blur_size = 0;
              brightness = 0.2;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "250, 60";
              outline_thickness = 2;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              outer_color = "rgba(0, 0, 0, 0)";
              inner_color = "rgba(0, 0, 0, 0.5)";
              font_color = "rgb(200, 200, 200)";
              fade_on_empty = false;
              placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
              hide_input = false;
              position = "0, -120";
              halign = "center";
              valign = "center";
            }
          ];
          label = [
            {
              monitor = "";
              text = "$TIME";
              font_size = 120;
              position = "0, 80";
              valign = "center";
              halign = "center";
            }
          ];
        };
      }
      cfg.hyprlock
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
      indicator = true; # Phone integration
    };
    services.cliphist.enable = true; # Clipboard history for wayland
    services.udiskie.enable = true; # USB automount
  };
}
