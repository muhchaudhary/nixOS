{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    (obsidian.override {electron = electron_24;})
  ];
}
