{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."swaylock" = {
    source = ../../../themes/assets/swaylock;
    recursive = true;
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      # indicator-image = "/home/muhammad/.config/swaylock/lockscreen.png";
      # color = "808080";
      # font-size = 24;
      # indicator-idle-visible = false;
      # indicator-radius = 100;
      # line-color = "ffffff";
      # show-failed-attempts = true;
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
    };
  };
}