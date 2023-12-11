{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = with pkgs; {
    enable = true;
    configDir = pkgs.aylurs-dots;
    extraPackages = [pkgs.libsoup_3];
  };
}
