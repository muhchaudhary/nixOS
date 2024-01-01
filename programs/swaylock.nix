{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."swaylock" = {
    source = ../themes/assets/swaylock;
    recursive = true;
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };
}
