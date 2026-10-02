{pkgs, ...}: {
  home.packages = with pkgs; [
    zed-editor-fhs
    nixd
    claude-code
    claude-monitor
    python3
    ffmpeg
    ffmpegthumbnailer
    inotify-tools
    desktop-file-utils
    wlr-randr
  ];
}
