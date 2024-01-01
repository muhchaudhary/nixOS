{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.swaylock = {
    enable = true;
    settings = {
      show-failed-attempts = true;
    };
  };
}
