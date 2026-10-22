{config, ...}: {
  boot.extraModulePackages = [
    # 0.15.4's install runs depmod, leaving modules.* index files that collide with
    # the kernel's own in the merged module tree; drop them (NixOS runs depmod itself).
    (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + "rm -f $out/lib/modules/*/modules.*\n";
    }))
  ];
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="DroidCam" exclusive_caps=1
  '';
}
