{ ... }: {
  imports = [
    ./hypr.nix
  ];
#  add packages here
#  home.packages = with pkgs; [
#    
#  ];
  wayland.windowManager.hyperland = {
    settings = {
      animations = {
        enabled = "yes";
      };
      bezier = [
        "linear, 0.05, 0.9, 0.1, 1.05"
      ];
      animation = [
        "windows, 1, 7, linear"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
        "borderangle, 1, 8, default"
      ];
      exec-once = [
        # TODO change config file location
        "waybar -c ~/.config/home-manager/hyprland-conf/waybar/waybar.json -s ~/.config/home-manager/hyprland-conf/waybar/style.css"
      ]
      
    }
  }
}