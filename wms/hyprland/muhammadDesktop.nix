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
      exec-once = [
        "waybar -c ~/.config/waybar/muhammadDesktop.jsonc -s ~/.config/waybar/style.css > /tmp/waybar.log &"
      ];
    };
  };
}