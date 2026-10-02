# Installs the `nilla` CLI plus the nilla-utils `os`/`home` plugins system-wide so
# `nilla os switch <host>` is available on every machine. Without this the CLI only
# exists transiently (e.g. `nix shell`) and disappears on reboot.
{inputs, ...}: {
  environment.systemPackages = [
    inputs.nilla-cli.result.packages.default.result.x86_64-linux
    inputs.nilla-utils.result.packages.default.result.x86_64-linux
  ];
}
