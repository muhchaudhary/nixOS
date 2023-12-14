{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadLaptop.nix
  ];

  programs.vscode.package = with pkgs;
  (pkgs.vscode.override {isInsiders = true;})
  .overrideAttrs
  (prevAttrs: {
    src = builtins.fetchTarball {
      url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
      sha256 = "15n680mydgjfxz6cvg8c5057yzrwzx86y4aq1764kwhbzff23420";
    };
    preFixup = ''
      gappsWrapperArgs+=(
        # Add gio to PATH so that moving files to the trash works when not using a desktop environment
        --prefix PATH : ${glib.bin}/bin
        --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
      )
    '';
    postFixup = ''
      patchelf \
        --add-needed ${libglvnd}/lib/libGLESv2.so.2 \
        --add-needed ${libglvnd}/lib/libGL.so.1 \
        --add-needed ${libglvnd}/lib/libEGL.so.1\
        $out/lib/vscode/code-insiders
    '';
    version = "latest";
  });
}