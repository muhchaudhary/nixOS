# Decky Loader: the plugin loader behind the "Decky" tab in Steam's Quick Access
# Menu, for gaming mode (modules/nixos/gaming/gaming-mode.nix). Not part of the
# `gaming` barrel: hosts that want it import `deckyLoader` (the desktop only).
#
# Not in nixpkgs; Jovian-NixOS (the `jovian` pin) packages it. Only its
# standalone decky-loader module and package are used, not the rest of Jovian
# (which would replace Steam/gamescope with its SteamOS versions). `.src` keeps
# Nilla from evaluating Jovian's flake.
#
# Like on SteamOS: the loader runs as root (it needs to: Jovian's module notes
# running unprivileged is unsupported) and runs plugins as the user, with
# plugins/settings in ~/homebrew. It injects into Steam's UI over the CEF
# debugger (127.0.0.1:8080), which needs ~/.steam/steam/.cef-enable-remote-debugging
# (Steam > Settings > Developer > "CEF Remote Debugging"; already set here).
{
  pkgs,
  inputs,
  ...
}: let
  jovian = inputs.jovian.src;
in {
  imports = ["${jovian}/modules/decky-loader.nix"];

  jovian.decky-loader = {
    enable = true;
    package = pkgs.callPackage "${jovian}/pkgs/decky-loader/stable.nix" {};
    user = "muhammad";
    stateDir = "/home/muhammad/homebrew";
    # Common plugin needs (downloads, archives, and Python for CLI helpers).
    extraPackages = with pkgs; [curl unzip python3];
  };
}
