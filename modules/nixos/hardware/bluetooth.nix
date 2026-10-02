{pkgs, ...}: {
  hardware.bluetooth = {
    powerOnBoot = true;
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        JustWorksRepairing = "always";
        FastConnectable = true;
        Class = "0x000100";
      };
      GATT = {
        ReconnectIntervals = "1,1,2,3,5,8,13,21,34,55";
        AutoEnable = true;
      };
    };
    input = {
      General = {
        UserspaceHID = true;
      };
    };
  };
  services.blueman.enable = true;
}
