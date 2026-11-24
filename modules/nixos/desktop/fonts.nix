{pkgs, ...}: let
  # hyprlock's clock (modules/home/hyprland): StretchPro, from MrVivekRajan/Hyprlock-Styles' Style-7.
  stretch-pro = pkgs.stdenvNoCC.mkDerivation {
    pname = "stretch-pro";
    version = "0-unstable-2024";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/aa2e5d4c7b1544158e94beddb9d37a713071f3e3/Style-7/Fonts/StretchPro/StretchPro.otf";
      sha256 = "0q98mlvr665vga7myv45lwskird6zsynqp7q1h7pn454d3h029ax";
    };
    dontUnpack = true;
    installPhase = "install -Dm444 $src $out/share/fonts/opentype/StretchPro.otf";
  };
in {
  fonts.packages = with pkgs; [
    stretch-pro
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
