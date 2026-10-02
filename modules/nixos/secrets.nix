# sops-nix wiring. The host importing this module sets `sops.defaultSopsFile`
# and declares its own `sops.secrets.*`.
{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.result.nixosModules.sops];

  environment.systemPackages = with pkgs; [sops age ssh-to-age];

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    # We don't derive age keys from SSH host keys — explicit per-host age key at keyFile.
    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [];
  };
}
