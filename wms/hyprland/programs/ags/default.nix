{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];

  programs.ags = {
    enable = true;
    #configDir = "${pkgs.aylurs-ags-dots}/config/ags";
    configDir = ./config;
    extraPackages = [pkgs.libsoup_3];
  };
}
