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
<<<<<<< HEAD
    # not including config due to active development
=======
>>>>>>> bbf3da2 (fix nvidia docker)
    #configDir = pkgs.aylurs-dots;
    extraPackages = [pkgs.libsoup_3];
  };
}
