{ config, pkgs, lib, ... }: {
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
  '';
}
