{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.sunshine;
in {
  options = {
    services.sunshine = {
      enable = mkEnableOption (mdDoc "Sunshine");
      wayland = true;
    };
  };

  config = mkIf config.services.sunshine.enable {
    environment.systemPackages = [
      (pkgs.sunshine.override {
        cudaSupport = true;
        stdenv = pkgs.cudaPackages.backendStdenv;
      })
    ];

    boot = {kernelModules = ["uinput"];};
    services = {
      udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [47984 47989 48010 47990 9993];
      allowedUDPPorts = [47998 47999 48000 48002 48010 9993];
    };

    services.avahi = {
      enable = true;
      reflector = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
        workstation = true;
      };
    };

    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    systemd.user.services.sunshine = {
      description = "sunshine";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
      };
    };
  };
}
# Enable using:
# services.sunshine.enable = true;
# Get Service Status
# systemctl --user status sunshine
# get logs
# journalctl --user -u sunshine --since "2 minutes ago"

