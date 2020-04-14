{ config, pkgs, ... }: {

  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    <nixos-hardware/common/pc/ssd>

  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.opengl.enable = true;
}
