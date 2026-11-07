# OpenSSH, key-only, with this machine's authorized key. A host that only wants
# SSH over the tailnet sets `services.openssh.openFirewall = false` (tailscale0 is
# trusted by the tailscale module).
{...}: {
  services.openssh = {
    enable = true;
    # Key-only: keyboard-interactive would otherwise still allow the account
    # password via PAM.
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.muhammad.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw/pFaCTF2sGl7WBmIRld/6ClenyRvbFm8kfzTE9Cf6 muhammadahmchaudhary@gmail.com"
  ];
}
