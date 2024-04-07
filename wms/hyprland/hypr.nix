{
  config,
  pkgs,
  ...
}: {
  #import specific hyprland programs
  imports = [
    ./programs
    ./plugins
    ../../themes
  ];

  xdg.configFile."hypr" = {
    source = ./config;
    recursive = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgba(85e0ffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        resize_on_border = true;
        no_cursor_warps = true;
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
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
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
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_invert = true;
        workspace_swipe_distance = 200;
      };
      input = {
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.25;
        };
      };
      misc = {
        disable_hyprland_logo = true;
      };
      source = [
        "./binds.conf"
      ];
      exec-once = [
        "dbus-update-activation-environment --systemd --all &"
        "sleep 1 && systemctl --user restart xdg-desktop-portal"
      ];
      exec-once = [
        "./launch_fabric"
      ];
      windowrulev2 = [
        "stayfocused, title:^(?!.*Steam Settings)$, class:^(steam)$"
        "minsize 1 1, title:^()$, class:^(steam)$"
      ];
      layerrule = [
        "blur, fabric"
        "ignorezero, fabric"
        "noanim, fabric"
      ];
    };
  };
}
