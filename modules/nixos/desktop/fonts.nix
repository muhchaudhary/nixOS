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

  # spotifast finds fallback fonts by walking font dirs only 4 levels deep, which misses the CJK
  # files under <store>/share/fonts/opentype/noto-cjk/. Linking them into
  # /run/current-system/sw/share/fonts (an XDG data dir it also scans) puts them within reach.
  environment.systemPackages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
  environment.pathsToLink = ["/share/fonts"];
}
