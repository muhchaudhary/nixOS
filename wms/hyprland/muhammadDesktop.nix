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
      exec-once = [
        "waybar -c ~/.config/waybar/muhammadDesktop-config.json -s ~/.config/waybar/css.json > /tmp/waybar.log &"
      ];
      # exec-once = [
      #   # TODO change config file location
      #   "waybar -c ~/.config/home-manager/hyprland-conf/waybar/waybar.json -s ~/.config/home-manager/hyprland-conf/waybar/style.css"
      # ];  
    }
  }
}