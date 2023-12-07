{...}: {
  imports = [
    ./hypr.nix
  ];
  #  add packages here
  #  home.packages = with pkgs; [
  #
  #  ];
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "HDMI-A-1, 2560x1440@75, 0x0, 1"
        "DP-1,1920x1080@60,2560x0,1"
      ];
      exec-once = [
        #"waybar -c ~/.config/waybar/muhammadDesktop.jsonc > /tmp/waybar.log &"
        "ags -r"
      ];
    };
  };
}
