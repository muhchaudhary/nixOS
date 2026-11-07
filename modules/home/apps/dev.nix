{pkgs, ...}: {
  home.packages = with pkgs; [
    zed-editor-fhs
    nixd
    python3
    ffmpeg
    ffmpegthumbnailer
    inotify-tools
    desktop-file-utils
    wlr-randr
  ];
}
