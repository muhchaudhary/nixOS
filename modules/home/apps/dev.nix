{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    zed-editor-fhs
    nixd
    # Pinned separately (sadjow/claude-code-nix, auto-bumped hourly upstream) so it can be
    # updated on its own with `npins update claude-code`. Built from its package.nix with our
    # pkgs rather than via the flake, which would evaluate a second nixpkgs.
    (pkgs.callPackage "${inputs.claude-code.src}/package.nix" {})
    claude-monitor
    python3
    ffmpeg
    ffmpegthumbnailer
    inotify-tools
    desktop-file-utils
    wlr-randr
  ];
}
