{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
  ];

  programs.hyprlock = with pkgs; {
    enable = true;
  };
}
