{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];

  programs.ags = {
    enable = true;
    configDir = ./config;
    extraPackages = [pkgs.libsoup_3];
  };
}
