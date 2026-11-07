# Entry point for `nix-shell` and direnv (`use nix`); the shell itself is
# `shells.default` in nilla.nix.
(import ./nilla.nix).shells.default.result.${builtins.currentSystem}
