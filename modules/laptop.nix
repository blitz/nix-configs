{ config, pkgs, ... }: {

  imports = [
    <nixos-hardware/common/pc/ssd>
    ./gnome3.nix
    ./common.nix
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  powerManagement.cpuFreqGovernor = "ondemand";
}
