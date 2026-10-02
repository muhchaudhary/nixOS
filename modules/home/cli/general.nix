{pkgs, ...}: {
  home.packages = with pkgs; [
    xdg-utils
    yazi
    btop # terminal process viewer/manager
    w3m
  ];

  programs.eza = {
    enable = true;
    icons = "auto";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
    };
  };
}
