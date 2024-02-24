{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hypridle.homeManagerModules.default
  ];

  programs.hypridle = with pkgs; {
    enable = true;
  };
}
