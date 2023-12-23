{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadLaptop.nix
  ];

  programs.vscode.package = with pkgs;
    (pkgs.vscode.override {isInsiders = true;})
    .overrideAttrs
    (prevAttrs: {
      src = builtins.fetchTarball {
        # run curl -I https://update.code.visualstudio.com/latest/linux-x64/insider to get latest url
        url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/9621add46007f7a1ab37d1fce9bcdcecca62aeb0/code-insider-x64-1703050604.tar.gz";
        sha256 = "017630xgr64qjva73imb56fcqr858xfcsbdgq97akawlxf1ydm5a";
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
