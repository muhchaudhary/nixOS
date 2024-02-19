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
        url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/00124e9e5830e3efc897db71c781899f8a676295/code-insider-x64-1708101203.tar.gz";
        sha256 = "0r78a5mqpijg7lvnvp5vpcq0avihpmsx6i0cq2b5qp0iyy9pwmjp";
        #sha256 = lib.fakeSha256;
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
