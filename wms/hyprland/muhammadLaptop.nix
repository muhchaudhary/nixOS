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
        "eDP-1, 1920x1080@60, 0x0, 1"
      ];
      exec-once = [
        "ags -b hypr"
      ];
    };
  };
}
