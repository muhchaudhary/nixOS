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
    # Only applies when the account is first created; change it later with `passwd`.
    # Regenerate with `mkpasswd -m yescrypt`.
    initialHashedPassword = "$y$j9T$57U1lw9EknuWVtm5GM.UB1$KxOA3v2gMkHo/T1Cw54KeRt74en2NMgb8brW4sym3Q6";
    # wheel for sudo; feature modules (network, printer,
    # steam, virtualisation, …) append their own groups via list merging.
    extraGroups = ["wheel"];
  };
}
