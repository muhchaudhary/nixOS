# ODESC motor controller (1209:0d3x) and its STM32 DFU bootloader (0483:df11), so
# odrivetool / dfu-util work without root. 0666 rather than uaccess so it also
# works over SSH; ModemManager is told to leave the ODESC's serial port alone.
{...}: {
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="0d3[0-9]", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666"
  '';
}
