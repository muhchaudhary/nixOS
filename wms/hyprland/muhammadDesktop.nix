{...}: {
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
    };
  };
}
