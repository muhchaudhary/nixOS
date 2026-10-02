{
  lib,
  pkgs,
  ...
}: {
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

  users.users.muhammad = {
    isNormalUser = true;
    description = "Muhammad Chaudhary";
    shell = pkgs.fish;
    # mkDefault so a host (e.g. the server) can pin a different uid.
    uid = lib.mkDefault 1000;
    initialPassword = "password";
    # extraGroups is intentionally empty here; feature modules (network, printer,
    # steam, virtualisation, …) append their own groups via list merging.
    extraGroups = [];
  };
}
