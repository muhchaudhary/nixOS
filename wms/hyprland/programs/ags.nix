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
    # not including config due to active development
    #configDir = pkgs.aylurs-dots;
    extraPackages = [pkgs.libsoup_3];
  };
}
