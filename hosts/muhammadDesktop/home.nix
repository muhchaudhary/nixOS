{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadDesktop.nix
  ];

  ## add desktop specific packages here

  home.packages = with pkgs; [
    blender_4_0
    yuzu-early-access
  ];

  programs.vscode.package = with pkgs;
    (pkgs.vscode.override {})
    .overrideAttrs
    (prevAttrs: {
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
      version = "latest";
    });
}
