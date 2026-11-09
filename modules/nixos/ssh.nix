# OpenSSH, key-only, with this machine's authorized key. Tailnet logins go through
# Tailscale SSH (see the tailscale module), which takes port 22 on the tailnet
# address; this is for the LAN, e.g. a fallback on a headless host if Tailscale
# is down.
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
