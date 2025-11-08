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
  hyprlandPackages = inputs.hyprland.packages.${pkgs.system};
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
      enable = true;
      portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
      settings = mkMerge [
        {
          cursor = {
            no_warps = true;
            no_hardware_cursors = true;
          };
          general = {
            gaps_in = 8;
            gaps_out = 16;
            border_size = 2;
            "col.active_border" = "rgba(333333cc)";
            "col.inactive_border" = "rgba(33333377)";
            layout = "dwindle";
            resize_on_border = true;
            allow_tearing = false;
          };
          decoration = {
            rounding = 22;
            active_opacity = 1.0;
            inactive_opacity = 0.92;

            shadow = {
              enabled = true;
              range = 30;
              render_power = 2;
            };

            blur = {
              enabled = true;
              size = 18;
              passes = 3;
              new_optimizations = "on";
              ignore_opacity = false;
              vibrancy = 0.18;
              brightness = 1;
              contrast = 1;
            };
          };
          animations = {
            enabled = "yes";
            bezier = [
              "ease, 0.15, 0.9, 0.1, 1.0"
            ];
            animation = [
              "windows,    1, 6, ease"
              "windowsOut, 1, 5, default, popin 80%"
              "border,     1, 10, default"
              "fade,       1, 7, default"
              "workspaces, 1, 6, default"
              "workspaces, 1, 6, default"
              "specialWorkspace, 1, 6, default, slide up"
            ];
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          gestures = {
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
            "dbus-update-activation-environment --systemd --all &"

            "sleep 1 && systemctl --user restart xdg-desktop-portal &"

            "~/.config/hypr/scripts/launch_fabric"
            "sleep 1 & ~/.config/hypr/scripts/randomize_wallpaper"
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
