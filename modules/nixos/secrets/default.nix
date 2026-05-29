{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.secrets;
in {
  options.${namespace}.secrets = {
    enable = mkBoolOpt false "Enable sops-nix secrets management for this host.";
    defaultSopsFile = mkOpt types.path null "Default encrypted secrets file (sops-encoded YAML).";
    keyFile = mkOpt types.str "/var/lib/sops-nix/key.txt" "Path to the host's age private key.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [sops age ssh-to-age];

    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      age.keyFile = cfg.keyFile;
      # We don't derive age keys from SSH host keys — explicit per-host age key at cfg.keyFile.
      age.sshKeyPaths = [];
      gnupg.sshKeyPaths = [];
    };
  };
}
