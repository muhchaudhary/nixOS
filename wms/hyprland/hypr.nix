{
  config,
  pkgs,
  ...
}: {
  #import specific hyprland programs
  imports = [
    ./programs
    # ./plugins
    ../../themes
  ];

  xdg.configFile."hypr" = {
    source = ./config;
    recursive = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
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
        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
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
        "wl-paste --watch cliphist store"
        "dbus-update-activation-environment --systemd --all &"
        "sleep 1 && systemctl --user restart xdg-desktop-portal &"
        "./launch_fabric"
      ];
      windowrulev2 = [
        "stayfocused, title:^(?!.*Steam Settings)$, class:^(steam)$"
        "minsize 1 1, title:^()$, class:^(steam)$"
        "noborder, onworkspace:w[t1]"
      ];
      windowrule = [
        "opacity 0.999 0.999, firefox"
      ];
      layerrule = [
        "blur, fabric"
        "ignorezero, fabric"
        "noanim, fabric"
      ];
    };
  };
}
