# Installs the `nilla` CLI plus the nilla-utils `os`/`home` plugins system-wide so
# `nilla os switch <host>` is available on every machine. Without this the CLI only
# exists transiently (e.g. `nix shell`) and disappears on reboot.
{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  environment.systemPackages = [
    inputs.nilla-cli.result.packages.default.result.${system}
    inputs.nilla-utils.result.packages.default.result.${system}
  ];
}
