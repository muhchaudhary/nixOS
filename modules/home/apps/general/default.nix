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
  cfg = config.${namespace}.apps.general;
in {
  options.${namespace}.apps.general = {
    enable = mkBoolOpt false "Whether to install general apps.";
  };

  config = mkIf cfg.enable {
    #TODO MOVE THESE TO SOMEWHERE BETTER
    services.mpris-proxy.enable = true;
    services.blueman-applet.enable = true;
    #TODO: ORGANIZE
    home.packages = with pkgs; [
      firefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.hyprland-qtutils.packages.${pkgs.stdenv.hostPlatform.system}.default
      chromium

      nautilus # file manager
      gnome-calculator # calculator
      gnome-system-monitor # system monitor
      totem # for thumbnails
      warpinator # send files around
      obsidian # note taking
      (mpv.override {scripts = [mpvScripts.mpris];}) # video/music player
      inkscape # vector editing
      transmission_4-gtk # torrenting
      transmission-remote-gtk # remote Transmission control
      teams-for-linux

      freecad
      kicad-small
      bottles
      # jellyfin-media-player
      jellyfin-mpv-shim
      telegram-desktop
      # discord
      vesktop

      libreoffice-qt # Office Apps
      kdePackages.gwenview
      godot_4

      #TODO MOVE TO SOMEHRER BETTER
      ffmpeg
      ffmpegthumbnailer
      inotify-tools
      desktop-file-utils
      python3
      wlr-randr
      blender_4_5
      zed-editor-fhs
      nixd
    ];

    programs.spicetify = {
      enable = true;
    };
  };
}
