{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  name = config.snowfallorg.user.name;
  cfg = config.${namespace}.user;
in {
  options.${namespace}.user = with types; {
    name = mkOpt str name "The name to use for the user account.";
    fullName = mkOpt str "Muhammd Chaudhary" "The full name of the user.";
    email = mkOpt str "muhammadahmchaudhary@gmail.com" "The email of the user.";
  };

  config = {
    programs.fish = {
      enable = true;
    };

    home.username = cfg.name;

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
