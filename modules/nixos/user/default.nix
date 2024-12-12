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
  cfg = config.${namespace}.user;
in {
  options.${namespace}.user = with types; {
    name = mkOpt str "muhammad" "The name to use for the user account.";
    fullName = mkOpt str "Muhammad Chaudhary" "The full name of the user.";
    initialPassword =
      mkOpt str "password"
      "The initial password to use when the user is first created.";
    uid = mkOpt int 1000 "The user ID.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    extraOptions =
      mkOpt attrs {}
      (mdDoc "Extra options passed to `users.users.<name>`. (options already declared will be overidden)");
  };

  config = {
    environment.systemPackages = with pkgs; [
      # Always have the ability to pull files
      git
      curl
      wget
      killall
      unzip
      ntfs3g
      micro
      pciutils
      usbutils
      zip
    ];

    # Fix nautilus video thumbnails and information
    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

    environment.variables = {
      EDITOR = "micro";
      NIXOS_OZONE_WL = "1";
    };

    programs.fish.enable = true;

    users.users.${cfg.name} =
      {
        isNormalUser = true;
        description = cfg.fullName;
        shell = pkgs.fish;
        uid = cfg.uid;
        inherit (cfg) name initialPassword extraGroups;
      }
      // cfg.extraOptions;
  };
}
