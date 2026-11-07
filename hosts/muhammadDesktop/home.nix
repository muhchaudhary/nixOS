# Home Manager config for this host, on top of the home `base` (applied to every
# host automatically). Host-only apps and overrides go here.
{homeModules, ...}: {
  imports = with homeModules; [
    workstation
    ./hyprland.nix
  ];

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
