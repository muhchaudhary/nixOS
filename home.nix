{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./programs
  ];

  home = {
    username = "muhammad";
    homeDirectory = "/home/muhammad";
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  xdg.userDirs = {
    enable = true;
  };

  home.packages = with pkgs; [
    desktop-file-utils
    steam
    gnome.gnome-tweaks
    (blender.override {cudaSupport = true;})
    gradience
    minecraft
    onlyoffice-bin
    kicad
    yuzu-early-access
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    waybar
    ((vscode.override {}).overrideAttrs (prevAttrs: {
      preFixup = ''
        gappsWrapperArgs+=(
          # Add gio to PATH so that moving files to the trash works when not using a desktop environment
          --prefix PATH : ${glib.bin}/bin
          --add-flags '--disable-gpu-sandbox'
        )
      '';
      postFixup = ''
        patchelf \
          --add-needed ${libglvnd}/lib/libGLESv2.so.2 \
          --add-needed ${libglvnd}/lib/libGL.so.1 \
          --add-needed ${libglvnd}/lib/libEGL.so.1\
          $out/lib/vscode/code
      '';
    }))
    .fhs
    telegram-desktop
    r2modman

    rnix-lsp
    alejandra
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
  home.stateVersion = "23.05";
}
