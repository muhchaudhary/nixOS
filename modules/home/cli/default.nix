# Core CLI tooling every host gets (via the home `base`). `infra.nix` is
# deliberately left out so headless hosts can skip it; hosts that want it get it
# from the `workstation` profile or import `homeModules.infra` directly.
{...}: {
  imports = [
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./general.nix
    ./git.nix
  ];
}
