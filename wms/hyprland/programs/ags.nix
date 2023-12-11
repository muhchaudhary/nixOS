{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
    #inputs.ags-dots
    #../../../../derivations/aylurs-ags-dots.nix
  ];

  programs.ags = with pkgs; {
    enable = true;
    configDir = pkgs.aylurs-ags-dots;
    #configDir = ./config;
    extraPackages = [pkgs.libsoup_3];
  };
}
