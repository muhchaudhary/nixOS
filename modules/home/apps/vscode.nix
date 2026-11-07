{
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  # Enable CUDA-linked VS Code only on hosts whose system uses the nvidia driver
  # (the desktop). `osConfig` is the NixOS config of the host this home runs on.
  cuda = lib.elem "nvidia" (osConfig.services.xserver.videoDrivers or []);

  # Latest Insiders build; bump with scripts/update-vscode-insiders (the weekly
  # pin-update workflow runs it too).
  insiders = lib.importJSON ./vscode-insiders.json;
in {
  # Read by VS Code's launcher. NIXOS_OZONE_WL already selects Wayland; Chromium only
  # honours the last --enable-features, so all features go in one flag.
  home.file.".config/code-flags.conf".text = ''
    --disable-gpu-sandbox
    --enable-features=WebRTCPipeWireCapturer,WaylandWindowDecorations
  '';

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
        # fetchurl rather than fetchTarball: fetched at build time, not on every evaluation.
        src = fetchurl {
          name = "vscode-insiders-${insiders.version}.tar.gz";
          inherit (insiders) url sha256;
        };
        inherit (insiders) version;
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
