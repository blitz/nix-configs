{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  powerManagement.cpuFreqGovernor = "schedutil";
}
