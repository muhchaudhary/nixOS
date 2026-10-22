{
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  # Enable CUDA-linked VS Code only on hosts whose system uses the nvidia driver
  # (the desktop). `osConfig` is the NixOS config of the host this home runs on.
  cuda = lib.elem "nvidia" (osConfig.services.xserver.videoDrivers or []);
in {
  home.packages = with pkgs; [
    alejandra
    ruff
    nil
  ];

  programs.vscode = {
    enable = true;
    package = with pkgs;
      (vscode.override {isInsiders = true;})
      .overrideAttrs
      (prevAttrs: {
        src = builtins.fetchTarball {
          # run `curl -I https://update.code.visualstudio.com/latest/linux-x64/insider | grep location: | cut -c 11-` to get latest url
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/76fae85ac19c965c60b10618426469bfd93a6d03/code-insider-x64-1792604446.tar.gz";
          sha256 = "sha256:172gy44r75c9d8kk56540wvsalnq7671ijf6kx7r4dlkkh08kvzr";
        };
        version = "latest";
        postPatch =
          (prevAttrs.postPatch or "")
          + ''
            find . -name "libonnxruntime_providers_tensorrt.so" -delete
          ''
          + lib.optionalString (!cuda) ''
            find . -name "libonnxruntime_providers_cuda.so" -delete
          '';
        buildInputs =
          prevAttrs.buildInputs or []
          ++ lib.optionals cuda (with cudaPackages; [
            cuda_cudart
            libcublas
            libcurand
            libcufft
            cudnn
          ])
          ++ [
            curl
            openssl
            webkitgtk_4_1
            libsoup_3
          ];
      });
    profiles.default.extensions = with pkgs;
    with vscode-extensions; [
      kamadorueda.alejandra
      bbenoist.nix
      esbenp.prettier-vscode
      ms-python.python
      ms-python.vscode-pylance
      timonwong.shellcheck
      foxundermoon.shell-format
      eamodio.gitlens
    ];
  };
}
