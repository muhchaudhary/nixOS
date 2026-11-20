# Home Manager config for this host, on top of the home `base` (applied to every
# host automatically). Host-only apps and overrides go here.
{homeModules, ...}: {
  imports = with homeModules; [
    workstation
    ./hyprland.nix
  ];

  # Sunshine runs as a systemd user service (configured in configuration.nix:
  # apps, prep-cmds, CAP_SYS_ADMIN wrapper). The package's own launcher entry
  # starts a second, bare `sunshine` that reads ~/.config/sunshine instead: none
  # of the declared apps or scripts, no KMS capture. Shadow it so the launcher
  # (re)starts the service — e.g. after "Quit" from the tray, which the
  # service doesn't restart from.
  xdg.desktopEntries."dev.lizardbyte.app.Sunshine" = {
    name = "Sunshine";
    comment = "Self-hosted game stream host for Moonlight";
    icon = "dev.lizardbyte.app.Sunshine";
    exec = "systemctl --user restart sunshine.service";
    categories = ["Network"];
  };

  # qwen-code refuses native terminal images whenever SSH_TTY/SSH_CLIENT is set, even
  # when forced. Kitty's graphics protocol works fine over SSH, so hide those vars and
  # force kitty when connected over SSH from kitty.
  programs.fish.functions.qwen = ''
    if set -q SSH_TTY; and test "$TERM" = xterm-kitty
      env -u SSH_TTY -u SSH_CLIENT QWEN_CODE_MERMAID_IMAGE_PROTOCOL=kitty qwen $argv
    else
      command qwen $argv
    end
  '';
}
