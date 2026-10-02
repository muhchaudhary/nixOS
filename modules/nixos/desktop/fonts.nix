{pkgs, ...}: {
  fonts.packages = with pkgs; [
    roboto
    roboto-mono
    roboto-slab
    jetbrains-mono
    league-spartan
    jost
    oswald

    nerd-fonts.fira-code
    nerd-fonts.hasklug
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
  ];
}
