{pkgs, ...}: {
  fonts.packages = with pkgs; [
    roboto
    roboto-mono
    roboto-slab
    jetbrains-mono
    league-spartan
    jost
    oswald
    inter # desktop clock (fabric)

    # multilingual titles (spotifast); CJK + colour emoji come from fonts.enableDefaultPackages
    noto-fonts

    nerd-fonts.fira-code
    nerd-fonts.hasklug
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
  ];
}
